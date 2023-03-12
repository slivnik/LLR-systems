
Program WEAVE ( webfile , changefile , texfile ) ;

Label 9999 ;

Const maxbytes = 45000 ;
  maxnames = 5000 ;
  maxmodules = 2000 ;
  hashsize = 353 ;
  bufsize = 100 ;
  longestname = 400 ;
  longbufsize = 500 ;
  linelength = 80 ;
  maxrefs = 30000 ;
  maxtoks = 30000 ;
  maxtexts = 2000 ;
  maxscraps = 1000 ;
  stacksize = 200 ;

Type ASCIIcode = 0 .. 255 ;
  textfile = packed file Of char ;
  eightbits = 0 .. 255 ;
  sixteenbits = 0 .. 65535 ;
  namepointer = 0 .. maxnames ;
  xrefnumber = 0 .. maxrefs ;
  textpointer = 0 .. maxtexts ;
  mode = 0 .. 1 ;
  outputstate = Record
    endfield : sixteenbits ;
    tokfield : sixteenbits ;
    modefield : mode ;
  End ;

Var history : 0 .. 3 ;
  xord : array [ char ] Of ASCIIcode ;
  xchr : array [ ASCIIcode ] Of char ;
  termout : textfile ;
  webfile : textfile ;
  changefile : textfile ;
  texfile : textfile ;
  buffer : array [ 0 .. longbufsize ] Of ASCIIcode ;
  phaseone : boolean ;
  phasethree : boolean ;
  bytemem : packed array [ 0 .. 1 , 0 .. maxbytes ] Of ASCIIcode ;
  bytestart : array [ 0 .. maxnames ] Of sixteenbits ;
  link : array [ 0 .. maxnames ] Of sixteenbits ;
  ilk : array [ 0 .. maxnames ] Of sixteenbits ;
  xref : array [ 0 .. maxnames ] Of sixteenbits ;
  nameptr : namepointer ;
  byteptr : array [ 0 .. 1 ] Of 0 .. maxbytes ;
  modulecount : 0 .. maxmodules ;
  changedmodule : packed array [ 0 .. maxmodules ] Of boolean ;
  changeexists : boolean ;
  xmem : array [ xrefnumber ] Of packed Record
    numfield : sixteenbits ;
    xlinkfield : sixteenbits ;
  End ;
  xrefptr : xrefnumber ;
  xrefswitch , modxrefswitch : 0 .. 10240 ;
  tokmem : packed array [ 0 .. maxtoks ] Of sixteenbits ;
  tokstart : array [ textpointer ] Of sixteenbits ;
  textptr : textpointer ;
  tokptr : 0 .. maxtoks ;
  idfirst : 0 .. longbufsize ;
  idloc : 0 .. longbufsize ;
  hash : array [ 0 .. hashsize ] Of sixteenbits ;
  curname : namepointer ;
  modtext : array [ 0 .. longestname ] Of ASCIIcode ;
  ii : integer ;
  line : integer ;
  otherline : integer ;
  templine : integer ;
  limit : 0 .. longbufsize ;
  loc : 0 .. longbufsize ;
  inputhasended : boolean ;
  changing : boolean ;
  changepending : boolean ;
  changebuffer : array [ 0 .. bufsize ] Of ASCIIcode ;
  changelimit : 0 .. bufsize ;
  curmodule : namepointer ;
  scanninghex : boolean ;
  nextcontrol : eightbits ;
  lhs , rhs : namepointer ;
  curxref : xrefnumber ;
  outbuf : array [ 0 .. linelength ] Of ASCIIcode ;
  outptr : 0 .. linelength ;
  outline : integer ;
  dig : array [ 0 .. 4 ] Of 0 .. 9 ;
  cat : array [ 0 .. maxscraps ] Of eightbits ;
  trans : array [ 0 .. maxscraps ] Of 0 .. 10239 ;
  pp : 0 .. maxscraps ;
  scrapbase : 0 .. maxscraps ;
  scrapptr : 0 .. maxscraps ;
  loptr : 0 .. maxscraps ;
  hiptr : 0 .. maxscraps ;
  curstate : outputstate ;
  stack : array [ 1 .. stacksize ] Of outputstate ;
  stackptr : 0 .. stacksize ;
  saveline : integer ;
  saveplace : sixteenbits ;
  thismodule : namepointer ;
  nextxref , thisxref , firstxref , midxref : xrefnumber ;
  kmodule : 0 .. maxmodules ;
  bucket : array [ ASCIIcode ] Of namepointer ;
  nextname : namepointer ;
  c : ASCIIcode ;
  h : 0 .. hashsize ;
  blink : array [ 0 .. maxnames ] Of sixteenbits ;
  curdepth : eightbits ;
  curbyte : 0 .. maxbytes ;
  curbank : 0 .. 1 ;
  curval : sixteenbits ;
  collate : array [ 0 .. 229 ] Of ASCIIcode ;
Procedure error ;

Var k , l : 0 .. longbufsize ;
Begin
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
    If buffer [ limit ] = 124 Then write ( termout , xchr [ 124 ] ) ;
    write ( termout , ' ' ) ;
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
  h : 0 .. hashsize ;
  c : ASCIIcode ;
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
  rewrite ( texfile ) ;
  For wi := 0 To 1 Do
    Begin
      bytestart [ wi ] := 0 ;
      byteptr [ wi ] := 0 ;
    End ;
  bytestart [ 2 ] := 0 ;
  nameptr := 1 ;
  ilk [ 0 ] := 0 ;
  xrefptr := 0 ;
  xrefswitch := 0 ;
  modxrefswitch := 0 ;
  xmem [ 0 ] . numfield := 0 ;
  xref [ 0 ] := 0 ;
  tokptr := 1 ;
  textptr := 1 ;
  tokstart [ 0 ] := 1 ;
  tokstart [ 1 ] := 1 ;
  For h := 0 To hashsize - 1 Do
    hash [ h ] := 0 ;
  scanninghex := false ;
  modtext [ 0 ] := 32 ;
  outptr := 1 ;
  outline := 1 ;
  outbuf [ 1 ] := 99 ;
  write ( texfile , '\input webma' ) ;
  outbuf [ 0 ] := 92 ;
  scrapbase := 1 ;
  scrapptr := 0 ;
  collate [ 0 ] := 0 ;
  collate [ 1 ] := 32 ;
  For c := 1 To 31 Do
    collate [ c + 1 ] := c ;
  For c := 33 To 47 Do
    collate [ c ] := c ;
  For c := 58 To 64 Do
    collate [ c - 10 ] := c ;
  For c := 91 To 94 Do
    collate [ c - 36 ] := c ;
  collate [ 59 ] := 96 ;
  For c := 123 To 255 Do
    collate [ c - 63 ] := c ;
  collate [ 193 ] := 95 ;
  For c := 97 To 122 Do
    collate [ c + 97 ] := c ;
  For c := 48 To 57 Do
    collate [ c + 172 ] := c ;
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
Procedure newxref ( p : namepointer ) ;

Label 10 ;

Var q : xrefnumber ;
  m , n : sixteenbits ;
Begin
  If ( ( ilk [ p ] > 3 ) Or ( bytestart [ p ] + 1 = bytestart [ p + 2 ] ) ) And ( xrefswitch = 0 ) Then goto 10 ;
  m := modulecount + xrefswitch ;
  xrefswitch := 0 ;
  q := xref [ p ] ;
  If q > 0 Then
    Begin
      n := xmem [ q ] . numfield ;
      If ( n = m ) Or ( n = m + 10240 ) Then goto 10
      Else If m = n + 10240 Then
             Begin
               xmem [ q ] . numfield := m ;
               goto 10 ;
             End ;
    End ;
  If xrefptr = maxrefs Then
    Begin
      writeln ( termout ) ;
      write ( termout , '! Sorry, ' , 'cross reference' , ' capacity exceeded' ) ;
      error ;
      history := 3 ;
      jumpout ;
    End
  Else
    Begin
      xrefptr := xrefptr + 1 ;
      xmem [ xrefptr ] . numfield := m ;
    End ;
  xmem [ xrefptr ] . xlinkfield := q ;
  xref [ p ] := xrefptr ;
  10 :
End ;
Procedure newmodxref ( p : namepointer ) ;

Var q , r : xrefnumber ;
Begin
  q := xref [ p ] ;
  r := 0 ;
  If q > 0 Then
    Begin
      If modxrefswitch = 0 Then While xmem [ q ] . numfield >= 10240 Do
                                  Begin
                                    r := q ;
                                    q := xmem [ q ] . xlinkfield ;
                                  End
                                  Else If xmem [ q ] . numfield >= 10240 Then
                                         Begin
                                           r := q ;
                                           q := xmem [ q ] . xlinkfield ;
                                         End ;
    End ;
  If xrefptr = maxrefs Then
    Begin
      writeln ( termout ) ;
      write ( termout , '! Sorry, ' , 'cross reference' , ' capacity exceeded' ) ;
      error ;
      history := 3 ;
      jumpout ;
    End
  Else
    Begin
      xrefptr := xrefptr + 1 ;
      xmem [ xrefptr ] . numfield := modulecount + modxrefswitch ;
    End ;
  xmem [ xrefptr ] . xlinkfield := q ;
  modxrefswitch := 0 ;
  If r = 0 Then xref [ p ] := xrefptr
  Else xmem [ r ] . xlinkfield := xrefptr ;
End ;
Function idlookup ( t : eightbits ) : namepointer ;

Label 31 ;

Var i : 0 .. longbufsize ;
  h : 0 .. hashsize ;
  k : 0 .. maxbytes ;
  w : 0 .. 1 ;
  l : 0 .. longbufsize ;
  p : namepointer ;
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
      If ( bytestart [ p + 2 ] - bytestart [ p ] = l ) And ( ( ilk [ p ] = t ) Or ( ( t = 0 ) And ( ilk [ p ] > 3 ) ) ) Then
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
  If p = nameptr Then
    Begin
      w := nameptr Mod 2 ;
      If byteptr [ w ] + l > maxbytes Then
        Begin
          writeln ( termout ) ;
          write ( termout , '! Sorry, ' , 'byte memory' , ' capacity exceeded' ) ;
          error ;
          history := 3 ;
          jumpout ;
        End ;
      If nameptr + 2 > maxnames Then
        Begin
          writeln ( termout ) ;
          write ( termout , '! Sorry, ' , 'name' , ' capacity exceeded' ) ;
          error ;
          history := 3 ;
          jumpout ;
        End ;
      i := idfirst ;
      k := byteptr [ w ] ;
      While i < idloc Do
        Begin
          bytemem [ w , k ] := buffer [ i ] ;
          k := k + 1 ;
          i := i + 1 ;
        End ;
      byteptr [ w ] := k ;
      bytestart [ nameptr + 2 ] := k ;
      nameptr := nameptr + 1 ;
      ilk [ p ] := t ;
      xref [ p ] := 0 ;
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
  xref [ p ] := 0 ;
  c := 1 ;
  For j := 1 To l Do
    bytemem [ w , k + j - 1 ] := modtext [ j ] ;
  byteptr [ w ] := k + l ;
  bytestart [ nameptr + 2 ] := k + l ;
  nameptr := nameptr + 1 ; ;
  31 : If c <> 1 Then
         Begin
           Begin
             If Not phaseone Then
               Begin
                 writeln ( termout ) ;
                 write ( termout , '! Incompatible section names' ) ;
                 error ;
               End ;
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
                         If Not phaseone Then
                           Begin
                             writeln ( termout ) ;
                             write ( termout , '! Name does not match' ) ;
                             error ;
                           End ;
                       End
  Else
    Begin
      If Not phaseone Then
        Begin
          writeln ( termout ) ;
          write ( termout , '! Ambiguous prefix' ) ;
          error ;
        End ;
    End ;
  prefixlookup := r ;
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
            If Not phaseone Then
              Begin
                writeln ( termout ) ;
                write ( termout , '! Where is the matching @x?' ) ;
                error ;
              End ;
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
          If Not phaseone Then
            Begin
              writeln ( termout ) ;
              write ( termout , '! Change file ended after @x' ) ;
              error ;
            End ;
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
  changepending := false ;
  If Not changedmodule [ modulecount ] Then
    Begin
      loc := 0 ;
      buffer [ limit ] := 33 ;
      While ( buffer [ loc ] = 32 ) Or ( buffer [ loc ] = 9 ) Do
        loc := loc + 1 ;
      buffer [ limit ] := 32 ;
      If buffer [ loc ] = 64 Then If ( buffer [ loc + 1 ] = 42 ) Or ( buffer [ loc + 1 ] = 32 ) Or ( buffer [ loc + 1 ] = 9 ) Then changepending := true ;
      If Not changepending Then changedmodule [ modulecount ] := true ;
    End ;
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
            If Not phaseone Then
              Begin
                writeln ( termout ) ;
                write ( termout , '! Change file ended before @y' ) ;
                error ;
              End ;
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
                                  If Not phaseone Then
                                    Begin
                                      writeln ( termout ) ;
                                      write ( termout , '! Where is the matching @y?' ) ;
                                      error ;
                                    End ;
                                End ;
                              End
                            Else If buffer [ 1 ] = 121 Then
                                   Begin
                                     If n > 0 Then
                                       Begin
                                         loc := 2 ;
                                         Begin
                                           If Not phaseone Then
                                             Begin
                                               writeln ( termout ) ;
                                               write ( termout , '! Hmm... ' , n : 1 , ' of the preceding lines failed to match' ) ;
                                               error ;
                                             End ;
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
            If Not phaseone Then
              Begin
                writeln ( termout ) ;
                write ( termout , '! WEB file ended during a change' ) ;
                error ;
              End ;
          End ;
          inputhasended := true ;
          goto 10 ;
        End ;
      If linesdontmatch Then n := n + 1 ;
    End ;
  10 :
End ;
Procedure resetinput ;
Begin
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
  inputhasended := false ;
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
                 If Not phaseone Then
                   Begin
                     writeln ( termout ) ;
                     write ( termout , '! Change file ended without @z' ) ;
                     error ;
                   End ;
               End ;
               buffer [ 0 ] := 64 ;
               buffer [ 1 ] := 122 ;
               limit := 2 ;
             End ;
           If limit > 0 Then
             Begin
               If changepending Then
                 Begin
                   loc := 0 ;
                   buffer [ limit ] := 33 ;
                   While ( buffer [ loc ] = 32 ) Or ( buffer [ loc ] = 9 ) Do
                     loc := loc + 1 ;
                   buffer [ limit ] := 32 ;
                   If buffer [ loc ] = 64 Then If ( buffer [ loc + 1 ] = 42 ) Or ( buffer [ loc + 1 ] = 32 ) Or ( buffer [ loc + 1 ] = 9 ) Then changepending := false ;
                   If changepending Then
                     Begin
                       changedmodule [ modulecount ] := true ;
                       changepending := false ;
                     End ;
                 End ;
               buffer [ limit ] := 32 ;
               If buffer [ 0 ] = 64 Then
                 Begin
                   If ( buffer [ 1 ] >= 88 ) And ( buffer [ 1 ] <= 90 ) Then buffer [ 1 ] := buffer [ 1 ] + 32 ;
                   If ( buffer [ 1 ] = 120 ) Or ( buffer [ 1 ] = 121 ) Then
                     Begin
                       loc := 2 ;
                       Begin
                         If Not phaseone Then
                           Begin
                             writeln ( termout ) ;
                             write ( termout , '! Where is the matching @z?' ) ;
                             error ;
                           End ;
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
    36 : controlcode := 135 ;
    32 , 9 , 42 : controlcode := 147 ;
    61 : controlcode := 2 ;
    92 : controlcode := 3 ;
    68 , 100 : controlcode := 144 ;
    70 , 102 : controlcode := 143 ;
    123 : controlcode := 9 ;
    125 : controlcode := 10 ;
    80 , 112 : controlcode := 145 ;
    38 : controlcode := 136 ;
    60 : controlcode := 146 ;
    62 :
         Begin
           Begin
             If Not phaseone Then
               Begin
                 writeln ( termout ) ;
                 write ( termout , '! Extra @>' ) ;
                 error ;
               End ;
           End ;
           controlcode := 0 ;
         End ;
    84 , 116 : controlcode := 134 ;
    33 : controlcode := 126 ;
    63 : controlcode := 125 ;
    94 : controlcode := 131 ;
    58 : controlcode := 132 ;
    46 : controlcode := 133 ;
    44 : controlcode := 137 ;
    124 : controlcode := 138 ;
    47 : controlcode := 139 ;
    35 : controlcode := 140 ;
    43 : controlcode := 141 ;
    59 : controlcode := 142 ;
    others :
             Begin
               Begin
                 If Not phaseone Then
                   Begin
                     writeln ( termout ) ;
                     write ( termout , '! Unknown control code' ) ;
                     error ;
                   End ;
               End ;
               controlcode := 0 ;
             End
  End ;
End ;
Procedure skiplimbo ;

Label 10 ;

Var c : ASCIIcode ;
Begin
  While true Do
    If loc > limit Then
      Begin
        getline ;
        If inputhasended Then goto 10 ;
      End
    Else
      Begin
        buffer [ limit + 1 ] := 64 ;
        While buffer [ loc ] <> 64 Do
          loc := loc + 1 ;
        If loc <= limit Then
          Begin
            loc := loc + 2 ;
            c := buffer [ loc - 1 ] ;
            If ( c = 32 ) Or ( c = 9 ) Or ( c = 42 ) Then goto 10 ;
          End ;
      End ;
  10 :
End ;
Function skipTeX : eightbits ;

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
              c := 147 ;
              goto 30 ;
            End ;
        End ;
      buffer [ limit + 1 ] := 64 ;
      Repeat
        c := buffer [ loc ] ;
        loc := loc + 1 ;
        If c = 124 Then goto 30 ;
      Until c = 64 ;
      If loc <= limit Then
        Begin
          c := controlcode ( buffer [ loc ] ) ;
          loc := loc + 1 ;
          goto 30 ;
        End ;
    End ;
  30 : skipTeX := c ;
End ;
Function skipcomment ( bal : eightbits ) : eightbits ;

Label 30 ;

