%% BAM - Bernardino Anderson Mário
%%       
%% Disciplina: Engenharia de Software 2010/2
%% Professor:  Jucimar Jr ( jucimar.jr@gmail.com )
%% Alunos : Anderson Pimentel ( andbrain@gmail.com )
%%          Mário Angel(mr.garcia1@hotmail.com)
%%          Rodrigo Bernardino ( rbbernardino@gmail.com )
%%
%% Objetivo : Módulo da interface texto

-module(bam_tui).
-vsn(0.11).

-author('rbbernardino@gmail.com').
-author('mr.garcia1@hotmail.com').
-author('andbrain@gmail.com').

-export([init/0, sel_oponente/0, ins_nome/1,
	sel_nivel/0, ativo/0]).

%%-----------------------------------------------------------------------------
%%init()
%%Imprime o cabecalho inicial e pergunta se deseja ou nao comecar uma partida 
init() ->
    io:format(os:cmd(clear)),
    io:format("\n\n" ++
	      "\t\t               JOGO DA VELHA BAM \n\n"++
	      "\t\t      Autores:  Mario, Rodrigo, Anderson \n\n"),

    io:format(
      "Jogo da velha BAM \n" ++ 
      "(1) Jogar \n" ++ 
      "(2) Sair\n"),

    Read = io:fread("Escolha Opcao: ","~d"),

    case Read of
	{ok,[1]} -> sel_oponente();
	{ok,[2]} -> sair();
	{ok, _} -> io:format("\nOPCAO INVALIDA\n"++"TENTE NOVAMENTE\n"),
		   init()	
    end.
%%-----------------------------------------------------------------------------
%%sel_oponente()
%%   
%% Escolha do tipo de oponente enviando para o modulo de controle			
%% de controle a opcao desejada e esperando um OK

sel_oponente() ->
    io:format(os:cmd(clear)),
    io:format("\n\nDigite o tipo de oponente desejado:~n~n"),
    io:format("(1) Humano x Humano\n" ++
	      "(2) Humano x Maquina\n" ++
	      "(3) Menu Principal\n"),

    {ok,[Opcao]} = io:fread("Opcao: ","~d"),

    case Opcao of

	3 ->
	    init();

	1 ->
	    bam_ctrl ! {bam_ui, oponente, humano};
	
	2 ->
	    bam_ctrl ! {bam_ui, oponente, robo}
    end,
    
    receive
	{bam_ctrl, oponente, ok} ->
	    case Opcao of
		1 -> ins_nome({vazio,vazio});
		2 -> sel_nivel()
	    end;
	{bam_ctrl, oponente, erro} ->
	    io:format("Erro na opcao do oponente desejado!~n"),
	    sel_oponente()
    end.

%%-----------------------------------------------------------------------------
%%ins_nome()
%%   
%% Permitir inserir o nome dos jogadores

ins_nome( { vazio, vazio} ) ->

    io:format(os:cmd(clear)),
    io:format("Digite o Nome dos jogadores...~n"),

    {ok,Nome1} = io:fread("Jogador 1: ","~s"),
    {ok,Nome2} = io:fread("Jogador 2: ","~s"),

    bam_ctrl ! {bam_ui, nomes, {Nome1,Nome2}},

    receive
	{bam_ctrl, nomes, ok} ->
	    nv_partida()
    end;

ins_nome( { computador, vazio} ) ->

    io:format("Digite o Nome do jogador...~n"),

    {ok,Nome} = io:fread("Jogador 1: ","~s"),

    bam_ctrl ! {bam_ui,ins_nome,nome,{Nome,"Computador"}},

    receive
	{bam_ctrl,nomes,ok} ->
	    nv_partida()
    end.

%%-----------------------------------------------------------------------------
%%sel_nivel()
%%   
%% Escolha do nivel do computador    

sel_nivel() ->

    io:format(os:cmd(clear)),	
    io:format(
      "Selecione o nivel de sua maquina\n"++
      "Tipos de niveis:\n"++
      "(1)Nivel Facil\n"++
      "(2)Nivel Intermediario\n"++
      "(3)Nivel Dificil\n"),

    Read = io: fread("Escolha Opcao: ","~d"),
    case Read of
	{ok,[1]} -> bam_ctrl ! {bam_ui, nivel, facil},
		    ins_nome({computador,vazio});
	{ok,[2]} -> bam_ctrl ! {bam_ui, nivel, intermediario},
		    ins_nome({computador,vazio});
	{ok,[3]} -> bam_ctrl ! {bam_ui, nivel, dificil},
		    ins_nome({computador,vazio});
	{ok, _} -> io:format("\nOPCAO INVALIDA\n"++
			     "TENTE NOVAMENTE\n\n"),
		   sel_nivel()
    end.

%%-----------------------------------------------------------------------------
%%nv_partida()
%%   
%% Inica uma nova partida

nv_partida() ->
    io:format(os:cmd(clear)),
    io:format("\n\nA PARTIDA SERA INICIADA\n\n"),
    
    bam_ctrl ! {bam_ui, nv_partida},
    
    receive
	{bam_ctrl, nv_partida, ok} ->
	     ativo()
    end.

%%-----------------------------------------------------------------------------
%%sair()
%%   
%% Permite jogar uma partida no jogo da velha BAM
%%

