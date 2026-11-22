# Isca de comentário que vira DM

Feita com a ferramenta de comentário para DM que o cliente usa (ManyChat ou similar). Quando alguém comenta a palavra-isca num post, ela responde no comentário e manda uma DM com o material. Também faz fluxos com respostas rápidas, captura de e-mail e histórico do lead.

## Pré-requisitos
- Conta profissional do Instagram conectada ao app da Meta, com os campos de comentário e mensagem assinados.
- Conta do cliente na ferramenta de comentário para DM, conectada ao Instagram dele.
- Zernio funcionando para agendar o post.

## Ordem obrigatória
1. **Material pronto**: PDF ou guia que o lead vai receber. Isca sem material é lead que comenta e não recebe nada.
2. **Página de entrega no ar** e respondendo 200. Se o link cair em 404 depois de o lead deixar o e-mail, a falha é do cliente.
3. **Post agendado** no Zernio. Guarde o ID do post.
4. **Automação criada com o ID do post.** Ela nasce **desligada**.
5. **Quando o post publica**, uma ponte liga o gatilho. Nunca ligue a mão antes de o post existir.

## O que a automação precisa
- Palavra-isca curta, única e ligada ao tema, mais variantes de grafia.
- O que o lead recebe (a oferta, em uma frase).
- Post amarrado pelo ID do agendamento.
- Mensagem de entrega com o link e uma frase de fecho.

## Cuidados
- Comandos de descadastro (sair, parar, cancelar) valem sempre. Não use essas palavras como isca.
- Retenção de dados do lead segue a política do cliente (LGPD).
- Ligar ou pausar fluxo é ação com aprovação do cliente.