Var c : ASCIIcode ;
Begin
  While true Do
    Begin
      If loc > limit Then
        Begin
          getline ;
          If inputhasended Then
            Begin
              bal := 0 ;
              goto 30 ;
            End ;
        End ;
      c := buffer [ loc ] ;
      loc := loc + 1 ;
      If c = 124 Then goto 30 ;
      If c = 64 Then
        Begin
          c := buffer [ loc ] ;
          If ( c <> 32 ) And ( c <> 9 ) And ( c <> 42 ) Then loc := loc + 1
          Else
            Begin
              loc := loc - 1 ;
              bal := 0 ;
              goto 30 ;
            End
        End
      Else If ( c = 92 ) And ( buffer [ loc ] <> 64 ) Then loc := loc + 1
      Else If c = 123 Then bal := bal + 1
      Else If c = 125 Then
             Begin
               bal := bal - 1 ;
               If bal = 0 Then goto 30 ;
             End ;
    End ;
  30 : skipcomment := bal ;
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
               c := 147 ;
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
                                                                                                                                                                                                                                                                                                 If ( ( c = 69 ) Or ( c = 101 ) ) And ( loc > 1 ) Then If ( buffer [ loc - 2 ] <= 57 ) And ( buffer [ loc - 2 ] >= 48 ) Then c := 128 ;
                                                                                                                                                                                                                                                                                                 If c <> 128 Then
                                                                                                                                                                                                                                                                                                   Begin
                                                                                                                                                                                                                                                                                                     loc := loc - 1 ;
                                                                                                                                                                                                                                                                                                     idfirst := loc ;
                                                                                                                                                                                                                                                                                                     Repeat
                                                                                                                                                                                                                                                                                                       loc := loc + 1 ;
                                                                                                                                                                                                                                                                                                       d := buffer [ loc ] ;
                                                                                                                                                                                                                                                                                                     Until ( ( d < 48 ) Or ( ( d > 57 ) And ( d < 65 ) ) Or ( ( d > 90 ) And ( d < 97 ) ) Or ( d > 122 ) ) And ( d <> 95 ) ;
                                                                                                                                                                                                                                                                                                     c := 130 ;
                                                                                                                                                                                                                                                                                                     idloc := loc ;
                                                                                                                                                                                                                                                                                                   End ;
                                                                                                                                                                                                                                                                                               End ;
    39 , 34 :
              Begin
                idfirst := loc - 1 ;
                Repeat
                  d := buffer [ loc ] ;
                  loc := loc + 1 ;
                  If loc > limit Then
                    Begin
                      Begin
                        If Not phaseone Then
                          Begin
                            writeln ( termout ) ;
                            write ( termout , '! String constant didn''t end' ) ;
                            error ;
                          End ;
                      End ;
                      loc := limit ;
                      d := c ;
                    End ;
                Until d = c ;
                idloc := loc ;
                c := 129 ;
              End ;
    64 :
         Begin
           c := controlcode ( buffer [ loc ] ) ;
           loc := loc + 1 ;
           If c = 126 Then
             Begin
               xrefswitch := 10240 ;
               goto 20 ;
             End
           Else If c = 125 Then
                  Begin
                    xrefswitch := 0 ;
                    goto 20 ;
                  End
           Else If ( c <= 134 ) And ( c >= 131 ) Then
                  Begin
                    idfirst := loc ;
                    buffer [ limit + 1 ] := 64 ;
                    While buffer [ loc ] <> 64 Do
                      loc := loc + 1 ;
                    idloc := loc ;
                    If loc > limit Then
                      Begin
                        Begin
                          If Not phaseone Then
                            Begin
                              writeln ( termout ) ;
                              write ( termout , '! Control text didn''t end' ) ;
                              error ;
                            End ;
                        End ;
                        loc := limit ;
                      End
                    Else
                      Begin
                        loc := loc + 2 ;
                        If buffer [ loc - 1 ] <> 62 Then
                          Begin
                            If Not phaseone Then
                              Begin
                                writeln ( termout ) ;
                                write ( termout , '! Control codes are forbidden in control text' ) ;
                                error ;
                              End ;
                          End ;
                      End ;
                  End
           Else If c = 13 Then scanninghex := true
           Else If c = 146 Then
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
                                  If Not phaseone Then
                                    Begin
                                      writeln ( termout ) ;
                                      write ( termout , '! Input ended in section name' ) ;
                                      error ;
                                    End ;
                                End ;
                                loc := 1 ;
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
                                  If Not phaseone Then
                                    Begin
                                      writeln ( termout ) ;
                                      write ( termout , '! Section name didn''t end' ) ;
                                      error ;
                                    End ;
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
                    If ( modtext [ k ] = 32 ) And ( k > 0 ) Then k := k - 1 ;
                    If k > 3 Then
                      Begin
                        If ( modtext [ k ] = 46 ) And ( modtext [ k - 1 ] = 46 ) And ( modtext [ k - 2 ] = 46 ) Then curmodule := prefixlookup ( k - 3 )
                        Else curmodule := modlookup ( k ) ;
                      End
                    Else curmodule := modlookup ( k ) ;
                    xrefswitch := 0 ;
                  End
           Else If c = 2 Then
                  Begin
                    idfirst := loc ;
                    loc := loc + 1 ;
                    buffer [ limit + 1 ] := 64 ;
                    buffer [ limit + 2 ] := 62 ;
                    While ( buffer [ loc ] <> 64 ) Or ( buffer [ loc + 1 ] <> 62 ) Do
                      loc := loc + 1 ;
                    If loc >= limit Then
                      Begin
                        If Not phaseone Then
                          Begin
                            writeln ( termout ) ;
                            write ( termout , '! Verbatim string didn''t end' ) ;
                            error ;
                          End ;
                      End ;
                    idloc := loc ;
                    loc := loc + 2 ;
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
    125 :
          Begin
            Begin
              If Not phaseone Then
                Begin
                  writeln ( termout ) ;
                  write ( termout , '! Extra }' ) ;
                  error ;
                End ;
            End ;
            goto 20 ;
          End ;
    others : If c >= 128 Then goto 20
             Else
  End ;
  31 : getnext := c ;
End ;
Procedure Pascalxref ;

Label 10 ;

Var p : namepointer ;
Begin
  While nextcontrol < 143 Do
    Begin
      If ( nextcontrol >= 130 ) And ( nextcontrol <= 133 ) Then
        Begin
          p := idlookup ( nextcontrol - 130 ) ;
          newxref ( p ) ;
          If ( ilk [ p ] = 17 ) Or ( ilk [ p ] = 22 ) Then xrefswitch := 10240 ;
        End ;
      nextcontrol := getnext ;
      If ( nextcontrol = 124 ) Or ( nextcontrol = 123 ) Then goto 10 ;
    End ;
  10 :
End ;
Procedure outerxref ;

Var bal : eightbits ;
Begin
  While nextcontrol < 143 Do
    If nextcontrol <> 123 Then Pascalxref
    Else
      Begin
        bal := skipcomment ( 1 ) ;
        nextcontrol := 124 ;
        While bal > 0 Do
          Begin
            Pascalxref ;
            If nextcontrol = 124 Then bal := skipcomment ( bal )
            Else bal := 0 ;
          End ;
      End ;
End ;
Procedure modcheck ( p : namepointer ) ;
Begin
  If p > 0 Then
    Begin
      modcheck ( link [ p ] ) ;
      curxref := xref [ p ] ;
      If xmem [ curxref ] . numfield < 10240 Then
        Begin
          Begin
            writeln ( termout ) ;
            write ( termout , '! Never defined: <' ) ;
          End ;
          printid ( p ) ;
          write ( termout , '>' ) ;
          If history = 0 Then history := 1 ;
        End ;
      While xmem [ curxref ] . numfield >= 10240 Do
        curxref := xmem [ curxref ] . xlinkfield ;
      If curxref = 0 Then
        Begin
          Begin
            writeln ( termout ) ;
            write ( termout , '! Never used: <' ) ;
          End ;
          printid ( p ) ;
          write ( termout , '>' ) ;
          If history = 0 Then history := 1 ;
        End ;
      modcheck ( ilk [ p ] ) ;
    End ;
End ;
Procedure flushbuffer ( b : eightbits ; percent , carryover : boolean ) ;

Label 30 , 31 ;

Var j , k : 0 .. linelength ;
Begin
  j := b ;
  If Not percent Then While true Do
                        Begin
                          If j = 0 Then goto 30 ;
                          If outbuf [ j ] <> 32 Then goto 30 ;
                          j := j - 1 ;
                        End ;
  30 : For k := 1 To j Do
         write ( texfile , xchr [ outbuf [ k ] ] ) ;
  If percent Then write ( texfile , xchr [ 37 ] ) ;
  writeln ( texfile ) ;
  outline := outline + 1 ;
  If carryover Then For k := 1 To j Do
                      If outbuf [ k ] = 37 Then If ( k = 1 ) Or ( outbuf [ k - 1 ] <> 92 ) Then
                                                  Begin
                                                    outbuf [ b ] := 37 ;
                                                    b := b - 1 ;
                                                    goto 31 ;
                                                  End ;
  31 : If ( b < outptr ) Then For k := b + 1 To outptr Do
                                outbuf [ k - b ] := outbuf [ k ] ;
  outptr := outptr - b ;
End ;
Procedure finishline ;

Label 10 ;

Var k : 0 .. bufsize ;
Begin
  If outptr > 0 Then flushbuffer ( outptr , false , false )
  Else
    Begin
      For k := 0 To limit Do
        If ( buffer [ k ] <> 32 ) And ( buffer [ k ] <> 9 ) Then goto 10 ;
      flushbuffer ( 0 , false , false ) ;
    End ;
  10 :
End ;
Procedure breakout ;

Label 10 ;

Var k : 0 .. linelength ;
  d : ASCIIcode ;
Begin
  k := outptr ;
  While true Do
    Begin
      If k = 0 Then
        Begin
          Begin
            writeln ( termout ) ;
            write ( termout , '! Line had to be broken (output l.' , outline : 1 ) ;
          End ;
          writeln ( termout , '):' ) ;
          For k := 1 To outptr - 1 Do
            write ( termout , xchr [ outbuf [ k ] ] ) ;
          writeln ( termout ) ;
          If history = 0 Then history := 1 ;
          flushbuffer ( outptr - 1 , true , true ) ;
          goto 10 ;
        End ;
      d := outbuf [ k ] ;
      If d = 32 Then
        Begin
          flushbuffer ( k , false , true ) ;
          goto 10 ;
        End ;
      If ( d = 92 ) And ( outbuf [ k - 1 ] <> 92 ) Then
        Begin
          flushbuffer ( k - 1 , true , true ) ;
          goto 10 ;
        End ;
      k := k - 1 ;
    End ;
  10 :
End ;
Procedure outmod ( m : integer ) ;

Var k : 0 .. 5 ;
  a : integer ;
Begin
  k := 0 ;
  a := m ;
  Repeat
    dig [ k ] := a Mod 10 ;
    a := a Div 10 ;
    k := k + 1 ;
  Until a = 0 ;
  Repeat
    k := k - 1 ;
    Begin
      If outptr = linelength Then breakout ;
      outptr := outptr + 1 ;
      outbuf [ outptr ] := dig [ k ] + 48 ;
    End ;
  Until k = 0 ;
  If changedmodule [ m ] Then
    Begin
      If outptr = linelength Then breakout ;
      outptr := outptr + 1 ;
      outbuf [ outptr ] := 92 ;
      If outptr = linelength Then breakout ;
      outptr := outptr + 1 ;
      outbuf [ outptr ] := 42 ;
    End ;
End ;
Procedure outname ( p : namepointer ) ;

Var k : 0 .. maxbytes ;
  w : 0 .. 1 ;
Begin
  Begin
    If outptr = linelength Then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 123 ;
  End ;
  w := p Mod 2 ;
  For k := bytestart [ p ] To bytestart [ p + 2 ] - 1 Do
    Begin
      If bytemem [ w , k ] = 95 Then
        Begin
          If outptr = linelength Then breakout ;
          outptr := outptr + 1 ;
          outbuf [ outptr ] := 92 ;
        End ;
      Begin
        If outptr = linelength Then breakout ;
        outptr := outptr + 1 ;
        outbuf [ outptr ] := bytemem [ w , k ] ;
      End ;
    End ;
  Begin
    If outptr = linelength Then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 125 ;
  End ;
End ;
Procedure copylimbo ;

Label 10 ;

Var c : ASCIIcode ;
Begin
  While true Do
    If loc > limit Then
      Begin
        finishline ;
        getline ;
        If inputhasended Then goto 10 ;
      End
    Else
      Begin
        buffer [ limit + 1 ] := 64 ;
        While buffer [ loc ] <> 64 Do
          Begin
            Begin
              If outptr = linelength Then breakout ;
              outptr := outptr + 1 ;
              outbuf [ outptr ] := buffer [ loc ] ;
            End ;
            loc := loc + 1 ;
          End ;
        If loc <= limit Then
          Begin
            loc := loc + 2 ;
            c := buffer [ loc - 1 ] ;
            If ( c = 32 ) Or ( c = 9 ) Or ( c = 42 ) Then goto 10 ;
            If ( c <> 122 ) And ( c <> 90 ) Then
              Begin
                Begin
                  If outptr = linelength Then breakout ;
                  outptr := outptr + 1 ;
                  outbuf [ outptr ] := 64 ;
                End ;
                If c <> 64 Then
                  Begin
                    If Not phaseone Then
                      Begin
                        writeln ( termout ) ;
                        write ( termout , '! Double @ required outside of sections' ) ;
                        error ;
                      End ;
                  End ;
              End ;
          End ;
      End ;
  10 :
End ;
Function copyTeX : eightbits ;

Label 30 ;

Var c : eightbits ;
Begin
  While true Do
    Begin
      If loc > limit Then
        Begin
          finishline ;
          getline ;
          If inputhasended Then
            Begin
              c := 147 ;
              goto 30 ;
            End ;
        End ;
      buffer [ limit + 1 ] := 64 ;
      Repeat
        c := buffer [ loc ] ;
        loc := loc + 1 ;
        If c = 124 Then goto 30 ;
        If c <> 64 Then
          Begin
            Begin
              If outptr = linelength Then breakout ;
              outptr := outptr + 1 ;
              outbuf [ outptr ] := c ;
            End ;
            If ( outptr = 1 ) And ( ( c = 32 ) Or ( c = 9 ) ) Then outptr := outptr - 1 ;
          End ;
      Until c = 64 ;
      If loc <= limit Then
        Begin
          c := controlcode ( buffer [ loc ] ) ;
          loc := loc + 1 ;
          goto 30 ;
        End ;
    End ;
  30 : copyTeX := c ;
End ;
Function copycomment ( bal : eightbits ) : eightbits ;

Label 30 ;

Var c : ASCIIcode ;
Begin
  While true Do
    Begin
      If loc > limit Then
        Begin
          getline ;
          If inputhasended Then
            Begin
              Begin
                If Not phaseone Then
                  Begin
                    writeln ( termout ) ;
                    write ( termout , '! Input ended in mid-comment' ) ;
                    error ;
                  End ;
              End ;
              loc := 1 ;
              Begin
                If tokptr + 2 > maxtoks Then
                  Begin
                    writeln ( termout ) ;
                    write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
                    error ;
                    history := 3 ;
                    jumpout ;
                  End ;
                tokmem [ tokptr ] := 32 ;
                tokptr := tokptr + 1 ;
              End ;
              Repeat
                Begin
                  If tokptr + 2 > maxtoks Then
                    Begin
                      writeln ( termout ) ;
                      write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
                      error ;
                      history := 3 ;
                      jumpout ;
                    End ;
                  tokmem [ tokptr ] := 125 ;
                  tokptr := tokptr + 1 ;
                End ;
                bal := bal - 1 ;
              Until bal = 0 ;
              goto 30 ; ;
            End ;
        End ;
      c := buffer [ loc ] ;
      loc := loc + 1 ;
      If c = 124 Then goto 30 ;
      Begin
        If tokptr + 2 > maxtoks Then
          Begin
            writeln ( termout ) ;
            write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
            error ;
            history := 3 ;
            jumpout ;
          End ;
        tokmem [ tokptr ] := c ;
        tokptr := tokptr + 1 ;
      End ;
      If c = 64 Then
        Begin
          loc := loc + 1 ;
          If buffer [ loc - 1 ] <> 64 Then
            Begin
              Begin
                If Not phaseone Then
                  Begin
                    writeln ( termout ) ;
                    write ( termout , '! Illegal use of @ in comment' ) ;
                    error ;
                  End ;
              End ;
              loc := loc - 2 ;
              tokptr := tokptr - 1 ;
              Begin
                If tokptr + 2 > maxtoks Then
                  Begin
                    writeln ( termout ) ;
                    write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
                    error ;
                    history := 3 ;
                    jumpout ;
                  End ;
                tokmem [ tokptr ] := 32 ;
                tokptr := tokptr + 1 ;
              End ;
              Repeat
                Begin
                  If tokptr + 2 > maxtoks Then
                    Begin
                      writeln ( termout ) ;
                      write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
                      error ;
                      history := 3 ;
                      jumpout ;
                    End ;
                  tokmem [ tokptr ] := 125 ;
                  tokptr := tokptr + 1 ;
                End ;
                bal := bal - 1 ;
              Until bal = 0 ;
              goto 30 ; ;
            End ;
        End
      Else If ( c = 92 ) And ( buffer [ loc ] <> 64 ) Then
             Begin
               Begin
                 If tokptr + 2 > maxtoks Then
                   Begin
                     writeln ( termout ) ;
                     write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
                     error ;
                     history := 3 ;
                     jumpout ;
                   End ;
                 tokmem [ tokptr ] := buffer [ loc ] ;
                 tokptr := tokptr + 1 ;
               End ;
               loc := loc + 1 ;
             End
      Else If c = 123 Then bal := bal + 1
      Else If c = 125 Then
             Begin
               bal := bal - 1 ;
               If bal = 0 Then goto 30 ;
             End ;
    End ;
  30 : copycomment := bal ;
End ;
Procedure red ( j : sixteenbits ; k : eightbits ; c : eightbits ; d : integer ) ;

Var i : 0 .. maxscraps ;
Begin
  cat [ j ] := c ;
  trans [ j ] := textptr ;
  textptr := textptr + 1 ;
  tokstart [ textptr ] := tokptr ;
  If k > 1 Then
    Begin
      For i := j + k To loptr Do
        Begin
          cat [ i - k + 1 ] := cat [ i ] ;
          trans [ i - k + 1 ] := trans [ i ] ;
        End ;
      loptr := loptr - k + 1 ;
    End ;
  If pp + d >= scrapbase Then pp := pp + d
  Else pp := scrapbase ;
End ;
Procedure sq ( j : sixteenbits ; k : eightbits ; c : eightbits ; d : integer ) ;

Var i : 0 .. maxscraps ;
Begin
  If k = 1 Then
    Begin
      cat [ j ] := c ;
      If pp + d >= scrapbase Then pp := pp + d
      Else pp := scrapbase ;
    End
  Else
    Begin
      For i := j To j + k - 1 Do
        Begin
          tokmem [ tokptr ] := 40960 + trans [ i ] ;
          tokptr := tokptr + 1 ;
        End ;
      red ( j , k , c , d ) ;
    End ;
End ;
Procedure fivecases ;

