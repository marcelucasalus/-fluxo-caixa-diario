                     ┌────────────────────────┐
                     │       Client/API       │
                     └─────────┬────────────┘
                               │
                               │ HTTP Requests
                               ▼
                ┌───────────────────────────────────┐
                │         FluxoCaixaAPI             │
                │                                   │
                │ ┌──────────────┐  ┌────────────┐ │
                │ │ Get Lancamentos│ │ Get Consolidado│ │
                │ └───────┬──────┘  └───────┬─────┘ │
                │         │ Cache Hit?           │   │
                │         ▼                     ▼   │
                │     ┌───────────┐       ┌───────────┐
                │     │ Redis     │       │ Redis     │
                │     └─────┬─────┘       └─────┬─────┘
                │           │ Cache Miss         │
                │           ▼                   ▼
                │     ┌───────────┐       ┌───────────┐
                │     │ SQL Server│       │ SQL Server│
                │     └─────┬─────┘       └─────┬─────┘
                │           │                   │
                │           ▼                   ▼
                │  Retorna resultado       Retorna Consolidado
                │      + Atualiza Cache       + Atualiza Cache
                │
                │ ┌──────────────┐
                │ │ Post Lancamentos │
                │ └───────┬────────┘
                │         │
                │   Criar Lançamento
                │         │
                │  Existe Consolidado no DB?
                │         │
          ┌─────No───────┴─────┐
          │                   │
   Marcar como pendente   Criar Consolidado
          │                   │
          ▼                   ▼
 ┌─────────────────┐    ┌─────────────────┐
 │ SQL Server       │    │ SQL Server       │
 └─────┬───────────┘    └─────┬───────────┘
       │                      │
       ▼                      ▼
 ┌─────────────┐           ┌─────────────┐
 │ RabbitMQ    │           │ Cache Redis │
 └─────┬───────┘           └─────────────┘
       │
       ▼
 ┌───────────────┐
 │ Background    │
 │ Worker        │
 │ (HealthCheck) │
 └─────┬─────────┘
       │ Processa lançamentos pendentes
       ▼
 ┌─────────────┐
 │ SQL Server  │
 │ Atualiza    │
 │ Consolidado │
 └─────────────┘
