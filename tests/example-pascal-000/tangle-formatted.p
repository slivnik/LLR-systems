
Program TANGLE ( webfile , changefile , Pascalfile , pool ) ;

Label 9999 ;

Const bufsize = 100 ;
  maxbytes = 45000 ;
  maxtoks = 50000 ;
  maxnames = 4000 ;
  maxtexts = 2000 ;
  hashsize = 353 ;
  longestname = 400 ;
  linelength = 72 ;
  outbufsize = 144 ;
  stacksize = 50 ;
  maxidlength = 12 ;
  unambiglength = 7 ;

Type ASCIIcode = 0 .. 255 ;
  textfile = packed file Of char ;
  eightbits = 0 .. 255 ;
  sixteenbits = 0 .. 65535 ;
  namepointer = 0 .. maxnames ;
  textpointer = 0 .. maxtexts ;
  outputstate = Record
    endfield : sixteenbits ;
    bytefield : sixteenbits ;
    namefield : namepointer ;
    replfield : textpointer ;
    modfield : 0 .. 12287 ;
  End ;

Var history : 0 .. 3 ;
  xord : array [ char ] Of ASCIIcode ;
  xchr : array [ ASCIIcode ] Of char ;
  termout : textfile ;
  webfile : textfile ;
  changefile : textfile ;
  Pascalfile : textfile ;
  pool : textfile ;
  buffer : array [ 0 .. bufsize ] Of ASCIIcode ;
  phaseone : boolean ;
  bytemem : packed array [ 0 .. 1 , 0 .. maxbytes ] Of ASCIIcode ;
  tokmem : packed array [ 0 .. 2 , 0 .. maxtoks ] Of eightbits ;
  bytestart : array [ 0 .. maxnames ] Of sixteenbits ;
  tokstart : array [ 0 .. maxtexts ] Of sixteenbits ;
  link : array [ 0 .. maxnames ] Of sixteenbits ;
  ilk : array [ 0 .. maxnames ] Of sixteenbits ;
  equiv : array [ 0 .. maxnames ] Of sixteenbits ;
  textlink : array [ 0 .. maxtexts ] Of sixteenbits ;
  nameptr : namepointer ;
  stringptr : namepointer ;
  byteptr : array [ 0 .. 1 ] Of 0 .. maxbytes ;
  poolchecksum : integer ;
  textptr : textpointer ;
  tokptr : array [ 0 .. 2 ] Of 0 .. maxtoks ;
  z : 0 .. 2 ;
  idfirst : 0 .. bufsize ;
  idloc : 0 .. bufsize ;
  doublechars : 0 .. bufsize ;
  hash , chophash : array [ 0 .. hashsize ] Of sixteenbits ;
  choppedid : array [ 0 .. unambiglength ] Of ASCIIcode ;
  modtext : array [ 0 .. longestname ] Of ASCIIcode ;
  lastunnamed : textpointer ;
  curstate : outputstate ;
  stack : array [ 1 .. stacksize ] Of outputstate ;
  stackptr : 0 .. stacksize ;
  zo : 0 .. 2 ;
  bracelevel : eightbits ;
  curval : integer ;
  outbuf : array [ 0 .. outbufsize ] Of ASCIIcode ;
  outptr : 0 .. outbufsize ;
  breakptr : 0 .. outbufsize ;
  semiptr : 0 .. outbufsize ;
  outstate : eightbits ;
  outval , outapp : integer ;
  outsign : ASCIIcode ;
  lastsign : - 1 .. + 1 ;
  outcontrib : array [ 1 .. linelength ] Of ASCIIcode ;
  ii : integer ;
  line : integer ;
  otherline : integer ;
  templine : integer ;
  limit : 0 .. bufsize ;
  loc : 0 .. bufsize ;
  inputhasended : boolean ;
  changing : boolean ;
  changebuffer : array [ 0 .. bufsize ] Of ASCIIcode ;
  changelimit : 0 .. bufsize ;
  curmodule : namepointer ;
  scanninghex : boolean ;
  nextcontrol : eightbits ;
  currepltext : textpointer ;
  modulecount : 0 .. 12287 ;
Procedure error ;

Var j : 0 .. outbufsize ;
  k , l : 0 .. bufsize ;
Begin
  If phaseone Then
    Begin
      If changing Then write ( termout , '. (change file ' )
      Else write ( termout , '. (' ) ;
      writeln ( termout , 'l.' , line : 1 , ')' ) ;
      If loc >= limit Then l := limit
      Else l := loc ;
      For k := 1 To l Do
        If buffer [ k - 1 ] = 9 Then write ( termout , ' ' )
        Else write ( termout , xchr [ buffer [ k - 1 ] ] ) ;
      writeln ( termout ) ;
      For k := 1 To l Do
        write ( termout , ' ' ) ;
      For k := l + 1 To limit Do
        write ( termout , xchr [ buffer [ k - 1 ] ] ) ;
      write ( termout , ' ' ) ;
    End
  Else
    Begin
      writeln ( termout , '. (l.' , line : 1 , ')' ) ;
      For j := 1 To outptr Do
        write ( termout , xchr [ outbuf [ j - 1 ] ] ) ;
      write ( termout , '... ' ) ;
    End ;
  break ( termout ) ;
  history := 2 ;
End ;
Procedure jumpout ;
Begin
  goto 9999 ;
End ;
Procedure initialize ;

Var i : 0 .. 255 ;
  wi : 0 .. 1 ;
  zi : 0 .. 2 ;
  h : 0 .. hashsize ;
