-module(bam_ttt).
%-export([ jogar/3, jogar_pc/1 ]).

-compile(export_all).

%% jog1 -> x
%% jog2 -> o

jogar( Tabuleiro, {Jogada, Jog}, {Jog1, Jog2} ) ->
    Tab_list = extrair_pos (Tabuleiro),
    case Jog of
	jog1 ->
	    Nv_pos = x,
	    Prox_jog = Jog2;
	jog2 ->
	    Nv_pos = o,
	    Prox_jog = Jog1
	end,

    case faz_jogada(Tab_list, {Jogada, Nv_pos}) of
	erro ->
	    {erro, pos_ocupada};
	{ok, Nv_tab_list} ->
	    Nv_Tab = montar_tab ( Nv_tab_list ),
	    case checar_vitoria ( Nv_Tab ) of
		{ok, Jog} ->
		    {ok, Nv_Tab, {vitoria, Jog}};

		erro ->
		    case checar_empate ( Nv_tab_list ) of
			true  -> {ok, Nv_Tab, empate};
			false -> {ok, Nv_Tab, {jogando, Prox_jog}}
		    end
	    end
    end.
    

jogar_pc( Tabuleiro ) ->
    Tab_list = extrair_pos (Tabuleiro),

    Prox_jog = jog1,
    Jogada = gerar_jogada_pc( Tab_list ),

    {ok, Nv_tab_list} = faz_jogada( Tab_list, {Jogada, o} ),

    Nv_Tab = montar_tab( Nv_tab_list ),

    case checar_vitoria ( Nv_Tab ) of
	{ok, jog1} ->
	    {ok, Nv_Tab, {vitoria, jog1}};
	{ok, jog2} ->
	    {ok, Nv_Tab, {vitoria, computador}};

	erro ->
	    case checar_empate ( Nv_tab_list ) of
		true  -> {ok, Nv_Tab, empate};
		false -> {ok, Nv_Tab, {jogando, Prox_jog}}
	    end
    end.

gerar_jogada_pc( Tab ) -> gerar_jogada_pc( Tab, 1 ).
gerar_jogada_pc( [vz|_], Jogada ) -> Jogada;
gerar_jogada_pc( [_| T], N ) -> gerar_jogada_pc( T, N+1 ).

faz_jogada( Tab_list, {N, Nv_pos} ) ->
    faz_jogada( Tab_list, {N, Nv_pos}, [] ).

faz_jogada( [ Pos |_], { 1 ,_},_) when Pos =/= vz ->
    erro;

faz_jogada( [Pos| T], {1, Nv_pos}, Nv_tab ) when Pos == vz ->
    {ok, lists:reverse( [Nv_pos| Nv_tab], T )};

faz_jogada( [ H| T], {N, Nv_pos}, Nv_Tab ) ->
    faz_jogada( T, {N-1, Nv_pos}, [H| Nv_Tab] ).

extrair_pos( Tabuleiro ) ->
    [ [P11, P12, P13],
      [P21, P22, P23],
      [P31, P32, P33]
    ] = Tabuleiro,

    [ P11, P12, P13,
      P21, P22, P23,
      P31, P32, P33
    ].

montar_tab( Tab_list ) ->
    [ P11, P12, P13,
      P21, P22, P23,
      P31, P32, P33 ] = Tab_list,

    [ [P11, P12, P13],
      [P21, P22, P23],
      [P31, P32, P33]
    ].

checar_empate( [] ) -> true;
checar_empate( [ vz| _] ) -> false;
checar_empate( [_|T] ) -> checar_empate( T ).

checar_vitoria( Tabuleiro ) ->
    case Tabuleiro of

	[ [x, _P12, _P13],
	  [_P21, x, _P23],
	  [_P31, _P32, x]
	] -> {ok, jog1};

	[ [_P11, _P12, x],
	  [_P21, x, _P23],
	  [x, _P32, _P33]
	] -> {ok, jog1};

	[ [x, _P12, _P13],
	  [x, _P22, _P23],
	  [x, _P32, _P33]
	] -> {ok, jog1};

	[ [_P11, _P12, x],
	  [_P21, _P22, x],
	  [_P31, _P32, x]
	] -> {ok, jog1};

	[ [_P11, x, _P13],
	  [_P21, x, _P23],
	  [_P31, x, _P33]
	] -> {ok, jog1};

	[ [  x,   x,   x],
	  [_P21, _P22, _P23],
	  [_P31, _P32, _P33]
	] -> {ok, jog1};

	[ [_P11, _P12, _P13],
	  [  x,   x,   x],
	  [_P31, _P32, _P33]
	] -> {ok, jog1};

	[ [_P11, _P12, _P13],
	  [_P21, _P22, _P23],
	  [  x,   x,   x]
	] -> {ok, jog1};

	[ [  o,   o,   o],
	  [_P21, _P22, _P23],
	  [_P31, _P32, _P33]
	] -> {ok, jog2};

	[ [_P11, _P12, _P13],
	  [  o,   o,   o],
	  [_P31, _P32, _P33]
	] -> {ok, jog2};

	[ [_P11, _P12, _P13],
	  [_P21, _P22, _P23],
	  [  o,   o,   o]
	] -> {ok, jog2};

	[ [  o, _P12, _P13],
	  [_P21,   o, _P23],
	  [_P31, _P32,   o]
	] -> {ok, jog2};

	[ [_P11, _P12,   o],
	  [_P21,   o, _P23],
	  [  o, _P32, _P33]
	] -> {ok, jog2};

	[ [  o, _P12, _P13],
	  [  o, _P22, _P23],
	  [  o, _P32, _P33]
	] -> {ok, jog2};

	[ [_P11, o, _P13],
	  [_P21, o, _P23],
	  [_P31, o, _P33]
	] -> {ok, jog2};

	[ [_P11, _P12, o],
	  [_P21, _P22, o],
	  [_P31, _P32, o]
	] -> {ok, jog2};
	_ ->
	    erro
    end.







