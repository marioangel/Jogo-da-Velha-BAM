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
	 set_nivel/0, ativo/4]).

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
	
	{bam_ui, oponente, computador} ->
	    bam_ui ! {bam_ctrl, oponente, ok},
	    set_nivel();
	
	{bam_ui, oponente, _} ->
	    bam_ui ! {bam_ctrl, oponente, erro};

	{bam_ui, reiniciar_jogo} ->
	    start();

	{bam_ui, sair} ->
	    die;

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
%% Tipo_oponente = humano | computador

set_nome( Tipo_oponente ) ->
    receive
	{bam_ui, nomes, Nomes} ->
	    bam_ui ! {bam_ctrl, nomes, ok},
	    inicia_partida( Tipo_oponente, Nomes );

	X ->
	    io:format("INESPERADO:\n" ++
		      "bam_ctrl:set_nome\n" ++
		      "receive  ->  ~p", [X])
    end.

%%-----------------------------------------------------------------------------
%% set_nivel()
%%    -> recebe o nivel e vai para set_nome

set_nivel() ->
    receive
	{bam_ui, nivel, Nivel} ->
	    set_nome( {computador, Nivel} )
    end.

%%-----------------------------------------------------------------------------
%% inicia_part( Tipo_oponente )
%%    -> determina condições iniciais (tabuleiro, estado)
%%    -> vai para estado ativo
%%
%% Tipo_oponente = humano | {computador, Nivel}
%% Nivel = facil | intermediario | dificil

inicia_partida( Tipo_oponente, Nomes ) ->
    Tabuleiro = [ [vz, vz, vz],
		  [vz, vz, vz],
		  [vz, vz, vz]
		 ],

    Estado = {jogando, jog1},

    receive
	{bam_ui, nv_partida} ->
	    bam_ui ! {bam_ctrl, nv_partida, ok};
	X ->
	    io:format("INESPERADO:\n" ++
		      "bam_ctrl:inicia_part\n" ++
		      "receive   ->  ~p", [X])
    end,

    Jogo = { Tabuleiro, Nomes, Estado },
    bam_ui ! {bam_ctrl, partida, {ok, Jogo} }, 

    ativo( Tipo_oponente, Tabuleiro, Estado, Nomes ).

%%-----------------------------------------------------------------------------
%% ativo_hum ( Tipo_oponente, Tabuleiro, Estado, Nomes  )
%%    -> espera por jogada ou comando de sair
%%    -> atualiza estado do jogo e envia para a tui
%%    -> chama entidade para processar jogada
%%    -> caso Estado seja empate ou venceu 
%%
%% Tipo_oponente = humano | {computador, Nivel}
%% Nivel = facil | intermediario | dificil
%%
%% Tabuleiro = { L1, L2, L3 }
%% LN = { PN1, PN2, PN3 }
%% PNX = o | x | vz
%%
%% Estado = {jogando, Jog} | empate | {vitoria, Jog}
%% Jog = jog1 | jog2 | computador

ativo( Tipo_op, Tabuleiro, Estado, Nomes ) ->
    receive
	{bam_ui, partida, refresh} ->
	    Jogo = {Tabuleiro, Nomes, Estado},
	    bam_ui ! {bam_ctrl, partida, {ok, Jogo}},
	    ativo( Tipo_op, Tabuleiro, Estado, Nomes );

	{bam_ui, jogada, {Posicao, _}} when (Posicao > 9) or (Posicao == 0)->
	    Jogo = {Tabuleiro, Nomes, Estado},
	    bam_ui ! {bam_ctrl, partida, {erro, pos_fora_tab, Jogo}},
	    ativo( Tipo_op, Tabuleiro, Estado, Nomes );

	{bam_ui, jogada, {Posicao, Jog}} ->
	    Jogs = case Tipo_op of
		       humano -> {jog1, jog2};
		       {computador, _} -> {jog1, computador}
		   end,

	    case bam_ttt:jogar( Tabuleiro, {Posicao, Jog}, Jogs ) of
		{erro, pos_ocupada} ->
		    Jogo = {Tabuleiro, Nomes, Estado},
	      	    bam_ui ! {bam_ctrl, partida, {erro, pos_ocupada, Jogo}},
		    ativo( Tipo_op, Tabuleiro, Estado, Nomes );

		{ok, Nv_Tabuleiro, Nv_Estado} ->
		    ativo( Tipo_op, Nv_Tabuleiro, Nv_Estado, Nomes )
	    end;

	{bam_ui, jogada, computador} ->
	    {ok, Nv_Tabuleiro, Nv_Estado} = bam_ttt:jogar_pc( Tabuleiro ),
	    ativo( Tipo_op, Nv_Tabuleiro, Nv_Estado, Nomes );

	{bam_ui, reiniciar_jogo} ->
	    start();

	{bam_ui, reiniciar_partida} ->	   
	    inicia_partida( humano, Nomes )
 
    end.