Begin
  history := 0 ;
  xchr [ 32 ] := ' ' ;
  xchr [ 33 ] := '!' ;
  xchr [ 34 ] := '"' ;
  xchr [ 35 ] := '#' ;
  xchr [ 36 ] := '$' ;
  xchr [ 37 ] := '%' ;
  xchr [ 38 ] := '&' ;
  xchr [ 39 ] := '''' ;
  xchr [ 40 ] := '(' ;
  xchr [ 41 ] := ')' ;
  xchr [ 42 ] := '*' ;
  xchr [ 43 ] := '+' ;
  xchr [ 44 ] := ',' ;
  xchr [ 45 ] := '-' ;
  xchr [ 46 ] := '.' ;
  xchr [ 47 ] := '/' ;
  xchr [ 48 ] := '0' ;
  xchr [ 49 ] := '1' ;
  xchr [ 50 ] := '2' ;
  xchr [ 51 ] := '3' ;
  xchr [ 52 ] := '4' ;
  xchr [ 53 ] := '5' ;
  xchr [ 54 ] := '6' ;
  xchr [ 55 ] := '7' ;
  xchr [ 56 ] := '8' ;
  xchr [ 57 ] := '9' ;
  xchr [ 58 ] := ':' ;
  xchr [ 59 ] := ';' ;
  xchr [ 60 ] := '<' ;
  xchr [ 61 ] := '=' ;
  xchr [ 62 ] := '>' ;
  xchr [ 63 ] := '?' ;
  xchr [ 64 ] := '@' ;
  xchr [ 65 ] := 'A' ;
  xchr [ 66 ] := 'B' ;
  xchr [ 67 ] := 'C' ;
  xchr [ 68 ] := 'D' ;
  xchr [ 69 ] := 'E' ;
  xchr [ 70 ] := 'F' ;
  xchr [ 71 ] := 'G' ;
  xchr [ 72 ] := 'H' ;
  xchr [ 73 ] := 'I' ;
  xchr [ 74 ] := 'J' ;
  xchr [ 75 ] := 'K' ;
  xchr [ 76 ] := 'L' ;
  xchr [ 77 ] := 'M' ;
  xchr [ 78 ] := 'N' ;
  xchr [ 79 ] := 'O' ;
  xchr [ 80 ] := 'P' ;
  xchr [ 81 ] := 'Q' ;
  xchr [ 82 ] := 'R' ;
  xchr [ 83 ] := 'S' ;
  xchr [ 84 ] := 'T' ;
  xchr [ 85 ] := 'U' ;
  xchr [ 86 ] := 'V' ;
  xchr [ 87 ] := 'W' ;
  xchr [ 88 ] := 'X' ;
  xchr [ 89 ] := 'Y' ;
  xchr [ 90 ] := 'Z' ;
  xchr [ 91 ] := '[' ;
  xchr [ 92 ] := '\' ;
  xchr [ 93 ] := ']' ;
  xchr [ 94 ] := '^' ;
  xchr [ 95 ] := '_' ;
  xchr [ 96 ] := '`' ;
  xchr [ 97 ] := 'a' ;
  xchr [ 98 ] := 'b' ;
  xchr [ 99 ] := 'c' ;
  xchr [ 100 ] := 'd' ;
  xchr [ 101 ] := 'e' ;
  xchr [ 102 ] := 'f' ;
  xchr [ 103 ] := 'g' ;
  xchr [ 104 ] := 'h' ;
  xchr [ 105 ] := 'i' ;
  xchr [ 106 ] := 'j' ;
  xchr [ 107 ] := 'k' ;
  xchr [ 108 ] := 'l' ;
  xchr [ 109 ] := 'm' ;
  xchr [ 110 ] := 'n' ;
  xchr [ 111 ] := 'o' ;
  xchr [ 112 ] := 'p' ;
  xchr [ 113 ] := 'q' ;
  xchr [ 114 ] := 'r' ;
  xchr [ 115 ] := 's' ;
  xchr [ 116 ] := 't' ;
  xchr [ 117 ] := 'u' ;
  xchr [ 118 ] := 'v' ;
  xchr [ 119 ] := 'w' ;
  xchr [ 120 ] := 'x' ;
  xchr [ 121 ] := 'y' ;
  xchr [ 122 ] := 'z' ;
  xchr [ 123 ] := '{' ;
  xchr [ 124 ] := '|' ;
  xchr [ 125 ] := '}' ;
  xchr [ 126 ] := '~' ;
  xchr [ 0 ] := ' ' ;
  xchr [ 127 ] := ' ' ;
  For i := 1 To 31 Do
    xchr [ i ] := ' ' ;
  For i := 128 To 255 Do
    xchr [ i ] := ' ' ;
  For i := 0 To 255 Do
    xord [ chr ( i ) ] := 32 ;
  For i := 1 To 255 Do
    xord [ xchr [ i ] ] := i ;
  xord [ ' ' ] := 32 ;
  rewrite ( termout , 'TTY:' ) ;
  rewrite ( Pascalfile ) ;
  rewrite ( pool ) ;
  For wi := 0 To 1 Do
    Begin
      bytestart [ wi ] := 0 ;
      byteptr [ wi ] := 0 ;
    End ;
  bytestart [ 2 ] := 0 ;
  nameptr := 1 ;
  stringptr := 256 ;
  poolchecksum := 271828 ;
  For zi := 0 To 2 Do
    Begin
      tokstart [ zi ] := 0 ;
      tokptr [ zi ] := 0 ;
    End ;
  tokstart [ 3 ] := 0 ;
  textptr := 1 ;
  z := 1 Mod 3 ;
  ilk [ 0 ] := 0 ;
  equiv [ 0 ] := 0 ;
  For h := 0 To hashsize - 1 Do
    Begin
      hash [ h ] := 0 ;
      chophash [ h ] := 0 ;
    End ;
  lastunnamed := 0 ;
  textlink [ 0 ] := 0 ;
  scanninghex := false ;
  modtext [ 0 ] := 32 ;
End ;
Procedure openinput ;
Begin
  reset ( webfile ) ;
  reset ( changefile ) ;
End ;
Function inputln ( Var f : textfile ) : boolean ;

Var finallimit : 0 .. bufsize ;
Begin
  limit := 0 ;
  finallimit := 0 ;
  If eof ( f ) Then inputln := false
  Else
    Begin
      While Not eoln ( f ) Do
        Begin
          buffer [ limit ] := xord [ f ^ ] ;
          get ( f ) ;
          limit := limit + 1 ;
          If buffer [ limit - 1 ] <> 32 Then finallimit := limit ;
          If limit = bufsize Then
            Begin
              While Not eoln ( f ) Do
                get ( f ) ;
              limit := limit - 1 ;
              If finallimit > limit Then finallimit := limit ;
              Begin
                writeln ( termout ) ;
                write ( termout , '! Input line too long' ) ;
              End ;
              loc := 0 ;
              error ;
            End ;
        End ;
      readln ( f ) ;
      limit := finallimit ;
      inputln := true ;
    End ;
End ;
Procedure printid ( p : namepointer ) ;

Var k : 0 .. maxbytes ;
  w : 0 .. 1 ;
Begin
  If p >= nameptr Then write ( termout , 'IMPOSSIBLE' )
  Else
    Begin
      w := p Mod 2 ;
      For k := bytestart [ p ] To bytestart [ p + 2 ] - 1 Do
        write ( termout , xchr [ bytemem [ w , k ] ] ) ;
    End ;
End ;
Function idlookup ( t : eightbits ) : namepointer ;

Label 31 , 32 ;

Var c : eightbits ;
  i : 0 .. bufsize ;
  h : 0 .. hashsize ;
  k : 0 .. maxbytes ;
  w : 0 .. 1 ;
  l : 0 .. bufsize ;
  p , q : namepointer ;
  s : 0 .. unambiglength ;
Begin
  l := idloc - idfirst ;
  h := buffer [ idfirst ] ;
  i := idfirst + 1 ;
  While i < idloc Do
    Begin
      h := ( h + h + buffer [ i ] ) Mod hashsize ;
      i := i + 1 ;
    End ;
  p := hash [ h ] ;
  While p <> 0 Do
    Begin
      If bytestart [ p + 2 ] - bytestart [ p ] = l Then
        Begin
          i := idfirst ;
          k := bytestart [ p ] ;
          w := p Mod 2 ;
          While ( i < idloc ) And ( buffer [ i ] = bytemem [ w , k ] ) Do
            Begin
              i := i + 1 ;
              k := k + 1 ;
            End ;
          If i = idloc Then goto 31 ;
        End ;
      p := link [ p ] ;
    End ;
  p := nameptr ;
  link [ p ] := hash [ h ] ;
  hash [ h ] := p ;
  31 : ;
  If ( p = nameptr ) Or ( t <> 0 ) Then
    Begin
      If ( ( p <> nameptr ) And ( t <> 0 ) And ( ilk [ p ] = 0 ) ) Or ( ( p = nameptr ) And ( t = 0 ) And ( buffer [ idfirst ] <> 34 ) ) Then
        Begin
          i := idfirst ;
          s := 0 ;
          h := 0 ;
          While ( i < idloc ) And ( s < unambiglength ) Do
            Begin
              If buffer [ i ] <> 95 Then
                Begin
                  If buffer [ i ] >= 97 Then choppedid [ s ] := buffer [ i ] - 32
                  Else choppedid [ s ] := buffer [ i ] ;
                  h := ( h + h + choppedid [ s ] ) Mod hashsize ;
                  s := s + 1 ;
                End ;
              i := i + 1 ;
            End ;
          choppedid [ s ] := 0 ;
        End ;
      If p <> nameptr Then
        Begin
          If ilk [ p ] = 0 Then
            Begin
              If t = 1 Then
                Begin
                  writeln ( termout ) ;
                  write ( termout , '! This identifier has already appeared' ) ;
                  error ;
                End ;
              q := chophash [ h ] ;
              If q = p Then chophash [ h ] := equiv [ p ]
              Else
                Begin
                  While equiv [ q ] <> p Do
                    q := equiv [ q ] ;
                  equiv [ q ] := equiv [ p ] ;
                End ;
            End
          Else
            Begin
              writeln ( termout ) ;
              write ( termout , '! This identifier was defined before' ) ;
              error ;
            End ;
          ilk [ p ] := t ;
        End
      Else
        Begin
          If ( t = 0 ) And ( buffer [ idfirst ] <> 34 ) Then
            Begin
              q := chophash [ h ] ;
              While q <> 0 Do
                Begin
                  Begin
                    k := bytestart [ q ] ;
                    s := 0 ;
                    w := q Mod 2 ;
                    While ( k < bytestart [ q + 2 ] ) And ( s < unambiglength ) Do
                      Begin
                        c := bytemem [ w , k ] ;
                        If c <> 95 Then
                          Begin
                            If c >= 97 Then c := c - 32 ;
                            If choppedid [ s ] <> c Then goto 32 ;
                            s := s + 1 ;
                          End ;
                        k := k + 1 ;
                      End ;
                    If ( k = bytestart [ q + 2 ] ) And ( choppedid [ s ] <> 0 ) Then goto 32 ;
                    Begin
                      writeln ( termout ) ;
                      write ( termout , '! Identifier conflict with ' ) ;
                    End ;
                    For k := bytestart [ q ] To bytestart [ q + 2 ] - 1 Do
                      write ( termout , xchr [ bytemem [ w , k ] ] ) ;
                    error ;
                    q := 0 ;
                    32 :
                  End ;
                  q := equiv [ q ] ;
                End ;
              equiv [ p ] := chophash [ h ] ;
              chophash [ h ] := p ;
            End ;
          w := nameptr Mod 2 ;
          k := byteptr [ w ] ;
          If k + l > maxbytes Then
            Begin
              writeln ( termout ) ;
              write ( termout , '! Sorry, ' , 'byte memory' , ' capacity exceeded' ) ;
              error ;
              history := 3 ;
              jumpout ;
            End ;
          If nameptr > maxnames - 2 Then
            Begin
              writeln ( termout ) ;
              write ( termout , '! Sorry, ' , 'name' , ' capacity exceeded' ) ;
              error ;
              history := 3 ;
              jumpout ;
            End ;
          i := idfirst ;
          While i < idloc Do
            Begin
              bytemem [ w , k ] := buffer [ i ] ;
              k := k + 1 ;
              i := i + 1 ;
            End ;
          byteptr [ w ] := k ;
          bytestart [ nameptr + 2 ] := k ;
          nameptr := nameptr + 1 ;
          If buffer [ idfirst ] <> 34 Then ilk [ p ] := t
          Else
            Begin
              ilk [ p ] := 1 ;
              If l - doublechars = 2 Then equiv [ p ] := buffer [ idfirst + 1 ] + 32768
              Else
                Begin
                  equiv [ p ] := stringptr + 32768 ;
                  l := l - doublechars - 1 ;
                  If l > 99 Then
                    Begin
                      writeln ( termout ) ;
                      write ( termout , '! Preprocessed string is too long' ) ;
                      error ;
                    End ;
                  stringptr := stringptr + 1 ;
                  write ( pool , xchr [ 48 + l Div 10 ] , xchr [ 48 + l Mod 10 ] ) ;
                  poolchecksum := poolchecksum + poolchecksum + l ;
                  While poolchecksum > 536870839 Do
                    poolchecksum := poolchecksum - 536870839 ;
                  i := idfirst + 1 ;
                  While i < idloc Do
                    Begin
                      write ( pool , xchr [ buffer [ i ] ] ) ;
                      poolchecksum := poolchecksum + poolchecksum + buffer [ i ] ;
                      While poolchecksum > 536870839 Do
                        poolchecksum := poolchecksum - 536870839 ;
                      If ( buffer [ i ] = 34 ) Or ( buffer [ i ] = 64 ) Then i := i + 2
                      Else i := i + 1 ;
                    End ;
                  writeln ( pool ) ;
                End ;
            End ;
        End ;
    End ;
  idlookup := p ;
End ;
Function modlookup ( l : sixteenbits ) : namepointer ;

Label 31 ;

Var c : 0 .. 4 ;
  j : 0 .. longestname ;
  k : 0 .. maxbytes ;
  w : 0 .. 1 ;
  p : namepointer ;
  q : namepointer ;
Begin
  c := 2 ;
  q := 0 ;
  p := ilk [ 0 ] ;
  While p <> 0 Do
    Begin
      Begin
        k := bytestart [ p ] ;
        w := p Mod 2 ;
        c := 1 ;
        j := 1 ;
        While ( k < bytestart [ p + 2 ] ) And ( j <= l ) And ( modtext [ j ] = bytemem [ w , k ] ) Do
          Begin
            k := k + 1 ;
            j := j + 1 ;
          End ;
        If k = bytestart [ p + 2 ] Then If j > l Then c := 1
        Else c := 4
        Else If j > l Then c := 3
        Else If modtext [ j ] < bytemem [ w , k ] Then c := 0
        Else c := 2 ;
      End ;
      q := p ;
      If c = 0 Then p := link [ q ]
      Else If c = 2 Then p := ilk [ q ]
      Else goto 31 ;
    End ;
  w := nameptr Mod 2 ;
  k := byteptr [ w ] ;
  If k + l > maxbytes Then
    Begin
      writeln ( termout ) ;
      write ( termout , '! Sorry, ' , 'byte memory' , ' capacity exceeded' ) ;
      error ;
      history := 3 ;
      jumpout ;
    End ;
  If nameptr > maxnames - 2 Then
    Begin
      writeln ( termout ) ;
      write ( termout , '! Sorry, ' , 'name' , ' capacity exceeded' ) ;
      error ;
      history := 3 ;
      jumpout ;
    End ;
  p := nameptr ;
  If c = 0 Then link [ q ] := p
  Else ilk [ q ] := p ;
  link [ p ] := 0 ;
  ilk [ p ] := 0 ;
  c := 1 ;
  equiv [ p ] := 0 ;
  For j := 1 To l Do
    bytemem [ w , k + j - 1 ] := modtext [ j ] ;
  byteptr [ w ] := k + l ;
  bytestart [ nameptr + 2 ] := k + l ;
  nameptr := nameptr + 1 ; ;
  31 : If c <> 1 Then
         Begin
           Begin
             writeln ( termout ) ;
             write ( termout , '! Incompatible section names' ) ;
             error ;
           End ;
           p := 0 ;
         End ;
  modlookup := p ;
End ;
Function prefixlookup ( l : sixteenbits ) : namepointer ;

Var c : 0 .. 4 ;
  count : 0 .. maxnames ;
  j : 0 .. longestname ;
  k : 0 .. maxbytes ;
  w : 0 .. 1 ;
  p : namepointer ;
  q : namepointer ;
  r : namepointer ;
Begin
  q := 0 ;
  p := ilk [ 0 ] ;
  count := 0 ;
  r := 0 ;
  While p <> 0 Do
    Begin
      Begin
        k := bytestart [ p ] ;
        w := p Mod 2 ;
        c := 1 ;
        j := 1 ;
        While ( k < bytestart [ p + 2 ] ) And ( j <= l ) And ( modtext [ j ] = bytemem [ w , k ] ) Do
          Begin
            k := k + 1 ;
            j := j + 1 ;
          End ;
        If k = bytestart [ p + 2 ] Then If j > l Then c := 1
        Else c := 4
        Else If j > l Then c := 3
        Else If modtext [ j ] < bytemem [ w , k ] Then c := 0
        Else c := 2 ;
      End ;
      If c = 0 Then p := link [ p ]
      Else If c = 2 Then p := ilk [ p ]
      Else
        Begin
          r := p ;
          count := count + 1 ;
          q := ilk [ p ] ;
          p := link [ p ] ;
        End ;
      If p = 0 Then
        Begin
          p := q ;
          q := 0 ;
        End ;
    End ;
  If count <> 1 Then If count = 0 Then
                       Begin
                         writeln ( termout ) ;
                         write ( termout , '! Name does not match' ) ;
                         error ;
                       End
  Else
    Begin
      writeln ( termout ) ;
      write ( termout , '! Ambiguous prefix' ) ;
      error ;
    End ;
  prefixlookup := r ;
End ;
Procedure storetwobytes ( x : sixteenbits ) ;
Begin
  If tokptr [ z ] + 2 > maxtoks Then
    Begin
      writeln ( termout ) ;
      write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
      error ;
      history := 3 ;
      jumpout ;
    End ;
  tokmem [ z , tokptr [ z ] ] := x Div 256 ;
  tokmem [ z , tokptr [ z ] + 1 ] := x Mod 256 ;
  tokptr [ z ] := tokptr [ z ] + 2 ;
End ;
Procedure pushlevel ( p : namepointer ) ;
Begin
  If stackptr = stacksize Then
    Begin
      writeln ( termout ) ;
      write ( termout , '! Sorry, ' , 'stack' , ' capacity exceeded' ) ;
      error ;
      history := 3 ;
      jumpout ;
    End
  Else
    Begin
      stack [ stackptr ] := curstate ;
      stackptr := stackptr + 1 ;
      curstate . namefield := p ;
      curstate . replfield := equiv [ p ] ;
      zo := curstate . replfield Mod 3 ;
      curstate . bytefield := tokstart [ curstate . replfield ] ;
      curstate . endfield := tokstart [ curstate . replfield + 3 ] ;
      curstate . modfield := 0 ;
    End ;
End ;
Procedure poplevel ;

Label 10 ;
Begin
  If textlink [ curstate . replfield ] = 0 Then
    Begin
      If ilk [ curstate . namefield ] = 3 Then
        Begin
          nameptr := nameptr - 1 ;
          textptr := textptr - 1 ;
          z := textptr Mod 3 ;
          tokptr [ z ] := tokstart [ textptr ] ;
        End ;
    End
  Else If textlink [ curstate . replfield ] < maxtexts Then
         Begin
           curstate . replfield := textlink [ curstate . replfield ] ;
           zo := curstate . replfield Mod 3 ;
           curstate . bytefield := tokstart [ curstate . replfield ] ;
           curstate . endfield := tokstart [ curstate . replfield + 3 ] ;
           goto 10 ;
         End ;
  stackptr := stackptr - 1 ;
  If stackptr > 0 Then
    Begin
      curstate := stack [ stackptr ] ;
      zo := curstate . replfield Mod 3 ;
    End ;
  10 :
End ;
Function getoutput : sixteenbits ;

Label 20 , 30 , 31 ;

Var a : sixteenbits ;
  b : eightbits ;
  bal : sixteenbits ;
  k : 0 .. maxbytes ;
  w : 0 .. 1 ;
Begin
  20 : If stackptr = 0 Then
         Begin
           a := 0 ;
           goto 31 ;
         End ;
  If curstate . bytefield = curstate . endfield Then
    Begin
      curval := - curstate . modfield ;
      poplevel ;
      If curval = 0 Then goto 20 ;
      a := 129 ;
      goto 31 ;
    End ;
  a := tokmem [ zo , curstate . bytefield ] ;
  curstate . bytefield := curstate . bytefield + 1 ;
  If a < 128 Then If a = 0 Then
                    Begin
                      pushlevel ( nameptr - 1 ) ;
                      goto 20 ;
                    End
  Else goto 31 ;
  a := ( a - 128 ) * 256 + tokmem [ zo , curstate . bytefield ] ;
  curstate . bytefield := curstate . bytefield + 1 ;
  If a < 10240 Then
    Begin
      Case ilk [ a ] Of 
        0 :
            Begin
              curval := a ;
              a := 130 ;
            End ;
        1 :
            Begin
              curval := equiv [ a ] - 32768 ;
              a := 128 ;
            End ;
        2 :
            Begin
              pushlevel ( a ) ;
              goto 20 ;
            End ;
        3 :
            Begin
              While ( curstate . bytefield = curstate . endfield ) And ( stackptr > 0 ) Do
                poplevel ;
              If ( stackptr = 0 ) Or ( tokmem [ zo , curstate . bytefield ] <> 40 ) Then
                Begin
                  Begin
                    writeln ( termout ) ;
                    write ( termout , '! No parameter given for ' ) ;
                  End ;
                  printid ( a ) ;
                  error ;
                  goto 20 ;
                End ;
              bal := 1 ;
              curstate . bytefield := curstate . bytefield + 1 ;
              While true Do
                Begin
                  b := tokmem [ zo , curstate . bytefield ] ;
                  curstate . bytefield := curstate . bytefield + 1 ;
                  If b = 0 Then storetwobytes ( nameptr + 32767 )
                  Else
                    Begin
                      If b >= 128 Then
                        Begin
                          Begin
                            If tokptr [ z ] = maxtoks Then
                              Begin
                                writeln ( termout ) ;
                                write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
                                error ;
                                history := 3 ;
                                jumpout ;
                              End ;
                            tokmem [ z , tokptr [ z ] ] := b ;
                            tokptr [ z ] := tokptr [ z ] + 1 ;
                          End ;
                          b := tokmem [ zo , curstate . bytefield ] ;
                          curstate . bytefield := curstate . bytefield + 1 ;
                        End
                      Else Case b Of 
                             40 : bal := bal + 1 ;
                             41 :
                                  Begin
                                    bal := bal - 1 ;
                                    If bal = 0 Then goto 30 ;
                                  End ;
                             39 : Repeat
                                    Begin
                                      If tokptr [ z ] = maxtoks Then
                                        Begin
                                          writeln ( termout ) ;
                                          write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
                                          error ;
                                          history := 3 ;
                                          jumpout ;
                                        End ;
                                      tokmem [ z , tokptr [ z ] ] := b ;
                                      tokptr [ z ] := tokptr [ z ] + 1 ;
                                    End ;
                                    b := tokmem [ zo , curstate . bytefield ] ;
                                    curstate . bytefield := curstate . bytefield + 1 ;
                                  Until b = 39 ;
                             others :
                        End ;
                      Begin
                        If tokptr [ z ] = maxtoks Then
                          Begin
                            writeln ( termout ) ;
                            write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
                            error ;
                            history := 3 ;
                            jumpout ;
                          End ;
                        tokmem [ z , tokptr [ z ] ] := b ;
                        tokptr [ z ] := tokptr [ z ] + 1 ;
                      End ;
                    End ;
                End ;
              30 : ;
              equiv [ nameptr ] := textptr ;
              ilk [ nameptr ] := 2 ;
              w := nameptr Mod 2 ;
              k := byteptr [ w ] ;
              If nameptr > maxnames - 2 Then
                Begin
                  writeln ( termout ) ;
                  write ( termout , '! Sorry, ' , 'name' , ' capacity exceeded' ) ;
                  error ;
                  history := 3 ;
                  jumpout ;
                End ;
              bytestart [ nameptr + 2 ] := k ;
              nameptr := nameptr + 1 ;
              If textptr > maxtexts - 3 Then
                Begin
                  writeln ( termout ) ;
                  write ( termout , '! Sorry, ' , 'text' , ' capacity exceeded' ) ;
                  error ;
                  history := 3 ;
                  jumpout ;
                End ;
              textlink [ textptr ] := 0 ;
              tokstart [ textptr + 3 ] := tokptr [ z ] ;
              textptr := textptr + 1 ;
              z := textptr Mod 3 ;
              pushlevel ( a ) ;
              goto 20 ;
            End ;
        others :
                 Begin
                   writeln ( termout ) ;
                   write ( termout , '! This can''t happen (' , 'output' , ')' ) ;
                   error ;
                   history := 3 ;
                   jumpout ;
                 End
      End ;
      goto 31 ;
    End ;
  If a < 20480 Then
    Begin
      a := a - 10240 ;
      If equiv [ a ] <> 0 Then pushlevel ( a )
      Else If a <> 0 Then
             Begin
               Begin
                 writeln ( termout ) ;
                 write ( termout , '! Not present: <' ) ;
               End ;
               printid ( a ) ;
               write ( termout , '>' ) ;
               error ;
             End ;
      goto 20 ;
    End ;
  curval := a - 20480 ;
  a := 129 ;
  curstate . modfield := curval ;
  31 : getoutput := a ;
End ;
Procedure flushbuffer ;

Var k : 0 .. outbufsize ;
  b : 0 .. outbufsize ;
Begin
  b := breakptr ;
  If ( semiptr <> 0 ) And ( outptr - semiptr <= linelength ) Then breakptr := semiptr ;
  For k := 1 To breakptr Do
    write ( Pascalfile , xchr [ outbuf [ k - 1 ] ] ) ;
  writeln ( Pascalfile ) ;
  line := line + 1 ;
  If line Mod 100 = 0 Then
    Begin
      write ( termout , '.' ) ;
      If line Mod 500 = 0 Then write ( termout , line : 1 ) ;
      break ( termout ) ;
    End ;
  If breakptr < outptr Then
    Begin
      If outbuf [ breakptr ] = 32 Then
        Begin
          breakptr := breakptr + 1 ;
          If breakptr > b Then b := breakptr ;
        End ;
      For k := breakptr To outptr - 1 Do
        outbuf [ k - breakptr ] := outbuf [ k ] ;
    End ;
  outptr := outptr - breakptr ;
  breakptr := b - breakptr ;
  semiptr := 0 ;
  If outptr > linelength Then
    Begin
      Begin
        writeln ( termout ) ;
        write ( termout , '! Long line must be truncated' ) ;
        error ;
      End ;
      outptr := linelength ;
    End ;
End ;
Procedure appval ( v : integer ) ;

Var k : 0 .. outbufsize ;
Begin
  k := outbufsize ;
  Repeat
    outbuf [ k ] := v Mod 10 ;
    v := v Div 10 ;
    k := k - 1 ;
  Until v = 0 ;
  Repeat
    k := k + 1 ;
    Begin
      outbuf [ outptr ] := outbuf [ k ] + 48 ;
      outptr := outptr + 1 ;
    End ;
  Until k = outbufsize ;
End ;
Procedure sendout ( t : eightbits ; v : sixteenbits ) ;

Label 20 ;

Var k : 0 .. linelength ;
Begin
  20 : Case outstate Of 
         1 : If t <> 3 Then
               Begin
                 breakptr := outptr ;
                 If t = 2 Then
                   Begin
                     outbuf [ outptr ] := 32 ;
                     outptr := outptr + 1 ;
                   End ;
               End ;
         2 :
             Begin
               Begin
                 outbuf [ outptr ] := 44 - outapp ;
                 outptr := outptr + 1 ;
               End ;
               If outptr > linelength Then flushbuffer ;
               breakptr := outptr ;
             End ;
         3 , 4 :
                 Begin
                   If ( outval < 0 ) Or ( ( outval = 0 ) And ( lastsign < 0 ) ) Then
                     Begin
                       outbuf [ outptr ] := 45 ;
                       outptr := outptr + 1 ;
                     End
                   Else If outsign > 0 Then
                          Begin
                            outbuf [ outptr ] := outsign ;
                            outptr := outptr + 1 ;
                          End ;
                   appval ( abs ( outval ) ) ;
                   If outptr > linelength Then flushbuffer ; ;
                   outstate := outstate - 2 ;
                   goto 20 ;
                 End ;
         5 :
             Begin
               If ( t = 3 ) Or ( ( ( t = 2 ) And ( v = 3 ) And ( ( ( outcontrib [ 1 ] = 68 ) And ( outcontrib [ 2 ] = 73 ) And ( outcontrib [ 3 ] = 86 ) ) Or ( ( outcontrib [ 1 ] = 77 ) And ( outcontrib [ 2 ] = 79 ) And ( outcontrib [ 3 ] = 68 ) ) ) ) Or ( ( t = 0 ) And ( ( v = 42 ) Or ( v = 47 ) ) ) ) Then
                 Begin
                   If ( outval < 0 ) Or ( ( outval = 0 ) And ( lastsign < 0 ) ) Then
                     Begin
                       outbuf [ outptr ] := 45 ;
                       outptr := outptr + 1 ;
                     End
                   Else If outsign > 0 Then
                          Begin
                            outbuf [ outptr ] := outsign ;
                            outptr := outptr + 1 ;
                          End ;
                   appval ( abs ( outval ) ) ;
                   If outptr > linelength Then flushbuffer ; ;
                   outsign := 43 ;
                   outval := outapp ;
                 End
               Else outval := outval + outapp ;
               outstate := 3 ;
               goto 20 ;
             End ;
         0 : If t <> 3 Then breakptr := outptr ;
         others :
       End ;
  If t <> 0 Then For k := 1 To v Do
                   Begin
                     outbuf [ outptr ] := outcontrib [ k ] ;
                     outptr := outptr + 1 ;
                   End
                   Else
                     Begin
                       outbuf [ outptr ] := v ;
                       outptr := outptr + 1 ;
                     End ;
  If outptr > linelength Then flushbuffer ;
  If ( t = 0 ) And ( ( v = 59 ) Or ( v = 125 ) ) Then
    Begin
      semiptr := outptr ;
      breakptr := outptr ;
    End ;
  If t >= 2 Then outstate := 1
  Else outstate := 0
End ;
Procedure sendsign ( v : integer ) ;
Begin
  Case outstate Of 
    2 , 4 : outapp := outapp * v ;
    3 :
        Begin
          outapp := v ;
          outstate := 4 ;
        End ;
    5 :
        Begin
          outval := outval + outapp ;
          outapp := v ;
          outstate := 4 ;
        End ;
    others :
             Begin
               breakptr := outptr ;
               outapp := v ;
               outstate := 2 ;
             End
  End ;
  lastsign := outapp ;
End ;
Procedure sendval ( v : integer ) ;

Label 666 , 10 ;
Begin
  Case outstate Of 
    1 :
        Begin
          If ( outptr = breakptr + 3 ) Or ( ( outptr = breakptr + 4 ) And ( outbuf [ breakptr ] = 32 ) ) Then If ( ( outbuf [ outptr - 3 ] = 68 ) And ( outbuf [ outptr - 2 ] = 73 ) And ( outbuf [ outptr - 1 ] = 86 ) ) Or ( ( outbuf [ outptr - 3 ] = 77 ) And ( outbuf [ outptr - 2 ] = 79 ) And ( outbuf [ outptr - 1 ] = 68 ) ) Then goto 666 ;
          outsign := 32 ;
          outstate := 3 ;
          outval := v ;
          breakptr := outptr ;
          lastsign := + 1 ;
        End ;
    0 :
        Begin
          If ( outptr = breakptr + 1 ) And ( ( outbuf [ breakptr ] = 42 ) Or ( outbuf [ breakptr ] = 47 ) ) Then goto 666 ;
          outsign := 0 ;
          outstate := 3 ;
          outval := v ;
          breakptr := outptr ;
          lastsign := + 1 ;
        End ;
    2 :
        Begin
          outsign := 43 ;
          outstate := 3 ;
          outval := outapp * v ;
        End ;
    3 :
        Begin
          outstate := 5 ;
          outapp := v ;
          Begin
            writeln ( termout ) ;
            write ( termout , '! Two numbers occurred without a sign between them' ) ;
            error ;
          End ;
        End ;
    4 :
        Begin
          outstate := 5 ;
          outapp := outapp * v ;
        End ;
    5 :
        Begin
          outval := outval + outapp ;
          outapp := v ;
          Begin
            writeln ( termout ) ;
            write ( termout , '! Two numbers occurred without a sign between them' ) ;
            error ;
          End ;
        End ;
    others : goto 666
  End ;
  goto 10 ;
  666 : If v >= 0 Then
          Begin
            If outstate = 1 Then
              Begin
                breakptr := outptr ;
                Begin
                  outbuf [ outptr ] := 32 ;
                  outptr := outptr + 1 ;
                End ;
              End ;
            appval ( v ) ;
            If outptr > linelength Then flushbuffer ;
            outstate := 1 ;
          End
        Else
          Begin
            Begin
              outbuf [ outptr ] := 40 ;
              outptr := outptr + 1 ;
            End ;
            Begin
              outbuf [ outptr ] := 45 ;
              outptr := outptr + 1 ;
            End ;
            appval ( - v ) ;
            Begin
              outbuf [ outptr ] := 41 ;
              outptr := outptr + 1 ;
            End ;
            If outptr > linelength Then flushbuffer ;
            outstate := 0 ;
          End ;
  10 :
End ;
Procedure sendtheoutput ;

Label 2 , 21 , 22 ;

Var curchar : eightbits ;
  k : 0 .. linelength ;
  j : 0 .. maxbytes ;
  w : 0 .. 1 ;
  n : integer ;
Begin
  While stackptr > 0 Do
    Begin
      curchar := getoutput ;
      21 : Case curchar Of 
             0 : ;
             65 , 66 , 67 , 68 , 69 , 70 , 71 , 72 , 73 , 74 , 75 , 76 , 77 , 78 , 79 , 80 , 81 , 82 , 83 , 84 , 85 , 86 , 87 , 88 , 89 , 90 :
                                                                                                                                               Begin
                                                                                                                                                 outcontrib [ 1 ] := curchar ;
                                                                                                                                                 sendout ( 2 , 1 ) ;
                                                                                                                                               End ;
             97 , 98 , 99 , 100 , 101 , 102 , 103 , 104 , 105 , 106 , 107 , 108 , 109 , 110 , 111 , 112 , 113 , 114 , 115 , 116 , 117 , 118 , 119 , 120 , 121 , 122 :
                                                                                                                                                                      Begin
                                                                                                                                                                        outcontrib [ 1 ] := curchar - 32 ;
                                                                                                                                                                        sendout ( 2 , 1 ) ;
                                                                                                                                                                      End ;
             130 :
                   Begin
                     k := 0 ;
                     j := bytestart [ curval ] ;
                     w := curval Mod 2 ;
                     While ( k < maxidlength ) And ( j < bytestart [ curval + 2 ] ) Do
                       Begin
                         k := k + 1 ;
                         outcontrib [ k ] := bytemem [ w , j ] ;
                         j := j + 1 ;
                         If outcontrib [ k ] >= 97 Then outcontrib [ k ] := outcontrib [ k ] - 32
                         Else If outcontrib [ k ] = 95 Then k := k - 1 ;
                       End ;
                     sendout ( 2 , k ) ;
                   End ;
             48 , 49 , 50 , 51 , 52 , 53 , 54 , 55 , 56 , 57 :
                                                               Begin
                                                                 n := 0 ;
                                                                 Repeat
                                                                   curchar := curchar - 48 ;
                                                                   If n >= 214748364 Then
                                                                     Begin
                                                                       writeln ( termout ) ;
                                                                       write ( termout , '! Constant too big' ) ;
                                                                       error ;
                                                                     End
                                                                   Else n := 10 * n + curchar ;
                                                                   curchar := getoutput ;
                                                                 Until ( curchar > 57 ) Or ( curchar < 48 ) ;
                                                                 sendval ( n ) ;
                                                                 k := 0 ;
                                                                 If curchar = 101 Then curchar := 69 ;
                                                                 If curchar = 69 Then goto 2
                                                                 Else goto 21 ;
                                                               End ;
             125 : sendval ( poolchecksum ) ;
             12 :
                  Begin
                    n := 0 ;
                    curchar := 48 ;
                    Repeat
                      curchar := curchar - 48 ;
                      If n >= 268435456 Then
                        Begin
                          writeln ( termout ) ;
                          write ( termout , '! Constant too big' ) ;
                          error ;
                        End
                      Else n := 8 * n + curchar ;
                      curchar := getoutput ;
                    Until ( curchar > 55 ) Or ( curchar < 48 ) ;
                    sendval ( n ) ;
                    goto 21 ;
                  End ;
             13 :
                  Begin
                    n := 0 ;
                    curchar := 48 ;
                    Repeat
                      If curchar >= 65 Then curchar := curchar - 55
                      Else curchar := curchar - 48 ;
                      If n >= 134217728 Then
                        Begin
                          writeln ( termout ) ;
                          write ( termout , '! Constant too big' ) ;
                          error ;
                        End
                      Else n := 16 * n + curchar ;
                      curchar := getoutput ;
                    Until ( curchar > 70 ) Or ( curchar < 48 ) Or ( ( curchar > 57 ) And ( curchar < 65 ) ) ;
                    sendval ( n ) ;
                    goto 21 ;
                  End ;
             128 : sendval ( curval ) ;
             46 :
                  Begin
                    k := 1 ;
                    outcontrib [ 1 ] := 46 ;
                    curchar := getoutput ;
                    If curchar = 46 Then
                      Begin
                        outcontrib [ 2 ] := 46 ;
                        sendout ( 1 , 2 ) ;
                      End
                    Else If ( curchar >= 48 ) And ( curchar <= 57 ) Then goto 2
                    Else
                      Begin
                        sendout ( 0 , 46 ) ;
                        goto 21 ;
                      End ;
                  End ;
             43 , 45 : sendsign ( 44 - curchar ) ;
             4 :
                 Begin
                   outcontrib [ 1 ] := 65 ;
                   outcontrib [ 2 ] := 78 ;
                   outcontrib [ 3 ] := 68 ;
                   sendout ( 2 , 3 ) ;
                 End ;
             5 :
                 Begin
                   outcontrib [ 1 ] := 78 ;
                   outcontrib [ 2 ] := 79 ;
                   outcontrib [ 3 ] := 84 ;
                   sendout ( 2 , 3 ) ;
                 End ;
             6 :
                 Begin
                   outcontrib [ 1 ] := 73 ;
                   outcontrib [ 2 ] := 78 ;
                   sendout ( 2 , 2 ) ;
                 End ;
             31 :
                  Begin
                    outcontrib [ 1 ] := 79 ;
                    outcontrib [ 2 ] := 82 ;
                    sendout ( 2 , 2 ) ;
                  End ;
             24 :
                  Begin
                    outcontrib [ 1 ] := 58 ;
                    outcontrib [ 2 ] := 61 ;
                    sendout ( 1 , 2 ) ;
                  End ;
             26 :
                  Begin
                    outcontrib [ 1 ] := 60 ;
                    outcontrib [ 2 ] := 62 ;
                    sendout ( 1 , 2 ) ;
                  End ;
             28 :
                  Begin
                    outcontrib [ 1 ] := 60 ;
                    outcontrib [ 2 ] := 61 ;
                    sendout ( 1 , 2 ) ;
                  End ;
             29 :
                  Begin
                    outcontrib [ 1 ] := 62 ;
                    outcontrib [ 2 ] := 61 ;
                    sendout ( 1 , 2 ) ;
                  End ;
             30 :
                  Begin
                    outcontrib [ 1 ] := 61 ;
                    outcontrib [ 2 ] := 61 ;
                    sendout ( 1 , 2 ) ;
                  End ;
             32 :
                  Begin
                    outcontrib [ 1 ] := 46 ;
                    outcontrib [ 2 ] := 46 ;
                    sendout ( 1 , 2 ) ;
                  End ;
             39 :
                  Begin
                    k := 1 ;
                    outcontrib [ 1 ] := 39 ;
                    Repeat
                      If k < linelength Then k := k + 1 ;
                      outcontrib [ k ] := getoutput ;
                    Until ( outcontrib [ k ] = 39 ) Or ( stackptr = 0 ) ;
                    If k = linelength Then
                      Begin
                        writeln ( termout ) ;
                        write ( termout , '! String too long' ) ;
                        error ;
                      End ;
                    sendout ( 1 , k ) ;
                    curchar := getoutput ;
                    If curchar = 39 Then outstate := 6 ;
                    goto 21 ;
                  End ;
             33 , 34 , 35 , 36 , 37 , 38 , 40 , 41 , 42 , 44 , 47 , 58 , 59 , 60 , 61 , 62 , 63 , 64 , 91 , 92 , 93 , 94 , 95 , 96 , 123 , 124 : sendout ( 0 , curchar ) ;
             9 :
                 Begin
                   If bracelevel = 0 Then sendout ( 0 , 123 )
                   Else sendout ( 0 , 91 ) ;
                   bracelevel := bracelevel + 1 ;
                 End ;
             10 : If bracelevel > 0 Then
                    Begin
                      bracelevel := bracelevel - 1 ;
                      If bracelevel = 0 Then sendout ( 0 , 125 )
                      Else sendout ( 0 , 93 ) ;
                    End
                  Else
                    Begin
                      writeln ( termout ) ;
                      write ( termout , '! Extra @}' ) ;
                      error ;
                    End ;
             129 :
                   Begin
                     k := 2 ;
                     If bracelevel = 0 Then outcontrib [ 1 ] := 123
                     Else outcontrib [ 1 ] := 91 ;
                     If curval < 0 Then
                       Begin
                         outcontrib [ k ] := 58 ;
                         curval := - curval ;
                         k := k + 1 ;
                       End ;
                     n := 10 ;
                     While curval >= n Do
                       n := 10 * n ;
                     Repeat
                       n := n Div 10 ;
                       outcontrib [ k ] := 48 + ( curval Div n ) ;
                       curval := curval Mod n ;
                       k := k + 1 ;
                     Until n = 1 ;
                     If outcontrib [ 2 ] <> 58 Then
                       Begin
                         outcontrib [ k ] := 58 ;
                         k := k + 1 ;
                       End ;
                     If bracelevel = 0 Then outcontrib [ k ] := 125
                     Else outcontrib [ k ] := 93 ;
                     sendout ( 1 , k ) ;
                   End ;
             127 :
                   Begin
                     sendout ( 3 , 0 ) ;
                     outstate := 6 ;
                   End ;
             2 :
                 Begin
                   k := 0 ;
                   Repeat
                     If k < linelength Then k := k + 1 ;
                     outcontrib [ k ] := getoutput ;
                   Until ( outcontrib [ k ] = 2 ) Or ( stackptr = 0 ) ;
                   If k = linelength Then
                     Begin
                       writeln ( termout ) ;
                       write ( termout , '! Verbatim string too long' ) ;
                       error ;
                     End ;
                   sendout ( 1 , k - 1 ) ;
                 End ;
             3 :
                 Begin
                   sendout ( 1 , 0 ) ;
                   While outptr > 0 Do
                     Begin
                       If outptr <= linelength Then breakptr := outptr ;
                       flushbuffer ;
                     End ;
                   outstate := 0 ;
                 End ;
             others :
                      Begin
                        writeln ( termout ) ;
                        write ( termout , '! Can''t output ASCII code ' , curchar : 1 ) ;
                        error ;
                      End
           End ;
      goto 22 ;
      2 : Repeat
            If k < linelength Then k := k + 1 ;
            outcontrib [ k ] := curchar ;
            curchar := getoutput ;
            If ( outcontrib [ k ] = 69 ) And ( ( curchar = 43 ) Or ( curchar = 45 ) ) Then
              Begin
                If k < linelength Then k := k + 1 ;
                outcontrib [ k ] := curchar ;
                curchar := getoutput ;
              End
            Else If curchar = 101 Then curchar := 69 ;
          Until ( curchar <> 69 ) And ( ( curchar < 48 ) Or ( curchar > 57 ) ) ;
      If k = linelength Then
        Begin
          writeln ( termout ) ;
          write ( termout , '! Fraction too long' ) ;
          error ;
        End ;
      sendout ( 3 , k ) ;
      goto 21 ;
      22 :
    End ;
End ;
Function linesdontmatch : boolean ;

Label 10 ;

Var k : 0 .. bufsize ;
Begin
  linesdontmatch := true ;
  If changelimit <> limit Then goto 10 ;
  If limit > 0 Then For k := 0 To limit - 1 Do
                      If changebuffer [ k ] <> buffer [ k ] Then goto 10 ;
  linesdontmatch := false ;
  10 :
End ;
Procedure primethechangebuffer ;

Label 22 , 30 , 10 ;

Var k : 0 .. bufsize ;
Begin
  changelimit := 0 ;
  While true Do
    Begin
      line := line + 1 ;
      If Not inputln ( changefile ) Then goto 10 ;
      If limit < 2 Then goto 22 ;
      If buffer [ 0 ] <> 64 Then goto 22 ;
      If ( buffer [ 1 ] >= 88 ) And ( buffer [ 1 ] <= 90 ) Then buffer [ 1 ] := buffer [ 1 ] + 32 ;
      If buffer [ 1 ] = 120 Then goto 30 ;
      If ( buffer [ 1 ] = 121 ) Or ( buffer [ 1 ] = 122 ) Then
        Begin
          loc := 2 ;
          Begin
            writeln ( termout ) ;
            write ( termout , '! Where is the matching @x?' ) ;
            error ;
          End ;
        End ;
      22 :
    End ;
  30 : ;
  Repeat
    line := line + 1 ;
    If Not inputln ( changefile ) Then
      Begin
        Begin
          writeln ( termout ) ;
          write ( termout , '! Change file ended after @x' ) ;
          error ;
        End ;
        goto 10 ;
      End ;
  Until limit > 0 ; ;
  Begin
    changelimit := limit ;
    If limit > 0 Then For k := 0 To limit - 1 Do
                        changebuffer [ k ] := buffer [ k ] ;
  End ;
  10 :
End ;
Procedure checkchange ;

Label 10 ;

Var n : integer ;
  k : 0 .. bufsize ;
Begin
  If linesdontmatch Then goto 10 ;
  n := 0 ;
  While true Do
    Begin
      changing := Not changing ;
      templine := otherline ;
      otherline := line ;
      line := templine ;
      line := line + 1 ;
      If Not inputln ( changefile ) Then
        Begin
          Begin
            writeln ( termout ) ;
            write ( termout , '! Change file ended before @y' ) ;
            error ;
          End ;
          changelimit := 0 ;
          changing := Not changing ;
          templine := otherline ;
          otherline := line ;
          line := templine ;
          goto 10 ;
        End ;
      If limit > 1 Then If buffer [ 0 ] = 64 Then
                          Begin
                            If ( buffer [ 1 ] >= 88 ) And ( buffer [ 1 ] <= 90 ) Then buffer [ 1 ] := buffer [ 1 ] + 32 ;
                            If ( buffer [ 1 ] = 120 ) Or ( buffer [ 1 ] = 122 ) Then
                              Begin
                                loc := 2 ;
                                Begin
                                  writeln ( termout ) ;
                                  write ( termout , '! Where is the matching @y?' ) ;
                                  error ;
                                End ;
                              End
                            Else If buffer [ 1 ] = 121 Then
                                   Begin
                                     If n > 0 Then
                                       Begin
                                         loc := 2 ;
                                         Begin
                                           writeln ( termout ) ;
                                           write ( termout , '! Hmm... ' , n : 1 , ' of the preceding lines failed to match' ) ;
                                           error ;
                                         End ;
                                       End ;
                                     goto 10 ;
                                   End ;
                          End ;
      Begin
        changelimit := limit ;
        If limit > 0 Then For k := 0 To limit - 1 Do
                            changebuffer [ k ] := buffer [ k ] ;
      End ;
      changing := Not changing ;
      templine := otherline ;
      otherline := line ;
      line := templine ;
      line := line + 1 ;
      If Not inputln ( webfile ) Then
        Begin
          Begin
            writeln ( termout ) ;
            write ( termout , '! WEB file ended during a change' ) ;
            error ;
          End ;
          inputhasended := true ;
          goto 10 ;
        End ;
      If linesdontmatch Then n := n + 1 ;
    End ;
  10 :
End ;
Procedure getline ;

Label 20 ;
Begin
  20 : If changing Then
         Begin
           line := line + 1 ;
           If Not inputln ( changefile ) Then
             Begin
               Begin
                 writeln ( termout ) ;
                 write ( termout , '! Change file ended without @z' ) ;
                 error ;
               End ;
               buffer [ 0 ] := 64 ;
               buffer [ 1 ] := 122 ;
               limit := 2 ;
             End ;
           If limit > 1 Then If buffer [ 0 ] = 64 Then
                               Begin
                                 If ( buffer [ 1 ] >= 88 ) And ( buffer [ 1 ] <= 90 ) Then buffer [ 1 ] := buffer [ 1 ] + 32 ;
                                 If ( buffer [ 1 ] = 120 ) Or ( buffer [ 1 ] = 121 ) Then
                                   Begin
                                     loc := 2 ;
                                     Begin
                                       writeln ( termout ) ;
                                       write ( termout , '! Where is the matching @z?' ) ;
                                       error ;
                                     End ;
                                   End
                                 Else If buffer [ 1 ] = 122 Then
                                        Begin
                                          primethechangebuffer ;
                                          changing := Not changing ;
                                          templine := otherline ;
                                          otherline := line ;
                                          line := templine ;
                                        End ;
                               End ;
         End ;
  If Not changing Then
    Begin
      Begin
        line := line + 1 ;
        If Not inputln ( webfile ) Then inputhasended := true
        Else If limit = changelimit Then If buffer [ 0 ] = changebuffer [ 0 ] Then If changelimit > 0 Then checkchange ;
      End ;
      If changing Then goto 20 ;
    End ;
  loc := 0 ;
  buffer [ limit ] := 32 ;
End ;
Function controlcode ( c : ASCIIcode ) : eightbits ;
Begin
  Case c Of 
    64 : controlcode := 64 ;
    39 : controlcode := 12 ;
    34 : controlcode := 13 ;
    36 : controlcode := 125 ;
    32 , 9 : controlcode := 136 ;
    42 :
         Begin
           write ( termout , '*' , modulecount + 1 : 1 ) ;
           break ( termout ) ;
           controlcode := 136 ;
         End ;
    68 , 100 : controlcode := 133 ;
    70 , 102 : controlcode := 132 ;
    123 : controlcode := 9 ;
    125 : controlcode := 10 ;
    80 , 112 : controlcode := 134 ;
    84 , 116 , 94 , 46 , 58 : controlcode := 131 ;
    38 : controlcode := 127 ;
    60 : controlcode := 135 ;
    61 : controlcode := 2 ;
    92 : controlcode := 3 ;
    others : controlcode := 0
  End ;
End ;
Function skipahead : eightbits ;

Label 30 ;

Var c : eightbits ;
Begin
  While true Do
    Begin
      If loc > limit Then
        Begin
          getline ;
          If inputhasended Then
            Begin
              c := 136 ;
              goto 30 ;
            End ;
        End ;
      buffer [ limit + 1 ] := 64 ;
      While buffer [ loc ] <> 64 Do
        loc := loc + 1 ;
      If loc <= limit Then
        Begin
          loc := loc + 2 ;
          c := controlcode ( buffer [ loc - 1 ] ) ;
          If ( c <> 0 ) Or ( buffer [ loc - 1 ] = 62 ) Then goto 30 ;
        End ;
    End ;
  30 : skipahead := c ;
End ;
Procedure skipcomment ;

Label 10 ;

Var bal : eightbits ;
  c : ASCIIcode ;
Begin
  bal := 0 ;
  While true Do
    Begin
      If loc > limit Then
        Begin
          getline ;
          If inputhasended Then
            Begin
              Begin
                writeln ( termout ) ;
                write ( termout , '! Input ended in mid-comment' ) ;
                error ;
              End ;
              goto 10 ;
            End ;
        End ;
      c := buffer [ loc ] ;
      loc := loc + 1 ;
      If c = 64 Then
        Begin
          c := buffer [ loc ] ;
          If ( c <> 32 ) And ( c <> 9 ) And ( c <> 42 ) And ( c <> 122 ) And ( c <> 90 ) Then loc := loc + 1
          Else
            Begin
              Begin
                writeln ( termout ) ;
                write ( termout , '! Section ended in mid-comment' ) ;
                error ;
              End ;
              loc := loc - 1 ;
              goto 10 ;
            End
        End
      Else If ( c = 92 ) And ( buffer [ loc ] <> 64 ) Then loc := loc + 1
      Else If c = 123 Then bal := bal + 1
      Else If c = 125 Then
             Begin
               If bal = 0 Then goto 10 ;
               bal := bal - 1 ;
             End ;
    End ;
  10 :
End ;
Function getnext : eightbits ;

Label 20 , 30 , 31 ;

Var c : eightbits ;
  d : eightbits ;
  j , k : 0 .. longestname ;
Begin
  20 : If loc > limit Then
         Begin
           getline ;
           If inputhasended Then
             Begin
               c := 136 ;
               goto 31 ;
             End ;
         End ;
  c := buffer [ loc ] ;
  loc := loc + 1 ;
  If scanninghex Then If ( ( c >= 48 ) And ( c <= 57 ) ) Or ( ( c >= 65 ) And ( c <= 70 ) ) Then goto 31
  Else scanninghex := false ;
  Case c Of 
    65 , 66 , 67 , 68 , 69 , 70 , 71 , 72 , 73 , 74 , 75 , 76 , 77 , 78 , 79 , 80 , 81 , 82 , 83 , 84 , 85 , 86 , 87 , 88 , 89 , 90 , 97 , 98 , 99 , 100 , 101 , 102 , 103 , 104 , 105 , 106 , 107 , 108 , 109 , 110 , 111 , 112 , 113 , 114 , 115 , 116 , 117 , 118 , 119 , 120 , 121 , 122 :
                                                                                                                                                                                                                                                                                               Begin
                                                                                                                                                                                                                                                                                                 If ( ( c = 101 ) Or ( c = 69 ) ) And ( loc > 1 ) Then If ( buffer [ loc - 2 ] <= 57 ) And ( buffer [ loc - 2 ] >= 48 ) Then c := 0 ;
                                                                                                                                                                                                                                                                                                 If c <> 0 Then
                                                                                                                                                                                                                                                                                                   Begin
                                                                                                                                                                                                                                                                                                     loc := loc - 1 ;
                                                                                                                                                                                                                                                                                                     idfirst := loc ;
                                                                                                                                                                                                                                                                                                     Repeat
                                                                                                                                                                                                                                                                                                       loc := loc + 1 ;
                                                                                                                                                                                                                                                                                                       d := buffer [ loc ] ;
                                                                                                                                                                                                                                                                                                     Until ( ( d < 48 ) Or ( ( d > 57 ) And ( d < 65 ) ) Or ( ( d > 90 ) And ( d < 97 ) ) Or ( d > 122 ) ) And ( d <> 95 ) ;
                                                                                                                                                                                                                                                                                                     If loc > idfirst + 1 Then
                                                                                                                                                                                                                                                                                                       Begin
                                                                                                                                                                                                                                                                                                         c := 130 ;
                                                                                                                                                                                                                                                                                                         idloc := loc ;
                                                                                                                                                                                                                                                                                                       End ;
                                                                                                                                                                                                                                                                                                   End
                                                                                                                                                                                                                                                                                                 Else c := 69 ;
                                                                                                                                                                                                                                                                                               End ;
    34 :
         Begin
           doublechars := 0 ;
           idfirst := loc - 1 ;
           Repeat
             d := buffer [ loc ] ;
             loc := loc + 1 ;
             If ( d = 34 ) Or ( d = 64 ) Then If buffer [ loc ] = d Then
                                                Begin
                                                  loc := loc + 1 ;
                                                  d := 0 ;
                                                  doublechars := doublechars + 1 ;
                                                End
             Else
               Begin
                 If d = 64 Then
                   Begin
                     writeln ( termout ) ;
                     write ( termout , '! Double @ sign missing' ) ;
                     error ;
                   End
               End
             Else If loc > limit Then
                    Begin
                      Begin
                        writeln ( termout ) ;
                        write ( termout , '! String constant didn''t end' ) ;
                        error ;
                      End ;
                      d := 34 ;
                    End ;
           Until d = 34 ;
           idloc := loc - 1 ;
           c := 130 ;
         End ;
    64 :
         Begin
           c := controlcode ( buffer [ loc ] ) ;
           loc := loc + 1 ;
           If c = 0 Then goto 20
           Else If c = 13 Then scanninghex := true
           Else If c = 135 Then
                  Begin
                    k := 0 ;
                    While true Do
                      Begin
                        If loc > limit Then
                          Begin
                            getline ;
                            If inputhasended Then
                              Begin
                                Begin
                                  writeln ( termout ) ;
                                  write ( termout , '! Input ended in section name' ) ;
                                  error ;
                                End ;
                                goto 30 ;
                              End ;
                          End ;
                        d := buffer [ loc ] ;
                        If d = 64 Then
                          Begin
                            d := buffer [ loc + 1 ] ;
                            If d = 62 Then
                              Begin
                                loc := loc + 2 ;
                                goto 30 ;
                              End ;
                            If ( d = 32 ) Or ( d = 9 ) Or ( d = 42 ) Then
                              Begin
                                Begin
                                  writeln ( termout ) ;
                                  write ( termout , '! Section name didn''t end' ) ;
                                  error ;
                                End ;
                                goto 30 ;
                              End ;
                            k := k + 1 ;
                            modtext [ k ] := 64 ;
                            loc := loc + 1 ;
                          End ;
                        loc := loc + 1 ;
                        If k < longestname - 1 Then k := k + 1 ;
                        If ( d = 32 ) Or ( d = 9 ) Then
                          Begin
                            d := 32 ;
                            If modtext [ k - 1 ] = 32 Then k := k - 1 ;
                          End ;
                        modtext [ k ] := d ;
                      End ;
                    30 : If k >= longestname - 2 Then
                           Begin
                             Begin
                               writeln ( termout ) ;
                               write ( termout , '! Section name too long: ' ) ;
                             End ;
                             For j := 1 To 25 Do
                               write ( termout , xchr [ modtext [ j ] ] ) ;
                             write ( termout , '...' ) ;
                             If history = 0 Then history := 1 ;
                           End ;
                    If ( modtext [ k ] = 32 ) And ( k > 0 ) Then k := k - 1 ; ;
                    If k > 3 Then
                      Begin
                        If ( modtext [ k ] = 46 ) And ( modtext [ k - 1 ] = 46 ) And ( modtext [ k - 2 ] = 46 ) Then curmodule := prefixlookup ( k - 3 )
                        Else curmodule := modlookup ( k ) ;
                      End
                    Else curmodule := modlookup ( k ) ;
                  End
           Else If c = 131 Then
                  Begin
                    Repeat
                      c := skipahead ;
                    Until c <> 64 ;
                    If buffer [ loc - 1 ] <> 62 Then
                      Begin
                        writeln ( termout ) ;
                        write ( termout , '! Improper @ within control text' ) ;
                        error ;
                      End ;
                    goto 20 ;
                  End ;
         End ;
    46 : If buffer [ loc ] = 46 Then
           Begin
             If loc <= limit Then
               Begin
                 c := 32 ;
                 loc := loc + 1 ;
               End ;
           End
         Else If buffer [ loc ] = 41 Then
                Begin
                  If loc <= limit Then
                    Begin
                      c := 93 ;
                      loc := loc + 1 ;
                    End ;
                End ;
    58 : If buffer [ loc ] = 61 Then
           Begin
             If loc <= limit Then
               Begin
                 c := 24 ;
                 loc := loc + 1 ;
               End ;
           End ;
    61 : If buffer [ loc ] = 61 Then
           Begin
             If loc <= limit Then
               Begin
                 c := 30 ;
                 loc := loc + 1 ;
               End ;
           End ;
    62 : If buffer [ loc ] = 61 Then
           Begin
             If loc <= limit Then
               Begin
                 c := 29 ;
                 loc := loc + 1 ;
               End ;
           End ;
    60 : If buffer [ loc ] = 61 Then
           Begin
             If loc <= limit Then
               Begin
                 c := 28 ;
                 loc := loc + 1 ;
               End ;
           End
         Else If buffer [ loc ] = 62 Then
                Begin
                  If loc <= limit Then
                    Begin
                      c := 26 ;
                      loc := loc + 1 ;
                    End ;
                End ;
    40 : If buffer [ loc ] = 42 Then
           Begin
             If loc <= limit Then
               Begin
                 c := 9 ;
                 loc := loc + 1 ;
               End ;
           End
         Else If buffer [ loc ] = 46 Then
                Begin
                  If loc <= limit Then
                    Begin
                      c := 91 ;
                      loc := loc + 1 ;
                    End ;
                End ;
    42 : If buffer [ loc ] = 41 Then
           Begin
             If loc <= limit Then
               Begin
                 c := 10 ;
                 loc := loc + 1 ;
               End ;
           End ;
    32 , 9 : goto 20 ;
    123 :
          Begin
            skipcomment ;
            goto 20 ;
          End ;
    125 :
          Begin
            Begin
              writeln ( termout ) ;
              write ( termout , '! Extra }' ) ;
              error ;
            End ;
            goto 20 ;
          End ;
    others : If c >= 128 Then goto 20
             Else
  End ;
  31 : getnext := c ;
End ;
Procedure scannumeric ( p : namepointer ) ;

Label 21 , 30 ;

Var accumulator : integer ;
  nextsign : - 1 .. + 1 ;
  q : namepointer ;
  val : integer ;
Begin
  accumulator := 0 ;
  nextsign := + 1 ;
  While true Do
    Begin
      nextcontrol := getnext ;
      21 : Case nextcontrol Of 
             48 , 49 , 50 , 51 , 52 , 53 , 54 , 55 , 56 , 57 :
                                                               Begin
                                                                 val := 0 ;
                                                                 Repeat
                                                                   val := 10 * val + nextcontrol - 48 ;
                                                                   nextcontrol := getnext ;
                                                                 Until ( nextcontrol > 57 ) Or ( nextcontrol < 48 ) ;
                                                                 Begin
                                                                   accumulator := accumulator + nextsign * ( val ) ;
                                                                   nextsign := + 1 ;
                                                                 End ;
                                                                 goto 21 ;
                                                               End ;
             12 :
                  Begin
                    val := 0 ;
                    nextcontrol := 48 ;
                    Repeat
                      val := 8 * val + nextcontrol - 48 ;
                      nextcontrol := getnext ;
                    Until ( nextcontrol > 55 ) Or ( nextcontrol < 48 ) ;
                    Begin
                      accumulator := accumulator + nextsign * ( val ) ;
                      nextsign := + 1 ;
                    End ;
                    goto 21 ;
                  End ;
             13 :
                  Begin
                    val := 0 ;
                    nextcontrol := 48 ;
                    Repeat
                      If nextcontrol >= 65 Then nextcontrol := nextcontrol - 7 ;
                      val := 16 * val + nextcontrol - 48 ;
                      nextcontrol := getnext ;
                    Until ( nextcontrol > 70 ) Or ( nextcontrol < 48 ) Or ( ( nextcontrol > 57 ) And ( nextcontrol < 65 ) ) ;
                    Begin
                      accumulator := accumulator + nextsign * ( val ) ;
                      nextsign := + 1 ;
                    End ;
                    goto 21 ;
                  End ;
             130 :
                   Begin
                     q := idlookup ( 0 ) ;
                     If ilk [ q ] <> 1 Then
                       Begin
                         nextcontrol := 42 ;
                         goto 21 ;
                       End ;
                     Begin
                       accumulator := accumulator + nextsign * ( equiv [ q ] - 32768 ) ;
                       nextsign := + 1 ;
                     End ;
                   End ;
             43 : ;
             45 : nextsign := - nextsign ;
             132 , 133 , 135 , 134 , 136 : goto 30 ;
             59 :
                  Begin
                    writeln ( termout ) ;
                    write ( termout , '! Omit semicolon in numeric definition' ) ;
                    error ;
                  End ;
             others :
                      Begin
                        Begin
                          writeln ( termout ) ;
                          write ( termout , '! Improper numeric definition will be flushed' ) ;
                          error ;
                        End ;
                        Repeat
                          nextcontrol := skipahead
                        Until ( nextcontrol >= 132 ) ;
                        If nextcontrol = 135 Then
                          Begin
                            loc := loc - 2 ;
                            nextcontrol := getnext ;
                          End ;
                        accumulator := 0 ;
                        goto 30 ;
                      End
           End ;
    End ;
  30 : ;
  If abs ( accumulator ) >= 32768 Then
    Begin
      Begin
        writeln ( termout ) ;
        write ( termout , '! Value too big: ' , accumulator : 1 ) ;
        error ;
      End ;
      accumulator := 0 ;
    End ;
  equiv [ p ] := accumulator + 32768 ;
End ;
Procedure scanrepl ( t : eightbits ) ;

Label 22 , 30 , 31 , 21 ;

Var a : sixteenbits ;
  b : ASCIIcode ;
  bal : eightbits ;
Begin
  bal := 0 ;
  While true Do
    Begin
      22 : a := getnext ;
      Case a Of 
        40 : bal := bal + 1 ;
        41 : If bal = 0 Then
               Begin
                 writeln ( termout ) ;
                 write ( termout , '! Extra )' ) ;
                 error ;
               End
             Else bal := bal - 1 ;
        39 :
             Begin
               b := 39 ;
               While true Do
                 Begin
                   Begin
                     If tokptr [ z ] = maxtoks Then
                       Begin
                         writeln ( termout ) ;
                         write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
                         error ;
                         history := 3 ;
                         jumpout ;
                       End ;
                     tokmem [ z , tokptr [ z ] ] := b ;
                     tokptr [ z ] := tokptr [ z ] + 1 ;
                   End ;
                   If b = 64 Then If buffer [ loc ] = 64 Then loc := loc + 1
                   Else
                     Begin
                       writeln ( termout ) ;
                       write ( termout , '! You should double @ signs in strings' ) ;
                       error ;
                     End ;
                   If loc = limit Then
                     Begin
                       Begin
                         writeln ( termout ) ;
                         write ( termout , '! String didn''t end' ) ;
                         error ;
                       End ;
                       buffer [ loc ] := 39 ;
                       buffer [ loc + 1 ] := 0 ;
                     End ;
                   b := buffer [ loc ] ;
                   loc := loc + 1 ;
                   If b = 39 Then
                     Begin
                       If buffer [ loc ] <> 39 Then goto 31
                       Else
                         Begin
                           loc := loc + 1 ;
                           Begin
                             If tokptr [ z ] = maxtoks Then
                               Begin
                                 writeln ( termout ) ;
                                 write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
                                 error ;
                                 history := 3 ;
                                 jumpout ;
                               End ;
                             tokmem [ z , tokptr [ z ] ] := 39 ;
                             tokptr [ z ] := tokptr [ z ] + 1 ;
                           End ;
                         End ;
                     End ;
                 End ;
               31 :
             End ;
        35 : If t = 3 Then a := 0 ;
        130 :
              Begin
                a := idlookup ( 0 ) ;
                Begin
                  If tokptr [ z ] = maxtoks Then
                    Begin
                      writeln ( termout ) ;
                      write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
                      error ;
                      history := 3 ;
                      jumpout ;
                    End ;
                  tokmem [ z , tokptr [ z ] ] := ( a Div 256 ) + 128 ;
                  tokptr [ z ] := tokptr [ z ] + 1 ;
                End ;
                a := a Mod 256 ;
              End ;
        135 : If t <> 135 Then goto 30
              Else
                Begin
                  Begin
                    If tokptr [ z ] = maxtoks Then
                      Begin
                        writeln ( termout ) ;
                        write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
                        error ;
                        history := 3 ;
                        jumpout ;
                      End ;
                    tokmem [ z , tokptr [ z ] ] := ( curmodule Div 256 ) + 168 ;
                    tokptr [ z ] := tokptr [ z ] + 1 ;
                  End ;
                  a := curmodule Mod 256 ;
                End ;
        2 :
            Begin
              Begin
                If tokptr [ z ] = maxtoks Then
                  Begin
                    writeln ( termout ) ;
                    write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
                    error ;
                    history := 3 ;
                    jumpout ;
                  End ;
                tokmem [ z , tokptr [ z ] ] := 2 ;
                tokptr [ z ] := tokptr [ z ] + 1 ;
              End ;
              buffer [ limit + 1 ] := 64 ;
              21 : If buffer [ loc ] = 64 Then
                     Begin
                       If loc < limit Then If buffer [ loc + 1 ] = 64 Then
                                             Begin
                                               Begin
                                                 If tokptr [ z ] = maxtoks Then
                                                   Begin
                                                     writeln ( termout ) ;
                                                     write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
                                                     error ;
                                                     history := 3 ;
                                                     jumpout ;
                                                   End ;
                                                 tokmem [ z , tokptr [ z ] ] := 64 ;
                                                 tokptr [ z ] := tokptr [ z ] + 1 ;
                                               End ;
                                               loc := loc + 2 ;
                                               goto 21 ;
                                             End ;
                     End
                   Else
                     Begin
                       Begin
                         If tokptr [ z ] = maxtoks Then
                           Begin
                             writeln ( termout ) ;
                             write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
                             error ;
                             history := 3 ;
                             jumpout ;
                           End ;
                         tokmem [ z , tokptr [ z ] ] := buffer [ loc ] ;
                         tokptr [ z ] := tokptr [ z ] + 1 ;
                       End ;
                       loc := loc + 1 ;
                       goto 21 ;
                     End ;
              If loc >= limit Then
                Begin
                  writeln ( termout ) ;
                  write ( termout , '! Verbatim string didn''t end' ) ;
                  error ;
                End
              Else If buffer [ loc + 1 ] <> 62 Then
                     Begin
                       writeln ( termout ) ;
                       write ( termout , '! You should double @ signs in verbatim strings' ) ;
                       error ;
                     End ;
              loc := loc + 2 ;
            End ;
        133 , 132 , 134 : If t <> 135 Then goto 30
                          Else
                            Begin
                              Begin
                                writeln ( termout ) ;
                                write ( termout , '! @' , xchr [ buffer [ loc - 1 ] ] , ' is ignored in Pascal text' ) ;
                                error ;
                              End ;
                              goto 22 ;
                            End ;
        136 : goto 30 ;
        others :
      End ;
      Begin
        If tokptr [ z ] = maxtoks Then
          Begin
            writeln ( termout ) ;
            write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
            error ;
            history := 3 ;
            jumpout ;
          End ;
        tokmem [ z , tokptr [ z ] ] := a ;
        tokptr [ z ] := tokptr [ z ] + 1 ;
      End ;
    End ;
  30 : nextcontrol := a ;
  If bal > 0 Then
    Begin
      If bal = 1 Then
        Begin
          writeln ( termout ) ;
          write ( termout , '! Missing )' ) ;
          error ;
        End
      Else
        Begin
          writeln ( termout ) ;
          write ( termout , '! Missing ' , bal : 1 , ' )''s' ) ;
          error ;
        End ;
      While bal > 0 Do
        Begin
          Begin
            If tokptr [ z ] = maxtoks Then
              Begin
                writeln ( termout ) ;
                write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
                error ;
                history := 3 ;
                jumpout ;
              End ;
            tokmem [ z , tokptr [ z ] ] := 41 ;
            tokptr [ z ] := tokptr [ z ] + 1 ;
          End ;
          bal := bal - 1 ;
        End ;
    End ;
  If textptr > maxtexts - 3 Then
    Begin
      writeln ( termout ) ;
      write ( termout , '! Sorry, ' , 'text' , ' capacity exceeded' ) ;
      error ;
      history := 3 ;
      jumpout ;
    End ;
  currepltext := textptr ;
  tokstart [ textptr + 3 ] := tokptr [ z ] ;
  textptr := textptr + 1 ;
  If z = 2 Then z := 0
  Else z := z + 1 ;
End ;
Procedure definemacro ( t : eightbits ) ;

Var p : namepointer ;
Begin
  p := idlookup ( t ) ;
  scanrepl ( t ) ;
  equiv [ p ] := currepltext ;
  textlink [ currepltext ] := 0 ;
End ;
Procedure scanmodule ;

Label 22 , 30 , 10 ;

Var p : namepointer ;
Begin
  modulecount := modulecount + 1 ;
  nextcontrol := 0 ;
  While true Do
    Begin
      22 : While nextcontrol <= 132 Do
             Begin
               nextcontrol := skipahead ;
               If nextcontrol = 135 Then
                 Begin
                   loc := loc - 2 ;
                   nextcontrol := getnext ;
                 End ;
             End ;
      If nextcontrol <> 133 Then goto 30 ;
      nextcontrol := getnext ;
      If nextcontrol <> 130 Then
        Begin
          Begin
            writeln ( termout ) ;
            write ( termout , '! Definition flushed, must start with ' , 'identifier of length > 1' ) ;
            error ;
          End ;
          goto 22 ;
        End ;
      nextcontrol := getnext ;
      If nextcontrol = 61 Then
        Begin
          scannumeric ( idlookup ( 1 ) ) ;
          goto 22 ;
        End
      Else If nextcontrol = 30 Then
             Begin
               definemacro ( 2 ) ;
               goto 22 ;
             End
      Else If nextcontrol = 40 Then
             Begin
               nextcontrol := getnext ;
               If nextcontrol = 35 Then
                 Begin
                   nextcontrol := getnext ;
                   If nextcontrol = 41 Then
                     Begin
                       nextcontrol := getnext ;
                       If nextcontrol = 61 Then
                         Begin
                           Begin
                             writeln ( termout ) ;
                             write ( termout , '! Use == for macros' ) ;
                             error ;
                           End ;
                           nextcontrol := 30 ;
                         End ;
                       If nextcontrol = 30 Then
                         Begin
                           definemacro ( 3 ) ;
                           goto 22 ;
                         End ;
                     End ;
                 End ;
             End ; ;
      Begin
        writeln ( termout ) ;
        write ( termout , '! Definition flushed since it starts badly' ) ;
        error ;
      End ;
    End ;
  30 : ;
  Case nextcontrol Of 
    134 : p := 0 ;
    135 :
          Begin
            p := curmodule ;
            Repeat
              nextcontrol := getnext ;
            Until nextcontrol <> 43 ;
            If ( nextcontrol <> 61 ) And ( nextcontrol <> 30 ) Then
              Begin
                Begin
                  writeln ( termout ) ;
                  write ( termout , '! Pascal text flushed, = sign is missing' ) ;
                  error ;
                End ;
                Repeat
                  nextcontrol := skipahead ;
                Until nextcontrol = 136 ;
                goto 10 ;
              End ;
          End ;
    others : goto 10
  End ;
  storetwobytes ( 53248 + modulecount ) ; ;
  scanrepl ( 135 ) ;
  If p = 0 Then
    Begin
      textlink [ lastunnamed ] := currepltext ;
      lastunnamed := currepltext ;
    End
  Else If equiv [ p ] = 0 Then equiv [ p ] := currepltext
  Else
    Begin
      p := equiv [ p ] ;
      While textlink [ p ] < maxtexts Do
        p := textlink [ p ] ;
      textlink [ p ] := currepltext ;
    End ;
  textlink [ currepltext ] := maxtexts ; ; ;
  10 :
End ;
Begin
  initialize ;
  openinput ;
  line := 0 ;
  otherline := 0 ;
  changing := true ;
  primethechangebuffer ;
  changing := Not changing ;
  templine := otherline ;
  otherline := line ;
  line := templine ;
  limit := 0 ;
  loc := 1 ;
  buffer [ 0 ] := 32 ;
  inputhasended := false ; ;
  writeln ( termout , 'This is TANGLE, Version 4.5' ) ;
  phaseone := true ;
  modulecount := 0 ;
  Repeat
    nextcontrol := skipahead ;
  Until nextcontrol = 136 ;
  While Not inputhasended Do
    scanmodule ;
  If changelimit <> 0 Then
    Begin
      For ii := 0 To changelimit Do
        buffer [ ii ] := changebuffer [ ii ] ;
      limit := changelimit ;
      changing := true ;
      line := otherline ;
      loc := changelimit ;
      Begin
        writeln ( termout ) ;
        write ( termout , '! Change file entry did not match' ) ;
        error ;
      End ;
    End ;
  phaseone := false ; ;
  If textlink [ 0 ] = 0 Then
    Begin
      Begin
        writeln ( termout ) ;
        write ( termout , '! No output was specified.' ) ;
      End ;
      If history = 0 Then history := 1 ;
    End
  Else
    Begin
      Begin
        writeln ( termout ) ;
        write ( termout , 'Writing the output file' ) ;
      End ;
      break ( termout ) ;
      stackptr := 1 ;
      bracelevel := 0 ;
      curstate . namefield := 0 ;
      curstate . replfield := textlink [ 0 ] ;
      zo := curstate . replfield Mod 3 ;
      curstate . bytefield := tokstart [ curstate . replfield ] ;
      curstate . endfield := tokstart [ curstate . replfield + 3 ] ;
      curstate . modfield := 0 ; ;
      outstate := 0 ;
      outptr := 0 ;
      breakptr := 0 ;
      semiptr := 0 ;
      outbuf [ 0 ] := 0 ;
      line := 1 ; ;
      sendtheoutput ;
      breakptr := outptr ;
      semiptr := 0 ;
      flushbuffer ;
      If bracelevel <> 0 Then
        Begin
          writeln ( termout ) ;
          write ( termout , '! Program ended at brace level ' , bracelevel : 1 ) ;
          error ;
        End ; ;
      Begin
        writeln ( termout ) ;
        write ( termout , 'Done.' ) ;
      End ;
    End ;
  9999 : If stringptr > 256 Then
           Begin
             Begin
               writeln ( termout ) ;
               write ( termout , stringptr - 256 : 1 , ' strings written to string pool file.' ) ;
             End ;
             write ( pool , '*' ) ;
             For ii := 1 To 9 Do
               Begin
                 outbuf [ ii ] := poolchecksum Mod 10 ;
                 poolchecksum := poolchecksum Div 10 ;
               End ;
             For ii := 9 Downto 1 Do
               write ( pool , xchr [ 48 + outbuf [ ii ] ] ) ;
             writeln ( pool ) ;
           End ;
  Case history Of 
    0 :
        Begin
          writeln ( termout ) ;
          write ( termout , '(No errors were found.)' ) ;
        End ;
    1 :
        Begin
          writeln ( termout ) ;
          write ( termout , '(Did you see the warning message above?)' ) ;
        End ;
    2 :
        Begin
          writeln ( termout ) ;
          write ( termout , '(Pardon me, but I think I spotted something wrong.)' ) ;
        End ;
    3 :
        Begin
          writeln ( termout ) ;
          write ( termout , '(That was a fatal error, my friend.)' ) ;
        End ;
  End ;
End .