Label 31 ;
Begin
  Case cat [ pp ] Of 
    5 : If cat [ pp + 1 ] = 6 Then
          Begin
            If ( cat [ pp + 2 ] = 10 ) Or ( cat [ pp + 2 ] = 11 ) Then
              Begin
                sq ( pp , 3 , 11 , - 2 ) ; ;
                goto 31 ;
              End ;
          End
        Else If cat [ pp + 1 ] = 11 Then
               Begin
                 tokmem [ tokptr ] := 40960 + trans [ pp ] ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 140 ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                 tokptr := tokptr + 1 ;
                 red ( pp , 2 , 5 , - 1 ) ; ;
                 goto 31 ;
               End ;
    3 : If cat [ pp + 1 ] = 11 Then
          Begin
            tokmem [ tokptr ] := 40960 + trans [ pp ] ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 32 ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 138 ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 55 ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 135 ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
            tokptr := tokptr + 1 ;
            red ( pp , 2 , 11 , - 2 ) ; ;
            goto 31 ;
          End ;
    2 : If cat [ pp + 1 ] = 6 Then
          Begin
            tokmem [ tokptr ] := 36 ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 40960 + trans [ pp ] ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 36 ;
            tokptr := tokptr + 1 ;
            red ( pp , 1 , 11 , - 2 ) ; ;
            goto 31 ;
          End
        Else If cat [ pp + 1 ] = 14 Then
               Begin
                 tokmem [ tokptr ] := 141 ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 139 ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 36 ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 40960 + trans [ pp ] ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 36 ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                 tokptr := tokptr + 1 ;
                 red ( pp , 2 , 3 , - 3 ) ; ;
                 goto 31 ;
               End
        Else If cat [ pp + 1 ] = 2 Then
               Begin
                 sq ( pp , 2 , 2 , - 1 ) ; ;
                 goto 31 ;
               End
        Else If cat [ pp + 1 ] = 1 Then
               Begin
                 sq ( pp , 2 , 2 , - 1 ) ; ;
                 goto 31 ;
               End
        Else If cat [ pp + 1 ] = 11 Then
               Begin
                 tokmem [ tokptr ] := 36 ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 40960 + trans [ pp ] ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 36 ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 136 ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 140 ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 135 ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 137 ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 141 ;
                 tokptr := tokptr + 1 ;
                 red ( pp , 2 , 11 , - 2 ) ; ;
                 goto 31 ;
               End
        Else If cat [ pp + 1 ] = 10 Then
               Begin
                 tokmem [ tokptr ] := 36 ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 40960 + trans [ pp ] ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 36 ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                 tokptr := tokptr + 1 ;
                 red ( pp , 2 , 11 , - 2 ) ; ;
                 goto 31 ;
               End ;
    4 : If ( cat [ pp + 1 ] = 17 ) And ( cat [ pp + 2 ] = 6 ) Then
          Begin
            tokmem [ tokptr ] := 40960 + trans [ pp ] ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 36 ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 135 ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 135 ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 137 ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 36 ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 40960 + trans [ pp + 2 ] ;
            tokptr := tokptr + 1 ;
            red ( pp , 3 , 2 , - 1 ) ; ;
            goto 31 ;
          End
        Else If cat [ pp + 1 ] = 6 Then
               Begin
                 tokmem [ tokptr ] := 40960 + trans [ pp ] ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 92 ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 44 ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                 tokptr := tokptr + 1 ;
                 red ( pp , 2 , 2 , - 1 ) ; ;
                 goto 31 ;
               End
        Else If cat [ pp + 1 ] = 2 Then
               Begin
                 If ( cat [ pp + 2 ] = 17 ) And ( cat [ pp + 3 ] = 6 ) Then
                   Begin
                     tokmem [ tokptr ] := 40960 + trans [ pp ] ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 36 ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 135 ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 40960 + trans [ pp + 2 ] ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 135 ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 137 ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 36 ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 40960 + trans [ pp + 3 ] ;
                     tokptr := tokptr + 1 ;
                     red ( pp , 4 , 2 , - 1 ) ; ;
                     goto 31 ;
                   End
                 Else If cat [ pp + 2 ] = 6 Then
                        Begin
                          sq ( pp , 3 , 2 , - 1 ) ; ;
                          goto 31 ;
                        End
                 Else If cat [ pp + 2 ] = 14 Then
                        Begin
                          sq ( pp + 1 , 2 , 2 , 0 ) ; ;
                          goto 31 ;
                        End
                 Else If cat [ pp + 2 ] = 16 Then
                        Begin
                          If cat [ pp + 3 ] = 3 Then
                            Begin
                              tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                              tokptr := tokptr + 1 ;
                              tokmem [ tokptr ] := 133 ;
                              tokptr := tokptr + 1 ;
                              tokmem [ tokptr ] := 135 ;
                              tokptr := tokptr + 1 ;
                              tokmem [ tokptr ] := 40960 + trans [ pp + 2 ] ;
                              tokptr := tokptr + 1 ;
                              tokmem [ tokptr ] := 125 ;
                              tokptr := tokptr + 1 ;
                              red ( pp + 1 , 3 , 2 , 0 ) ; ;
                              goto 31 ;
                            End ;
                        End
                 Else If cat [ pp + 2 ] = 9 Then
                        Begin
                          tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                          tokptr := tokptr + 1 ;
                          tokmem [ tokptr ] := 40960 + trans [ pp + 2 ] ;
                          tokptr := tokptr + 1 ;
                          tokmem [ tokptr ] := 92 ;
                          tokptr := tokptr + 1 ;
                          tokmem [ tokptr ] := 44 ;
                          tokptr := tokptr + 1 ;
                          tokmem [ tokptr ] := 138 ;
                          tokptr := tokptr + 1 ;
                          tokmem [ tokptr ] := 53 ;
                          tokptr := tokptr + 1 ;
                          red ( pp + 1 , 2 , 2 , 0 ) ; ;
                          goto 31 ;
                        End
                 Else If cat [ pp + 2 ] = 19 Then
                        Begin
                          If cat [ pp + 3 ] = 3 Then
                            Begin
                              tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                              tokptr := tokptr + 1 ;
                              tokmem [ tokptr ] := 133 ;
                              tokptr := tokptr + 1 ;
                              tokmem [ tokptr ] := 135 ;
                              tokptr := tokptr + 1 ;
                              tokmem [ tokptr ] := 40960 + trans [ pp + 2 ] ;
                              tokptr := tokptr + 1 ;
                              tokmem [ tokptr ] := 125 ;
                              tokptr := tokptr + 1 ;
                              red ( pp + 1 , 3 , 2 , 0 ) ; ;
                              goto 31 ;
                            End ;
                        End ;
               End
        Else If cat [ pp + 1 ] = 16 Then
               Begin
                 If cat [ pp + 2 ] = 3 Then
                   Begin
                     tokmem [ tokptr ] := 133 ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 135 ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 125 ;
                     tokptr := tokptr + 1 ;
                     red ( pp + 1 , 2 , 2 , 0 ) ; ;
                     goto 31 ;
                   End ;
               End
        Else If cat [ pp + 1 ] = 1 Then
               Begin
                 sq ( pp + 1 , 1 , 2 , 0 ) ; ;
                 goto 31 ;
               End
        Else If ( cat [ pp + 1 ] = 11 ) And ( cat [ pp + 2 ] = 6 ) Then
               Begin
                 tokmem [ tokptr ] := 40960 + trans [ pp ] ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 36 ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 135 ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 135 ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 36 ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 40960 + trans [ pp + 2 ] ;
                 tokptr := tokptr + 1 ;
                 red ( pp , 3 , 2 , - 1 ) ; ;
                 goto 31 ;
               End
        Else If cat [ pp + 1 ] = 19 Then
               Begin
                 If cat [ pp + 2 ] = 3 Then
                   Begin
                     tokmem [ tokptr ] := 133 ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 135 ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 125 ;
                     tokptr := tokptr + 1 ;
                     red ( pp + 1 , 2 , 2 , 0 ) ; ;
                     goto 31 ;
                   End ;
               End ;
    1 : If cat [ pp + 1 ] = 6 Then
          Begin
            sq ( pp , 1 , 11 , - 2 ) ; ;
            goto 31 ;
          End
        Else If cat [ pp + 1 ] = 14 Then
               Begin
                 tokmem [ tokptr ] := 141 ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 139 ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 40960 + trans [ pp ] ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                 tokptr := tokptr + 1 ;
                 red ( pp , 2 , 3 , - 3 ) ; ;
                 goto 31 ;
               End
        Else If cat [ pp + 1 ] = 2 Then
               Begin
                 sq ( pp , 2 , 2 , - 1 ) ; ;
                 goto 31 ;
               End
        Else If cat [ pp + 1 ] = 22 Then
               Begin
                 sq ( pp , 2 , 22 , 0 ) ; ;
                 goto 31 ;
               End
        Else If cat [ pp + 1 ] = 1 Then
               Begin
                 sq ( pp , 2 , 1 , - 2 ) ; ;
                 goto 31 ;
               End
        Else If cat [ pp + 1 ] = 10 Then
               Begin
                 sq ( pp , 2 , 11 , - 2 ) ; ;
                 goto 31 ;
               End ;
    others :
  End ;
  pp := pp + 1 ;
  31 :
End ;
Procedure alphacases ;

Label 31 ;
Begin
  If cat [ pp + 1 ] = 2 Then
    Begin
      If cat [ pp + 2 ] = 14 Then
        Begin
          sq ( pp + 1 , 2 , 2 , 0 ) ; ;
          goto 31 ;
        End
      Else If cat [ pp + 2 ] = 8 Then
             Begin
               tokmem [ tokptr ] := 40960 + trans [ pp ] ;
               tokptr := tokptr + 1 ;
               tokmem [ tokptr ] := 32 ;
               tokptr := tokptr + 1 ;
               tokmem [ tokptr ] := 36 ;
               tokptr := tokptr + 1 ;
               tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
               tokptr := tokptr + 1 ;
               tokmem [ tokptr ] := 36 ;
               tokptr := tokptr + 1 ;
               tokmem [ tokptr ] := 32 ;
               tokptr := tokptr + 1 ;
               tokmem [ tokptr ] := 136 ;
               tokptr := tokptr + 1 ;
               tokmem [ tokptr ] := 40960 + trans [ pp + 2 ] ;
               tokptr := tokptr + 1 ;
               red ( pp , 3 , 13 , - 2 ) ; ;
               goto 31 ;
             End ;
    End
  Else If cat [ pp + 1 ] = 8 Then
         Begin
           tokmem [ tokptr ] := 40960 + trans [ pp ] ;
           tokptr := tokptr + 1 ;
           tokmem [ tokptr ] := 32 ;
           tokptr := tokptr + 1 ;
           tokmem [ tokptr ] := 136 ;
           tokptr := tokptr + 1 ;
           tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
           tokptr := tokptr + 1 ;
           red ( pp , 2 , 13 , - 2 ) ; ;
           goto 31 ;
         End
  Else If cat [ pp + 1 ] = 1 Then
         Begin
           sq ( pp + 1 , 1 , 2 , 0 ) ; ;
           goto 31 ;
         End ;
  pp := pp + 1 ;
  31 :
End ;
Function translate : textpointer ;

Label 30 , 31 ;

Var i : 1 .. maxscraps ;
  j : 0 .. maxscraps ;
  k : 0 .. longbufsize ;
Begin
  pp := scrapbase ;
  loptr := pp - 1 ;
  hiptr := pp ; ;
  While true Do
    Begin
      If loptr < pp + 3 Then
        Begin
          Repeat
            If hiptr <= scrapptr Then
              Begin
                loptr := loptr + 1 ;
                cat [ loptr ] := cat [ hiptr ] ;
                trans [ loptr ] := trans [ hiptr ] ;
                hiptr := hiptr + 1 ;
              End ;
          Until ( hiptr > scrapptr ) Or ( loptr = pp + 3 ) ;
          For i := loptr + 1 To pp + 3 Do
            cat [ i ] := 0 ;
        End ;
      If ( tokptr + 8 > maxtoks ) Or ( textptr + 4 > maxtexts ) Then
        Begin
          Begin
            writeln ( termout ) ;
            write ( termout , '! Sorry, ' , 'token/text' , ' capacity exceeded' ) ;
            error ;
            history := 3 ;
            jumpout ;
          End ;
        End ;
      If pp > loptr Then goto 30 ;
      If cat [ pp ] <= 7 Then If cat [ pp ] < 7 Then fivecases
      Else alphacases
      Else
        Begin
          Case cat [ pp ] Of 
            17 : If cat [ pp + 1 ] = 21 Then
                   Begin
                     If cat [ pp + 2 ] = 13 Then
                       Begin
                         tokmem [ tokptr ] := 40960 + trans [ pp ] ;
                         tokptr := tokptr + 1 ;
                         tokmem [ tokptr ] := 137 ;
                         tokptr := tokptr + 1 ;
                         tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                         tokptr := tokptr + 1 ;
                         tokmem [ tokptr ] := 40960 + trans [ pp + 2 ] ;
                         tokptr := tokptr + 1 ;
                         red ( pp , 3 , 17 , 0 ) ; ;
                         goto 31 ;
                       End ;
                   End
                 Else If cat [ pp + 1 ] = 6 Then
                        Begin
                          If cat [ pp + 2 ] = 10 Then
                            Begin
                              tokmem [ tokptr ] := 40960 + trans [ pp ] ;
                              tokptr := tokptr + 1 ;
                              tokmem [ tokptr ] := 135 ;
                              tokptr := tokptr + 1 ;
                              tokmem [ tokptr ] := 137 ;
                              tokptr := tokptr + 1 ;
                              tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                              tokptr := tokptr + 1 ;
                              tokmem [ tokptr ] := 40960 + trans [ pp + 2 ] ;
                              tokptr := tokptr + 1 ;
                              red ( pp , 3 , 11 , - 2 ) ; ;
                              goto 31 ;
                            End ;
                        End
                 Else If cat [ pp + 1 ] = 11 Then
                        Begin
                          tokmem [ tokptr ] := 40960 + trans [ pp ] ;
                          tokptr := tokptr + 1 ;
                          tokmem [ tokptr ] := 141 ;
                          tokptr := tokptr + 1 ;
                          tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                          tokptr := tokptr + 1 ;
                          red ( pp , 2 , 17 , 0 ) ; ;
                          goto 31 ;
                        End ;
            21 : If cat [ pp + 1 ] = 13 Then
                   Begin
                     sq ( pp , 2 , 17 , 0 ) ; ;
                     goto 31 ;
                   End ;
            13 : If cat [ pp + 1 ] = 11 Then
                   Begin
                     tokmem [ tokptr ] := 40960 + trans [ pp ] ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 140 ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 135 ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 137 ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 141 ;
                     tokptr := tokptr + 1 ;
                     red ( pp , 2 , 11 , - 2 ) ; ;
                     goto 31 ;
                   End ;
            12 : If ( cat [ pp + 1 ] = 13 ) And ( cat [ pp + 2 ] = 11 ) Then If cat [ pp + 3 ] = 20 Then
                                                                               Begin
                                                                                 tokmem [ tokptr ] := 40960 + trans [ pp ] ;
                                                                                 tokptr := tokptr + 1 ;
                                                                                 tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                                                                                 tokptr := tokptr + 1 ;
                                                                                 tokmem [ tokptr ] := 140 ;
                                                                                 tokptr := tokptr + 1 ;
                                                                                 tokmem [ tokptr ] := 40960 + trans [ pp + 2 ] ;
                                                                                 tokptr := tokptr + 1 ;
                                                                                 tokmem [ tokptr ] := 40960 + trans [ pp + 3 ] ;
                                                                                 tokptr := tokptr + 1 ;
                                                                                 tokmem [ tokptr ] := 32 ;
                                                                                 tokptr := tokptr + 1 ;
                                                                                 tokmem [ tokptr ] := 135 ;
                                                                                 tokptr := tokptr + 1 ;
                                                                                 red ( pp , 4 , 13 , - 2 ) ; ;
                                                                                 goto 31 ;
                                                                               End
                 Else
                   Begin
                     tokmem [ tokptr ] := 40960 + trans [ pp ] ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 140 ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 40960 + trans [ pp + 2 ] ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 135 ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 137 ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 141 ;
                     tokptr := tokptr + 1 ;
                     red ( pp , 3 , 11 , - 2 ) ; ;
                     goto 31 ;
                   End ;
            20 :
                 Begin
                   sq ( pp , 1 , 3 , - 3 ) ; ;
                   goto 31 ;
                 End ;
            15 : If cat [ pp + 1 ] = 2 Then
                   Begin
                     If cat [ pp + 2 ] = 1 Then If cat [ pp + 3 ] <> 1 Then
                                                  Begin
                                                    tokmem [ tokptr ] := 40960 + trans [ pp ] ;
                                                    tokptr := tokptr + 1 ;
                                                    tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                                                    tokptr := tokptr + 1 ;
                                                    tokmem [ tokptr ] := 40960 + trans [ pp + 2 ] ;
                                                    tokptr := tokptr + 1 ;
                                                    tokmem [ tokptr ] := 125 ;
                                                    tokptr := tokptr + 1 ;
                                                    red ( pp , 3 , 2 , - 1 ) ; ;
                                                    goto 31 ;
                                                  End ;
                   End
                 Else If cat [ pp + 1 ] = 1 Then If cat [ pp + 2 ] <> 1 Then
                                                   Begin
                                                     tokmem [ tokptr ] := 40960 + trans [ pp ] ;
                                                     tokptr := tokptr + 1 ;
                                                     tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                                                     tokptr := tokptr + 1 ;
                                                     tokmem [ tokptr ] := 125 ;
                                                     tokptr := tokptr + 1 ;
                                                     red ( pp , 2 , 2 , - 1 ) ; ;
                                                     goto 31 ;
                                                   End ;
            22 : If ( cat [ pp + 1 ] = 10 ) Or ( cat [ pp + 1 ] = 9 ) Then
                   Begin
                     tokmem [ tokptr ] := 40960 + trans [ pp ] ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 141 ;
                     tokptr := tokptr + 1 ;
                     red ( pp , 2 , 11 , - 2 ) ; ;
                     goto 31 ;
                   End
                 Else
                   Begin
                     sq ( pp , 1 , 1 , - 2 ) ; ;
                     goto 31 ;
                   End ;
            16 : If cat [ pp + 1 ] = 5 Then
                   Begin
                     If ( cat [ pp + 2 ] = 6 ) And ( cat [ pp + 3 ] = 10 ) Then
                       Begin
                         tokmem [ tokptr ] := 40960 + trans [ pp ] ;
                         tokptr := tokptr + 1 ;
                         tokmem [ tokptr ] := 135 ;
                         tokptr := tokptr + 1 ;
                         tokmem [ tokptr ] := 137 ;
                         tokptr := tokptr + 1 ;
                         tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                         tokptr := tokptr + 1 ;
                         tokmem [ tokptr ] := 40960 + trans [ pp + 2 ] ;
                         tokptr := tokptr + 1 ;
                         tokmem [ tokptr ] := 40960 + trans [ pp + 3 ] ;
                         tokptr := tokptr + 1 ;
                         red ( pp , 4 , 11 , - 2 ) ; ;
                         goto 31 ;
                       End ;
                   End
                 Else If cat [ pp + 1 ] = 11 Then
                        Begin
                          tokmem [ tokptr ] := 40960 + trans [ pp ] ;
                          tokptr := tokptr + 1 ;
                          tokmem [ tokptr ] := 140 ;
                          tokptr := tokptr + 1 ;
                          tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                          tokptr := tokptr + 1 ;
                          red ( pp , 2 , 16 , - 2 ) ; ;
                          goto 31 ;
                        End ;
            18 : If ( cat [ pp + 1 ] = 3 ) And ( cat [ pp + 2 ] = 21 ) Then
                   Begin
                     tokmem [ tokptr ] := 40960 + trans [ pp ] ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 32 ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 135 ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 40960 + trans [ pp + 2 ] ;
                     tokptr := tokptr + 1 ;
                     red ( pp , 3 , 21 , - 2 ) ; ;
                     goto 31 ;
                   End
                 Else
                   Begin
                     tokmem [ tokptr ] := 136 ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 40960 + trans [ pp ] ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 135 ;
                     tokptr := tokptr + 1 ;
                     red ( pp , 1 , 17 , 0 ) ; ;
                     goto 31 ;
                   End ;
            9 :
                Begin
                  sq ( pp , 1 , 10 , - 3 ) ; ;
                  goto 31 ;
                End ;
            11 : If cat [ pp + 1 ] = 11 Then
                   Begin
                     tokmem [ tokptr ] := 40960 + trans [ pp ] ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 140 ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                     tokptr := tokptr + 1 ;
                     red ( pp , 2 , 11 , - 2 ) ; ;
                     goto 31 ;
                   End ;
            10 :
                 Begin
                   sq ( pp , 1 , 11 , - 2 ) ; ;
                   goto 31 ;
                 End ;
            19 : If cat [ pp + 1 ] = 5 Then
                   Begin
                     sq ( pp , 1 , 11 , - 2 ) ; ;
                     goto 31 ;
                   End
                 Else If cat [ pp + 1 ] = 2 Then
                        Begin
                          If cat [ pp + 2 ] = 14 Then
                            Begin
                              tokmem [ tokptr ] := 36 ;
                              tokptr := tokptr + 1 ;
                              tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                              tokptr := tokptr + 1 ;
                              tokmem [ tokptr ] := 36 ;
                              tokptr := tokptr + 1 ;
                              tokmem [ tokptr ] := 40960 + trans [ pp + 2 ] ;
                              tokptr := tokptr + 1 ;
                              red ( pp + 1 , 2 , 3 , + 1 ) ; ;
                              goto 31 ;
                            End ;
                        End
                 Else If cat [ pp + 1 ] = 1 Then
                        Begin
                          If cat [ pp + 2 ] = 14 Then
                            Begin
                              sq ( pp + 1 , 2 , 3 , + 1 ) ; ;
                              goto 31 ;
                            End ;
                        End
                 Else If cat [ pp + 1 ] = 11 Then
                        Begin
                          tokmem [ tokptr ] := 40960 + trans [ pp ] ;
                          tokptr := tokptr + 1 ;
                          tokmem [ tokptr ] := 140 ;
                          tokptr := tokptr + 1 ;
                          tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                          tokptr := tokptr + 1 ;
                          red ( pp , 2 , 19 , - 2 ) ; ;
                          goto 31 ;
                        End ;
            others :
          End ;
          pp := pp + 1 ;
          31 :
        End ;
    End ;
  30 : ;
  If ( loptr = scrapbase ) And ( cat [ loptr ] <> 2 ) Then translate := trans [ loptr ]
  Else
    Begin ;
      For j := scrapbase To loptr Do
        Begin
          If j <> scrapbase Then
            Begin
              tokmem [ tokptr ] := 32 ;
              tokptr := tokptr + 1 ;
            End ;
          If cat [ j ] = 2 Then
            Begin
              tokmem [ tokptr ] := 36 ;
              tokptr := tokptr + 1 ;
            End ;
          tokmem [ tokptr ] := 40960 + trans [ j ] ;
          tokptr := tokptr + 1 ;
          If cat [ j ] = 2 Then
            Begin
              tokmem [ tokptr ] := 36 ;
              tokptr := tokptr + 1 ;
            End ;
          If tokptr + 6 > maxtoks Then
            Begin
              writeln ( termout ) ;
              write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
              error ;
              history := 3 ;
              jumpout ;
            End ;
        End ;
      textptr := textptr + 1 ;
      tokstart [ textptr ] := tokptr ;
      translate := textptr - 1 ;
    End ;
