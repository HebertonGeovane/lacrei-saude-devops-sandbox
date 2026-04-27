const express = require('express');
const client = require('prom-client');

const app = express();
const PORT = 3000;

const ASAAS_API_KEY = process.env.ASAAS_API_KEY;
const ASAAS_URL = 'https://sandbox.asaas.com/api/v3'; // Usar Sandbox para testes

const { SNSClient, PublishCommand } = require("@aws-sdk/client-sns");
const snsClient = new SNSClient({ region: "us-east-1" });

// coleta métricas padrão
client.collectDefaultMetrics();

// rota status (FORÇANDO ERRO PARA TESTAR VALIDAÇÃO DO PIPELINE - PONTO 4)
app.get('/status', (req, res) => {
  res.status(500).json({
    status: 'error',
    message: 'Falha crítica detectada pelo Pipeline'
  });
});

// rota de métricas (Prometheus)
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.end(await client.register.metrics());
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

app.use(express.json());

app.post('/payments/create', async (req, res) => {
  try {
    const paymentData = {
      customer: req.body.customerId,
      billingType: "CREDIT_CARD",
      value: req.body.value,
      dueDate: new Date().toISOString().split('T')[0],
      // CONFIGURAÇÃO DO SPLIT (O diferencial do desafio)
      split: [{
        walletId: "ID-DA-CARTEIRA-LACREI",
        fixedValue: 10.00 // Exemplo: Taxa fixa para a plataforma
      }]
    };

    const response = await fetch(`${ASAAS_URL}/payments`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'access_token': ASAAS_API_KEY
      },
      body: JSON.stringify(paymentData)
    });

    const data = await response.json();
    res.status(201).json(data);
  } catch (error) {
    res.status(500).json({ error: "Erro ao processar split na Asaas" });
  }
});

app.post('/webhooks/asaas', async (req, res) => {
  const { event, payment } = req.body;

  try {
    if (event === 'PAYMENT_CONFIRMED') {
      console.log(`Pagamento ${payment.id} confirmado para o cliente ${payment.customer}`);
      
      // Publicar no SNS (O diferencial do seu projeto)
      const params = {
        Message: `Sucesso: Pagamento confirmado via Asaas. ID: ${payment.id} | Cliente: ${payment.customer}`,
        Subject: "Confirmação de Pagamento Lacrei Saúde",
        TopicArn: process.env.SNS_TOPIC_ARN // Melhor usar variável de ambiente injetada pelo Terraform
      };
      
      await snsClient.send(new PublishCommand(params));
    }
    res.status(200).send('Webhook processado');
  } catch (error) {
    console.error("Erro ao processar webhook:", error);
    res.status(500).send('Erro interno');
  }
});