ativo() ->
    receive 
	{bam_ctrl, partida, {ok, Jogo}} ->
	    { Tabuleiro, {Nome1, Nome2}, Estado} = Jogo,
	    monta_tabuleiro(Tabuleiro),

	    case Estado of
		{ jogando, computador} ->
		    io:format(os:cmd(clear)),
		    ativo();

		{ jogando, Jog} ->
		    Nome = case Jog of
			       jog1 -> Nome1;
			       jog2 -> Nome2
			   end,
		    Jogada = io:fread("Jogador: "++Nome++
					  "\nEm qual posicao deseja jogar:" ,"~d"),
		    case Jogada of
			{ok, [Numero]}->
			    bam_ctrl ! {bam_ui, jogada, {Numero,Jog}},
			    io:format(os:cmd(clear)),
			    ativo();			    
			{error, _}->
			    io:format("\nDIGITE APENAS NUMEROS\n"),
			    io:fread("...Pressione <ENTER> para continuar...",""),
			    io:format(os:cmd(clear)),
			    ativo()
		    end;


		empate ->
		    io:format("\nSeu partida VELHOU\n\n"++
				  "Menu BAM\n"++
				  "(1)Menu Principal\n"++
				  "(2)Reiniciar Partida\n"),
		    Opcao = io:fread("O que deseja fazer :" ,"~d"),
		    case Opcao of
			{ok,[1]} ->
			    bam_ctrl ! {bam_ui, reiniciar_jogo},
			    io:format(os:cmd(clear)),
			    init();
			{ok,[2]} ->
			    bam_ctrl ! {bam_ui, reiniciar_partida},
			    io:format(os:cmd(clear)),
			    nv_partida();
			{ok, _} ->
			    io:format("\nOPCAO INVALIDA\n"),
			    io:fread("...Pressione <ENTER> para continuar...",""),
			    io:format(os:cmd(clear)),
			    ativo();
			{error, _}->
			    io:format("\nDIGITE APENAS NUMEROS\n"),
			    io:fread("...Pressione <ENTER> para continuar...",""),
			    io:format(os:cmd(clear)),
			    ativo()
		    end;


		{vitoria,Jog} ->
		    Nome = case Jog of
			       jog1 -> Nome1;
			       jog2 -> Nome2
			   end,
		    io:format("\nSua partida TERMINOU\n\n"++
				  "O jogador "++ Nome ++" GANHOU o/o/o/ \n\n"++
				  "Menu BAM\n"++
				  "(1)Menu Principal\n"++
				  "(2)Reiniciar Partida\n"),
		    Opcao = io:fread("O que deseja fazer :" ,"~d"),
		    case Opcao of
			{ok,[1]} ->
			    bam_ctrl ! {bam_ui, reiniciar_jogo},
			    io:format(os:cmd(clear)),
			    init();
			{ok,[2]} ->
			    bam_ctrl ! {bam_ui, reiniciar_partida},
			    io:format(os:cmd(clear)),
			    nv_partida();
			{ok, _} ->
			    io:format("\nOPCAO INVALIDA\n"),
			    io:fread("...Pressione <ENTER> para continuar...",""),
			    io:format(os:cmd(clear)),
			    ativo();
			{error, _}->
			    io:format("\nDIGITE APENAS NUMEROS\n"),
			    io:fread("...Pressione <ENTER> para continuar...",""),
			    io:format(os:cmd(clear)),
			    ativo()
		    end

	    end;
	{bam_ctrl, partida, {erro,Why,_}} -> 
	    case Why of
		pos_fora_tab ->
		    io:format("Posicao fora das definidas no tabuleiro!!"),
		    io:fread("...Pressione <ENTER> para continuar...",""),
		    io:format(os:cmd(clear)),
		    ativo();

		pos_ocupada ->
		    io:format("Posicao ja ocupada!!"),
		    io:fread("...Pressione <ENTER> para continuar...",""),
		    io:format(os:cmd(clear)),
		    ativo()
	    end
    end.

%%-----------------------------------------------------------------------------
%% monta_tabuleiro()
%%   
%% Monta o tabuleiro do jogo da velha BAM
%% 

monta_tabuleiro(Tabuleiro)->
    io:format(
      "\nUSE O TECLADO NUMERICO \n\n"++
	  "\t_1_|_2_|_3_ \n"++
	  "\t_4_|_5_|_6_ \n"++
	  "\t 7 | 8 | 9  \n"++
	  "\n"++
	  "Para jogar digite a posicao desejada conforme o esquema acima."	
     ),
    [[P11,P12,P13],[P21,P22,P23],[P31,P32,P33]] = Tabuleiro,
    io:format("\n\n_"++transf(P11)++"_|_"++transf(P12)++"_|_"++transf(P13)++"_\n"++
		  "_"++transf(P21)++"_|_"++transf(P22)++"_|_"++transf(P23)++"_\n"++
		  " "++transf(P31)++" | "++transf(P32)++" | "++transf(P33)++" \n").

transf(Posicao) ->
    case Posicao of
	x ->
	    "x";
	o ->
	    "o";
	vz ->
	    "_"
    end.

%%-----------------------------------------------------------------------------
%%sair()
%%   
%% Sai do jogo

sair() ->

    io:format("\n\nSaindo do jogo da velha BAM\n"),
    bam_ctrl ! {bam_ui, sair}.