End ;
Procedure appcomment ;
Begin
  textptr := textptr + 1 ;
  tokstart [ textptr ] := tokptr ;
  If ( scrapptr < scrapbase ) Or ( cat [ scrapptr ] < 8 ) Or ( cat [ scrapptr ] > 10 ) Then
    Begin
      scrapptr := scrapptr + 1 ;
      cat [ scrapptr ] := 10 ;
      trans [ scrapptr ] := 0 ;
    End
  Else
    Begin
      tokmem [ tokptr ] := 40960 + trans [ scrapptr ] ;
      tokptr := tokptr + 1 ;
    End ;
  tokmem [ tokptr ] := textptr + 40959 ;
  tokptr := tokptr + 1 ;
  trans [ scrapptr ] := textptr ;
  textptr := textptr + 1 ;
  tokstart [ textptr ] := tokptr ;
End ;
Procedure appoctal ;
Begin
  tokmem [ tokptr ] := 92 ;
  tokptr := tokptr + 1 ;
  tokmem [ tokptr ] := 79 ;
  tokptr := tokptr + 1 ;
  tokmem [ tokptr ] := 123 ;
  tokptr := tokptr + 1 ;
  While ( buffer [ loc ] >= 48 ) And ( buffer [ loc ] <= 55 ) Do
    Begin
      Begin
        If tokptr + 2 > maxtoks Then
          Begin
            writeln ( termout ) ;
            write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
            error ;
            history := 3 ;
            jumpout ;
          End ;
        tokmem [ tokptr ] := buffer [ loc ] ;
        tokptr := tokptr + 1 ;
      End ;
      loc := loc + 1 ;
    End ;
  Begin
    tokmem [ tokptr ] := 125 ;
    tokptr := tokptr + 1 ;
    scrapptr := scrapptr + 1 ;
    cat [ scrapptr ] := 1 ;
    trans [ scrapptr ] := textptr ;
    textptr := textptr + 1 ;
    tokstart [ textptr ] := tokptr ;
  End ;
End ;
Procedure apphex ;
Begin
  tokmem [ tokptr ] := 92 ;
  tokptr := tokptr + 1 ;
  tokmem [ tokptr ] := 72 ;
  tokptr := tokptr + 1 ;
  tokmem [ tokptr ] := 123 ;
  tokptr := tokptr + 1 ;
  While ( ( buffer [ loc ] >= 48 ) And ( buffer [ loc ] <= 57 ) ) Or ( ( buffer [ loc ] >= 65 ) And ( buffer [ loc ] <= 70 ) ) Do
    Begin
      Begin
        If tokptr + 2 > maxtoks Then
          Begin
            writeln ( termout ) ;
            write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
            error ;
            history := 3 ;
            jumpout ;
          End ;
        tokmem [ tokptr ] := buffer [ loc ] ;
        tokptr := tokptr + 1 ;
      End ;
      loc := loc + 1 ;
    End ;
  Begin
    tokmem [ tokptr ] := 125 ;
    tokptr := tokptr + 1 ;
    scrapptr := scrapptr + 1 ;
    cat [ scrapptr ] := 1 ;
    trans [ scrapptr ] := textptr ;
    textptr := textptr + 1 ;
    tokstart [ textptr ] := tokptr ;
  End ;
End ;
Procedure easycases ;
Begin
  Case nextcontrol Of 
    6 :
        Begin
          tokmem [ tokptr ] := 92 ;
          tokptr := tokptr + 1 ;
          tokmem [ tokptr ] := 105 ;
          tokptr := tokptr + 1 ;
          tokmem [ tokptr ] := 110 ;
          tokptr := tokptr + 1 ;
          scrapptr := scrapptr + 1 ;
          cat [ scrapptr ] := 2 ;
          trans [ scrapptr ] := textptr ;
          textptr := textptr + 1 ;
          tokstart [ textptr ] := tokptr ;
        End ;
    32 :
         Begin
           tokmem [ tokptr ] := 92 ;
           tokptr := tokptr + 1 ;
           tokmem [ tokptr ] := 116 ;
           tokptr := tokptr + 1 ;
           tokmem [ tokptr ] := 111 ;
           tokptr := tokptr + 1 ;
           scrapptr := scrapptr + 1 ;
           cat [ scrapptr ] := 2 ;
           trans [ scrapptr ] := textptr ;
           textptr := textptr + 1 ;
           tokstart [ textptr ] := tokptr ;
         End ;
    35 , 36 , 37 , 94 , 95 :
                             Begin
                               tokmem [ tokptr ] := 92 ;
                               tokptr := tokptr + 1 ;
                               tokmem [ tokptr ] := nextcontrol ;
                               tokptr := tokptr + 1 ;
                               scrapptr := scrapptr + 1 ;
                               cat [ scrapptr ] := 2 ;
                               trans [ scrapptr ] := textptr ;
                               textptr := textptr + 1 ;
                               tokstart [ textptr ] := tokptr ;
                             End ;
    0 , 124 , 131 , 132 , 133 : ;
    40 , 91 :
              Begin
                tokmem [ tokptr ] := nextcontrol ;
                tokptr := tokptr + 1 ;
                scrapptr := scrapptr + 1 ;
                cat [ scrapptr ] := 4 ;
                trans [ scrapptr ] := textptr ;
                textptr := textptr + 1 ;
                tokstart [ textptr ] := tokptr ;
              End ;
    41 , 93 :
              Begin
                tokmem [ tokptr ] := nextcontrol ;
                tokptr := tokptr + 1 ;
                scrapptr := scrapptr + 1 ;
                cat [ scrapptr ] := 6 ;
                trans [ scrapptr ] := textptr ;
                textptr := textptr + 1 ;
                tokstart [ textptr ] := tokptr ;
              End ;
    42 :
         Begin
           tokmem [ tokptr ] := 92 ;
           tokptr := tokptr + 1 ;
           tokmem [ tokptr ] := 97 ;
           tokptr := tokptr + 1 ;
           tokmem [ tokptr ] := 115 ;
           tokptr := tokptr + 1 ;
           tokmem [ tokptr ] := 116 ;
           tokptr := tokptr + 1 ;
           scrapptr := scrapptr + 1 ;
           cat [ scrapptr ] := 2 ;
           trans [ scrapptr ] := textptr ;
           textptr := textptr + 1 ;
           tokstart [ textptr ] := tokptr ;
         End ;
    44 :
         Begin
           tokmem [ tokptr ] := 44 ;
           tokptr := tokptr + 1 ;
           tokmem [ tokptr ] := 138 ;
           tokptr := tokptr + 1 ;
           tokmem [ tokptr ] := 57 ;
           tokptr := tokptr + 1 ;
           scrapptr := scrapptr + 1 ;
           cat [ scrapptr ] := 2 ;
           trans [ scrapptr ] := textptr ;
           textptr := textptr + 1 ;
           tokstart [ textptr ] := tokptr ;
         End ;
    46 , 48 , 49 , 50 , 51 , 52 , 53 , 54 , 55 , 56 , 57 :
                                                           Begin
                                                             tokmem [ tokptr ] := nextcontrol ;
                                                             tokptr := tokptr + 1 ;
                                                             scrapptr := scrapptr + 1 ;
                                                             cat [ scrapptr ] := 1 ;
                                                             trans [ scrapptr ] := textptr ;
                                                             textptr := textptr + 1 ;
                                                             tokstart [ textptr ] := tokptr ;
                                                           End ;
    59 :
         Begin
           tokmem [ tokptr ] := 59 ;
           tokptr := tokptr + 1 ;
           scrapptr := scrapptr + 1 ;
           cat [ scrapptr ] := 9 ;
           trans [ scrapptr ] := textptr ;
           textptr := textptr + 1 ;
           tokstart [ textptr ] := tokptr ;
         End ;
    58 :
         Begin
           tokmem [ tokptr ] := 58 ;
           tokptr := tokptr + 1 ;
           scrapptr := scrapptr + 1 ;
           cat [ scrapptr ] := 14 ;
           trans [ scrapptr ] := textptr ;
           textptr := textptr + 1 ;
           tokstart [ textptr ] := tokptr ;
         End ;
    26 :
         Begin
           tokmem [ tokptr ] := 92 ;
           tokptr := tokptr + 1 ;
           tokmem [ tokptr ] := 73 ;
           tokptr := tokptr + 1 ;
           scrapptr := scrapptr + 1 ;
           cat [ scrapptr ] := 2 ;
           trans [ scrapptr ] := textptr ;
           textptr := textptr + 1 ;
           tokstart [ textptr ] := tokptr ;
         End ;
    28 :
         Begin
           tokmem [ tokptr ] := 92 ;
           tokptr := tokptr + 1 ;
           tokmem [ tokptr ] := 76 ;
           tokptr := tokptr + 1 ;
           scrapptr := scrapptr + 1 ;
           cat [ scrapptr ] := 2 ;
           trans [ scrapptr ] := textptr ;
           textptr := textptr + 1 ;
           tokstart [ textptr ] := tokptr ;
         End ;
    29 :
         Begin
           tokmem [ tokptr ] := 92 ;
           tokptr := tokptr + 1 ;
           tokmem [ tokptr ] := 71 ;
           tokptr := tokptr + 1 ;
           scrapptr := scrapptr + 1 ;
           cat [ scrapptr ] := 2 ;
           trans [ scrapptr ] := textptr ;
           textptr := textptr + 1 ;
           tokstart [ textptr ] := tokptr ;
         End ;
    30 :
         Begin
           tokmem [ tokptr ] := 92 ;
           tokptr := tokptr + 1 ;
           tokmem [ tokptr ] := 83 ;
           tokptr := tokptr + 1 ;
           scrapptr := scrapptr + 1 ;
           cat [ scrapptr ] := 2 ;
           trans [ scrapptr ] := textptr ;
           textptr := textptr + 1 ;
           tokstart [ textptr ] := tokptr ;
         End ;
    4 :
        Begin
          tokmem [ tokptr ] := 92 ;
          tokptr := tokptr + 1 ;
          tokmem [ tokptr ] := 87 ;
          tokptr := tokptr + 1 ;
          scrapptr := scrapptr + 1 ;
          cat [ scrapptr ] := 2 ;
          trans [ scrapptr ] := textptr ;
          textptr := textptr + 1 ;
          tokstart [ textptr ] := tokptr ;
        End ;
    31 :
         Begin
           tokmem [ tokptr ] := 92 ;
           tokptr := tokptr + 1 ;
           tokmem [ tokptr ] := 86 ;
           tokptr := tokptr + 1 ;
           scrapptr := scrapptr + 1 ;
           cat [ scrapptr ] := 2 ;
           trans [ scrapptr ] := textptr ;
           textptr := textptr + 1 ;
           tokstart [ textptr ] := tokptr ;
         End ;
    5 :
        Begin
          tokmem [ tokptr ] := 92 ;
          tokptr := tokptr + 1 ;
          tokmem [ tokptr ] := 82 ;
          tokptr := tokptr + 1 ;
          scrapptr := scrapptr + 1 ;
          cat [ scrapptr ] := 2 ;
          trans [ scrapptr ] := textptr ;
          textptr := textptr + 1 ;
          tokstart [ textptr ] := tokptr ;
        End ;
    24 :
         Begin
           tokmem [ tokptr ] := 92 ;
           tokptr := tokptr + 1 ;
           tokmem [ tokptr ] := 75 ;
           tokptr := tokptr + 1 ;
           scrapptr := scrapptr + 1 ;
           cat [ scrapptr ] := 2 ;
           trans [ scrapptr ] := textptr ;
           textptr := textptr + 1 ;
           tokstart [ textptr ] := tokptr ;
         End ;
    128 :
          Begin
            tokmem [ tokptr ] := 92 ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 69 ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 123 ;
            tokptr := tokptr + 1 ;
            scrapptr := scrapptr + 1 ;
            cat [ scrapptr ] := 15 ;
            trans [ scrapptr ] := textptr ;
            textptr := textptr + 1 ;
            tokstart [ textptr ] := tokptr ;
          End ;
    9 :
        Begin
          tokmem [ tokptr ] := 92 ;
          tokptr := tokptr + 1 ;
          tokmem [ tokptr ] := 66 ;
          tokptr := tokptr + 1 ;
          scrapptr := scrapptr + 1 ;
          cat [ scrapptr ] := 2 ;
          trans [ scrapptr ] := textptr ;
          textptr := textptr + 1 ;
          tokstart [ textptr ] := tokptr ;
        End ;
    10 :
         Begin
           tokmem [ tokptr ] := 92 ;
           tokptr := tokptr + 1 ;
           tokmem [ tokptr ] := 84 ;
           tokptr := tokptr + 1 ;
           scrapptr := scrapptr + 1 ;
           cat [ scrapptr ] := 2 ;
           trans [ scrapptr ] := textptr ;
           textptr := textptr + 1 ;
           tokstart [ textptr ] := tokptr ;
         End ;
    12 : appoctal ;
    13 : apphex ;
    135 :
          Begin
            tokmem [ tokptr ] := 92 ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 41 ;
            tokptr := tokptr + 1 ;
            scrapptr := scrapptr + 1 ;
            cat [ scrapptr ] := 1 ;
            trans [ scrapptr ] := textptr ;
            textptr := textptr + 1 ;
            tokstart [ textptr ] := tokptr ;
          End ;
    3 :
        Begin
          tokmem [ tokptr ] := 92 ;
          tokptr := tokptr + 1 ;
          tokmem [ tokptr ] := 93 ;
          tokptr := tokptr + 1 ;
          scrapptr := scrapptr + 1 ;
          cat [ scrapptr ] := 1 ;
          trans [ scrapptr ] := textptr ;
          textptr := textptr + 1 ;
          tokstart [ textptr ] := tokptr ;
        End ;
    137 :
          Begin
            tokmem [ tokptr ] := 92 ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 44 ;
            tokptr := tokptr + 1 ;
            scrapptr := scrapptr + 1 ;
            cat [ scrapptr ] := 2 ;
            trans [ scrapptr ] := textptr ;
            textptr := textptr + 1 ;
            tokstart [ textptr ] := tokptr ;
          End ;
    138 :
          Begin
            tokmem [ tokptr ] := 138 ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 48 ;
            tokptr := tokptr + 1 ;
            scrapptr := scrapptr + 1 ;
            cat [ scrapptr ] := 1 ;
            trans [ scrapptr ] := textptr ;
            textptr := textptr + 1 ;
            tokstart [ textptr ] := tokptr ;
          End ;
    139 :
          Begin
            tokmem [ tokptr ] := 141 ;
            tokptr := tokptr + 1 ;
            appcomment ;
          End ;
    140 :
          Begin
            tokmem [ tokptr ] := 142 ;
            tokptr := tokptr + 1 ;
            appcomment ;
          End ;
    141 :
          Begin
            tokmem [ tokptr ] := 134 ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 92 ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 32 ;
            tokptr := tokptr + 1 ;
            Begin
              tokmem [ tokptr ] := 134 ;
              tokptr := tokptr + 1 ;
              appcomment ;
            End ;
          End ;
    142 :
          Begin
            scrapptr := scrapptr + 1 ;
            cat [ scrapptr ] := 9 ;
            trans [ scrapptr ] := 0 ;
          End ;
    136 :
          Begin
            tokmem [ tokptr ] := 92 ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 74 ;
            tokptr := tokptr + 1 ;
            scrapptr := scrapptr + 1 ;
            cat [ scrapptr ] := 2 ;
            trans [ scrapptr ] := textptr ;
            textptr := textptr + 1 ;
            tokstart [ textptr ] := tokptr ;
          End ;
    others :
             Begin
               tokmem [ tokptr ] := nextcontrol ;
               tokptr := tokptr + 1 ;
               scrapptr := scrapptr + 1 ;
               cat [ scrapptr ] := 2 ;
               trans [ scrapptr ] := textptr ;
               textptr := textptr + 1 ;
               tokstart [ textptr ] := tokptr ;
             End
  End ;
