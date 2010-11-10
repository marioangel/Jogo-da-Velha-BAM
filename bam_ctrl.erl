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

-export([start/0, set_oponente/0, set_nome/2,
	 set_nivel/0, ativo_hum/0, ativo_pc/0]).

%%-----------------------------------------------------------------------------
%% start()
%%    -> inicia processo controle

start() ->
    set_oponente().

set_oponente() ->
    receive
	{bam_ui, oponente, Opcao} ->
	    case Opcao of
		hum ->
		    set_nome(hum, {vazio, vazio});
		robo ->
		    set_nome(rodo, {vazio, "Computador"});
		_ ->
		    bam_ui ! {bam_ctrl, oponente, erro},
		    set_oponente()
	    end;
	{bam_ui, reiniciar_jogo} ->
	    start()
    end.

set_nome(_, _) ->
    ok.

set_nivel() ->
    ok.

ativo_hum() ->
    ok.

ativo_pc() ->
    ok.
