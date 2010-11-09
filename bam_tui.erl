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

-export([init/0, sel_op/0, ins_nome/0,
	sel_nivel/0, ativo/0]).

%%-----------------------------------------------------------------------------
%%init()
%%Imprimi o cabecalho inicial e pergunta se deseja ou nao comecar uma partida 
init() ->
	io:format(
	"\t\t\t INICIANDO JOGO DA VELHA BAM \n\n"++
	"\t\t      Autores:Mario, Rodrigo, Anderson \n\n"),

	io:format(
	"Jogo da velha BAM \n"++"(1) Jogar \n"++"(2) Sair\n"),

	Read = io: fread("Escolha Opcao: ","~d"),
	case Read of
		{ok,[1]} -> sel_oponente();
		{ok,[2]} -> sair();
		{ok, _} -> io:format("\nOPCAO INVALIDA\n"++"TENTE NOVAMENTE\n"),
				init()	
	end.
%%-----------------------------------------------------------------------------
%%sel_oponente()
%%   funcao, metodo utilizado, etc
%%   nao faca linha muito grandes, respeite o limite de 80 caracteres, ou seja,
%%   a linha com "-" acima
sel_oponente() ->
    io:format("Digite o tipo de oponente desejado:~n~n"),
    io:format("(1) Humano x Humano (2) Humano x Maquina (3) Menu Principal~n"),
    {ok,[Opcao]} = io:fread("Opcao: ","~d"),
    case Opcao of

	3 ->
	    init();

	UmOuDois ->
	    bam_crtl ! {bam_ui,oponente,Opcao},
	    receive
		{bam_ctrl,oponente,ok} ->
		    case Opcao of
			1 -> ins_nome({vazio,vazio});
			2 -> sel_nivel()
		    end;
		{bam_ctrl,oponente,erro} ->
		    io:format("Erro na opcao do oponente desejado!~n"),
		    sel_oponente()
	    end.

end.


ins_nome() ->
    ok.

sel_nivel() ->
    ok.

inicia_part() ->
    io:format("------------ INICIANDO PARTIDA ------------\n"

	      ativo() ->

