%% BAM - Bernardino Anderson Mário
%%       
%% Disciplina: Engenharia de Software 2010/2
%% Professor:  Jucimar Jr ( jucimar.jr@gmail.com )
%% Alunos : Anderson Pimentel ( andbrain@gmail.com )
%%          Mário Angel(mr.garcia1@hotmail.com)
%%          Rodrigo Bernardino ( rbbernardino@gmail.com )
%%
%% Objetivo : Módulo controle

-module(bam_ctrl).
-vsn(0.11).

-author('rbbernardino@gmail.com').
-author('mr.garcia1@hotmail.com').
-author('andbrain@gmail.com').

-export([start/0, set_oponente/0, set_nome/1,
	 set_nivel/1, ativo_hum/3, ativo_pc/4]).

%%-----------------------------------------------------------------------------
%% start()
%%    -> inicia processo controle

start() ->
    set_oponente().

set_oponente() ->
    receive
	{bam_ui, oponente, humano} ->
	    bam_ui ! {bam_ctrl, oponente, ok},
	    set_nome( humano );
	
	{bam_ui, oponente, robo} ->
	    bam_ui ! {bam_ctrl, oponente, ok},
	    set_nome( robo );
	
	{bam_ui, oponente, _} ->
	    bam_ui ! {bam_ctrl, oponente, erro};

	{bam_ui, reiniciar_jogo} ->
	    start();
	X ->
	    io:format("INESPERADO:\n" ++
		      "bam_ctrl:set_oponente\n" ++
		      "receive  ->  ~p", [X])
    end.

%%-----------------------------------------------------------------------------
%% set_nome( Tipo_oponente )
%%    -> recebe o nome dos jogadores
%%    -> envia confirmação para ui
%%
%% Tipo_oponente = humano | robo

set_nome( Tipo_oponente ) ->
    receive
	{bam_ui, nomes, Nomes} ->
	    bam_ui ! {bam_ctrl, nomes, ok},

	    case Tipo_oponente of
		humano -> inicia_part( Tipo_oponente, Nomes );
		robo -> set_nivel ( Nomes );
		X ->
		    io:format("INESPERADO:\n" ++
			      "bam_ctrl:set_nome\n" ++
			      "case  ->  ~p", [X])

	    end;

	X ->
	    io:format("INESPERADO:\n" ++
		      "bam_ctrl:set_nome\n" ++
		      "receive  ->  ~p", [X])
    end.

%%-----------------------------------------------------------------------------
%% set_nivel( Nomes )
%%    -> recebe o nivel e vai para ativo_pc

set_nivel( Nomes ) ->
    receive
	{bam_ui, nivel, Nivel} ->
	    inicia_part( {robo, Nivel}, Nomes )
    end.

%%-----------------------------------------------------------------------------
%% inicia_part( Tipo_oponente )
%%    -> determina condições iniciais (tabuleiro, estado)
%%    -> vai para estado ativo

inicia_part( Tipo_oponente, Nomes ) ->
    Tabuleiro = { {vazio, vazio, vazio},
		  {vazio, vazio, vazio},
		  {vazio, vazio, vazio}
		 },
    Estado = jogando,

    receive
	{bam_ui, nv_partida} ->
	    bam_ui ! {bam_ctrl, nv_partida, ok};
	X ->
	    io:format("INESPERADO:\n" ++
		      "bam_ctrl:inicia_part\n" ++
		      "receive   ->  ~p", [X])
    end,
    case Tipo_oponente of
	humano        -> ativo_hum(Tabuleiro, Estado, Nomes);
	{robo, Nivel} -> ativo_pc (Tabuleiro, Estado, Nomes, Nivel)
    end.

ativo_hum(_Tabuleiro, _Estado, _Nomes) ->
    ok.

ativo_pc(_Tabuleiro, _Estado, _Nomes, _Nivel) ->
    ok.
