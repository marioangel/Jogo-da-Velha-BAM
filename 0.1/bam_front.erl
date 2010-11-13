%% BAM - Bernardino Anderson Mário
%%       
%% Disciplina: Engenharia de Software 2010/2
%% Professor:  Jucimar Jr ( jucimar.jr@gmail.com )
%% Alunos : Anderson Pimentel ( andbrain@gmail.com )
%%          Mário Angel
%%          Rodrigo Bernardino ( rbbernardino@gmail.com )
%%
%% Objetivo : Módulo front - função para iniciar o jogo

-module(bam_front).
-vsn(0.11).

-author('rbbernardino@gmail.com').
-author('mr.garcia1@hotmail.com').
-author('andbrain@gmail.com').

-export([start/1, restart/0, stop/0,
	ins_nome/1, sel_op/1, sel_nivel/1
	jogar/1]).

%%-----------------------------------------------------------------------------
%% start( UI )
%%   -> inicia os processos do jogo
%%   -> dependendo da interface selecionada, inicia a GUI ou TUI

start( text_ui ) ->
    register( bam_ui,   spawn( bam_tui,  init,  [] ) ),
    register( bam_ctrl, spawn( bam_ctrl, start, [] ) ),
    ok;

start( graf_ui ) ->
    register( bam_ui,   spawn( bam_gui,  init,  [] ) ),
    register( bam_ctrl, spawn( bam_ctrl, start, [] ) ),
    ok;

start( _ ) ->
    io:format("Tipo de interface invalido!\n" ++ 
	      "Jogo nao iniciado!\n\n").
