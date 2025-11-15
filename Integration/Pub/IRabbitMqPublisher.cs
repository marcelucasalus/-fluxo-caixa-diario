using FluxoCaixa.LancamentoRegistrar.Entity;

public interface IRabbitMqPublisher
{
    public void PublishLancamento(Lancamento lancamento);
}