End ;
Procedure subcases ( p : namepointer ) ;
Begin
  Case ilk [ p ] Of 
    0 :
        Begin
          tokmem [ tokptr ] := 10240 + p ;
          tokptr := tokptr + 1 ;
          scrapptr := scrapptr + 1 ;
          cat [ scrapptr ] := 1 ;
          trans [ scrapptr ] := textptr ;
          textptr := textptr + 1 ;
          tokstart [ textptr ] := tokptr ;
        End ;
    4 :
        Begin
          tokmem [ tokptr ] := 20480 + p ;
          tokptr := tokptr + 1 ;
          scrapptr := scrapptr + 1 ;
          cat [ scrapptr ] := 7 ;
          trans [ scrapptr ] := textptr ;
          textptr := textptr + 1 ;
          tokstart [ textptr ] := tokptr ;
        End ;
    7 :
        Begin
          tokmem [ tokptr ] := 141 ;
          tokptr := tokptr + 1 ;
          tokmem [ tokptr ] := 139 ;
          tokptr := tokptr + 1 ;
          tokmem [ tokptr ] := 20480 + p ;
          tokptr := tokptr + 1 ;
          scrapptr := scrapptr + 1 ;
          cat [ scrapptr ] := 3 ;
          trans [ scrapptr ] := textptr ;
          textptr := textptr + 1 ;
          tokstart [ textptr ] := tokptr ;
        End ;
    8 :
        Begin
          tokmem [ tokptr ] := 131 ;
          tokptr := tokptr + 1 ;
          tokmem [ tokptr ] := 20480 + p ;
          tokptr := tokptr + 1 ;
          tokmem [ tokptr ] := 125 ;
          tokptr := tokptr + 1 ;
          scrapptr := scrapptr + 1 ;
          cat [ scrapptr ] := 2 ;
          trans [ scrapptr ] := textptr ;
          textptr := textptr + 1 ;
          tokstart [ textptr ] := tokptr ;
        End ;
    9 :
        Begin
          tokmem [ tokptr ] := 20480 + p ;
          tokptr := tokptr + 1 ;
          scrapptr := scrapptr + 1 ;
          cat [ scrapptr ] := 8 ;
          trans [ scrapptr ] := textptr ;
          textptr := textptr + 1 ;
          tokstart [ textptr ] := tokptr ;
        End ;
    12 :
         Begin
           tokmem [ tokptr ] := 141 ;
           tokptr := tokptr + 1 ;
           tokmem [ tokptr ] := 20480 + p ;
           tokptr := tokptr + 1 ;
           scrapptr := scrapptr + 1 ;
           cat [ scrapptr ] := 7 ;
           trans [ scrapptr ] := textptr ;
           textptr := textptr + 1 ;
           tokstart [ textptr ] := tokptr ;
         End ;
    13 :
         Begin
           tokmem [ tokptr ] := 20480 + p ;
           tokptr := tokptr + 1 ;
           scrapptr := scrapptr + 1 ;
           cat [ scrapptr ] := 3 ;
           trans [ scrapptr ] := textptr ;
           textptr := textptr + 1 ;
           tokstart [ textptr ] := tokptr ;
         End ;
    16 :
         Begin
           tokmem [ tokptr ] := 20480 + p ;
           tokptr := tokptr + 1 ;
           scrapptr := scrapptr + 1 ;
           cat [ scrapptr ] := 1 ;
           trans [ scrapptr ] := textptr ;
           textptr := textptr + 1 ;
           tokstart [ textptr ] := tokptr ;
         End ;
    20 :
         Begin
           tokmem [ tokptr ] := 132 ;
           tokptr := tokptr + 1 ;
           tokmem [ tokptr ] := 20480 + p ;
           tokptr := tokptr + 1 ;
           tokmem [ tokptr ] := 125 ;
           tokptr := tokptr + 1 ;
           scrapptr := scrapptr + 1 ;
           cat [ scrapptr ] := 2 ;
           trans [ scrapptr ] := textptr ;
           textptr := textptr + 1 ;
           tokstart [ textptr ] := tokptr ;
         End ;
  End ;
End ;
Procedure Pascalparse ;

Label 21 , 10 ;

Var j : 0 .. longbufsize ;
  p : namepointer ;
Begin
  While nextcontrol < 143 Do
    Begin
      If ( scrapptr + 4 > maxscraps ) Or ( tokptr + 6 > maxtoks ) Or ( textptr + 4 > maxtexts ) Then
        Begin
          Begin
            writeln ( termout ) ;
            write ( termout , '! Sorry, ' , 'scrap/token/text' , ' capacity exceeded' ) ;
            error ;
            history := 3 ;
            jumpout ;
          End ;
        End ;
      21 : Case nextcontrol Of 
             129 , 2 :
                       Begin
                         tokmem [ tokptr ] := 92 ;
                         tokptr := tokptr + 1 ;
                         If nextcontrol = 2 Then
                           Begin
                             tokmem [ tokptr ] := 61 ;
                             tokptr := tokptr + 1 ;
                           End
                         Else
                           Begin
                             tokmem [ tokptr ] := 46 ;
                             tokptr := tokptr + 1 ;
                           End ;
                         tokmem [ tokptr ] := 123 ;
                         tokptr := tokptr + 1 ;
                         j := idfirst ;
                         While j < idloc Do
                           Begin
                             Case buffer [ j ] Of 
                               32 , 92 , 35 , 37 , 36 , 94 , 39 , 96 , 123 , 125 , 126 , 38 , 95 :
                                                                                                   Begin
                                                                                                     tokmem [ tokptr ] := 92 ;
                                                                                                     tokptr := tokptr + 1 ;
                                                                                                   End ;
                               64 : If buffer [ j + 1 ] = 64 Then j := j + 1
                                    Else
                                      Begin
                                        If Not phaseone Then
                                          Begin
                                            writeln ( termout ) ;
                                            write ( termout , '! Double @ should be used in strings' ) ;
                                            error ;
                                          End ;
                                      End ;
                               others :
                             End ;
                             Begin
                               If tokptr + 2 > maxtoks Then
                                 Begin
                                   writeln ( termout ) ;
                                   write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
                                   error ;
                                   history := 3 ;
                                   jumpout ;
                                 End ;
                               tokmem [ tokptr ] := buffer [ j ] ;
                               tokptr := tokptr + 1 ;
                             End ;
                             j := j + 1 ;
                           End ;
                         Begin
                           tokmem [ tokptr ] := 125 ;
                           tokptr := tokptr + 1 ;
                           scrapptr := scrapptr + 1 ;
                           cat [ scrapptr ] := 1 ;
                           trans [ scrapptr ] := textptr ;
                           textptr := textptr + 1 ;
                           tokstart [ textptr ] := tokptr ;
                         End ;
                       End ;
             130 :
                   Begin
                     p := idlookup ( 0 ) ;
                     Case ilk [ p ] Of 
                       0 , 4 , 7 , 8 , 9 , 12 , 13 , 16 , 20 : subcases ( p ) ;
                       5 :
                           Begin
                             Begin
                               tokmem [ tokptr ] := 141 ;
                               tokptr := tokptr + 1 ;
                               tokmem [ tokptr ] := 20480 + p ;
                               tokptr := tokptr + 1 ;
                               tokmem [ tokptr ] := 135 ;
                               tokptr := tokptr + 1 ;
                               scrapptr := scrapptr + 1 ;
                               cat [ scrapptr ] := 5 ;
                               trans [ scrapptr ] := textptr ;
                               textptr := textptr + 1 ;
                               tokstart [ textptr ] := tokptr ;
                             End ;
                             Begin
                               scrapptr := scrapptr + 1 ;
                               cat [ scrapptr ] := 3 ;
                               trans [ scrapptr ] := 0 ;
                             End ;
                           End ;
                       6 :
                           Begin
                             Begin
                               scrapptr := scrapptr + 1 ;
                               cat [ scrapptr ] := 21 ;
                               trans [ scrapptr ] := 0 ;
                             End ;
                             Begin
                               tokmem [ tokptr ] := 141 ;
                               tokptr := tokptr + 1 ;
                               tokmem [ tokptr ] := 20480 + p ;
                               tokptr := tokptr + 1 ;
                               scrapptr := scrapptr + 1 ;
                               cat [ scrapptr ] := 7 ;
                               trans [ scrapptr ] := textptr ;
                               textptr := textptr + 1 ;
                               tokstart [ textptr ] := tokptr ;
                             End ;
                           End ;
                       10 :
                            Begin
                              If ( scrapptr < scrapbase ) Or ( ( cat [ scrapptr ] <> 10 ) And ( cat [ scrapptr ] <> 9 ) ) Then
                                Begin
                                  scrapptr := scrapptr + 1 ;
                                  cat [ scrapptr ] := 10 ;
                                  trans [ scrapptr ] := 0 ;
                                End ;
                              Begin
                                tokmem [ tokptr ] := 141 ;
                                tokptr := tokptr + 1 ;
                                tokmem [ tokptr ] := 139 ;
                                tokptr := tokptr + 1 ;
                                tokmem [ tokptr ] := 20480 + p ;
                                tokptr := tokptr + 1 ;
                                scrapptr := scrapptr + 1 ;
                                cat [ scrapptr ] := 20 ;
                                trans [ scrapptr ] := textptr ;
                                textptr := textptr + 1 ;
                                tokstart [ textptr ] := tokptr ;
                              End ;
                            End ;
                       11 :
                            Begin
                              If ( scrapptr < scrapbase ) Or ( ( cat [ scrapptr ] <> 10 ) And ( cat [ scrapptr ] <> 9 ) ) Then
                                Begin
                                  scrapptr := scrapptr + 1 ;
                                  cat [ scrapptr ] := 10 ;
                                  trans [ scrapptr ] := 0 ;
                                End ;
                              Begin
                                tokmem [ tokptr ] := 141 ;
                                tokptr := tokptr + 1 ;
                                tokmem [ tokptr ] := 20480 + p ;
                                tokptr := tokptr + 1 ;
                                scrapptr := scrapptr + 1 ;
                                cat [ scrapptr ] := 6 ;
                                trans [ scrapptr ] := textptr ;
                                textptr := textptr + 1 ;
                                tokstart [ textptr ] := tokptr ;
                              End ;
                            End ;
                       14 :
                            Begin
                              Begin
                                scrapptr := scrapptr + 1 ;
                                cat [ scrapptr ] := 12 ;
                                trans [ scrapptr ] := 0 ;
                              End ;
                              Begin
                                tokmem [ tokptr ] := 141 ;
                                tokptr := tokptr + 1 ;
                                tokmem [ tokptr ] := 20480 + p ;
                                tokptr := tokptr + 1 ;
                                scrapptr := scrapptr + 1 ;
                                cat [ scrapptr ] := 7 ;
                                trans [ scrapptr ] := textptr ;
                                textptr := textptr + 1 ;
                                tokstart [ textptr ] := tokptr ;
                              End ;
                            End ;
                       23 :
                            Begin
                              Begin
                                tokmem [ tokptr ] := 141 ;
                                tokptr := tokptr + 1 ;
                                tokmem [ tokptr ] := 92 ;
                                tokptr := tokptr + 1 ;
                                tokmem [ tokptr ] := 126 ;
                                tokptr := tokptr + 1 ;
                                scrapptr := scrapptr + 1 ;
                                cat [ scrapptr ] := 7 ;
                                trans [ scrapptr ] := textptr ;
                                textptr := textptr + 1 ;
                                tokstart [ textptr ] := tokptr ;
                              End ;
                              Begin
                                tokmem [ tokptr ] := 20480 + p ;
                                tokptr := tokptr + 1 ;
                                scrapptr := scrapptr + 1 ;
                                cat [ scrapptr ] := 8 ;
                                trans [ scrapptr ] := textptr ;
                                textptr := textptr + 1 ;
                                tokstart [ textptr ] := tokptr ;
                              End ;
                            End ;
                       17 :
                            Begin
                              Begin
                                tokmem [ tokptr ] := 141 ;
                                tokptr := tokptr + 1 ;
                                tokmem [ tokptr ] := 139 ;
                                tokptr := tokptr + 1 ;
                                tokmem [ tokptr ] := 20480 + p ;
                                tokptr := tokptr + 1 ;
                                tokmem [ tokptr ] := 135 ;
                                tokptr := tokptr + 1 ;
                                scrapptr := scrapptr + 1 ;
                                cat [ scrapptr ] := 16 ;
                                trans [ scrapptr ] := textptr ;
                                textptr := textptr + 1 ;
                                tokstart [ textptr ] := tokptr ;
                              End ;
                              Begin
                                tokmem [ tokptr ] := 136 ;
                                tokptr := tokptr + 1 ;
                                tokmem [ tokptr ] := 92 ;
                                tokptr := tokptr + 1 ;
                                tokmem [ tokptr ] := 32 ;
                                tokptr := tokptr + 1 ;
                                scrapptr := scrapptr + 1 ;
                                cat [ scrapptr ] := 3 ;
                                trans [ scrapptr ] := textptr ;
                                textptr := textptr + 1 ;
                                tokstart [ textptr ] := tokptr ;
                              End ;
                            End ;
                       18 :
                            Begin
                              Begin
                                tokmem [ tokptr ] := 20480 + p ;
                                tokptr := tokptr + 1 ;
                                scrapptr := scrapptr + 1 ;
                                cat [ scrapptr ] := 18 ;
                                trans [ scrapptr ] := textptr ;
                                textptr := textptr + 1 ;
                                tokstart [ textptr ] := tokptr ;
                              End ;
                              Begin
                                scrapptr := scrapptr + 1 ;
                                cat [ scrapptr ] := 3 ;
                                trans [ scrapptr ] := 0 ;
                              End ;
                            End ;
                       19 :
                            Begin
                              Begin
                                tokmem [ tokptr ] := 141 ;
                                tokptr := tokptr + 1 ;
                                tokmem [ tokptr ] := 136 ;
                                tokptr := tokptr + 1 ;
                                tokmem [ tokptr ] := 20480 + p ;
                                tokptr := tokptr + 1 ;
                                tokmem [ tokptr ] := 135 ;
                                tokptr := tokptr + 1 ;
                                scrapptr := scrapptr + 1 ;
                                cat [ scrapptr ] := 5 ;
                                trans [ scrapptr ] := textptr ;
                                textptr := textptr + 1 ;
                                tokstart [ textptr ] := tokptr ;
                              End ;
                              Begin
                                scrapptr := scrapptr + 1 ;
                                cat [ scrapptr ] := 3 ;
                                trans [ scrapptr ] := 0 ;
                              End ;
                            End ;
                       21 :
                            Begin
                              If ( scrapptr < scrapbase ) Or ( ( cat [ scrapptr ] <> 10 ) And ( cat [ scrapptr ] <> 9 ) ) Then
                                Begin
                                  scrapptr := scrapptr + 1 ;
                                  cat [ scrapptr ] := 10 ;
                                  trans [ scrapptr ] := 0 ;
                                End ;
                              Begin
                                tokmem [ tokptr ] := 141 ;
                                tokptr := tokptr + 1 ;
                                tokmem [ tokptr ] := 139 ;
                                tokptr := tokptr + 1 ;
                                tokmem [ tokptr ] := 20480 + p ;
                                tokptr := tokptr + 1 ;
                                scrapptr := scrapptr + 1 ;
                                cat [ scrapptr ] := 6 ;
                                trans [ scrapptr ] := textptr ;
                                textptr := textptr + 1 ;
                                tokstart [ textptr ] := tokptr ;
                              End ;
                              Begin
                                scrapptr := scrapptr + 1 ;
                                cat [ scrapptr ] := 13 ;
                                trans [ scrapptr ] := 0 ;
                              End ;
                            End ;
                       22 :
                            Begin
                              Begin
                                tokmem [ tokptr ] := 141 ;
                                tokptr := tokptr + 1 ;
                                tokmem [ tokptr ] := 139 ;
                                tokptr := tokptr + 1 ;
                                tokmem [ tokptr ] := 20480 + p ;
                                tokptr := tokptr + 1 ;
                                tokmem [ tokptr ] := 135 ;
                                tokptr := tokptr + 1 ;
                                scrapptr := scrapptr + 1 ;
                                cat [ scrapptr ] := 19 ;
                                trans [ scrapptr ] := textptr ;
                                textptr := textptr + 1 ;
                                tokstart [ textptr ] := tokptr ;
                              End ;
                              Begin
                                scrapptr := scrapptr + 1 ;
                                cat [ scrapptr ] := 3 ;
                                trans [ scrapptr ] := 0 ;
                              End ;
                            End ;
                       others :
                                Begin
                                  nextcontrol := ilk [ p ] - 24 ;
                                  goto 21 ;
                                End
                     End ;
                   End ;
             134 :
                   Begin
                     tokmem [ tokptr ] := 92 ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 104 ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 98 ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 111 ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 120 ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 123 ;
                     tokptr := tokptr + 1 ;
                     For j := idfirst To idloc - 1 Do
                       Begin
                         If tokptr + 2 > maxtoks Then
                           Begin
                             writeln ( termout ) ;
                             write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
                             error ;
                             history := 3 ;
                             jumpout ;
                           End ;
                         tokmem [ tokptr ] := buffer [ j ] ;
                         tokptr := tokptr + 1 ;
                       End ;
                     Begin
                       tokmem [ tokptr ] := 125 ;
                       tokptr := tokptr + 1 ;
                       scrapptr := scrapptr + 1 ;
                       cat [ scrapptr ] := 1 ;
                       trans [ scrapptr ] := textptr ;
                       textptr := textptr + 1 ;
                       tokstart [ textptr ] := tokptr ;
                     End ;
                   End ;
             others : easycases
           End ;
      nextcontrol := getnext ;
      If ( nextcontrol = 124 ) Or ( nextcontrol = 123 ) Then goto 10 ;
    End ;
  10 :
