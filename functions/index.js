
const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { defineSecret, defineString } = require('firebase-functions/params');
const logger = require('firebase-functions/logger');

const API_BASE_URL = defineString('NEOGYM_API_BASE_URL');
const INTERNAL_SECRET = defineSecret('NEOGYM_NOTIFICATION_SECRET');

exports.notificarNovaMensagem = onDocumentCreated(
  {
    document: 'chats/{chatId}/messages/{messageId}',
    secrets: [INTERNAL_SECRET],
  },
  async (event) => {
    const snapshot = event.data;

    if (!snapshot) {
      logger.warn('Documento da mensagem não encontrado.');
      return;
    }

    const mensagem = snapshot.data();
    const { chatId, messageId } = event.params;

    const remetenteId = Number(mensagem.senderUsuarioId);
    const destinatarioId = Number(mensagem.recipientUsuarioId);

    // Ignora mensagens antigas que não têm os IDs do NeoGym.
    if (
      !Number.isInteger(remetenteId) ||
      !Number.isInteger(destinatarioId)
    ) {
      logger.info('Mensagem ignorada: IDs ausentes.', {
        chatId,
        messageId,
      });
      return;
    }

    // Não permite notificar o próprio remetente.
    if (remetenteId === destinatarioId) {
      logger.warn('Mensagem ignorada: remetente e destinatário iguais.');
      return;
    }

    // Confere se os IDs correspondem ao chat esperado.
    const match = /^chat_(\d+)_(\d+)$/.exec(chatId);

    if (!match) {
      logger.warn('Formato de chat inválido.', { chatId });
      return;
    }

    const participantes = [
      Number(match[1]),
      Number(match[2]),
    ];

    if (
      !participantes.includes(remetenteId) ||
      !participantes.includes(destinatarioId)
    ) {
      logger.warn('Participantes não correspondem ao chat.', {
        chatId,
        remetenteId,
        destinatarioId,
      });
      return;
    }

    const texto = String(mensagem.text || '').trim();

    const corpo = texto
      ? texto
      : mensagem.imageUrl
        ? 'Enviou uma imagem.'
        : 'Você recebeu uma nova mensagem.';

    const baseUrl = API_BASE_URL.value().replace(/\/+$/, '');

    const payload = {
      eventId: `${chatId}_${messageId}`,
      chatId,
      messageId,
      senderFirebaseUid: String(mensagem.senderId || ''),
      senderUsuarioId: remetenteId,
      recipientUsuarioId: destinatarioId,
      senderName: String(mensagem.senderName || 'Nova mensagem'),
      text: corpo,
      imageUrl: mensagem.imageUrl || null,
    };

    const resposta = await fetch(
      `${baseUrl}/notificacoes/chat`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Internal-Token': INTERNAL_SECRET.value(),
        },
        body: JSON.stringify(payload),
      },
    );

    if (!resposta.ok) {
      const detalhe = await resposta.text();

      logger.error('Erro ao encaminhar notificação para o backend.', {
        status: resposta.status,
        detalhe,
        chatId,
        messageId,
      });

      throw new Error(
        `Erro no backend: HTTP ${resposta.status}`,
      );
    }

    logger.info('Notificação encaminhada ao backend.', {
      chatId,
      messageId,
      destinatarioId,
    });
  },
);
