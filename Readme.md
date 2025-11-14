# FluxoCaixa

## Descrição do Projeto
Aplicação backend em .NET para controle de fluxo de caixa diário, com serviços independentes de Lançamentos e Consolidado Diário, garantindo alta disponibilidade, resiliência, segurança e performance.

- **Serviço de Lançamentos:** Responsável por registrar lançamentos (débitos e créditos) e se nao existir um consolidado vinculado, acaba registrando. Consulta de lancamentos por data especifica.  
- **Serviço de Consolidado Diário:** Calcula e fornece saldo diário consolidado.
 - **Serviço de Worker:** Existe um servico de worker que roda em background para processar lancamentos pendentes e atualizar o consolidado diario.

O sistema utiliza arquitetura de microsserviços, mensageria (RabbitMQ), cache (Redis), logs centralizados (Elastic), segurança via Identity e JWT, e escalabilidade com Docker + Nginx e banco sql server.

---

## **Arquitetura da Solução**

### Diagrama de arquitetura
![Diagrama de Arquitetura](diagrama.png)

**Fluxo principal:**
1. Usuário realiza um lançamento via `POST /lancamentos`.
2. O serviço de Lançamentos salva o lançamento no banco.
3. Se o serviço de Consolidado estiver indisponível:
   - O lançamento é registrado como **pendente** e enviado para **RabbitMQ**.
   - Um **Worker** processa os lançamentos pendentes quando o serviço volta.
4. Serviço de Consolidado consome lançamentos e atualiza o saldo diário.
5. Consultas podem ser feitas via:
   - `GET /lancamentos?data=yyyy-MM-dd`
   - `GET /consolidado?data=yyyy-MM-dd`
6. Cache (Redis) otimiza consultas frequentes de saldo.

---

## **Tecnologias utilizadas**
- **Backend:** .NET 7 / C#  
- **Banco de dados:** SQL Server  
- **Mensageria:** RabbitMQ  
- **Cache:** Redis  
- **Logs:** Serilog + ElasticSearch  
- **Segurança:** Identity + JWT  
- **Orquestração:** Docker + Docker Compose + Nginx  
- **Testes:** xUnit

---

## **Como rodar localmente**

### Pré-requisitos
- Docker e Docker Compose
- .NET SDK 7 instalado (opcional se for rodar sem containers)


### Passos

1. Clonar o repositório:
```bash
git clone https://github.com/marcelucasalus/-fluxo-caixa-diario
cd fluxocaixa
```
2. Acessar caminho raiz do repositorio
3. Executar os comandos do docker-compose
```bash
docker-compose build
docker-compose up -d sqlserver redis rabbitmq elasticsearch
docker-compose up -d fluxocaixaapi nginx
```


## Descrição do fluxo

1. Get Lancamentos

    - Consulta cache (Redis)

    - Se não existir, consulta SQL Server

    - Atualiza cache com o resultado

2. Get Consolidado

    - Consulta cache

    - Se não existir, consulta SQL Server

    - Atualiza cache

3. Post Lancamentos

    - Cria lançamento

    - Verifica se consolidado existe:

        - Se existir → vincula lançamento

        - Se não → cria consolidado e vincula

    - Caso serviço de consolidado esteja offline:

        - Marca lançamento como pendente

        - Salva no banco e envia para RabbitMQ

    - Worker monitora health check:

        - Processa lançamentos pendentes

        - Atualiza consolidado no banco

4. Logs

    - Toda operação gera logs enviados para Elasticsearch via Serilog


## 🚀 Melhorias Futuras

### 1️⃣ Monitoramento e Observabilidade
- **Prometheus** para coleta de métricas (latência, contagem de requisições, filas pendentes).  
- **Grafana** para dashboards interativos e alertas.  
- **Tracing distribuído (OpenTelemetry)** para rastrear o fluxo completo de lançamentos.

### 2️⃣ Orquestração e Escalabilidade
- **Kubernetes** para deploy, escalabilidade e health checks automáticos.  
- **Horizontal Pod Autoscaling (HPA)** para ajustar réplicas conforme demanda.  
- **ConfigMaps e Secrets** para gerenciar configurações e senhas com segurança.

### 3️⃣ Resiliência e Mensageria
- **Circuit Breaker / Retry Policies** para falhas no SQL Server ou Redis.  
- **Dead Letter Queue no RabbitMQ** para mensagens que falharem várias vezes.

### 4️⃣ Logging e Centralização
- Integração futura com **Loki/Grafana** para centralização de logs.  
- Alertas automáticos caso worker ou banco falhem.

### 5️⃣ CI/CD e Automação
- Pipelines para build, testes e deploy automático (GitHub Actions, GitLab CI/CD ou Azure DevOps).  
- Deploy automatizado no Kubernetes com **Helm Charts** ou **Kustomize**.