End ;
Function Pascaltranslate : textpointer ;

Var p : textpointer ;
  savebase : 0 .. maxscraps ;
Begin
  savebase := scrapbase ;
  scrapbase := scrapptr + 1 ;
  Pascalparse ;
  If nextcontrol <> 124 Then
    Begin
      If Not phaseone Then
        Begin
          writeln ( termout ) ;
          write ( termout , '! Missing "|" after Pascal text' ) ;
          error ;
        End ;
    End ;
  Begin
    If tokptr + 2 > maxtoks Then
      Begin
        writeln ( termout ) ;
        write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
        error ;
        history := 3 ;
        jumpout ;
      End ;
    tokmem [ tokptr ] := 135 ;
    tokptr := tokptr + 1 ;
  End ;
  appcomment ;
  p := translate ;
  scrapptr := scrapbase - 1 ;
  scrapbase := savebase ;
  Pascaltranslate := p ;
End ;
Procedure outerparse ;

Var bal : eightbits ;
  p , q : textpointer ;
Begin
  While nextcontrol < 143 Do
    If nextcontrol <> 123 Then Pascalparse
    Else
      Begin
        If ( tokptr + 7 > maxtoks ) Or ( textptr + 3 > maxtexts ) Or ( scrapptr >= maxscraps ) Then
          Begin
            Begin
              writeln ( termout ) ;
              write ( termout , '! Sorry, ' , 'token/text/scrap' , ' capacity exceeded' ) ;
              error ;
              history := 3 ;
              jumpout ;
            End ;
          End ;
        tokmem [ tokptr ] := 92 ;
        tokptr := tokptr + 1 ;
        tokmem [ tokptr ] := 67 ;
        tokptr := tokptr + 1 ;
        tokmem [ tokptr ] := 123 ;
        tokptr := tokptr + 1 ;
        bal := copycomment ( 1 ) ;
        nextcontrol := 124 ;
        While bal > 0 Do
          Begin
            p := textptr ;
            textptr := textptr + 1 ;
            tokstart [ textptr ] := tokptr ;
            q := Pascaltranslate ;
            tokmem [ tokptr ] := 40960 + p ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 51200 + q ;
            tokptr := tokptr + 1 ;
            If nextcontrol = 124 Then bal := copycomment ( bal )
            Else bal := 0 ;
          End ;
        tokmem [ tokptr ] := 141 ;
        tokptr := tokptr + 1 ;
        appcomment ;
      End ;
End ;
Procedure pushlevel ( p : textpointer ) ;
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
      If stackptr > 0 Then stack [ stackptr ] := curstate ;
      stackptr := stackptr + 1 ;
      curstate . tokfield := tokstart [ p ] ;
      curstate . endfield := tokstart [ p + 1 ] ;
    End ;
End ;
Function getoutput : eightbits ;

Label 20 ;

Var a : sixteenbits ;
Begin
  20 : While curstate . tokfield = curstate . endfield Do
         Begin
           stackptr := stackptr - 1 ;
           curstate := stack [ stackptr ] ;
         End ;
  a := tokmem [ curstate . tokfield ] ;
  curstate . tokfield := curstate . tokfield + 1 ;
  If a >= 256 Then
    Begin
      curname := a Mod 10240 ;
      Case a Div 10240 Of 
        2 : a := 129 ;
        3 : a := 128 ;
        4 :
            Begin
              pushlevel ( curname ) ;
              goto 20 ;
            End ;
        5 :
            Begin
              pushlevel ( curname ) ;
              curstate . modefield := 0 ;
              goto 20 ;
            End ;
        others : a := 130
      End ;
    End ;
  getoutput := a ;
End ;
Procedure makeoutput ;
forward ;
Procedure outputPascal ;

Var savetokptr , savetextptr , savenextcontrol : sixteenbits ;
  p : textpointer ;
Begin
  savetokptr := tokptr ;
  savetextptr := textptr ;
  savenextcontrol := nextcontrol ;
  nextcontrol := 124 ;
  p := Pascaltranslate ;
  tokmem [ tokptr ] := p + 51200 ;
  tokptr := tokptr + 1 ;
  makeoutput ;
  textptr := savetextptr ;
  tokptr := savetokptr ;
  nextcontrol := savenextcontrol ;
End ;
Procedure makeoutput ;

Label 21 , 10 , 31 ;

Var a : eightbits ;
  b : eightbits ;
  k , klimit : 0 .. maxbytes ;
  w : 0 .. 1 ;
  j : 0 .. longbufsize ;
  stringdelimiter : ASCIIcode ;
  saveloc , savelimit : 0 .. longbufsize ;
  curmodname : namepointer ;
  savemode : mode ;
Begin
  tokmem [ tokptr ] := 143 ;
  tokptr := tokptr + 1 ;
  textptr := textptr + 1 ;
  tokstart [ textptr ] := tokptr ;
  pushlevel ( textptr - 1 ) ;
  While true Do
    Begin
      a := getoutput ;
      21 : Case a Of 
             143 : goto 10 ;
             130 , 129 :
                         Begin
                           Begin
                             If outptr = linelength Then breakout ;
                             outptr := outptr + 1 ;
                             outbuf [ outptr ] := 92 ;
                           End ;
                           If a = 130 Then If bytestart [ curname + 2 ] - bytestart [ curname ] = 1 Then
                                             Begin
                                               If outptr = linelength Then breakout ;
                                               outptr := outptr + 1 ;
                                               outbuf [ outptr ] := 124 ;
                                             End
                           Else
                             Begin
                               If outptr = linelength Then breakout ;
                               outptr := outptr + 1 ;
                               outbuf [ outptr ] := 92 ;
                             End
                           Else
                             Begin
                               If outptr = linelength Then breakout ;
                               outptr := outptr + 1 ;
                               outbuf [ outptr ] := 38 ;
                             End ;
                           If bytestart [ curname + 2 ] - bytestart [ curname ] = 1 Then
                             Begin
                               If outptr = linelength Then breakout ;
                               outptr := outptr + 1 ;
                               outbuf [ outptr ] := bytemem [ curname Mod 2 , bytestart [ curname ] ] ;
                             End
                           Else outname ( curname ) ;
                         End ;
             128 :
                   Begin
                     Begin
                       If outptr = linelength Then breakout ;
                       outptr := outptr + 1 ;
                       outbuf [ outptr ] := 92 ;
                       If outptr = linelength Then breakout ;
                       outptr := outptr + 1 ;
                       outbuf [ outptr ] := 88 ;
                     End ;
                     curxref := xref [ curname ] ;
                     If xmem [ curxref ] . numfield >= 10240 Then
                       Begin
                         outmod ( xmem [ curxref ] . numfield - 10240 ) ;
                         If phasethree Then
                           Begin
                             curxref := xmem [ curxref ] . xlinkfield ;
                             While xmem [ curxref ] . numfield >= 10240 Do
                               Begin
                                 Begin
                                   If outptr = linelength Then breakout ;
                                   outptr := outptr + 1 ;
                                   outbuf [ outptr ] := 44 ;
                                   If outptr = linelength Then breakout ;
                                   outptr := outptr + 1 ;
                                   outbuf [ outptr ] := 32 ;
                                 End ;
                                 outmod ( xmem [ curxref ] . numfield - 10240 ) ;
                                 curxref := xmem [ curxref ] . xlinkfield ;
                               End ;
                           End ;
                       End
                     Else
                       Begin
                         If outptr = linelength Then breakout ;
                         outptr := outptr + 1 ;
                         outbuf [ outptr ] := 48 ;
                       End ;
                     Begin
                       If outptr = linelength Then breakout ;
                       outptr := outptr + 1 ;
                       outbuf [ outptr ] := 58 ;
                     End ;
                     k := bytestart [ curname ] ;
                     w := curname Mod 2 ;
                     klimit := bytestart [ curname + 2 ] ;
                     curmodname := curname ;
                     While k < klimit Do
                       Begin
                         b := bytemem [ w , k ] ;
                         k := k + 1 ;
                         If b = 64 Then
                           Begin
                             If bytemem [ w , k ] <> 64 Then
                               Begin
                                 Begin
                                   writeln ( termout ) ;
                                   write ( termout , '! Illegal control code in section name:' ) ;
                                 End ;
                                 Begin
                                   writeln ( termout ) ;
                                   write ( termout , '<' ) ;
                                 End ;
                                 printid ( curmodname ) ;
                                 write ( termout , '> ' ) ;
                                 history := 2 ;
                               End ;
                             k := k + 1 ;
                           End ;
                         If b <> 124 Then
                           Begin
                             If outptr = linelength Then breakout ;
                             outptr := outptr + 1 ;
                             outbuf [ outptr ] := b ;
                           End
                         Else
                           Begin
                             j := limit + 1 ;
                             buffer [ j ] := 124 ;
                             stringdelimiter := 0 ;
                             While true Do
                               Begin
                                 If k >= klimit Then
                                   Begin
                                     Begin
                                       writeln ( termout ) ;
                                       write ( termout , '! Pascal text in section name didn''t end:' ) ;
                                     End ;
                                     Begin
                                       writeln ( termout ) ;
                                       write ( termout , '<' ) ;
                                     End ;
                                     printid ( curmodname ) ;
                                     write ( termout , '> ' ) ;
                                     history := 2 ;
                                     goto 31 ;
                                   End ;
                                 b := bytemem [ w , k ] ;
                                 k := k + 1 ;
                                 If b = 64 Then
                                   Begin
                                     If j > longbufsize - 4 Then
                                       Begin
                                         writeln ( termout ) ;
                                         write ( termout , '! Sorry, ' , 'buffer' , ' capacity exceeded' ) ;
                                         error ;
                                         history := 3 ;
                                         jumpout ;
                                       End ;
                                     buffer [ j + 1 ] := 64 ;
                                     buffer [ j + 2 ] := bytemem [ w , k ] ;
                                     j := j + 2 ;
                                     k := k + 1 ;
                                   End
                                 Else
                                   Begin
                                     If ( b = 34 ) Or ( b = 39 ) Then If stringdelimiter = 0 Then stringdelimiter := b
                                     Else If stringdelimiter = b Then stringdelimiter := 0 ;
                                     If ( b <> 124 ) Or ( stringdelimiter <> 0 ) Then
                                       Begin
                                         If j > longbufsize - 3 Then
                                           Begin
                                             writeln ( termout ) ;
                                             write ( termout , '! Sorry, ' , 'buffer' , ' capacity exceeded' ) ;
                                             error ;
                                             history := 3 ;
                                             jumpout ;
                                           End ;
                                         j := j + 1 ;
                                         buffer [ j ] := b ;
                                       End
                                     Else goto 31 ;
                                   End ;
                               End ;
                             31 : ;
                             saveloc := loc ;
                             savelimit := limit ;
                             loc := limit + 2 ;
                             limit := j + 1 ;
                             buffer [ limit ] := 124 ;
                             outputPascal ;
                             loc := saveloc ;
                             limit := savelimit ;
                           End ;
                       End ;
                     Begin
                       If outptr = linelength Then breakout ;
                       outptr := outptr + 1 ;
                       outbuf [ outptr ] := 92 ;
                       If outptr = linelength Then breakout ;
                       outptr := outptr + 1 ;
                       outbuf [ outptr ] := 88 ;
                     End ;
                   End ;
             131 , 133 , 132 :
                               Begin
                                 Begin
                                   If outptr = linelength Then breakout ;
                                   outptr := outptr + 1 ;
                                   outbuf [ outptr ] := 92 ;
                                   If outptr = linelength Then breakout ;
                                   outptr := outptr + 1 ;
                                   outbuf [ outptr ] := 109 ;
                                   If outptr = linelength Then breakout ;
                                   outptr := outptr + 1 ;
                                   outbuf [ outptr ] := 97 ;
                                   If outptr = linelength Then breakout ;
                                   outptr := outptr + 1 ;
                                   outbuf [ outptr ] := 116 ;
                                   If outptr = linelength Then breakout ;
                                   outptr := outptr + 1 ;
                                   outbuf [ outptr ] := 104 ;
                                 End ;
                                 If a = 131 Then
                                   Begin
                                     If outptr = linelength Then breakout ;
                                     outptr := outptr + 1 ;
                                     outbuf [ outptr ] := 98 ;
                                     If outptr = linelength Then breakout ;
                                     outptr := outptr + 1 ;
                                     outbuf [ outptr ] := 105 ;
                                     If outptr = linelength Then breakout ;
                                     outptr := outptr + 1 ;
                                     outbuf [ outptr ] := 110 ;
                                   End
                                 Else If a = 132 Then
                                        Begin
                                          If outptr = linelength Then breakout ;
                                          outptr := outptr + 1 ;
                                          outbuf [ outptr ] := 114 ;
                                          If outptr = linelength Then breakout ;
                                          outptr := outptr + 1 ;
                                          outbuf [ outptr ] := 101 ;
                                          If outptr = linelength Then breakout ;
                                          outptr := outptr + 1 ;
                                          outbuf [ outptr ] := 108 ;
                                        End
                                 Else
                                   Begin
                                     If outptr = linelength Then breakout ;
                                     outptr := outptr + 1 ;
                                     outbuf [ outptr ] := 111 ;
                                     If outptr = linelength Then breakout ;
                                     outptr := outptr + 1 ;
                                     outbuf [ outptr ] := 112 ;
                                   End ;
                                 Begin
                                   If outptr = linelength Then breakout ;
                                   outptr := outptr + 1 ;
                                   outbuf [ outptr ] := 123 ;
                                 End ;
                               End ;
             135 :
                   Begin
                     Repeat
                       a := getoutput ;
                     Until ( a < 139 ) Or ( a > 142 ) ;
                     goto 21 ;
                   End ;
             134 :
                   Begin
                     Repeat
                       a := getoutput ;
                     Until ( ( a < 139 ) And ( a <> 32 ) ) Or ( a > 142 ) ;
                     goto 21 ;
                   End ;
             136 , 137 , 138 , 139 , 140 , 141 , 142 : If a < 140 Then
                                                         Begin
                                                           If curstate . modefield = 1 Then
                                                             Begin
                                                               Begin
                                                                 If outptr = linelength Then breakout ;
                                                                 outptr := outptr + 1 ;
                                                                 outbuf [ outptr ] := 92 ;
                                                                 If outptr = linelength Then breakout ;
                                                                 outptr := outptr + 1 ;
                                                                 outbuf [ outptr ] := a - 87 ;
                                                               End ;
                                                               If a = 138 Then
                                                                 Begin
                                                                   If outptr = linelength Then breakout ;
                                                                   outptr := outptr + 1 ;
                                                                   outbuf [ outptr ] := getoutput ;
                                                                 End
                                                             End
                                                           Else If a = 138 Then b := getoutput
                                                         End
                                                       Else
                                                         Begin
                                                           b := a ;
                                                           savemode := curstate . modefield ;
                                                           While true Do
                                                             Begin
                                                               a := getoutput ;
                                                               If ( a = 135 ) Or ( a = 134 ) Then goto 21 ;
                                                               If ( ( a <> 32 ) And ( a < 140 ) ) Or ( a > 142 ) Then
                                                                 Begin
                                                                   If savemode = 1 Then
                                                                     Begin
                                                                       If outptr > 3 Then If ( outbuf [ outptr ] = 80 ) And ( outbuf [ outptr - 1 ] = 92 ) And ( outbuf [ outptr - 2 ] = 89 ) And ( outbuf [ outptr - 3 ] = 92 ) Then goto 21 ;
                                                                       Begin
                                                                         If outptr = linelength Then breakout ;
                                                                         outptr := outptr + 1 ;
                                                                         outbuf [ outptr ] := 92 ;
                                                                         If outptr = linelength Then breakout ;
                                                                         outptr := outptr + 1 ;
                                                                         outbuf [ outptr ] := b - 87 ;
                                                                       End ;
                                                                       If a <> 143 Then finishline ;
                                                                     End
                                                                   Else If ( a <> 143 ) And ( curstate . modefield = 0 ) Then
                                                                          Begin
                                                                            If outptr = linelength Then breakout ;
                                                                            outptr := outptr + 1 ;
                                                                            outbuf [ outptr ] := 32 ;
                                                                          End ;
                                                                   goto 21 ;
                                                                 End ;
                                                               If a > b Then b := a ;
                                                             End ;
                                                         End ;
             others :
                      Begin
                        If outptr = linelength Then breakout ;
                        outptr := outptr + 1 ;
                        outbuf [ outptr ] := a ;
                      End
           End ;
    End ;
  10 :
End ;
Procedure finishPascal ;

Var p : textpointer ;
Begin
  Begin
    If outptr = linelength Then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 92 ;
    If outptr = linelength Then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 80 ;
  End ;
  Begin
    If tokptr + 2 > maxtoks Then
      Begin
        writeln ( termout ) ;
        write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
        error ;
        history := 3 ;
        jumpout ;
      End ;
    tokmem [ tokptr ] := 141 ;
    tokptr := tokptr + 1 ;
  End ;
  appcomment ;
  p := translate ;
  tokmem [ tokptr ] := p + 40960 ;
  tokptr := tokptr + 1 ;
  makeoutput ;
  If outptr > 1 Then If outbuf [ outptr - 1 ] = 92 Then If outbuf [ outptr ] = 54 Then outptr := outptr - 2
  Else If outbuf [ outptr ] = 55 Then outbuf [ outptr ] := 89 ;
  Begin
    If outptr = linelength Then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 92 ;
    If outptr = linelength Then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 112 ;
    If outptr = linelength Then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 97 ;
    If outptr = linelength Then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 114 ;
  End ;
  finishline ;
  tokptr := 1 ;
  textptr := 1 ;
  scrapptr := 0 ;
End ;
Procedure footnote ( flag : sixteenbits ) ;

Label 30 , 10 ;

