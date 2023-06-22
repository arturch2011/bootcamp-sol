// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {

    uint256 totalWaves;

    /*
     * Utilizaremos isso abaixo para gerar um número randômico
     */
    uint256 private seed;

    /*
     * Um pouco de mágica, use o Google para entender o que são eventos em Solidity!
     */
    event NewWave(address indexed from, uint256 timestamp, string message);

    /*
     * Crio um struct Wave.
     * Um struct é basicamente um tipo de dados customizado onde nós podemos customizar o que queremos armazenar dentro dele
     */
    struct Wave {
        address waver;      // Endereço do usuário que deu tchauzinho
        string message;     // Mensagem que o usuário envio
        uint256 timestamp;  // Data/hora de quando o usuário tchauzinhou.
    }

    /*
     * Declara a variável waves que permite armazenar um array de structs.
     * Isto que me permite armazenar todos os tchauzinhos que qualquer um tenha me enviado!
     */
    Wave[] waves; 


    /*
     * Este é um endereço => uint mapping, o que significa que eu posso associar o endereço com um número!
     * Neste caso, armazenarei o endereço com o últimoo horário que o usuário tchauzinhou.
     */
    mapping(address => uint256) public lastWavedAt;

    constructor() payable {
        
        console.log("Bem vindo a Blockchain");

        /*
         * Define a semente inicial
         */
        seed = (block.timestamp + block.difficulty) % 100;
    }

    /*
     * Você notará que eu mudei um pouco a função de tchauzinho e agora requer uma string chamada _message. Esta é a mensagem que o nosso usuário enviou pelo frontend!
     */
    function wave(string memory _message) public {
        
         /*
         * Precisamos garantir que o valor corrente de timestamp é ao menos 15 minutos maior que o último timestamp armazenado
         */
        require(
            lastWavedAt[msg.sender] + 5 minutes < block.timestamp,
            "Espere 5 minutos antes de enviar o proximo tchauzinho"
        );

        /*
         * Atualiza o timestamp atual do usuário
         */
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        console.log("%s enviou um tchauzinhou com a mensagem -> %s", msg.sender, _message);

        /*
         * Aqui é onde eu efetivamenete armazeno o tchauzinho no array.
         */
        waves.push(Wave(msg.sender, _message, block.timestamp));

        /*
         * Gera uma nova semente para o próximo que mandar um tchauzinho
         */
        seed = (block.difficulty + block.timestamp + seed) % 100;

        console.log("# randomico gerado: %d", seed);

        /*
         * Dá 50%  de chance do usuário ganhar o prêmio.
         */
        if (seed <= 50) {
            
            console.log("%s ganhou!", msg.sender);
                      
            //Defidindo o Valor que será enviado a quem mandou um thauzinho
            uint256 prizeAmount = 0.0001 ether;
        
            //Verificando se o Contrato tem Saldo
            require(prizeAmount <= address(this).balance,"Tentando sacar mais dinheiro que o contrato possui.");
        
            //Enviando o valor para o mensageiro
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
        
            //Se falhou, avisa
            require(success, "Falhou em sacar dinheiro do contrato.");
        }
        else{
            console.log("nao ganhou!");
        }

        /*
         * Eu adicionei algo novo aqui. Use o Google para tentar entender o que é e depois me conte o que aprendeu em #general-chill-chat
         */
        emit NewWave(msg.sender, block.timestamp, _message);

    }

    /*
     * Adicionei uma função getAllWaves que retornará os tchauzinhos.
     * Isso permitirá recuperar os tchauzinhos a partir do nosso site!
     */
    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256){

        console.log("Temos um total de %d thauzinhos",totalWaves);
        return totalWaves;

    }

}