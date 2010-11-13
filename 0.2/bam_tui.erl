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

ins_nome( {vazio,vazio} ) ->
	    io:format("Digite o Nome dos jogadores...~n"),
	    
	    {ok,Nome1} = io:fread("Jogador 1: ","~s"),
	    {ok,Nome2} = io:fread("Jogador 2: ","~s"),
	    
	    bam_ctrl ! {bam_ui, nomes, {Nome1,Nome2}},
	    
	    receive
		{bam_ctrl, nomes, ok} ->
		    nv_partida()
	    end;

ins_nome( {computador,vazio} ) ->

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
	   io:format(
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
    io:format("\n\nUMA NOVA PARTIDA SERA INICADA\n\n"),
    
    bam_ctrl ! {bam_ui, nv_partida},
    
    receive
	{bam_ctrl, nv_partida, ok} ->
	     ativo()
    end.

ativo() ->
    ok.

sair() ->
    ok.