Var q : xrefnumber ;
Begin
  If xmem [ curxref ] . numfield <= flag Then goto 10 ;
  finishline ;
  Begin
    If outptr = linelength Then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 92 ;
  End ;
  If flag = 0 Then
    Begin
      If outptr = linelength Then breakout ;
      outptr := outptr + 1 ;
      outbuf [ outptr ] := 85 ;
    End
  Else
    Begin
      If outptr = linelength Then breakout ;
      outptr := outptr + 1 ;
      outbuf [ outptr ] := 65 ;
    End ;
  q := curxref ;
  If xmem [ xmem [ q ] . xlinkfield ] . numfield > flag Then
    Begin
      If outptr = linelength Then breakout ;
      outptr := outptr + 1 ;
      outbuf [ outptr ] := 115 ;
    End ;
  While true Do
    Begin
      outmod ( xmem [ curxref ] . numfield - flag ) ;
      curxref := xmem [ curxref ] . xlinkfield ;
      If xmem [ curxref ] . numfield <= flag Then goto 30 ;
      If xmem [ xmem [ curxref ] . xlinkfield ] . numfield > flag Then
        Begin
          If outptr = linelength Then breakout ;
          outptr := outptr + 1 ;
          outbuf [ outptr ] := 44 ;
          If outptr = linelength Then breakout ;
          outptr := outptr + 1 ;
          outbuf [ outptr ] := 32 ;
        End
      Else
        Begin
          Begin
            If outptr = linelength Then breakout ;
            outptr := outptr + 1 ;
            outbuf [ outptr ] := 92 ;
            If outptr = linelength Then breakout ;
            outptr := outptr + 1 ;
            outbuf [ outptr ] := 69 ;
            If outptr = linelength Then breakout ;
            outptr := outptr + 1 ;
            outbuf [ outptr ] := 84 ;
          End ;
          If curxref <> xmem [ q ] . xlinkfield Then
            Begin
              If outptr = linelength Then breakout ;
              outptr := outptr + 1 ;
              outbuf [ outptr ] := 115 ;
            End ;
        End ;
    End ;
  30 : ;
  Begin
    If outptr = linelength Then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 46 ;
  End ;
  10 :
End ;
Procedure unbucket ( d : eightbits ) ;

Var c : ASCIIcode ;
Begin
  For c := 229 Downto 0 Do
    If bucket [ collate [ c ] ] > 0 Then
      Begin
        If scrapptr > maxscraps Then
          Begin
            writeln ( termout ) ;
            write ( termout , '! Sorry, ' , 'sorting' , ' capacity exceeded' ) ;
            error ;
            history := 3 ;
            jumpout ;
          End ;
        scrapptr := scrapptr + 1 ;
        If c = 0 Then cat [ scrapptr ] := 255
        Else cat [ scrapptr ] := d ;
        trans [ scrapptr ] := bucket [ collate [ c ] ] ;
        bucket [ collate [ c ] ] := 0 ;
      End ;
End ;
Procedure modprint ( p : namepointer ) ;
Begin
  If p > 0 Then
    Begin
      modprint ( link [ p ] ) ;
      Begin
        If outptr = linelength Then breakout ;
        outptr := outptr + 1 ;
        outbuf [ outptr ] := 92 ;
        If outptr = linelength Then breakout ;
        outptr := outptr + 1 ;
        outbuf [ outptr ] := 58 ;
      End ;
      tokptr := 1 ;
      textptr := 1 ;
      scrapptr := 0 ;
      stackptr := 0 ;
      curstate . modefield := 1 ;
      tokmem [ tokptr ] := p + 30720 ;
      tokptr := tokptr + 1 ;
      makeoutput ;
      footnote ( 0 ) ;
      finishline ;
      modprint ( ilk [ p ] ) ;
    End ;
End ;
Procedure PhaseI ;
Begin
  phaseone := true ;
  phasethree := false ;
  resetinput ;
  modulecount := 0 ;
  skiplimbo ;
  changeexists := false ;
  While Not inputhasended Do
    Begin
      modulecount := modulecount + 1 ;
      If modulecount = maxmodules Then
        Begin
          writeln ( termout ) ;
          write ( termout , '! Sorry, ' , 'section number' , ' capacity exceeded' ) ;
          error ;
          history := 3 ;
          jumpout ;
        End ;
      changedmodule [ modulecount ] := changing ;
      If buffer [ loc - 1 ] = 42 Then
        Begin
          write ( termout , '*' , modulecount : 1 ) ;
          break ( termout ) ;
        End ;
      Repeat
        nextcontrol := skipTeX ;
        Case nextcontrol Of 
          126 : xrefswitch := 10240 ;
          125 : xrefswitch := 0 ;
          124 : Pascalxref ;
          131 , 132 , 133 , 146 :
                                  Begin
                                    loc := loc - 2 ;
                                    nextcontrol := getnext ;
                                    If nextcontrol <> 146 Then newxref ( idlookup ( nextcontrol - 130 ) ) ;
                                  End ;
          others :
        End ;
      Until nextcontrol >= 143 ;
      While nextcontrol <= 144 Do
        Begin
          xrefswitch := 10240 ;
          If nextcontrol = 144 Then nextcontrol := getnext
          Else
            Begin
              nextcontrol := getnext ;
              If nextcontrol = 130 Then
                Begin
                  lhs := idlookup ( 0 ) ;
                  ilk [ lhs ] := 0 ;
                  newxref ( lhs ) ;
                  nextcontrol := getnext ;
                  If nextcontrol = 30 Then
                    Begin
                      nextcontrol := getnext ;
                      If nextcontrol = 130 Then
                        Begin
                          rhs := idlookup ( 0 ) ;
                          ilk [ lhs ] := ilk [ rhs ] ;
                          ilk [ rhs ] := 0 ;
                          newxref ( rhs ) ;
                          ilk [ rhs ] := ilk [ lhs ] ;
                          nextcontrol := getnext ;
                        End ;
                    End ;
                End ;
            End ;
          outerxref ;
        End ;
      If nextcontrol <= 146 Then
        Begin
          If nextcontrol = 145 Then modxrefswitch := 0
          Else modxrefswitch := 10240 ;
          Repeat
            If nextcontrol = 146 Then newmodxref ( curmodule ) ;
            nextcontrol := getnext ;
            outerxref ;
          Until nextcontrol > 146 ;
        End ;
      If changedmodule [ modulecount ] Then changeexists := true ;
    End ;
  changedmodule [ modulecount ] := changeexists ;
  phaseone := false ;
  modcheck ( ilk [ 0 ] ) ; ;
End ;
Procedure PhaseII ;
Begin
  resetinput ;
  Begin
    writeln ( termout ) ;
    write ( termout , 'Writing the output file...' ) ;
  End ;
  modulecount := 0 ;
  copylimbo ;
  finishline ;
  flushbuffer ( 0 , false , false ) ;
  While Not inputhasended Do
    Begin
      modulecount := modulecount + 1 ;
      Begin
        If outptr = linelength Then breakout ;
        outptr := outptr + 1 ;
        outbuf [ outptr ] := 92 ;
      End ;
      If buffer [ loc - 1 ] <> 42 Then
        Begin
          If outptr = linelength Then breakout ;
          outptr := outptr + 1 ;
          outbuf [ outptr ] := 77 ;
        End
      Else
        Begin
          Begin
            If outptr = linelength Then breakout ;
            outptr := outptr + 1 ;
            outbuf [ outptr ] := 78 ;
          End ;
          write ( termout , '*' , modulecount : 1 ) ;
          break ( termout ) ;
        End ;
      outmod ( modulecount ) ;
      Begin
        If outptr = linelength Then breakout ;
        outptr := outptr + 1 ;
        outbuf [ outptr ] := 46 ;
        If outptr = linelength Then breakout ;
        outptr := outptr + 1 ;
        outbuf [ outptr ] := 32 ;
      End ;
      saveline := outline ;
      saveplace := outptr ;
      Repeat
        nextcontrol := copyTeX ;
        Case nextcontrol Of 
          124 :
                Begin
                  stackptr := 0 ;
                  curstate . modefield := 1 ;
                  outputPascal ;
                End ;
          64 :
               Begin
                 If outptr = linelength Then breakout ;
                 outptr := outptr + 1 ;
                 outbuf [ outptr ] := 64 ;
               End ;
          12 :
               Begin
                 Begin
                   If outptr = linelength Then breakout ;
                   outptr := outptr + 1 ;
                   outbuf [ outptr ] := 92 ;
                   If outptr = linelength Then breakout ;
                   outptr := outptr + 1 ;
                   outbuf [ outptr ] := 79 ;
                   If outptr = linelength Then breakout ;
                   outptr := outptr + 1 ;
                   outbuf [ outptr ] := 123 ;
                 End ;
                 While ( buffer [ loc ] >= 48 ) And ( buffer [ loc ] <= 55 ) Do
                   Begin
                     Begin
                       If outptr = linelength Then breakout ;
                       outptr := outptr + 1 ;
                       outbuf [ outptr ] := buffer [ loc ] ;
                     End ;
                     loc := loc + 1 ;
                   End ;
                 Begin
                   If outptr = linelength Then breakout ;
                   outptr := outptr + 1 ;
                   outbuf [ outptr ] := 125 ;
                 End ;
               End ;
          13 :
               Begin
                 Begin
                   If outptr = linelength Then breakout ;
                   outptr := outptr + 1 ;
                   outbuf [ outptr ] := 92 ;
                   If outptr = linelength Then breakout ;
                   outptr := outptr + 1 ;
                   outbuf [ outptr ] := 72 ;
                   If outptr = linelength Then breakout ;
                   outptr := outptr + 1 ;
                   outbuf [ outptr ] := 123 ;
                 End ;
                 While ( ( buffer [ loc ] >= 48 ) And ( buffer [ loc ] <= 57 ) ) Or ( ( buffer [ loc ] >= 65 ) And ( buffer [ loc ] <= 70 ) ) Do
                   Begin
                     Begin
                       If outptr = linelength Then breakout ;
                       outptr := outptr + 1 ;
                       outbuf [ outptr ] := buffer [ loc ] ;
                     End ;
                     loc := loc + 1 ;
                   End ;
                 Begin
                   If outptr = linelength Then breakout ;
                   outptr := outptr + 1 ;
                   outbuf [ outptr ] := 125 ;
                 End ;
               End ;
          134 , 131 , 132 , 133 , 146 :
                                        Begin
                                          loc := loc - 2 ;
                                          nextcontrol := getnext ;
                                          If nextcontrol = 134 Then
                                            Begin
                                              If Not phaseone Then
                                                Begin
                                                  writeln ( termout ) ;
                                                  write ( termout , '! TeX string should be in Pascal text only' ) ;
                                                  error ;
                                                End ;
                                            End ;
                                        End ;
          9 , 10 , 135 , 137 , 138 , 139 , 140 , 141 , 136 , 142 :
                                                                   Begin
                                                                     If Not phaseone Then
                                                                       Begin
                                                                         writeln ( termout ) ;
                                                                         write ( termout , '! You can''t do that in TeX text' ) ;
                                                                         error ;
                                                                       End ;
                                                                   End ;
          others :
        End ;
      Until nextcontrol >= 143 ;
      If nextcontrol <= 144 Then
        Begin
          If ( saveline <> outline ) Or ( saveplace <> outptr ) Then
            Begin
              If outptr = linelength Then breakout ;
              outptr := outptr + 1 ;
              outbuf [ outptr ] := 92 ;
              If outptr = linelength Then breakout ;
              outptr := outptr + 1 ;
              outbuf [ outptr ] := 89 ;
            End ;
          saveline := outline ;
          saveplace := outptr ;
        End ;
      While nextcontrol <= 144 Do
        Begin
          stackptr := 0 ;
          curstate . modefield := 1 ;
          If nextcontrol = 144 Then
            Begin
              Begin
                tokmem [ tokptr ] := 92 ;
                tokptr := tokptr + 1 ;
                tokmem [ tokptr ] := 68 ;
                tokptr := tokptr + 1 ;
                scrapptr := scrapptr + 1 ;
                cat [ scrapptr ] := 3 ;
                trans [ scrapptr ] := textptr ;
                textptr := textptr + 1 ;
                tokstart [ textptr ] := tokptr ;
              End ;
              nextcontrol := getnext ;
              If nextcontrol <> 130 Then
                Begin
                  If Not phaseone Then
                    Begin
                      writeln ( termout ) ;
                      write ( termout , '! Improper macro definition' ) ;
                      error ;
                    End ;
                End
              Else
                Begin
                  tokmem [ tokptr ] := 10240 + idlookup ( 0 ) ;
                  tokptr := tokptr + 1 ;
                  scrapptr := scrapptr + 1 ;
                  cat [ scrapptr ] := 2 ;
                  trans [ scrapptr ] := textptr ;
                  textptr := textptr + 1 ;
                  tokstart [ textptr ] := tokptr ;
                End ;
              nextcontrol := getnext ;
            End
          Else
            Begin
              Begin
                tokmem [ tokptr ] := 92 ;
                tokptr := tokptr + 1 ;
                tokmem [ tokptr ] := 70 ;
                tokptr := tokptr + 1 ;
                scrapptr := scrapptr + 1 ;
                cat [ scrapptr ] := 3 ;
                trans [ scrapptr ] := textptr ;
                textptr := textptr + 1 ;
                tokstart [ textptr ] := tokptr ;
              End ;
              nextcontrol := getnext ;
              If nextcontrol = 130 Then
                Begin
                  Begin
                    tokmem [ tokptr ] := 10240 + idlookup ( 0 ) ;
                    tokptr := tokptr + 1 ;
                    scrapptr := scrapptr + 1 ;
                    cat [ scrapptr ] := 2 ;
                    trans [ scrapptr ] := textptr ;
                    textptr := textptr + 1 ;
                    tokstart [ textptr ] := tokptr ;
                  End ;
                  nextcontrol := getnext ;
                  If nextcontrol = 30 Then
                    Begin
                      Begin
                        tokmem [ tokptr ] := 92 ;
                        tokptr := tokptr + 1 ;
                        tokmem [ tokptr ] := 83 ;
                        tokptr := tokptr + 1 ;
                        scrapptr := scrapptr + 1 ;
                        cat [ scrapptr ] := 2 ;
                        trans [ scrapptr ] := textptr ;
                        textptr := textptr + 1 ;
                        tokstart [ textptr ] := tokptr ;
                      End ;
                      nextcontrol := getnext ;
                      If nextcontrol = 130 Then
                        Begin
                          Begin
                            tokmem [ tokptr ] := 10240 + idlookup ( 0 ) ;
                            tokptr := tokptr + 1 ;
                            scrapptr := scrapptr + 1 ;
                            cat [ scrapptr ] := 2 ;
                            trans [ scrapptr ] := textptr ;
                            textptr := textptr + 1 ;
                            tokstart [ textptr ] := tokptr ;
                          End ;
                          Begin
                            scrapptr := scrapptr + 1 ;
                            cat [ scrapptr ] := 9 ;
                            trans [ scrapptr ] := 0 ;
                          End ;
                          nextcontrol := getnext ;
                        End ;
                    End ;
                End ;
              If scrapptr <> 5 Then
                Begin
                  If Not phaseone Then
                    Begin
                      writeln ( termout ) ;
                      write ( termout , '! Improper format definition' ) ;
                      error ;
                    End ;
                End ;
            End ;
          outerparse ;
          finishPascal ;
        End ;
      thismodule := 0 ;
      If nextcontrol <= 146 Then
        Begin
          If ( saveline <> outline ) Or ( saveplace <> outptr ) Then
            Begin
              If outptr = linelength Then breakout ;
              outptr := outptr + 1 ;
              outbuf [ outptr ] := 92 ;
              If outptr = linelength Then breakout ;
              outptr := outptr + 1 ;
              outbuf [ outptr ] := 89 ;
            End ;
          stackptr := 0 ;
          curstate . modefield := 1 ;
          If nextcontrol = 145 Then nextcontrol := getnext
          Else
            Begin
              thismodule := curmodule ;
              Repeat
                nextcontrol := getnext ;
              Until nextcontrol <> 43 ;
              If ( nextcontrol <> 61 ) And ( nextcontrol <> 30 ) Then
                Begin
                  If Not phaseone Then
                    Begin
                      writeln ( termout ) ;
                      write ( termout , '! You need an = sign after the section name' ) ;
                      error ;
                    End ;
                End
              Else nextcontrol := getnext ;
              If outptr > 1 Then If ( outbuf [ outptr ] = 89 ) And ( outbuf [ outptr - 1 ] = 92 ) Then
                                   Begin
                                     tokmem [ tokptr ] := 139 ;
                                     tokptr := tokptr + 1 ;
                                   End ;
              Begin
                tokmem [ tokptr ] := 30720 + thismodule ;
                tokptr := tokptr + 1 ;
                scrapptr := scrapptr + 1 ;
                cat [ scrapptr ] := 22 ;
                trans [ scrapptr ] := textptr ;
                textptr := textptr + 1 ;
                tokstart [ textptr ] := tokptr ;
              End ;
              curxref := xref [ thismodule ] ;
              If xmem [ curxref ] . numfield <> modulecount + 10240 Then
                Begin
                  Begin
                    tokmem [ tokptr ] := 132 ;
                    tokptr := tokptr + 1 ;
                    tokmem [ tokptr ] := 43 ;
                    tokptr := tokptr + 1 ;
                    tokmem [ tokptr ] := 125 ;
                    tokptr := tokptr + 1 ;
                    scrapptr := scrapptr + 1 ;
                    cat [ scrapptr ] := 2 ;
                    trans [ scrapptr ] := textptr ;
                    textptr := textptr + 1 ;
                    tokstart [ textptr ] := tokptr ;
                  End ;
                  thismodule := 0 ;
                End ;
              Begin
                tokmem [ tokptr ] := 92 ;
                tokptr := tokptr + 1 ;
                tokmem [ tokptr ] := 83 ;
                tokptr := tokptr + 1 ;
                scrapptr := scrapptr + 1 ;
                cat [ scrapptr ] := 2 ;
                trans [ scrapptr ] := textptr ;
                textptr := textptr + 1 ;
                tokstart [ textptr ] := tokptr ;
              End ;
              Begin
                tokmem [ tokptr ] := 141 ;
                tokptr := tokptr + 1 ;
                scrapptr := scrapptr + 1 ;
                cat [ scrapptr ] := 9 ;
                trans [ scrapptr ] := textptr ;
                textptr := textptr + 1 ;
                tokstart [ textptr ] := tokptr ;
              End ; ;
            End ;
          While nextcontrol <= 146 Do
            Begin
              outerparse ;
              If nextcontrol < 146 Then
                Begin
                  Begin
                    If Not phaseone Then
                      Begin
                        writeln ( termout ) ;
                        write ( termout , '! You can''t do that in Pascal text' ) ;
                        error ;
                      End ;
                  End ;
                  nextcontrol := getnext ;
                End
              Else If nextcontrol = 146 Then
                     Begin
                       Begin
                         tokmem [ tokptr ] := 30720 + curmodule ;
                         tokptr := tokptr + 1 ;
                         scrapptr := scrapptr + 1 ;
                         cat [ scrapptr ] := 22 ;
                         trans [ scrapptr ] := textptr ;
                         textptr := textptr + 1 ;
                         tokstart [ textptr ] := tokptr ;
                       End ;
                       nextcontrol := getnext ;
                     End ;
            End ;
          finishPascal ;
        End ;
      If thismodule > 0 Then
        Begin
          firstxref := xref [ thismodule ] ;
          thisxref := xmem [ firstxref ] . xlinkfield ;
          If xmem [ thisxref ] . numfield > 10240 Then
            Begin
              midxref := thisxref ;
              curxref := 0 ;
              Repeat
                nextxref := xmem [ thisxref ] . xlinkfield ;
                xmem [ thisxref ] . xlinkfield := curxref ;
                curxref := thisxref ;
                thisxref := nextxref ;
              Until xmem [ thisxref ] . numfield <= 10240 ;
              xmem [ firstxref ] . xlinkfield := curxref ;
            End
          Else midxref := 0 ;
          curxref := 0 ;
          While thisxref <> 0 Do
            Begin
              nextxref := xmem [ thisxref ] . xlinkfield ;
              xmem [ thisxref ] . xlinkfield := curxref ;
              curxref := thisxref ;
              thisxref := nextxref ;
            End ;
          If midxref > 0 Then xmem [ midxref ] . xlinkfield := curxref
          Else xmem [ firstxref ] . xlinkfield := curxref ;
          curxref := xmem [ firstxref ] . xlinkfield ;
          footnote ( 10240 ) ;
          footnote ( 0 ) ;
        End ;
      Begin
        If outptr = linelength Then breakout ;
        outptr := outptr + 1 ;
        outbuf [ outptr ] := 92 ;
        If outptr = linelength Then breakout ;
        outptr := outptr + 1 ;
        outbuf [ outptr ] := 102 ;
        If outptr = linelength Then breakout ;
        outptr := outptr + 1 ;
        outbuf [ outptr ] := 105 ;
      End ;
      finishline ;
      flushbuffer ( 0 , false , false ) ; ;
    End ;
End ;
Begin
  initialize ;
  writeln ( termout , 'This is WEAVE, Version 4.4' ) ;
  idloc := 10 ;
  idfirst := 7 ;
  buffer [ 7 ] := 97 ;
  buffer [ 8 ] := 110 ;
  buffer [ 9 ] := 100 ;
  curname := idlookup ( 28 ) ;
  idfirst := 5 ;
  buffer [ 5 ] := 97 ;
  buffer [ 6 ] := 114 ;
  buffer [ 7 ] := 114 ;
  buffer [ 8 ] := 97 ;
  buffer [ 9 ] := 121 ;
  curname := idlookup ( 4 ) ;
  idfirst := 5 ;
  buffer [ 5 ] := 98 ;
  buffer [ 6 ] := 101 ;
  buffer [ 7 ] := 103 ;
  buffer [ 8 ] := 105 ;
  buffer [ 9 ] := 110 ;
  curname := idlookup ( 5 ) ;
  idfirst := 6 ;
  buffer [ 6 ] := 99 ;
  buffer [ 7 ] := 97 ;
  buffer [ 8 ] := 115 ;
  buffer [ 9 ] := 101 ;
  curname := idlookup ( 6 ) ;
  idfirst := 5 ;
  buffer [ 5 ] := 99 ;
  buffer [ 6 ] := 111 ;
  buffer [ 7 ] := 110 ;
  buffer [ 8 ] := 115 ;
  buffer [ 9 ] := 116 ;
  curname := idlookup ( 7 ) ;
  idfirst := 7 ;
  buffer [ 7 ] := 100 ;
  buffer [ 8 ] := 105 ;
  buffer [ 9 ] := 118 ;
  curname := idlookup ( 8 ) ;
  idfirst := 8 ;
  buffer [ 8 ] := 100 ;
  buffer [ 9 ] := 111 ;
  curname := idlookup ( 9 ) ;
  idfirst := 4 ;
  buffer [ 4 ] := 100 ;
  buffer [ 5 ] := 111 ;
  buffer [ 6 ] := 119 ;
  buffer [ 7 ] := 110 ;
  buffer [ 8 ] := 116 ;
  buffer [ 9 ] := 111 ;
  curname := idlookup ( 20 ) ;
  idfirst := 6 ;
  buffer [ 6 ] := 101 ;
  buffer [ 7 ] := 108 ;
  buffer [ 8 ] := 115 ;
  buffer [ 9 ] := 101 ;
  curname := idlookup ( 10 ) ;
  idfirst := 7 ;
  buffer [ 7 ] := 101 ;
  buffer [ 8 ] := 110 ;
  buffer [ 9 ] := 100 ;
  curname := idlookup ( 11 ) ;
  idfirst := 6 ;
  buffer [ 6 ] := 102 ;
  buffer [ 7 ] := 105 ;
  buffer [ 8 ] := 108 ;
  buffer [ 9 ] := 101 ;
  curname := idlookup ( 4 ) ;
  idfirst := 7 ;
  buffer [ 7 ] := 102 ;
  buffer [ 8 ] := 111 ;
  buffer [ 9 ] := 114 ;
  curname := idlookup ( 12 ) ;
  idfirst := 2 ;
  buffer [ 2 ] := 102 ;
  buffer [ 3 ] := 117 ;
  buffer [ 4 ] := 110 ;
  buffer [ 5 ] := 99 ;
  buffer [ 6 ] := 116 ;
  buffer [ 7 ] := 105 ;
  buffer [ 8 ] := 111 ;
  buffer [ 9 ] := 110 ;
  curname := idlookup ( 17 ) ;
  idfirst := 6 ;
  buffer [ 6 ] := 103 ;
  buffer [ 7 ] := 111 ;
  buffer [ 8 ] := 116 ;
  buffer [ 9 ] := 111 ;
  curname := idlookup ( 13 ) ;
  idfirst := 8 ;
  buffer [ 8 ] := 105 ;
  buffer [ 9 ] := 102 ;
  curname := idlookup ( 14 ) ;
  idfirst := 8 ;
  buffer [ 8 ] := 105 ;
  buffer [ 9 ] := 110 ;
  curname := idlookup ( 30 ) ;
  idfirst := 5 ;
  buffer [ 5 ] := 108 ;
  buffer [ 6 ] := 97 ;
  buffer [ 7 ] := 98 ;
  buffer [ 8 ] := 101 ;
  buffer [ 9 ] := 108 ;
  curname := idlookup ( 7 ) ;
  idfirst := 7 ;
  buffer [ 7 ] := 109 ;
  buffer [ 8 ] := 111 ;
  buffer [ 9 ] := 100 ;
  curname := idlookup ( 8 ) ;
  idfirst := 7 ;
  buffer [ 7 ] := 110 ;
  buffer [ 8 ] := 105 ;
  buffer [ 9 ] := 108 ;
  curname := idlookup ( 16 ) ;
  idfirst := 7 ;
  buffer [ 7 ] := 110 ;
  buffer [ 8 ] := 111 ;
  buffer [ 9 ] := 116 ;
  curname := idlookup ( 29 ) ;
  idfirst := 8 ;
  buffer [ 8 ] := 111 ;
  buffer [ 9 ] := 102 ;
  curname := idlookup ( 9 ) ;
  idfirst := 8 ;
  buffer [ 8 ] := 111 ;
  buffer [ 9 ] := 114 ;
  curname := idlookup ( 55 ) ;
  idfirst := 4 ;
  buffer [ 4 ] := 112 ;
  buffer [ 5 ] := 97 ;
  buffer [ 6 ] := 99 ;
  buffer [ 7 ] := 107 ;
  buffer [ 8 ] := 101 ;
  buffer [ 9 ] := 100 ;
  curname := idlookup ( 13 ) ;
  idfirst := 1 ;
  buffer [ 1 ] := 112 ;
  buffer [ 2 ] := 114 ;
  buffer [ 3 ] := 111 ;
  buffer [ 4 ] := 99 ;
  buffer [ 5 ] := 101 ;
  buffer [ 6 ] := 100 ;
  buffer [ 7 ] := 117 ;
  buffer [ 8 ] := 114 ;
  buffer [ 9 ] := 101 ;
  curname := idlookup ( 17 ) ;
  idfirst := 3 ;
  buffer [ 3 ] := 112 ;
  buffer [ 4 ] := 114 ;
  buffer [ 5 ] := 111 ;
  buffer [ 6 ] := 103 ;
  buffer [ 7 ] := 114 ;
  buffer [ 8 ] := 97 ;
  buffer [ 9 ] := 109 ;
  curname := idlookup ( 17 ) ;
  idfirst := 4 ;
  buffer [ 4 ] := 114 ;
  buffer [ 5 ] := 101 ;
  buffer [ 6 ] := 99 ;
  buffer [ 7 ] := 111 ;
  buffer [ 8 ] := 114 ;
  buffer [ 9 ] := 100 ;
  curname := idlookup ( 18 ) ;
  idfirst := 4 ;
  buffer [ 4 ] := 114 ;
  buffer [ 5 ] := 101 ;
  buffer [ 6 ] := 112 ;
  buffer [ 7 ] := 101 ;
  buffer [ 8 ] := 97 ;
  buffer [ 9 ] := 116 ;
  curname := idlookup ( 19 ) ;
  idfirst := 7 ;
  buffer [ 7 ] := 115 ;
  buffer [ 8 ] := 101 ;
  buffer [ 9 ] := 116 ;
  curname := idlookup ( 4 ) ;
  idfirst := 6 ;
  buffer [ 6 ] := 116 ;
  buffer [ 7 ] := 104 ;
  buffer [ 8 ] := 101 ;
  buffer [ 9 ] := 110 ;
  curname := idlookup ( 9 ) ;
  idfirst := 8 ;
  buffer [ 8 ] := 116 ;
  buffer [ 9 ] := 111 ;
  curname := idlookup ( 20 ) ;
  idfirst := 6 ;
  buffer [ 6 ] := 116 ;
  buffer [ 7 ] := 121 ;
  buffer [ 8 ] := 112 ;
  buffer [ 9 ] := 101 ;
  curname := idlookup ( 7 ) ;
  idfirst := 5 ;
  buffer [ 5 ] := 117 ;
  buffer [ 6 ] := 110 ;
  buffer [ 7 ] := 116 ;
  buffer [ 8 ] := 105 ;
  buffer [ 9 ] := 108 ;
  curname := idlookup ( 21 ) ;
  idfirst := 7 ;
  buffer [ 7 ] := 118 ;
  buffer [ 8 ] := 97 ;
  buffer [ 9 ] := 114 ;
  curname := idlookup ( 22 ) ;
  idfirst := 5 ;
  buffer [ 5 ] := 119 ;
  buffer [ 6 ] := 104 ;
  buffer [ 7 ] := 105 ;
  buffer [ 8 ] := 108 ;
  buffer [ 9 ] := 101 ;
  curname := idlookup ( 12 ) ;
  idfirst := 6 ;
  buffer [ 6 ] := 119 ;
  buffer [ 7 ] := 105 ;
  buffer [ 8 ] := 116 ;
  buffer [ 9 ] := 104 ;
  curname := idlookup ( 12 ) ;
  idfirst := 3 ;
  buffer [ 3 ] := 120 ;
  buffer [ 4 ] := 99 ;
  buffer [ 5 ] := 108 ;
  buffer [ 6 ] := 97 ;
  buffer [ 7 ] := 117 ;
  buffer [ 8 ] := 115 ;
  buffer [ 9 ] := 101 ;
  curname := idlookup ( 23 ) ; ;
  PhaseI ;
  PhaseII ;
  phasethree := true ;
  Begin
    writeln ( termout ) ;
    write ( termout , 'Writing the index...' ) ;
  End ;
  If changeexists Then
    Begin
      finishline ;
      Begin
        kmodule := 1 ;
        Begin
          If outptr = linelength Then breakout ;
          outptr := outptr + 1 ;
          outbuf [ outptr ] := 92 ;
          If outptr = linelength Then breakout ;
          outptr := outptr + 1 ;
          outbuf [ outptr ] := 99 ;
          If outptr = linelength Then breakout ;
          outptr := outptr + 1 ;
          outbuf [ outptr ] := 104 ;
          If outptr = linelength Then breakout ;
          outptr := outptr + 1 ;
          outbuf [ outptr ] := 32 ;
        End ;
        While kmodule < modulecount Do
          Begin
            If changedmodule [ kmodule ] Then
              Begin
                outmod ( kmodule ) ;
                Begin
                  If outptr = linelength Then breakout ;
                  outptr := outptr + 1 ;
                  outbuf [ outptr ] := 44 ;
                  If outptr = linelength Then breakout ;
                  outptr := outptr + 1 ;
                  outbuf [ outptr ] := 32 ;
                End ;
              End ;
            kmodule := kmodule + 1 ;
          End ;
        outmod ( kmodule ) ;
        Begin
          If outptr = linelength Then breakout ;
          outptr := outptr + 1 ;
          outbuf [ outptr ] := 46 ;
        End ;
      End ;
    End ;
  finishline ;
  Begin
    If outptr = linelength Then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 92 ;
    If outptr = linelength Then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 105 ;
    If outptr = linelength Then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 110 ;
    If outptr = linelength Then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 120 ;
  End ;
  finishline ;
  For c := 0 To 255 Do
    bucket [ c ] := 0 ;
  For h := 0 To hashsize - 1 Do
    Begin
      nextname := hash [ h ] ;
      While nextname <> 0 Do
        Begin
          curname := nextname ;
          nextname := link [ curname ] ;
          If xref [ curname ] <> 0 Then
            Begin
              c := bytemem [ curname Mod 2 , bytestart [ curname ] ] ;
              If ( c <= 90 ) And ( c >= 65 ) Then c := c + 32 ;
              blink [ curname ] := bucket [ c ] ;
              bucket [ c ] := curname ;
            End ;
        End ;
    End ;
  scrapptr := 0 ;
  unbucket ( 1 ) ;
  While scrapptr > 0 Do
    Begin
      curdepth := cat [ scrapptr ] ;
      If ( blink [ trans [ scrapptr ] ] = 0 ) Or ( curdepth = 255 ) Then
        Begin
          curname := trans [ scrapptr ] ;
          Repeat
            Begin
              If outptr = linelength Then breakout ;
              outptr := outptr + 1 ;
              outbuf [ outptr ] := 92 ;
              If outptr = linelength Then breakout ;
              outptr := outptr + 1 ;
              outbuf [ outptr ] := 58 ;
            End ;
            Case ilk [ curname ] Of 
              0 : If bytestart [ curname + 2 ] - bytestart [ curname ] = 1 Then
                    Begin
                      If outptr = linelength Then breakout ;
                      outptr := outptr + 1 ;
                      outbuf [ outptr ] := 92 ;
                      If outptr = linelength Then breakout ;
                      outptr := outptr + 1 ;
                      outbuf [ outptr ] := 124 ;
                    End
                  Else
                    Begin
                      If outptr = linelength Then breakout ;
                      outptr := outptr + 1 ;
                      outbuf [ outptr ] := 92 ;
                      If outptr = linelength Then breakout ;
                      outptr := outptr + 1 ;
                      outbuf [ outptr ] := 92 ;
                    End ;
              1 : ;
              2 :
                  Begin
                    If outptr = linelength Then breakout ;
                    outptr := outptr + 1 ;
                    outbuf [ outptr ] := 92 ;
                    If outptr = linelength Then breakout ;
                    outptr := outptr + 1 ;
                    outbuf [ outptr ] := 57 ;
                  End ;
              3 :
                  Begin
                    If outptr = linelength Then breakout ;
                    outptr := outptr + 1 ;
                    outbuf [ outptr ] := 92 ;
                    If outptr = linelength Then breakout ;
                    outptr := outptr + 1 ;
                    outbuf [ outptr ] := 46 ;
                  End ;
              others :
                       Begin
                         If outptr = linelength Then breakout ;
                         outptr := outptr + 1 ;
                         outbuf [ outptr ] := 92 ;
                         If outptr = linelength Then breakout ;
                         outptr := outptr + 1 ;
                         outbuf [ outptr ] := 38 ;
                       End
            End ;
            outname ( curname ) ;
            thisxref := xref [ curname ] ;
            curxref := 0 ;
            Repeat
              nextxref := xmem [ thisxref ] . xlinkfield ;
              xmem [ thisxref ] . xlinkfield := curxref ;
              curxref := thisxref ;
              thisxref := nextxref ;
            Until thisxref = 0 ;
            Repeat
              Begin
                If outptr = linelength Then breakout ;
                outptr := outptr + 1 ;
                outbuf [ outptr ] := 44 ;
                If outptr = linelength Then breakout ;
                outptr := outptr + 1 ;
                outbuf [ outptr ] := 32 ;
              End ;
              curval := xmem [ curxref ] . numfield ;
              If curval < 10240 Then outmod ( curval )
              Else
                Begin
                  Begin
                    If outptr = linelength Then breakout ;
                    outptr := outptr + 1 ;
                    outbuf [ outptr ] := 92 ;
                    If outptr = linelength Then breakout ;
                    outptr := outptr + 1 ;
                    outbuf [ outptr ] := 91 ;
                  End ;
                  outmod ( curval - 10240 ) ;
                  Begin
                    If outptr = linelength Then breakout ;
                    outptr := outptr + 1 ;
                    outbuf [ outptr ] := 93 ;
                  End ;
                End ;
              curxref := xmem [ curxref ] . xlinkfield ;
            Until curxref = 0 ;
            Begin
              If outptr = linelength Then breakout ;
              outptr := outptr + 1 ;
              outbuf [ outptr ] := 46 ;
            End ;
            finishline ;
            curname := blink [ curname ] ;
          Until curname = 0 ;
          scrapptr := scrapptr - 1 ;
        End
      Else
        Begin
          nextname := trans [ scrapptr ] ;
          Repeat
            curname := nextname ;
            nextname := blink [ curname ] ;
            curbyte := bytestart [ curname ] + curdepth ;
            curbank := curname Mod 2 ;
            If curbyte = bytestart [ curname + 2 ] Then c := 0
            Else
              Begin
                c := bytemem [ curbank , curbyte ] ;
                If ( c <= 90 ) And ( c >= 65 ) Then c := c + 32 ;
              End ;
            blink [ curname ] := bucket [ c ] ;
            bucket [ c ] := curname ;
          Until nextname = 0 ;
          scrapptr := scrapptr - 1 ;
          unbucket ( curdepth + 1 ) ;
        End ;
    End ;
  Begin
    If outptr = linelength Then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 92 ;
    If outptr = linelength Then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 102 ;
    If outptr = linelength Then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 105 ;
    If outptr = linelength Then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 110 ;
  End ;
  finishline ;
  modprint ( ilk [ 0 ] ) ;
  Begin
    If outptr = linelength Then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 92 ;
    If outptr = linelength Then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 99 ;
    If outptr = linelength Then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 111 ;
    If outptr = linelength Then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 110 ;
  End ;
  finishline ;
  write ( termout , 'Done.' ) ; ;
  If changelimit <> 0 Then
    Begin
      For ii := 0 To changelimit Do
        buffer [ ii ] := changebuffer [ ii ] ;
      limit := changelimit ;
      changing := true ;
      line := otherline ;
      loc := changelimit ;
      Begin
        If Not phaseone Then
          Begin
            writeln ( termout ) ;
            write ( termout , '! Change file entry did not match' ) ;
            error ;
          End ;
      End ;
    End ;
  9999 : Case history Of 
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
