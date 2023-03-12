
program WEAVE ( webfile , changefile , texfile ) ;

label 9999 ;

const maxbytes = 45000 ;
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

type ASCIIcode = 0 .. 255 ;
  textfile = packed file of char ;
  eightbits = 0 .. 255 ;
  sixteenbits = 0 .. 65535 ;
  namepointer = 0 .. maxnames ;
  xrefnumber = 0 .. maxrefs ;
  textpointer = 0 .. maxtexts ;
  mode = 0 .. 1 ;
  outputstate = record
    endfield : sixteenbits ;
    tokfield : sixteenbits ;
    modefield : mode ;
  end ;

var history : 0 .. 3 ;
  xord : array [ char ] of ASCIIcode ;
  xchr : array [ ASCIIcode ] of char ;
  termout : textfile ;
  webfile : textfile ;
  changefile : textfile ;
  texfile : textfile ;
  buffer : array [ 0 .. longbufsize ] of ASCIIcode ;
  phaseone : boolean ;
  phasethree : boolean ;
  bytemem : packed array [ 0 .. 1 , 0 .. maxbytes ] of ASCIIcode ;
  bytestart : array [ 0 .. maxnames ] of sixteenbits ;
  link : array [ 0 .. maxnames ] of sixteenbits ;
  ilk : array [ 0 .. maxnames ] of sixteenbits ;
  xref : array [ 0 .. maxnames ] of sixteenbits ;
  nameptr : namepointer ;
  byteptr : array [ 0 .. 1 ] of 0 .. maxbytes ;
  modulecount : 0 .. maxmodules ;
  changedmodule : packed array [ 0 .. maxmodules ] of boolean ;
  changeexists : boolean ;
  xmem : array [ xrefnumber ] of packed record
    numfield : sixteenbits ;
    xlinkfield : sixteenbits ;
  end ;
  xrefptr : xrefnumber ;
  xrefswitch , modxrefswitch : 0 .. 10240 ;
  tokmem : packed array [ 0 .. maxtoks ] of sixteenbits ;
  tokstart : array [ textpointer ] of sixteenbits ;
  textptr : textpointer ;
  tokptr : 0 .. maxtoks ;
  idfirst : 0 .. longbufsize ;
  idloc : 0 .. longbufsize ;
  hash : array [ 0 .. hashsize ] of sixteenbits ;
  curname : namepointer ;
  modtext : array [ 0 .. longestname ] of ASCIIcode ;
  ii : integer ;
  line : integer ;
  otherline : integer ;
  templine : integer ;
  limit : 0 .. longbufsize ;
  loc : 0 .. longbufsize ;
  inputhasended : boolean ;
  changing : boolean ;
  changepending : boolean ;
  changebuffer : array [ 0 .. bufsize ] of ASCIIcode ;
  changelimit : 0 .. bufsize ;
  curmodule : namepointer ;
  scanninghex : boolean ;
  nextcontrol : eightbits ;
  lhs , rhs : namepointer ;
  curxref : xrefnumber ;
  outbuf : array [ 0 .. linelength ] of ASCIIcode ;
  outptr : 0 .. linelength ;
  outline : integer ;
  dig : array [ 0 .. 4 ] of 0 .. 9 ;
  cat : array [ 0 .. maxscraps ] of eightbits ;
  trans : array [ 0 .. maxscraps ] of 0 .. 10239 ;
  pp : 0 .. maxscraps ;
  scrapbase : 0 .. maxscraps ;
  scrapptr : 0 .. maxscraps ;
  loptr : 0 .. maxscraps ;
  hiptr : 0 .. maxscraps ;
  curstate : outputstate ;
  stack : array [ 1 .. stacksize ] of outputstate ;
  stackptr : 0 .. stacksize ;
  saveline : integer ;
  saveplace : sixteenbits ;
  thismodule : namepointer ;
  nextxref , thisxref , firstxref , midxref : xrefnumber ;
  kmodule : 0 .. maxmodules ;
  bucket : array [ ASCIIcode ] of namepointer ;
  nextname : namepointer ;
  c : ASCIIcode ;
  h : 0 .. hashsize ;
  blink : array [ 0 .. maxnames ] of sixteenbits ;
  curdepth : eightbits ;
  curbyte : 0 .. maxbytes ;
  curbank : 0 .. 1 ;
  curval : sixteenbits ;
  collate : array [ 0 .. 229 ] of ASCIIcode ;
procedure error ;

var k , l : 0 .. longbufsize ;
begin
  begin
    if changing then write ( termout , '. (change file ' )
    else write ( termout , '. (' ) ;
    writeln ( termout , 'l.' , line : 1 , ')' ) ;
    if loc >= limit then l := limit
    else l := loc ;
    for k := 1 to l do
      if buffer [ k - 1 ] = 9 then write ( termout , ' ' )
      else write ( termout , xchr [ buffer [ k - 1 ] ] ) ;
    writeln ( termout ) ;
    for k := 1 to l do
      write ( termout , ' ' ) ;
    for k := l + 1 to limit do
      write ( termout , xchr [ buffer [ k - 1 ] ] ) ;
    if buffer [ limit ] = 124 then write ( termout , xchr [ 124 ] ) ;
    write ( termout , ' ' ) ;
  end ;
  break ( termout ) ;
  history := 2 ;
end ;
procedure jumpout ;
begin
  goto 9999 ;
end ;
procedure initialize ;

var i : 0 .. 255 ;
  wi : 0 .. 1 ;
  h : 0 .. hashsize ;
  c : ASCIIcode ;
begin
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
  for i := 1 to 31 do
    xchr [ i ] := ' ' ;
  for i := 128 to 255 do
    xchr [ i ] := ' ' ;
  for i := 0 to 255 do
    xord [ chr ( i ) ] := 32 ;
  for i := 1 to 255 do
    xord [ xchr [ i ] ] := i ;
  xord [ ' ' ] := 32 ;
  rewrite ( termout , 'TTY:' ) ;
  rewrite ( texfile ) ;
  for wi := 0 to 1 do
    begin
      bytestart [ wi ] := 0 ;
      byteptr [ wi ] := 0 ;
    end ;
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
  for h := 0 to hashsize - 1 do
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
  for c := 1 to 31 do
    collate [ c + 1 ] := c ;
  for c := 33 to 47 do
    collate [ c ] := c ;
  for c := 58 to 64 do
    collate [ c - 10 ] := c ;
  for c := 91 to 94 do
    collate [ c - 36 ] := c ;
  collate [ 59 ] := 96 ;
  for c := 123 to 255 do
    collate [ c - 63 ] := c ;
  collate [ 193 ] := 95 ;
  for c := 97 to 122 do
    collate [ c + 97 ] := c ;
  for c := 48 to 57 do
    collate [ c + 172 ] := c ;
end ;
procedure openinput ;
begin
  reset ( webfile ) ;
  reset ( changefile ) ;
end ;
function inputln ( var f : textfile ) : boolean ;

var finallimit : 0 .. bufsize ;
begin
  limit := 0 ;
  finallimit := 0 ;
  if eof ( f ) then inputln := false
  else
    begin
      while not eoln ( f ) do
        begin
          buffer [ limit ] := xord [ f ^ ] ;
          get ( f ) ;
          limit := limit + 1 ;
          if buffer [ limit - 1 ] <> 32 then finallimit := limit ;
          if limit = bufsize then
            begin
              while not eoln ( f ) do
                get ( f ) ;
              limit := limit - 1 ;
              if finallimit > limit then finallimit := limit ;
              begin
                writeln ( termout ) ;
                write ( termout , '! Input line too long' ) ;
              end ;
              loc := 0 ;
              error ;
            end ;
        end ;
      readln ( f ) ;
      limit := finallimit ;
      inputln := true ;
    end ;
end ;
procedure printid ( p : namepointer ) ;

var k : 0 .. maxbytes ;
  w : 0 .. 1 ;
begin
  if p >= nameptr then write ( termout , 'IMPOSSIBLE' )
  else
    begin
      w := p mod 2 ;
      for k := bytestart [ p ] to bytestart [ p + 2 ] - 1 do
        write ( termout , xchr [ bytemem [ w , k ] ] ) ;
    end ;
end ;
procedure newxref ( p : namepointer ) ;

label 10 ;

var q : xrefnumber ;
  m , n : sixteenbits ;
begin
  if ( ( ilk [ p ] > 3 ) or ( bytestart [ p ] + 1 = bytestart [ p + 2 ] ) ) and ( xrefswitch = 0 ) then goto 10 ;
  m := modulecount + xrefswitch ;
  xrefswitch := 0 ;
  q := xref [ p ] ;
  if q > 0 then
    begin
      n := xmem [ q ] . numfield ;
      if ( n = m ) or ( n = m + 10240 ) then goto 10
      else if m = n + 10240 then
             begin
               xmem [ q ] . numfield := m ;
               goto 10 ;
             end ;
    end ;
  if xrefptr = maxrefs then
    begin
      writeln ( termout ) ;
      write ( termout , '! Sorry, ' , 'cross reference' , ' capacity exceeded' ) ;
      error ;
      history := 3 ;
      jumpout ;
    end
  else
    begin
      xrefptr := xrefptr + 1 ;
      xmem [ xrefptr ] . numfield := m ;
    end ;
  xmem [ xrefptr ] . xlinkfield := q ;
  xref [ p ] := xrefptr ;
  10 :
end ;
procedure newmodxref ( p : namepointer ) ;

var q , r : xrefnumber ;
begin
  q := xref [ p ] ;
  r := 0 ;
  if q > 0 then
    begin
      if modxrefswitch = 0 then while xmem [ q ] . numfield >= 10240 do
                                  begin
                                    r := q ;
                                    q := xmem [ q ] . xlinkfield ;
                                  end
                                  else if xmem [ q ] . numfield >= 10240 then
                                         begin
                                           r := q ;
                                           q := xmem [ q ] . xlinkfield ;
                                         end ;
    end ;
  if xrefptr = maxrefs then
    begin
      writeln ( termout ) ;
      write ( termout , '! Sorry, ' , 'cross reference' , ' capacity exceeded' ) ;
      error ;
      history := 3 ;
      jumpout ;
    end
  else
    begin
      xrefptr := xrefptr + 1 ;
      xmem [ xrefptr ] . numfield := modulecount + modxrefswitch ;
    end ;
  xmem [ xrefptr ] . xlinkfield := q ;
  modxrefswitch := 0 ;
  if r = 0 then xref [ p ] := xrefptr
  else xmem [ r ] . xlinkfield := xrefptr ;
end ;
function idlookup ( t : eightbits ) : namepointer ;

label 31 ;

var i : 0 .. longbufsize ;
  h : 0 .. hashsize ;
  k : 0 .. maxbytes ;
  w : 0 .. 1 ;
  l : 0 .. longbufsize ;
  p : namepointer ;
begin
  l := idloc - idfirst ;
  h := buffer [ idfirst ] ;
  i := idfirst + 1 ;
  while i < idloc do
    begin
      h := ( h + h + buffer [ i ] ) mod hashsize ;
      i := i + 1 ;
    end ;
  p := hash [ h ] ;
  while p <> 0 do
    begin
      if ( bytestart [ p + 2 ] - bytestart [ p ] = l ) and ( ( ilk [ p ] = t ) or ( ( t = 0 ) and ( ilk [ p ] > 3 ) ) ) then
        begin
          i := idfirst ;
          k := bytestart [ p ] ;
          w := p mod 2 ;
          while ( i < idloc ) and ( buffer [ i ] = bytemem [ w , k ] ) do
            begin
              i := i + 1 ;
              k := k + 1 ;
            end ;
          if i = idloc then goto 31 ;
        end ;
      p := link [ p ] ;
    end ;
  p := nameptr ;
  link [ p ] := hash [ h ] ;
  hash [ h ] := p ;
  31 : ;
  if p = nameptr then
    begin
      w := nameptr mod 2 ;
      if byteptr [ w ] + l > maxbytes then
        begin
          writeln ( termout ) ;
          write ( termout , '! Sorry, ' , 'byte memory' , ' capacity exceeded' ) ;
          error ;
          history := 3 ;
          jumpout ;
        end ;
      if nameptr + 2 > maxnames then
        begin
          writeln ( termout ) ;
          write ( termout , '! Sorry, ' , 'name' , ' capacity exceeded' ) ;
          error ;
          history := 3 ;
          jumpout ;
        end ;
      i := idfirst ;
      k := byteptr [ w ] ;
      while i < idloc do
        begin
          bytemem [ w , k ] := buffer [ i ] ;
          k := k + 1 ;
          i := i + 1 ;
        end ;
      byteptr [ w ] := k ;
      bytestart [ nameptr + 2 ] := k ;
      nameptr := nameptr + 1 ;
      ilk [ p ] := t ;
      xref [ p ] := 0 ;
    end ;
  idlookup := p ;
end ;
function modlookup ( l : sixteenbits ) : namepointer ;

label 31 ;

var c : 0 .. 4 ;
  j : 0 .. longestname ;
  k : 0 .. maxbytes ;
  w : 0 .. 1 ;
  p : namepointer ;
  q : namepointer ;
begin
  c := 2 ;
  q := 0 ;
  p := ilk [ 0 ] ;
  while p <> 0 do
    begin
      begin
        k := bytestart [ p ] ;
        w := p mod 2 ;
        c := 1 ;
        j := 1 ;
        while ( k < bytestart [ p + 2 ] ) and ( j <= l ) and ( modtext [ j ] = bytemem [ w , k ] ) do
          begin
            k := k + 1 ;
            j := j + 1 ;
          end ;
        if k = bytestart [ p + 2 ] then if j > l then c := 1
        else c := 4
        else if j > l then c := 3
        else if modtext [ j ] < bytemem [ w , k ] then c := 0
        else c := 2 ;
      end ;
      q := p ;
      if c = 0 then p := link [ q ]
      else if c = 2 then p := ilk [ q ]
      else goto 31 ;
    end ;
  w := nameptr mod 2 ;
  k := byteptr [ w ] ;
  if k + l > maxbytes then
    begin
      writeln ( termout ) ;
      write ( termout , '! Sorry, ' , 'byte memory' , ' capacity exceeded' ) ;
      error ;
      history := 3 ;
      jumpout ;
    end ;
  if nameptr > maxnames - 2 then
    begin
      writeln ( termout ) ;
      write ( termout , '! Sorry, ' , 'name' , ' capacity exceeded' ) ;
      error ;
      history := 3 ;
      jumpout ;
    end ;
  p := nameptr ;
  if c = 0 then link [ q ] := p
  else ilk [ q ] := p ;
  link [ p ] := 0 ;
  ilk [ p ] := 0 ;
  xref [ p ] := 0 ;
  c := 1 ;
  for j := 1 to l do
    bytemem [ w , k + j - 1 ] := modtext [ j ] ;
  byteptr [ w ] := k + l ;
  bytestart [ nameptr + 2 ] := k + l ;
  nameptr := nameptr + 1 ; ;
  31 : if c <> 1 then
         begin
           begin
             if not phaseone then
               begin
                 writeln ( termout ) ;
                 write ( termout , '! Incompatible section names' ) ;
                 error ;
               end ;
           end ;
           p := 0 ;
         end ;
  modlookup := p ;
end ;
function prefixlookup ( l : sixteenbits ) : namepointer ;

var c : 0 .. 4 ;
  count : 0 .. maxnames ;
  j : 0 .. longestname ;
  k : 0 .. maxbytes ;
  w : 0 .. 1 ;
  p : namepointer ;
  q : namepointer ;
  r : namepointer ;
begin
  q := 0 ;
  p := ilk [ 0 ] ;
  count := 0 ;
  r := 0 ;
  while p <> 0 do
    begin
      begin
        k := bytestart [ p ] ;
        w := p mod 2 ;
        c := 1 ;
        j := 1 ;
        while ( k < bytestart [ p + 2 ] ) and ( j <= l ) and ( modtext [ j ] = bytemem [ w , k ] ) do
          begin
            k := k + 1 ;
            j := j + 1 ;
          end ;
        if k = bytestart [ p + 2 ] then if j > l then c := 1
        else c := 4
        else if j > l then c := 3
        else if modtext [ j ] < bytemem [ w , k ] then c := 0
        else c := 2 ;
      end ;
      if c = 0 then p := link [ p ]
      else if c = 2 then p := ilk [ p ]
      else
        begin
          r := p ;
          count := count + 1 ;
          q := ilk [ p ] ;
          p := link [ p ] ;
        end ;
      if p = 0 then
        begin
          p := q ;
          q := 0 ;
        end ;
    end ;
  if count <> 1 then if count = 0 then
                       begin
                         if not phaseone then
                           begin
                             writeln ( termout ) ;
                             write ( termout , '! Name does not match' ) ;
                             error ;
                           end ;
                       end
  else
    begin
      if not phaseone then
        begin
          writeln ( termout ) ;
          write ( termout , '! Ambiguous prefix' ) ;
          error ;
        end ;
    end ;
  prefixlookup := r ;
end ;
function linesdontmatch : boolean ;

label 10 ;

var k : 0 .. bufsize ;
begin
  linesdontmatch := true ;
  if changelimit <> limit then goto 10 ;
  if limit > 0 then for k := 0 to limit - 1 do
                      if changebuffer [ k ] <> buffer [ k ] then goto 10 ;
  linesdontmatch := false ;
  10 :
end ;
procedure primethechangebuffer ;

label 22 , 30 , 10 ;

var k : 0 .. bufsize ;
begin
  changelimit := 0 ;
  while true do
    begin
      line := line + 1 ;
      if not inputln ( changefile ) then goto 10 ;
      if limit < 2 then goto 22 ;
      if buffer [ 0 ] <> 64 then goto 22 ;
      if ( buffer [ 1 ] >= 88 ) and ( buffer [ 1 ] <= 90 ) then buffer [ 1 ] := buffer [ 1 ] + 32 ;
      if buffer [ 1 ] = 120 then goto 30 ;
      if ( buffer [ 1 ] = 121 ) or ( buffer [ 1 ] = 122 ) then
        begin
          loc := 2 ;
          begin
            if not phaseone then
              begin
                writeln ( termout ) ;
                write ( termout , '! Where is the matching @x?' ) ;
                error ;
              end ;
          end ;
        end ;
      22 :
    end ;
  30 : ;
  repeat
    line := line + 1 ;
    if not inputln ( changefile ) then
      begin
        begin
          if not phaseone then
            begin
              writeln ( termout ) ;
              write ( termout , '! Change file ended after @x' ) ;
              error ;
            end ;
        end ;
        goto 10 ;
      end ;
  until limit > 0 ; ;
  begin
    changelimit := limit ;
    if limit > 0 then for k := 0 to limit - 1 do
                        changebuffer [ k ] := buffer [ k ] ;
  end ;
  10 :
end ;
procedure checkchange ;

label 10 ;

var n : integer ;
  k : 0 .. bufsize ;
begin
  if linesdontmatch then goto 10 ;
  changepending := false ;
  if not changedmodule [ modulecount ] then
    begin
      loc := 0 ;
      buffer [ limit ] := 33 ;
      while ( buffer [ loc ] = 32 ) or ( buffer [ loc ] = 9 ) do
        loc := loc + 1 ;
      buffer [ limit ] := 32 ;
      if buffer [ loc ] = 64 then if ( buffer [ loc + 1 ] = 42 ) or ( buffer [ loc + 1 ] = 32 ) or ( buffer [ loc + 1 ] = 9 ) then changepending := true ;
      if not changepending then changedmodule [ modulecount ] := true ;
    end ;
  n := 0 ;
  while true do
    begin
      changing := not changing ;
      templine := otherline ;
      otherline := line ;
      line := templine ;
      line := line + 1 ;
      if not inputln ( changefile ) then
        begin
          begin
            if not phaseone then
              begin
                writeln ( termout ) ;
                write ( termout , '! Change file ended before @y' ) ;
                error ;
              end ;
          end ;
          changelimit := 0 ;
          changing := not changing ;
          templine := otherline ;
          otherline := line ;
          line := templine ;
          goto 10 ;
        end ;
      if limit > 1 then if buffer [ 0 ] = 64 then
                          begin
                            if ( buffer [ 1 ] >= 88 ) and ( buffer [ 1 ] <= 90 ) then buffer [ 1 ] := buffer [ 1 ] + 32 ;
                            if ( buffer [ 1 ] = 120 ) or ( buffer [ 1 ] = 122 ) then
                              begin
                                loc := 2 ;
                                begin
                                  if not phaseone then
                                    begin
                                      writeln ( termout ) ;
                                      write ( termout , '! Where is the matching @y?' ) ;
                                      error ;
                                    end ;
                                end ;
                              end
                            else if buffer [ 1 ] = 121 then
                                   begin
                                     if n > 0 then
                                       begin
                                         loc := 2 ;
                                         begin
                                           if not phaseone then
                                             begin
                                               writeln ( termout ) ;
                                               write ( termout , '! Hmm... ' , n : 1 , ' of the preceding lines failed to match' ) ;
                                               error ;
                                             end ;
                                         end ;
                                       end ;
                                     goto 10 ;
                                   end ;
                          end ;
      begin
        changelimit := limit ;
        if limit > 0 then for k := 0 to limit - 1 do
                            changebuffer [ k ] := buffer [ k ] ;
      end ;
      changing := not changing ;
      templine := otherline ;
      otherline := line ;
      line := templine ;
      line := line + 1 ;
      if not inputln ( webfile ) then
        begin
          begin
            if not phaseone then
              begin
                writeln ( termout ) ;
                write ( termout , '! WEB file ended during a change' ) ;
                error ;
              end ;
          end ;
          inputhasended := true ;
          goto 10 ;
        end ;
      if linesdontmatch then n := n + 1 ;
    end ;
  10 :
end ;
procedure resetinput ;
begin
  openinput ;
  line := 0 ;
  otherline := 0 ;
  changing := true ;
  primethechangebuffer ;
  changing := not changing ;
  templine := otherline ;
  otherline := line ;
  line := templine ;
  limit := 0 ;
  loc := 1 ;
  buffer [ 0 ] := 32 ;
  inputhasended := false ;
end ;
procedure getline ;

label 20 ;
begin
  20 : if changing then
         begin
           line := line + 1 ;
           if not inputln ( changefile ) then
             begin
               begin
                 if not phaseone then
                   begin
                     writeln ( termout ) ;
                     write ( termout , '! Change file ended without @z' ) ;
                     error ;
                   end ;
               end ;
               buffer [ 0 ] := 64 ;
               buffer [ 1 ] := 122 ;
               limit := 2 ;
             end ;
           if limit > 0 then
             begin
               if changepending then
                 begin
                   loc := 0 ;
                   buffer [ limit ] := 33 ;
                   while ( buffer [ loc ] = 32 ) or ( buffer [ loc ] = 9 ) do
                     loc := loc + 1 ;
                   buffer [ limit ] := 32 ;
                   if buffer [ loc ] = 64 then if ( buffer [ loc + 1 ] = 42 ) or ( buffer [ loc + 1 ] = 32 ) or ( buffer [ loc + 1 ] = 9 ) then changepending := false ;
                   if changepending then
                     begin
                       changedmodule [ modulecount ] := true ;
                       changepending := false ;
                     end ;
                 end ;
               buffer [ limit ] := 32 ;
               if buffer [ 0 ] = 64 then
                 begin
                   if ( buffer [ 1 ] >= 88 ) and ( buffer [ 1 ] <= 90 ) then buffer [ 1 ] := buffer [ 1 ] + 32 ;
                   if ( buffer [ 1 ] = 120 ) or ( buffer [ 1 ] = 121 ) then
                     begin
                       loc := 2 ;
                       begin
                         if not phaseone then
                           begin
                             writeln ( termout ) ;
                             write ( termout , '! Where is the matching @z?' ) ;
                             error ;
                           end ;
                       end ;
                     end
                   else if buffer [ 1 ] = 122 then
                          begin
                            primethechangebuffer ;
                            changing := not changing ;
                            templine := otherline ;
                            otherline := line ;
                            line := templine ;
                          end ;
                 end ;
             end ;
         end ;
  if not changing then
    begin
      begin
        line := line + 1 ;
        if not inputln ( webfile ) then inputhasended := true
        else if limit = changelimit then if buffer [ 0 ] = changebuffer [ 0 ] then if changelimit > 0 then checkchange ;
      end ;
      if changing then goto 20 ;
    end ;
  loc := 0 ;
  buffer [ limit ] := 32 ;
end ;
function controlcode ( c : ASCIIcode ) : eightbits ;
begin
  case c of 
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
         begin
           begin
             if not phaseone then
               begin
                 writeln ( termout ) ;
                 write ( termout , '! Extra @>' ) ;
                 error ;
               end ;
           end ;
           controlcode := 0 ;
         end ;
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
             begin
               begin
                 if not phaseone then
                   begin
                     writeln ( termout ) ;
                     write ( termout , '! Unknown control code' ) ;
                     error ;
                   end ;
               end ;
               controlcode := 0 ;
             end
  end ;
end ;
procedure skiplimbo ;

label 10 ;

var c : ASCIIcode ;
begin
  while true do
    if loc > limit then
      begin
        getline ;
        if inputhasended then goto 10 ;
      end
    else
      begin
        buffer [ limit + 1 ] := 64 ;
        while buffer [ loc ] <> 64 do
          loc := loc + 1 ;
        if loc <= limit then
          begin
            loc := loc + 2 ;
            c := buffer [ loc - 1 ] ;
            if ( c = 32 ) or ( c = 9 ) or ( c = 42 ) then goto 10 ;
          end ;
      end ;
  10 :
end ;
function skipTeX : eightbits ;

label 30 ;

var c : eightbits ;
begin
  while true do
    begin
      if loc > limit then
        begin
          getline ;
          if inputhasended then
            begin
              c := 147 ;
              goto 30 ;
            end ;
        end ;
      buffer [ limit + 1 ] := 64 ;
      repeat
        c := buffer [ loc ] ;
        loc := loc + 1 ;
        if c = 124 then goto 30 ;
      until c = 64 ;
      if loc <= limit then
        begin
          c := controlcode ( buffer [ loc ] ) ;
          loc := loc + 1 ;
          goto 30 ;
        end ;
    end ;
  30 : skipTeX := c ;
end ;
function skipcomment ( bal : eightbits ) : eightbits ;

label 30 ;

var c : ASCIIcode ;
begin
  while true do
    begin
      if loc > limit then
        begin
          getline ;
          if inputhasended then
            begin
              bal := 0 ;
              goto 30 ;
            end ;
        end ;
      c := buffer [ loc ] ;
      loc := loc + 1 ;
      if c = 124 then goto 30 ;
      if c = 64 then
        begin
          c := buffer [ loc ] ;
          if ( c <> 32 ) and ( c <> 9 ) and ( c <> 42 ) then loc := loc + 1
          else
            begin
              loc := loc - 1 ;
              bal := 0 ;
              goto 30 ;
            end
        end
      else if ( c = 92 ) and ( buffer [ loc ] <> 64 ) then loc := loc + 1
      else if c = 123 then bal := bal + 1
      else if c = 125 then
             begin
               bal := bal - 1 ;
               if bal = 0 then goto 30 ;
             end ;
    end ;
  30 : skipcomment := bal ;
end ;
function getnext : eightbits ;

label 20 , 30 , 31 ;

var c : eightbits ;
  d : eightbits ;
  j , k : 0 .. longestname ;
begin
  20 : if loc > limit then
         begin
           getline ;
           if inputhasended then
             begin
               c := 147 ;
               goto 31 ;
             end ;
         end ;
  c := buffer [ loc ] ;
  loc := loc + 1 ;
  if scanninghex then if ( ( c >= 48 ) and ( c <= 57 ) ) or ( ( c >= 65 ) and ( c <= 70 ) ) then goto 31
  else scanninghex := false ;
  case c of 
    65 , 66 , 67 , 68 , 69 , 70 , 71 , 72 , 73 , 74 , 75 , 76 , 77 , 78 , 79 , 80 , 81 , 82 , 83 , 84 , 85 , 86 , 87 , 88 , 89 , 90 , 97 , 98 , 99 , 100 , 101 , 102 , 103 , 104 , 105 , 106 , 107 , 108 , 109 , 110 , 111 , 112 , 113 , 114 , 115 , 116 , 117 , 118 , 119 , 120 , 121 , 122 :
                                                                                                                                                                                                                                                                                               begin
                                                                                                                                                                                                                                                                                                 if ( ( c = 69 ) or ( c = 101 ) ) and ( loc > 1 ) then if ( buffer [ loc - 2 ] <= 57 ) and ( buffer [ loc - 2 ] >= 48 ) then c := 128 ;
                                                                                                                                                                                                                                                                                                 if c <> 128 then
                                                                                                                                                                                                                                                                                                   begin
                                                                                                                                                                                                                                                                                                     loc := loc - 1 ;
                                                                                                                                                                                                                                                                                                     idfirst := loc ;
                                                                                                                                                                                                                                                                                                     repeat
                                                                                                                                                                                                                                                                                                       loc := loc + 1 ;
                                                                                                                                                                                                                                                                                                       d := buffer [ loc ] ;
                                                                                                                                                                                                                                                                                                     until ( ( d < 48 ) or ( ( d > 57 ) and ( d < 65 ) ) or ( ( d > 90 ) and ( d < 97 ) ) or ( d > 122 ) ) and ( d <> 95 ) ;
                                                                                                                                                                                                                                                                                                     c := 130 ;
                                                                                                                                                                                                                                                                                                     idloc := loc ;
                                                                                                                                                                                                                                                                                                   end ;
                                                                                                                                                                                                                                                                                               end ;
    39 , 34 :
              begin
                idfirst := loc - 1 ;
                repeat
                  d := buffer [ loc ] ;
                  loc := loc + 1 ;
                  if loc > limit then
                    begin
                      begin
                        if not phaseone then
                          begin
                            writeln ( termout ) ;
                            write ( termout , '! String constant didn''t end' ) ;
                            error ;
                          end ;
                      end ;
                      loc := limit ;
                      d := c ;
                    end ;
                until d = c ;
                idloc := loc ;
                c := 129 ;
              end ;
    64 :
         begin
           c := controlcode ( buffer [ loc ] ) ;
           loc := loc + 1 ;
           if c = 126 then
             begin
               xrefswitch := 10240 ;
               goto 20 ;
             end
           else if c = 125 then
                  begin
                    xrefswitch := 0 ;
                    goto 20 ;
                  end
           else if ( c <= 134 ) and ( c >= 131 ) then
                  begin
                    idfirst := loc ;
                    buffer [ limit + 1 ] := 64 ;
                    while buffer [ loc ] <> 64 do
                      loc := loc + 1 ;
                    idloc := loc ;
                    if loc > limit then
                      begin
                        begin
                          if not phaseone then
                            begin
                              writeln ( termout ) ;
                              write ( termout , '! Control text didn''t end' ) ;
                              error ;
                            end ;
                        end ;
                        loc := limit ;
                      end
                    else
                      begin
                        loc := loc + 2 ;
                        if buffer [ loc - 1 ] <> 62 then
                          begin
                            if not phaseone then
                              begin
                                writeln ( termout ) ;
                                write ( termout , '! Control codes are forbidden in control text' ) ;
                                error ;
                              end ;
                          end ;
                      end ;
                  end
           else if c = 13 then scanninghex := true
           else if c = 146 then
                  begin
                    k := 0 ;
                    while true do
                      begin
                        if loc > limit then
                          begin
                            getline ;
                            if inputhasended then
                              begin
                                begin
                                  if not phaseone then
                                    begin
                                      writeln ( termout ) ;
                                      write ( termout , '! Input ended in section name' ) ;
                                      error ;
                                    end ;
                                end ;
                                loc := 1 ;
                                goto 30 ;
                              end ;
                          end ;
                        d := buffer [ loc ] ;
                        if d = 64 then
                          begin
                            d := buffer [ loc + 1 ] ;
                            if d = 62 then
                              begin
                                loc := loc + 2 ;
                                goto 30 ;
                              end ;
                            if ( d = 32 ) or ( d = 9 ) or ( d = 42 ) then
                              begin
                                begin
                                  if not phaseone then
                                    begin
                                      writeln ( termout ) ;
                                      write ( termout , '! Section name didn''t end' ) ;
                                      error ;
                                    end ;
                                end ;
                                goto 30 ;
                              end ;
                            k := k + 1 ;
                            modtext [ k ] := 64 ;
                            loc := loc + 1 ;
                          end ;
                        loc := loc + 1 ;
                        if k < longestname - 1 then k := k + 1 ;
                        if ( d = 32 ) or ( d = 9 ) then
                          begin
                            d := 32 ;
                            if modtext [ k - 1 ] = 32 then k := k - 1 ;
                          end ;
                        modtext [ k ] := d ;
                      end ;
                    30 : if k >= longestname - 2 then
                           begin
                             begin
                               writeln ( termout ) ;
                               write ( termout , '! Section name too long: ' ) ;
                             end ;
                             for j := 1 to 25 do
                               write ( termout , xchr [ modtext [ j ] ] ) ;
                             write ( termout , '...' ) ;
                             if history = 0 then history := 1 ;
                           end ;
                    if ( modtext [ k ] = 32 ) and ( k > 0 ) then k := k - 1 ;
                    if k > 3 then
                      begin
                        if ( modtext [ k ] = 46 ) and ( modtext [ k - 1 ] = 46 ) and ( modtext [ k - 2 ] = 46 ) then curmodule := prefixlookup ( k - 3 )
                        else curmodule := modlookup ( k ) ;
                      end
                    else curmodule := modlookup ( k ) ;
                    xrefswitch := 0 ;
                  end
           else if c = 2 then
                  begin
                    idfirst := loc ;
                    loc := loc + 1 ;
                    buffer [ limit + 1 ] := 64 ;
                    buffer [ limit + 2 ] := 62 ;
                    while ( buffer [ loc ] <> 64 ) or ( buffer [ loc + 1 ] <> 62 ) do
                      loc := loc + 1 ;
                    if loc >= limit then
                      begin
                        if not phaseone then
                          begin
                            writeln ( termout ) ;
                            write ( termout , '! Verbatim string didn''t end' ) ;
                            error ;
                          end ;
                      end ;
                    idloc := loc ;
                    loc := loc + 2 ;
                  end ;
         end ;
    46 : if buffer [ loc ] = 46 then
           begin
             if loc <= limit then
               begin
                 c := 32 ;
                 loc := loc + 1 ;
               end ;
           end
         else if buffer [ loc ] = 41 then
                begin
                  if loc <= limit then
                    begin
                      c := 93 ;
                      loc := loc + 1 ;
                    end ;
                end ;
    58 : if buffer [ loc ] = 61 then
           begin
             if loc <= limit then
               begin
                 c := 24 ;
                 loc := loc + 1 ;
               end ;
           end ;
    61 : if buffer [ loc ] = 61 then
           begin
             if loc <= limit then
               begin
                 c := 30 ;
                 loc := loc + 1 ;
               end ;
           end ;
    62 : if buffer [ loc ] = 61 then
           begin
             if loc <= limit then
               begin
                 c := 29 ;
                 loc := loc + 1 ;
               end ;
           end ;
    60 : if buffer [ loc ] = 61 then
           begin
             if loc <= limit then
               begin
                 c := 28 ;
                 loc := loc + 1 ;
               end ;
           end
         else if buffer [ loc ] = 62 then
                begin
                  if loc <= limit then
                    begin
                      c := 26 ;
                      loc := loc + 1 ;
                    end ;
                end ;
    40 : if buffer [ loc ] = 42 then
           begin
             if loc <= limit then
               begin
                 c := 9 ;
                 loc := loc + 1 ;
               end ;
           end
         else if buffer [ loc ] = 46 then
                begin
                  if loc <= limit then
                    begin
                      c := 91 ;
                      loc := loc + 1 ;
                    end ;
                end ;
    42 : if buffer [ loc ] = 41 then
           begin
             if loc <= limit then
               begin
                 c := 10 ;
                 loc := loc + 1 ;
               end ;
           end ;
    32 , 9 : goto 20 ;
    125 :
          begin
            begin
              if not phaseone then
                begin
                  writeln ( termout ) ;
                  write ( termout , '! Extra }' ) ;
                  error ;
                end ;
            end ;
            goto 20 ;
          end ;
    others : if c >= 128 then goto 20
             else
  end ;
  31 : getnext := c ;
end ;
procedure Pascalxref ;

label 10 ;

var p : namepointer ;
begin
  while nextcontrol < 143 do
    begin
      if ( nextcontrol >= 130 ) and ( nextcontrol <= 133 ) then
        begin
          p := idlookup ( nextcontrol - 130 ) ;
          newxref ( p ) ;
          if ( ilk [ p ] = 17 ) or ( ilk [ p ] = 22 ) then xrefswitch := 10240 ;
        end ;
      nextcontrol := getnext ;
      if ( nextcontrol = 124 ) or ( nextcontrol = 123 ) then goto 10 ;
    end ;
  10 :
end ;
procedure outerxref ;

var bal : eightbits ;
begin
  while nextcontrol < 143 do
    if nextcontrol <> 123 then Pascalxref
    else
      begin
        bal := skipcomment ( 1 ) ;
        nextcontrol := 124 ;
        while bal > 0 do
          begin
            Pascalxref ;
            if nextcontrol = 124 then bal := skipcomment ( bal )
            else bal := 0 ;
          end ;
      end ;
end ;
procedure modcheck ( p : namepointer ) ;
begin
  if p > 0 then
    begin
      modcheck ( link [ p ] ) ;
      curxref := xref [ p ] ;
      if xmem [ curxref ] . numfield < 10240 then
        begin
          begin
            writeln ( termout ) ;
            write ( termout , '! Never defined: <' ) ;
          end ;
          printid ( p ) ;
          write ( termout , '>' ) ;
          if history = 0 then history := 1 ;
        end ;
      while xmem [ curxref ] . numfield >= 10240 do
        curxref := xmem [ curxref ] . xlinkfield ;
      if curxref = 0 then
        begin
          begin
            writeln ( termout ) ;
            write ( termout , '! Never used: <' ) ;
          end ;
          printid ( p ) ;
          write ( termout , '>' ) ;
          if history = 0 then history := 1 ;
        end ;
      modcheck ( ilk [ p ] ) ;
    end ;
end ;
procedure flushbuffer ( b : eightbits ; percent , carryover : boolean ) ;

label 30 , 31 ;

var j , k : 0 .. linelength ;
begin
  j := b ;
  if not percent then while true do
                        begin
                          if j = 0 then goto 30 ;
                          if outbuf [ j ] <> 32 then goto 30 ;
                          j := j - 1 ;
                        end ;
  30 : for k := 1 to j do
         write ( texfile , xchr [ outbuf [ k ] ] ) ;
  if percent then write ( texfile , xchr [ 37 ] ) ;
  writeln ( texfile ) ;
  outline := outline + 1 ;
  if carryover then for k := 1 to j do
                      if outbuf [ k ] = 37 then if ( k = 1 ) or ( outbuf [ k - 1 ] <> 92 ) then
                                                  begin
                                                    outbuf [ b ] := 37 ;
                                                    b := b - 1 ;
                                                    goto 31 ;
                                                  end ;
  31 : if ( b < outptr ) then for k := b + 1 to outptr do
                                outbuf [ k - b ] := outbuf [ k ] ;
  outptr := outptr - b ;
end ;
procedure finishline ;

label 10 ;

var k : 0 .. bufsize ;
begin
  if outptr > 0 then flushbuffer ( outptr , false , false )
  else
    begin
      for k := 0 to limit do
        if ( buffer [ k ] <> 32 ) and ( buffer [ k ] <> 9 ) then goto 10 ;
      flushbuffer ( 0 , false , false ) ;
    end ;
  10 :
end ;
procedure breakout ;

label 10 ;

var k : 0 .. linelength ;
  d : ASCIIcode ;
begin
  k := outptr ;
  while true do
    begin
      if k = 0 then
        begin
          begin
            writeln ( termout ) ;
            write ( termout , '! Line had to be broken (output l.' , outline : 1 ) ;
          end ;
          writeln ( termout , '):' ) ;
          for k := 1 to outptr - 1 do
            write ( termout , xchr [ outbuf [ k ] ] ) ;
          writeln ( termout ) ;
          if history = 0 then history := 1 ;
          flushbuffer ( outptr - 1 , true , true ) ;
          goto 10 ;
        end ;
      d := outbuf [ k ] ;
      if d = 32 then
        begin
          flushbuffer ( k , false , true ) ;
          goto 10 ;
        end ;
      if ( d = 92 ) and ( outbuf [ k - 1 ] <> 92 ) then
        begin
          flushbuffer ( k - 1 , true , true ) ;
          goto 10 ;
        end ;
      k := k - 1 ;
    end ;
  10 :
end ;
procedure outmod ( m : integer ) ;

var k : 0 .. 5 ;
  a : integer ;
begin
  k := 0 ;
  a := m ;
  repeat
    dig [ k ] := a mod 10 ;
    a := a div 10 ;
    k := k + 1 ;
  until a = 0 ;
  repeat
    k := k - 1 ;
    begin
      if outptr = linelength then breakout ;
      outptr := outptr + 1 ;
      outbuf [ outptr ] := dig [ k ] + 48 ;
    end ;
  until k = 0 ;
  if changedmodule [ m ] then
    begin
      if outptr = linelength then breakout ;
      outptr := outptr + 1 ;
      outbuf [ outptr ] := 92 ;
      if outptr = linelength then breakout ;
      outptr := outptr + 1 ;
      outbuf [ outptr ] := 42 ;
    end ;
end ;
procedure outname ( p : namepointer ) ;

var k : 0 .. maxbytes ;
  w : 0 .. 1 ;
begin
  begin
    if outptr = linelength then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 123 ;
  end ;
  w := p mod 2 ;
  for k := bytestart [ p ] to bytestart [ p + 2 ] - 1 do
    begin
      if bytemem [ w , k ] = 95 then
        begin
          if outptr = linelength then breakout ;
          outptr := outptr + 1 ;
          outbuf [ outptr ] := 92 ;
        end ;
      begin
        if outptr = linelength then breakout ;
        outptr := outptr + 1 ;
        outbuf [ outptr ] := bytemem [ w , k ] ;
      end ;
    end ;
  begin
    if outptr = linelength then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 125 ;
  end ;
end ;
procedure copylimbo ;

label 10 ;

var c : ASCIIcode ;
begin
  while true do
    if loc > limit then
      begin
        finishline ;
        getline ;
        if inputhasended then goto 10 ;
      end
    else
      begin
        buffer [ limit + 1 ] := 64 ;
        while buffer [ loc ] <> 64 do
          begin
            begin
              if outptr = linelength then breakout ;
              outptr := outptr + 1 ;
              outbuf [ outptr ] := buffer [ loc ] ;
            end ;
            loc := loc + 1 ;
          end ;
        if loc <= limit then
          begin
            loc := loc + 2 ;
            c := buffer [ loc - 1 ] ;
            if ( c = 32 ) or ( c = 9 ) or ( c = 42 ) then goto 10 ;
            if ( c <> 122 ) and ( c <> 90 ) then
              begin
                begin
                  if outptr = linelength then breakout ;
                  outptr := outptr + 1 ;
                  outbuf [ outptr ] := 64 ;
                end ;
                if c <> 64 then
                  begin
                    if not phaseone then
                      begin
                        writeln ( termout ) ;
                        write ( termout , '! Double @ required outside of sections' ) ;
                        error ;
                      end ;
                  end ;
              end ;
          end ;
      end ;
  10 :
end ;
function copyTeX : eightbits ;

label 30 ;

var c : eightbits ;
begin
  while true do
    begin
      if loc > limit then
        begin
          finishline ;
          getline ;
          if inputhasended then
            begin
              c := 147 ;
              goto 30 ;
            end ;
        end ;
      buffer [ limit + 1 ] := 64 ;
      repeat
        c := buffer [ loc ] ;
        loc := loc + 1 ;
        if c = 124 then goto 30 ;
        if c <> 64 then
          begin
            begin
              if outptr = linelength then breakout ;
              outptr := outptr + 1 ;
              outbuf [ outptr ] := c ;
            end ;
            if ( outptr = 1 ) and ( ( c = 32 ) or ( c = 9 ) ) then outptr := outptr - 1 ;
          end ;
      until c = 64 ;
      if loc <= limit then
        begin
          c := controlcode ( buffer [ loc ] ) ;
          loc := loc + 1 ;
          goto 30 ;
        end ;
    end ;
  30 : copyTeX := c ;
end ;
function copycomment ( bal : eightbits ) : eightbits ;

label 30 ;

var c : ASCIIcode ;
begin
  while true do
    begin
      if loc > limit then
        begin
          getline ;
          if inputhasended then
            begin
              begin
                if not phaseone then
                  begin
                    writeln ( termout ) ;
                    write ( termout , '! Input ended in mid-comment' ) ;
                    error ;
                  end ;
              end ;
              loc := 1 ;
              begin
                if tokptr + 2 > maxtoks then
                  begin
                    writeln ( termout ) ;
                    write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
                    error ;
                    history := 3 ;
                    jumpout ;
                  end ;
                tokmem [ tokptr ] := 32 ;
                tokptr := tokptr + 1 ;
              end ;
              repeat
                begin
                  if tokptr + 2 > maxtoks then
                    begin
                      writeln ( termout ) ;
                      write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
                      error ;
                      history := 3 ;
                      jumpout ;
                    end ;
                  tokmem [ tokptr ] := 125 ;
                  tokptr := tokptr + 1 ;
                end ;
                bal := bal - 1 ;
              until bal = 0 ;
              goto 30 ; ;
            end ;
        end ;
      c := buffer [ loc ] ;
      loc := loc + 1 ;
      if c = 124 then goto 30 ;
      begin
        if tokptr + 2 > maxtoks then
          begin
            writeln ( termout ) ;
            write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
            error ;
            history := 3 ;
            jumpout ;
          end ;
        tokmem [ tokptr ] := c ;
        tokptr := tokptr + 1 ;
      end ;
      if c = 64 then
        begin
          loc := loc + 1 ;
          if buffer [ loc - 1 ] <> 64 then
            begin
              begin
                if not phaseone then
                  begin
                    writeln ( termout ) ;
                    write ( termout , '! Illegal use of @ in comment' ) ;
                    error ;
                  end ;
              end ;
              loc := loc - 2 ;
              tokptr := tokptr - 1 ;
              begin
                if tokptr + 2 > maxtoks then
                  begin
                    writeln ( termout ) ;
                    write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
                    error ;
                    history := 3 ;
                    jumpout ;
                  end ;
                tokmem [ tokptr ] := 32 ;
                tokptr := tokptr + 1 ;
              end ;
              repeat
                begin
                  if tokptr + 2 > maxtoks then
                    begin
                      writeln ( termout ) ;
                      write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
                      error ;
                      history := 3 ;
                      jumpout ;
                    end ;
                  tokmem [ tokptr ] := 125 ;
                  tokptr := tokptr + 1 ;
                end ;
                bal := bal - 1 ;
              until bal = 0 ;
              goto 30 ; ;
            end ;
        end
      else if ( c = 92 ) and ( buffer [ loc ] <> 64 ) then
             begin
               begin
                 if tokptr + 2 > maxtoks then
                   begin
                     writeln ( termout ) ;
                     write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
                     error ;
                     history := 3 ;
                     jumpout ;
                   end ;
                 tokmem [ tokptr ] := buffer [ loc ] ;
                 tokptr := tokptr + 1 ;
               end ;
               loc := loc + 1 ;
             end
      else if c = 123 then bal := bal + 1
      else if c = 125 then
             begin
               bal := bal - 1 ;
               if bal = 0 then goto 30 ;
             end ;
    end ;
  30 : copycomment := bal ;
end ;
procedure red ( j : sixteenbits ; k : eightbits ; c : eightbits ; d : integer ) ;

var i : 0 .. maxscraps ;
begin
  cat [ j ] := c ;
  trans [ j ] := textptr ;
  textptr := textptr + 1 ;
  tokstart [ textptr ] := tokptr ;
  if k > 1 then
    begin
      for i := j + k to loptr do
        begin
          cat [ i - k + 1 ] := cat [ i ] ;
          trans [ i - k + 1 ] := trans [ i ] ;
        end ;
      loptr := loptr - k + 1 ;
    end ;
  if pp + d >= scrapbase then pp := pp + d
  else pp := scrapbase ;
end ;
procedure sq ( j : sixteenbits ; k : eightbits ; c : eightbits ; d : integer ) ;

var i : 0 .. maxscraps ;
begin
  if k = 1 then
    begin
      cat [ j ] := c ;
      if pp + d >= scrapbase then pp := pp + d
      else pp := scrapbase ;
    end
  else
    begin
      for i := j to j + k - 1 do
        begin
          tokmem [ tokptr ] := 40960 + trans [ i ] ;
          tokptr := tokptr + 1 ;
        end ;
      red ( j , k , c , d ) ;
    end ;
end ;
procedure fivecases ;

label 31 ;
begin
  case cat [ pp ] of 
    5 : if cat [ pp + 1 ] = 6 then
          begin
            if ( cat [ pp + 2 ] = 10 ) or ( cat [ pp + 2 ] = 11 ) then
              begin
                sq ( pp , 3 , 11 , - 2 ) ; ;
                goto 31 ;
              end ;
          end
        else if cat [ pp + 1 ] = 11 then
               begin
                 tokmem [ tokptr ] := 40960 + trans [ pp ] ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 140 ;
                 tokptr := tokptr + 1 ;
                 tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                 tokptr := tokptr + 1 ;
                 red ( pp , 2 , 5 , - 1 ) ; ;
                 goto 31 ;
               end ;
    3 : if cat [ pp + 1 ] = 11 then
          begin
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
          end ;
    2 : if cat [ pp + 1 ] = 6 then
          begin
            tokmem [ tokptr ] := 36 ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 40960 + trans [ pp ] ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 36 ;
            tokptr := tokptr + 1 ;
            red ( pp , 1 , 11 , - 2 ) ; ;
            goto 31 ;
          end
        else if cat [ pp + 1 ] = 14 then
               begin
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
               end
        else if cat [ pp + 1 ] = 2 then
               begin
                 sq ( pp , 2 , 2 , - 1 ) ; ;
                 goto 31 ;
               end
        else if cat [ pp + 1 ] = 1 then
               begin
                 sq ( pp , 2 , 2 , - 1 ) ; ;
                 goto 31 ;
               end
        else if cat [ pp + 1 ] = 11 then
               begin
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
               end
        else if cat [ pp + 1 ] = 10 then
               begin
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
               end ;
    4 : if ( cat [ pp + 1 ] = 17 ) and ( cat [ pp + 2 ] = 6 ) then
          begin
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
          end
        else if cat [ pp + 1 ] = 6 then
               begin
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
               end
        else if cat [ pp + 1 ] = 2 then
               begin
                 if ( cat [ pp + 2 ] = 17 ) and ( cat [ pp + 3 ] = 6 ) then
                   begin
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
                   end
                 else if cat [ pp + 2 ] = 6 then
                        begin
                          sq ( pp , 3 , 2 , - 1 ) ; ;
                          goto 31 ;
                        end
                 else if cat [ pp + 2 ] = 14 then
                        begin
                          sq ( pp + 1 , 2 , 2 , 0 ) ; ;
                          goto 31 ;
                        end
                 else if cat [ pp + 2 ] = 16 then
                        begin
                          if cat [ pp + 3 ] = 3 then
                            begin
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
                            end ;
                        end
                 else if cat [ pp + 2 ] = 9 then
                        begin
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
                        end
                 else if cat [ pp + 2 ] = 19 then
                        begin
                          if cat [ pp + 3 ] = 3 then
                            begin
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
                            end ;
                        end ;
               end
        else if cat [ pp + 1 ] = 16 then
               begin
                 if cat [ pp + 2 ] = 3 then
                   begin
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
                   end ;
               end
        else if cat [ pp + 1 ] = 1 then
               begin
                 sq ( pp + 1 , 1 , 2 , 0 ) ; ;
                 goto 31 ;
               end
        else if ( cat [ pp + 1 ] = 11 ) and ( cat [ pp + 2 ] = 6 ) then
               begin
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
               end
        else if cat [ pp + 1 ] = 19 then
               begin
                 if cat [ pp + 2 ] = 3 then
                   begin
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
                   end ;
               end ;
    1 : if cat [ pp + 1 ] = 6 then
          begin
            sq ( pp , 1 , 11 , - 2 ) ; ;
            goto 31 ;
          end
        else if cat [ pp + 1 ] = 14 then
               begin
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
               end
        else if cat [ pp + 1 ] = 2 then
               begin
                 sq ( pp , 2 , 2 , - 1 ) ; ;
                 goto 31 ;
               end
        else if cat [ pp + 1 ] = 22 then
               begin
                 sq ( pp , 2 , 22 , 0 ) ; ;
                 goto 31 ;
               end
        else if cat [ pp + 1 ] = 1 then
               begin
                 sq ( pp , 2 , 1 , - 2 ) ; ;
                 goto 31 ;
               end
        else if cat [ pp + 1 ] = 10 then
               begin
                 sq ( pp , 2 , 11 , - 2 ) ; ;
                 goto 31 ;
               end ;
    others :
  end ;
  pp := pp + 1 ;
  31 :
end ;
procedure alphacases ;

label 31 ;
begin
  if cat [ pp + 1 ] = 2 then
    begin
      if cat [ pp + 2 ] = 14 then
        begin
          sq ( pp + 1 , 2 , 2 , 0 ) ; ;
          goto 31 ;
        end
      else if cat [ pp + 2 ] = 8 then
             begin
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
             end ;
    end
  else if cat [ pp + 1 ] = 8 then
         begin
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
         end
  else if cat [ pp + 1 ] = 1 then
         begin
           sq ( pp + 1 , 1 , 2 , 0 ) ; ;
           goto 31 ;
         end ;
  pp := pp + 1 ;
  31 :
end ;
function translate : textpointer ;

label 30 , 31 ;

var i : 1 .. maxscraps ;
  j : 0 .. maxscraps ;
  k : 0 .. longbufsize ;
begin
  pp := scrapbase ;
  loptr := pp - 1 ;
  hiptr := pp ; ;
  while true do
    begin
      if loptr < pp + 3 then
        begin
          repeat
            if hiptr <= scrapptr then
              begin
                loptr := loptr + 1 ;
                cat [ loptr ] := cat [ hiptr ] ;
                trans [ loptr ] := trans [ hiptr ] ;
                hiptr := hiptr + 1 ;
              end ;
          until ( hiptr > scrapptr ) or ( loptr = pp + 3 ) ;
          for i := loptr + 1 to pp + 3 do
            cat [ i ] := 0 ;
        end ;
      if ( tokptr + 8 > maxtoks ) or ( textptr + 4 > maxtexts ) then
        begin
          begin
            writeln ( termout ) ;
            write ( termout , '! Sorry, ' , 'token/text' , ' capacity exceeded' ) ;
            error ;
            history := 3 ;
            jumpout ;
          end ;
        end ;
      if pp > loptr then goto 30 ;
      if cat [ pp ] <= 7 then if cat [ pp ] < 7 then fivecases
      else alphacases
      else
        begin
          case cat [ pp ] of 
            17 : if cat [ pp + 1 ] = 21 then
                   begin
                     if cat [ pp + 2 ] = 13 then
                       begin
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
                       end ;
                   end
                 else if cat [ pp + 1 ] = 6 then
                        begin
                          if cat [ pp + 2 ] = 10 then
                            begin
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
                            end ;
                        end
                 else if cat [ pp + 1 ] = 11 then
                        begin
                          tokmem [ tokptr ] := 40960 + trans [ pp ] ;
                          tokptr := tokptr + 1 ;
                          tokmem [ tokptr ] := 141 ;
                          tokptr := tokptr + 1 ;
                          tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                          tokptr := tokptr + 1 ;
                          red ( pp , 2 , 17 , 0 ) ; ;
                          goto 31 ;
                        end ;
            21 : if cat [ pp + 1 ] = 13 then
                   begin
                     sq ( pp , 2 , 17 , 0 ) ; ;
                     goto 31 ;
                   end ;
            13 : if cat [ pp + 1 ] = 11 then
                   begin
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
                   end ;
            12 : if ( cat [ pp + 1 ] = 13 ) and ( cat [ pp + 2 ] = 11 ) then if cat [ pp + 3 ] = 20 then
                                                                               begin
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
                                                                               end
                 else
                   begin
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
                   end ;
            20 :
                 begin
                   sq ( pp , 1 , 3 , - 3 ) ; ;
                   goto 31 ;
                 end ;
            15 : if cat [ pp + 1 ] = 2 then
                   begin
                     if cat [ pp + 2 ] = 1 then if cat [ pp + 3 ] <> 1 then
                                                  begin
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
                                                  end ;
                   end
                 else if cat [ pp + 1 ] = 1 then if cat [ pp + 2 ] <> 1 then
                                                   begin
                                                     tokmem [ tokptr ] := 40960 + trans [ pp ] ;
                                                     tokptr := tokptr + 1 ;
                                                     tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                                                     tokptr := tokptr + 1 ;
                                                     tokmem [ tokptr ] := 125 ;
                                                     tokptr := tokptr + 1 ;
                                                     red ( pp , 2 , 2 , - 1 ) ; ;
                                                     goto 31 ;
                                                   end ;
            22 : if ( cat [ pp + 1 ] = 10 ) or ( cat [ pp + 1 ] = 9 ) then
                   begin
                     tokmem [ tokptr ] := 40960 + trans [ pp ] ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 141 ;
                     tokptr := tokptr + 1 ;
                     red ( pp , 2 , 11 , - 2 ) ; ;
                     goto 31 ;
                   end
                 else
                   begin
                     sq ( pp , 1 , 1 , - 2 ) ; ;
                     goto 31 ;
                   end ;
            16 : if cat [ pp + 1 ] = 5 then
                   begin
                     if ( cat [ pp + 2 ] = 6 ) and ( cat [ pp + 3 ] = 10 ) then
                       begin
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
                       end ;
                   end
                 else if cat [ pp + 1 ] = 11 then
                        begin
                          tokmem [ tokptr ] := 40960 + trans [ pp ] ;
                          tokptr := tokptr + 1 ;
                          tokmem [ tokptr ] := 140 ;
                          tokptr := tokptr + 1 ;
                          tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                          tokptr := tokptr + 1 ;
                          red ( pp , 2 , 16 , - 2 ) ; ;
                          goto 31 ;
                        end ;
            18 : if ( cat [ pp + 1 ] = 3 ) and ( cat [ pp + 2 ] = 21 ) then
                   begin
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
                   end
                 else
                   begin
                     tokmem [ tokptr ] := 136 ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 40960 + trans [ pp ] ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 135 ;
                     tokptr := tokptr + 1 ;
                     red ( pp , 1 , 17 , 0 ) ; ;
                     goto 31 ;
                   end ;
            9 :
                begin
                  sq ( pp , 1 , 10 , - 3 ) ; ;
                  goto 31 ;
                end ;
            11 : if cat [ pp + 1 ] = 11 then
                   begin
                     tokmem [ tokptr ] := 40960 + trans [ pp ] ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 140 ;
                     tokptr := tokptr + 1 ;
                     tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                     tokptr := tokptr + 1 ;
                     red ( pp , 2 , 11 , - 2 ) ; ;
                     goto 31 ;
                   end ;
            10 :
                 begin
                   sq ( pp , 1 , 11 , - 2 ) ; ;
                   goto 31 ;
                 end ;
            19 : if cat [ pp + 1 ] = 5 then
                   begin
                     sq ( pp , 1 , 11 , - 2 ) ; ;
                     goto 31 ;
                   end
                 else if cat [ pp + 1 ] = 2 then
                        begin
                          if cat [ pp + 2 ] = 14 then
                            begin
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
                            end ;
                        end
                 else if cat [ pp + 1 ] = 1 then
                        begin
                          if cat [ pp + 2 ] = 14 then
                            begin
                              sq ( pp + 1 , 2 , 3 , + 1 ) ; ;
                              goto 31 ;
                            end ;
                        end
                 else if cat [ pp + 1 ] = 11 then
                        begin
                          tokmem [ tokptr ] := 40960 + trans [ pp ] ;
                          tokptr := tokptr + 1 ;
                          tokmem [ tokptr ] := 140 ;
                          tokptr := tokptr + 1 ;
                          tokmem [ tokptr ] := 40960 + trans [ pp + 1 ] ;
                          tokptr := tokptr + 1 ;
                          red ( pp , 2 , 19 , - 2 ) ; ;
                          goto 31 ;
                        end ;
            others :
          end ;
          pp := pp + 1 ;
          31 :
        end ;
    end ;
  30 : ;
  if ( loptr = scrapbase ) and ( cat [ loptr ] <> 2 ) then translate := trans [ loptr ]
  else
    begin ;
      for j := scrapbase to loptr do
        begin
          if j <> scrapbase then
            begin
              tokmem [ tokptr ] := 32 ;
              tokptr := tokptr + 1 ;
            end ;
          if cat [ j ] = 2 then
            begin
              tokmem [ tokptr ] := 36 ;
              tokptr := tokptr + 1 ;
            end ;
          tokmem [ tokptr ] := 40960 + trans [ j ] ;
          tokptr := tokptr + 1 ;
          if cat [ j ] = 2 then
            begin
              tokmem [ tokptr ] := 36 ;
              tokptr := tokptr + 1 ;
            end ;
          if tokptr + 6 > maxtoks then
            begin
              writeln ( termout ) ;
              write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
              error ;
              history := 3 ;
              jumpout ;
            end ;
        end ;
      textptr := textptr + 1 ;
      tokstart [ textptr ] := tokptr ;
      translate := textptr - 1 ;
    end ;
end ;
procedure appcomment ;
begin
  textptr := textptr + 1 ;
  tokstart [ textptr ] := tokptr ;
  if ( scrapptr < scrapbase ) or ( cat [ scrapptr ] < 8 ) or ( cat [ scrapptr ] > 10 ) then
    begin
      scrapptr := scrapptr + 1 ;
      cat [ scrapptr ] := 10 ;
      trans [ scrapptr ] := 0 ;
    end
  else
    begin
      tokmem [ tokptr ] := 40960 + trans [ scrapptr ] ;
      tokptr := tokptr + 1 ;
    end ;
  tokmem [ tokptr ] := textptr + 40959 ;
  tokptr := tokptr + 1 ;
  trans [ scrapptr ] := textptr ;
  textptr := textptr + 1 ;
  tokstart [ textptr ] := tokptr ;
end ;
procedure appoctal ;
begin
  tokmem [ tokptr ] := 92 ;
  tokptr := tokptr + 1 ;
  tokmem [ tokptr ] := 79 ;
  tokptr := tokptr + 1 ;
  tokmem [ tokptr ] := 123 ;
  tokptr := tokptr + 1 ;
  while ( buffer [ loc ] >= 48 ) and ( buffer [ loc ] <= 55 ) do
    begin
      begin
        if tokptr + 2 > maxtoks then
          begin
            writeln ( termout ) ;
            write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
            error ;
            history := 3 ;
            jumpout ;
          end ;
        tokmem [ tokptr ] := buffer [ loc ] ;
        tokptr := tokptr + 1 ;
      end ;
      loc := loc + 1 ;
    end ;
  begin
    tokmem [ tokptr ] := 125 ;
    tokptr := tokptr + 1 ;
    scrapptr := scrapptr + 1 ;
    cat [ scrapptr ] := 1 ;
    trans [ scrapptr ] := textptr ;
    textptr := textptr + 1 ;
    tokstart [ textptr ] := tokptr ;
  end ;
end ;
procedure apphex ;
begin
  tokmem [ tokptr ] := 92 ;
  tokptr := tokptr + 1 ;
  tokmem [ tokptr ] := 72 ;
  tokptr := tokptr + 1 ;
  tokmem [ tokptr ] := 123 ;
  tokptr := tokptr + 1 ;
  while ( ( buffer [ loc ] >= 48 ) and ( buffer [ loc ] <= 57 ) ) or ( ( buffer [ loc ] >= 65 ) and ( buffer [ loc ] <= 70 ) ) do
    begin
      begin
        if tokptr + 2 > maxtoks then
          begin
            writeln ( termout ) ;
            write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
            error ;
            history := 3 ;
            jumpout ;
          end ;
        tokmem [ tokptr ] := buffer [ loc ] ;
        tokptr := tokptr + 1 ;
      end ;
      loc := loc + 1 ;
    end ;
  begin
    tokmem [ tokptr ] := 125 ;
    tokptr := tokptr + 1 ;
    scrapptr := scrapptr + 1 ;
    cat [ scrapptr ] := 1 ;
    trans [ scrapptr ] := textptr ;
    textptr := textptr + 1 ;
    tokstart [ textptr ] := tokptr ;
  end ;
end ;
procedure easycases ;
begin
  case nextcontrol of 
    6 :
        begin
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
        end ;
    32 :
         begin
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
         end ;
    35 , 36 , 37 , 94 , 95 :
                             begin
                               tokmem [ tokptr ] := 92 ;
                               tokptr := tokptr + 1 ;
                               tokmem [ tokptr ] := nextcontrol ;
                               tokptr := tokptr + 1 ;
                               scrapptr := scrapptr + 1 ;
                               cat [ scrapptr ] := 2 ;
                               trans [ scrapptr ] := textptr ;
                               textptr := textptr + 1 ;
                               tokstart [ textptr ] := tokptr ;
                             end ;
    0 , 124 , 131 , 132 , 133 : ;
    40 , 91 :
              begin
                tokmem [ tokptr ] := nextcontrol ;
                tokptr := tokptr + 1 ;
                scrapptr := scrapptr + 1 ;
                cat [ scrapptr ] := 4 ;
                trans [ scrapptr ] := textptr ;
                textptr := textptr + 1 ;
                tokstart [ textptr ] := tokptr ;
              end ;
    41 , 93 :
              begin
                tokmem [ tokptr ] := nextcontrol ;
                tokptr := tokptr + 1 ;
                scrapptr := scrapptr + 1 ;
                cat [ scrapptr ] := 6 ;
                trans [ scrapptr ] := textptr ;
                textptr := textptr + 1 ;
                tokstart [ textptr ] := tokptr ;
              end ;
    42 :
         begin
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
         end ;
    44 :
         begin
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
         end ;
    46 , 48 , 49 , 50 , 51 , 52 , 53 , 54 , 55 , 56 , 57 :
                                                           begin
                                                             tokmem [ tokptr ] := nextcontrol ;
                                                             tokptr := tokptr + 1 ;
                                                             scrapptr := scrapptr + 1 ;
                                                             cat [ scrapptr ] := 1 ;
                                                             trans [ scrapptr ] := textptr ;
                                                             textptr := textptr + 1 ;
                                                             tokstart [ textptr ] := tokptr ;
                                                           end ;
    59 :
         begin
           tokmem [ tokptr ] := 59 ;
           tokptr := tokptr + 1 ;
           scrapptr := scrapptr + 1 ;
           cat [ scrapptr ] := 9 ;
           trans [ scrapptr ] := textptr ;
           textptr := textptr + 1 ;
           tokstart [ textptr ] := tokptr ;
         end ;
    58 :
         begin
           tokmem [ tokptr ] := 58 ;
           tokptr := tokptr + 1 ;
           scrapptr := scrapptr + 1 ;
           cat [ scrapptr ] := 14 ;
           trans [ scrapptr ] := textptr ;
           textptr := textptr + 1 ;
           tokstart [ textptr ] := tokptr ;
         end ;
    26 :
         begin
           tokmem [ tokptr ] := 92 ;
           tokptr := tokptr + 1 ;
           tokmem [ tokptr ] := 73 ;
           tokptr := tokptr + 1 ;
           scrapptr := scrapptr + 1 ;
           cat [ scrapptr ] := 2 ;
           trans [ scrapptr ] := textptr ;
           textptr := textptr + 1 ;
           tokstart [ textptr ] := tokptr ;
         end ;
    28 :
         begin
           tokmem [ tokptr ] := 92 ;
           tokptr := tokptr + 1 ;
           tokmem [ tokptr ] := 76 ;
           tokptr := tokptr + 1 ;
           scrapptr := scrapptr + 1 ;
           cat [ scrapptr ] := 2 ;
           trans [ scrapptr ] := textptr ;
           textptr := textptr + 1 ;
           tokstart [ textptr ] := tokptr ;
         end ;
    29 :
         begin
           tokmem [ tokptr ] := 92 ;
           tokptr := tokptr + 1 ;
           tokmem [ tokptr ] := 71 ;
           tokptr := tokptr + 1 ;
           scrapptr := scrapptr + 1 ;
           cat [ scrapptr ] := 2 ;
           trans [ scrapptr ] := textptr ;
           textptr := textptr + 1 ;
           tokstart [ textptr ] := tokptr ;
         end ;
    30 :
         begin
           tokmem [ tokptr ] := 92 ;
           tokptr := tokptr + 1 ;
           tokmem [ tokptr ] := 83 ;
           tokptr := tokptr + 1 ;
           scrapptr := scrapptr + 1 ;
           cat [ scrapptr ] := 2 ;
           trans [ scrapptr ] := textptr ;
           textptr := textptr + 1 ;
           tokstart [ textptr ] := tokptr ;
         end ;
    4 :
        begin
          tokmem [ tokptr ] := 92 ;
          tokptr := tokptr + 1 ;
          tokmem [ tokptr ] := 87 ;
          tokptr := tokptr + 1 ;
          scrapptr := scrapptr + 1 ;
          cat [ scrapptr ] := 2 ;
          trans [ scrapptr ] := textptr ;
          textptr := textptr + 1 ;
          tokstart [ textptr ] := tokptr ;
        end ;
    31 :
         begin
           tokmem [ tokptr ] := 92 ;
           tokptr := tokptr + 1 ;
           tokmem [ tokptr ] := 86 ;
           tokptr := tokptr + 1 ;
           scrapptr := scrapptr + 1 ;
           cat [ scrapptr ] := 2 ;
           trans [ scrapptr ] := textptr ;
           textptr := textptr + 1 ;
           tokstart [ textptr ] := tokptr ;
         end ;
    5 :
        begin
          tokmem [ tokptr ] := 92 ;
          tokptr := tokptr + 1 ;
          tokmem [ tokptr ] := 82 ;
          tokptr := tokptr + 1 ;
          scrapptr := scrapptr + 1 ;
          cat [ scrapptr ] := 2 ;
          trans [ scrapptr ] := textptr ;
          textptr := textptr + 1 ;
          tokstart [ textptr ] := tokptr ;
        end ;
    24 :
         begin
           tokmem [ tokptr ] := 92 ;
           tokptr := tokptr + 1 ;
           tokmem [ tokptr ] := 75 ;
           tokptr := tokptr + 1 ;
           scrapptr := scrapptr + 1 ;
           cat [ scrapptr ] := 2 ;
           trans [ scrapptr ] := textptr ;
           textptr := textptr + 1 ;
           tokstart [ textptr ] := tokptr ;
         end ;
    128 :
          begin
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
          end ;
    9 :
        begin
          tokmem [ tokptr ] := 92 ;
          tokptr := tokptr + 1 ;
          tokmem [ tokptr ] := 66 ;
          tokptr := tokptr + 1 ;
          scrapptr := scrapptr + 1 ;
          cat [ scrapptr ] := 2 ;
          trans [ scrapptr ] := textptr ;
          textptr := textptr + 1 ;
          tokstart [ textptr ] := tokptr ;
        end ;
    10 :
         begin
           tokmem [ tokptr ] := 92 ;
           tokptr := tokptr + 1 ;
           tokmem [ tokptr ] := 84 ;
           tokptr := tokptr + 1 ;
           scrapptr := scrapptr + 1 ;
           cat [ scrapptr ] := 2 ;
           trans [ scrapptr ] := textptr ;
           textptr := textptr + 1 ;
           tokstart [ textptr ] := tokptr ;
         end ;
    12 : appoctal ;
    13 : apphex ;
    135 :
          begin
            tokmem [ tokptr ] := 92 ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 41 ;
            tokptr := tokptr + 1 ;
            scrapptr := scrapptr + 1 ;
            cat [ scrapptr ] := 1 ;
            trans [ scrapptr ] := textptr ;
            textptr := textptr + 1 ;
            tokstart [ textptr ] := tokptr ;
          end ;
    3 :
        begin
          tokmem [ tokptr ] := 92 ;
          tokptr := tokptr + 1 ;
          tokmem [ tokptr ] := 93 ;
          tokptr := tokptr + 1 ;
          scrapptr := scrapptr + 1 ;
          cat [ scrapptr ] := 1 ;
          trans [ scrapptr ] := textptr ;
          textptr := textptr + 1 ;
          tokstart [ textptr ] := tokptr ;
        end ;
    137 :
          begin
            tokmem [ tokptr ] := 92 ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 44 ;
            tokptr := tokptr + 1 ;
            scrapptr := scrapptr + 1 ;
            cat [ scrapptr ] := 2 ;
            trans [ scrapptr ] := textptr ;
            textptr := textptr + 1 ;
            tokstart [ textptr ] := tokptr ;
          end ;
    138 :
          begin
            tokmem [ tokptr ] := 138 ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 48 ;
            tokptr := tokptr + 1 ;
            scrapptr := scrapptr + 1 ;
            cat [ scrapptr ] := 1 ;
            trans [ scrapptr ] := textptr ;
            textptr := textptr + 1 ;
            tokstart [ textptr ] := tokptr ;
          end ;
    139 :
          begin
            tokmem [ tokptr ] := 141 ;
            tokptr := tokptr + 1 ;
            appcomment ;
          end ;
    140 :
          begin
            tokmem [ tokptr ] := 142 ;
            tokptr := tokptr + 1 ;
            appcomment ;
          end ;
    141 :
          begin
            tokmem [ tokptr ] := 134 ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 92 ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 32 ;
            tokptr := tokptr + 1 ;
            begin
              tokmem [ tokptr ] := 134 ;
              tokptr := tokptr + 1 ;
              appcomment ;
            end ;
          end ;
    142 :
          begin
            scrapptr := scrapptr + 1 ;
            cat [ scrapptr ] := 9 ;
            trans [ scrapptr ] := 0 ;
          end ;
    136 :
          begin
            tokmem [ tokptr ] := 92 ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 74 ;
            tokptr := tokptr + 1 ;
            scrapptr := scrapptr + 1 ;
            cat [ scrapptr ] := 2 ;
            trans [ scrapptr ] := textptr ;
            textptr := textptr + 1 ;
            tokstart [ textptr ] := tokptr ;
          end ;
    others :
             begin
               tokmem [ tokptr ] := nextcontrol ;
               tokptr := tokptr + 1 ;
               scrapptr := scrapptr + 1 ;
               cat [ scrapptr ] := 2 ;
               trans [ scrapptr ] := textptr ;
               textptr := textptr + 1 ;
               tokstart [ textptr ] := tokptr ;
             end
  end ;
end ;
procedure subcases ( p : namepointer ) ;
begin
  case ilk [ p ] of 
    0 :
        begin
          tokmem [ tokptr ] := 10240 + p ;
          tokptr := tokptr + 1 ;
          scrapptr := scrapptr + 1 ;
          cat [ scrapptr ] := 1 ;
          trans [ scrapptr ] := textptr ;
          textptr := textptr + 1 ;
          tokstart [ textptr ] := tokptr ;
        end ;
    4 :
        begin
          tokmem [ tokptr ] := 20480 + p ;
          tokptr := tokptr + 1 ;
          scrapptr := scrapptr + 1 ;
          cat [ scrapptr ] := 7 ;
          trans [ scrapptr ] := textptr ;
          textptr := textptr + 1 ;
          tokstart [ textptr ] := tokptr ;
        end ;
    7 :
        begin
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
        end ;
    8 :
        begin
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
        end ;
    9 :
        begin
          tokmem [ tokptr ] := 20480 + p ;
          tokptr := tokptr + 1 ;
          scrapptr := scrapptr + 1 ;
          cat [ scrapptr ] := 8 ;
          trans [ scrapptr ] := textptr ;
          textptr := textptr + 1 ;
          tokstart [ textptr ] := tokptr ;
        end ;
    12 :
         begin
           tokmem [ tokptr ] := 141 ;
           tokptr := tokptr + 1 ;
           tokmem [ tokptr ] := 20480 + p ;
           tokptr := tokptr + 1 ;
           scrapptr := scrapptr + 1 ;
           cat [ scrapptr ] := 7 ;
           trans [ scrapptr ] := textptr ;
           textptr := textptr + 1 ;
           tokstart [ textptr ] := tokptr ;
         end ;
    13 :
         begin
           tokmem [ tokptr ] := 20480 + p ;
           tokptr := tokptr + 1 ;
           scrapptr := scrapptr + 1 ;
           cat [ scrapptr ] := 3 ;
           trans [ scrapptr ] := textptr ;
           textptr := textptr + 1 ;
           tokstart [ textptr ] := tokptr ;
         end ;
    16 :
         begin
           tokmem [ tokptr ] := 20480 + p ;
           tokptr := tokptr + 1 ;
           scrapptr := scrapptr + 1 ;
           cat [ scrapptr ] := 1 ;
           trans [ scrapptr ] := textptr ;
           textptr := textptr + 1 ;
           tokstart [ textptr ] := tokptr ;
         end ;
    20 :
         begin
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
         end ;
  end ;
end ;
procedure Pascalparse ;

label 21 , 10 ;

var j : 0 .. longbufsize ;
  p : namepointer ;
begin
  while nextcontrol < 143 do
    begin
      if ( scrapptr + 4 > maxscraps ) or ( tokptr + 6 > maxtoks ) or ( textptr + 4 > maxtexts ) then
        begin
          begin
            writeln ( termout ) ;
            write ( termout , '! Sorry, ' , 'scrap/token/text' , ' capacity exceeded' ) ;
            error ;
            history := 3 ;
            jumpout ;
          end ;
        end ;
      21 : case nextcontrol of 
             129 , 2 :
                       begin
                         tokmem [ tokptr ] := 92 ;
                         tokptr := tokptr + 1 ;
                         if nextcontrol = 2 then
                           begin
                             tokmem [ tokptr ] := 61 ;
                             tokptr := tokptr + 1 ;
                           end
                         else
                           begin
                             tokmem [ tokptr ] := 46 ;
                             tokptr := tokptr + 1 ;
                           end ;
                         tokmem [ tokptr ] := 123 ;
                         tokptr := tokptr + 1 ;
                         j := idfirst ;
                         while j < idloc do
                           begin
                             case buffer [ j ] of 
                               32 , 92 , 35 , 37 , 36 , 94 , 39 , 96 , 123 , 125 , 126 , 38 , 95 :
                                                                                                   begin
                                                                                                     tokmem [ tokptr ] := 92 ;
                                                                                                     tokptr := tokptr + 1 ;
                                                                                                   end ;
                               64 : if buffer [ j + 1 ] = 64 then j := j + 1
                                    else
                                      begin
                                        if not phaseone then
                                          begin
                                            writeln ( termout ) ;
                                            write ( termout , '! Double @ should be used in strings' ) ;
                                            error ;
                                          end ;
                                      end ;
                               others :
                             end ;
                             begin
                               if tokptr + 2 > maxtoks then
                                 begin
                                   writeln ( termout ) ;
                                   write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
                                   error ;
                                   history := 3 ;
                                   jumpout ;
                                 end ;
                               tokmem [ tokptr ] := buffer [ j ] ;
                               tokptr := tokptr + 1 ;
                             end ;
                             j := j + 1 ;
                           end ;
                         begin
                           tokmem [ tokptr ] := 125 ;
                           tokptr := tokptr + 1 ;
                           scrapptr := scrapptr + 1 ;
                           cat [ scrapptr ] := 1 ;
                           trans [ scrapptr ] := textptr ;
                           textptr := textptr + 1 ;
                           tokstart [ textptr ] := tokptr ;
                         end ;
                       end ;
             130 :
                   begin
                     p := idlookup ( 0 ) ;
                     case ilk [ p ] of 
                       0 , 4 , 7 , 8 , 9 , 12 , 13 , 16 , 20 : subcases ( p ) ;
                       5 :
                           begin
                             begin
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
                             end ;
                             begin
                               scrapptr := scrapptr + 1 ;
                               cat [ scrapptr ] := 3 ;
                               trans [ scrapptr ] := 0 ;
                             end ;
                           end ;
                       6 :
                           begin
                             begin
                               scrapptr := scrapptr + 1 ;
                               cat [ scrapptr ] := 21 ;
                               trans [ scrapptr ] := 0 ;
                             end ;
                             begin
                               tokmem [ tokptr ] := 141 ;
                               tokptr := tokptr + 1 ;
                               tokmem [ tokptr ] := 20480 + p ;
                               tokptr := tokptr + 1 ;
                               scrapptr := scrapptr + 1 ;
                               cat [ scrapptr ] := 7 ;
                               trans [ scrapptr ] := textptr ;
                               textptr := textptr + 1 ;
                               tokstart [ textptr ] := tokptr ;
                             end ;
                           end ;
                       10 :
                            begin
                              if ( scrapptr < scrapbase ) or ( ( cat [ scrapptr ] <> 10 ) and ( cat [ scrapptr ] <> 9 ) ) then
                                begin
                                  scrapptr := scrapptr + 1 ;
                                  cat [ scrapptr ] := 10 ;
                                  trans [ scrapptr ] := 0 ;
                                end ;
                              begin
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
                              end ;
                            end ;
                       11 :
                            begin
                              if ( scrapptr < scrapbase ) or ( ( cat [ scrapptr ] <> 10 ) and ( cat [ scrapptr ] <> 9 ) ) then
                                begin
                                  scrapptr := scrapptr + 1 ;
                                  cat [ scrapptr ] := 10 ;
                                  trans [ scrapptr ] := 0 ;
                                end ;
                              begin
                                tokmem [ tokptr ] := 141 ;
                                tokptr := tokptr + 1 ;
                                tokmem [ tokptr ] := 20480 + p ;
                                tokptr := tokptr + 1 ;
                                scrapptr := scrapptr + 1 ;
                                cat [ scrapptr ] := 6 ;
                                trans [ scrapptr ] := textptr ;
                                textptr := textptr + 1 ;
                                tokstart [ textptr ] := tokptr ;
                              end ;
                            end ;
                       14 :
                            begin
                              begin
                                scrapptr := scrapptr + 1 ;
                                cat [ scrapptr ] := 12 ;
                                trans [ scrapptr ] := 0 ;
                              end ;
                              begin
                                tokmem [ tokptr ] := 141 ;
                                tokptr := tokptr + 1 ;
                                tokmem [ tokptr ] := 20480 + p ;
                                tokptr := tokptr + 1 ;
                                scrapptr := scrapptr + 1 ;
                                cat [ scrapptr ] := 7 ;
                                trans [ scrapptr ] := textptr ;
                                textptr := textptr + 1 ;
                                tokstart [ textptr ] := tokptr ;
                              end ;
                            end ;
                       23 :
                            begin
                              begin
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
                              end ;
                              begin
                                tokmem [ tokptr ] := 20480 + p ;
                                tokptr := tokptr + 1 ;
                                scrapptr := scrapptr + 1 ;
                                cat [ scrapptr ] := 8 ;
                                trans [ scrapptr ] := textptr ;
                                textptr := textptr + 1 ;
                                tokstart [ textptr ] := tokptr ;
                              end ;
                            end ;
                       17 :
                            begin
                              begin
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
                              end ;
                              begin
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
                              end ;
                            end ;
                       18 :
                            begin
                              begin
                                tokmem [ tokptr ] := 20480 + p ;
                                tokptr := tokptr + 1 ;
                                scrapptr := scrapptr + 1 ;
                                cat [ scrapptr ] := 18 ;
                                trans [ scrapptr ] := textptr ;
                                textptr := textptr + 1 ;
                                tokstart [ textptr ] := tokptr ;
                              end ;
                              begin
                                scrapptr := scrapptr + 1 ;
                                cat [ scrapptr ] := 3 ;
                                trans [ scrapptr ] := 0 ;
                              end ;
                            end ;
                       19 :
                            begin
                              begin
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
                              end ;
                              begin
                                scrapptr := scrapptr + 1 ;
                                cat [ scrapptr ] := 3 ;
                                trans [ scrapptr ] := 0 ;
                              end ;
                            end ;
                       21 :
                            begin
                              if ( scrapptr < scrapbase ) or ( ( cat [ scrapptr ] <> 10 ) and ( cat [ scrapptr ] <> 9 ) ) then
                                begin
                                  scrapptr := scrapptr + 1 ;
                                  cat [ scrapptr ] := 10 ;
                                  trans [ scrapptr ] := 0 ;
                                end ;
                              begin
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
                              end ;
                              begin
                                scrapptr := scrapptr + 1 ;
                                cat [ scrapptr ] := 13 ;
                                trans [ scrapptr ] := 0 ;
                              end ;
                            end ;
                       22 :
                            begin
                              begin
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
                              end ;
                              begin
                                scrapptr := scrapptr + 1 ;
                                cat [ scrapptr ] := 3 ;
                                trans [ scrapptr ] := 0 ;
                              end ;
                            end ;
                       others :
                                begin
                                  nextcontrol := ilk [ p ] - 24 ;
                                  goto 21 ;
                                end
                     end ;
                   end ;
             134 :
                   begin
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
                     for j := idfirst to idloc - 1 do
                       begin
                         if tokptr + 2 > maxtoks then
                           begin
                             writeln ( termout ) ;
                             write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
                             error ;
                             history := 3 ;
                             jumpout ;
                           end ;
                         tokmem [ tokptr ] := buffer [ j ] ;
                         tokptr := tokptr + 1 ;
                       end ;
                     begin
                       tokmem [ tokptr ] := 125 ;
                       tokptr := tokptr + 1 ;
                       scrapptr := scrapptr + 1 ;
                       cat [ scrapptr ] := 1 ;
                       trans [ scrapptr ] := textptr ;
                       textptr := textptr + 1 ;
                       tokstart [ textptr ] := tokptr ;
                     end ;
                   end ;
             others : easycases
           end ;
      nextcontrol := getnext ;
      if ( nextcontrol = 124 ) or ( nextcontrol = 123 ) then goto 10 ;
    end ;
  10 :
end ;
function Pascaltranslate : textpointer ;

var p : textpointer ;
  savebase : 0 .. maxscraps ;
begin
  savebase := scrapbase ;
  scrapbase := scrapptr + 1 ;
  Pascalparse ;
  if nextcontrol <> 124 then
    begin
      if not phaseone then
        begin
          writeln ( termout ) ;
          write ( termout , '! Missing "|" after Pascal text' ) ;
          error ;
        end ;
    end ;
  begin
    if tokptr + 2 > maxtoks then
      begin
        writeln ( termout ) ;
        write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
        error ;
        history := 3 ;
        jumpout ;
      end ;
    tokmem [ tokptr ] := 135 ;
    tokptr := tokptr + 1 ;
  end ;
  appcomment ;
  p := translate ;
  scrapptr := scrapbase - 1 ;
  scrapbase := savebase ;
  Pascaltranslate := p ;
end ;
procedure outerparse ;

var bal : eightbits ;
  p , q : textpointer ;
begin
  while nextcontrol < 143 do
    if nextcontrol <> 123 then Pascalparse
    else
      begin
        if ( tokptr + 7 > maxtoks ) or ( textptr + 3 > maxtexts ) or ( scrapptr >= maxscraps ) then
          begin
            begin
              writeln ( termout ) ;
              write ( termout , '! Sorry, ' , 'token/text/scrap' , ' capacity exceeded' ) ;
              error ;
              history := 3 ;
              jumpout ;
            end ;
          end ;
        tokmem [ tokptr ] := 92 ;
        tokptr := tokptr + 1 ;
        tokmem [ tokptr ] := 67 ;
        tokptr := tokptr + 1 ;
        tokmem [ tokptr ] := 123 ;
        tokptr := tokptr + 1 ;
        bal := copycomment ( 1 ) ;
        nextcontrol := 124 ;
        while bal > 0 do
          begin
            p := textptr ;
            textptr := textptr + 1 ;
            tokstart [ textptr ] := tokptr ;
            q := Pascaltranslate ;
            tokmem [ tokptr ] := 40960 + p ;
            tokptr := tokptr + 1 ;
            tokmem [ tokptr ] := 51200 + q ;
            tokptr := tokptr + 1 ;
            if nextcontrol = 124 then bal := copycomment ( bal )
            else bal := 0 ;
          end ;
        tokmem [ tokptr ] := 141 ;
        tokptr := tokptr + 1 ;
        appcomment ;
      end ;
end ;
procedure pushlevel ( p : textpointer ) ;
begin
  if stackptr = stacksize then
    begin
      writeln ( termout ) ;
      write ( termout , '! Sorry, ' , 'stack' , ' capacity exceeded' ) ;
      error ;
      history := 3 ;
      jumpout ;
    end
  else
    begin
      if stackptr > 0 then stack [ stackptr ] := curstate ;
      stackptr := stackptr + 1 ;
      curstate . tokfield := tokstart [ p ] ;
      curstate . endfield := tokstart [ p + 1 ] ;
    end ;
end ;
function getoutput : eightbits ;

label 20 ;

var a : sixteenbits ;
begin
  20 : while curstate . tokfield = curstate . endfield do
         begin
           stackptr := stackptr - 1 ;
           curstate := stack [ stackptr ] ;
         end ;
  a := tokmem [ curstate . tokfield ] ;
  curstate . tokfield := curstate . tokfield + 1 ;
  if a >= 256 then
    begin
      curname := a mod 10240 ;
      case a div 10240 of 
        2 : a := 129 ;
        3 : a := 128 ;
        4 :
            begin
              pushlevel ( curname ) ;
              goto 20 ;
            end ;
        5 :
            begin
              pushlevel ( curname ) ;
              curstate . modefield := 0 ;
              goto 20 ;
            end ;
        others : a := 130
      end ;
    end ;
  getoutput := a ;
end ;
procedure makeoutput ;
forward ;
procedure outputPascal ;

var savetokptr , savetextptr , savenextcontrol : sixteenbits ;
  p : textpointer ;
begin
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
end ;
procedure makeoutput ;

label 21 , 10 , 31 ;

var a : eightbits ;
  b : eightbits ;
  k , klimit : 0 .. maxbytes ;
  w : 0 .. 1 ;
  j : 0 .. longbufsize ;
  stringdelimiter : ASCIIcode ;
  saveloc , savelimit : 0 .. longbufsize ;
  curmodname : namepointer ;
  savemode : mode ;
begin
  tokmem [ tokptr ] := 143 ;
  tokptr := tokptr + 1 ;
  textptr := textptr + 1 ;
  tokstart [ textptr ] := tokptr ;
  pushlevel ( textptr - 1 ) ;
  while true do
    begin
      a := getoutput ;
      21 : case a of 
             143 : goto 10 ;
             130 , 129 :
                         begin
                           begin
                             if outptr = linelength then breakout ;
                             outptr := outptr + 1 ;
                             outbuf [ outptr ] := 92 ;
                           end ;
                           if a = 130 then if bytestart [ curname + 2 ] - bytestart [ curname ] = 1 then
                                             begin
                                               if outptr = linelength then breakout ;
                                               outptr := outptr + 1 ;
                                               outbuf [ outptr ] := 124 ;
                                             end
                           else
                             begin
                               if outptr = linelength then breakout ;
                               outptr := outptr + 1 ;
                               outbuf [ outptr ] := 92 ;
                             end
                           else
                             begin
                               if outptr = linelength then breakout ;
                               outptr := outptr + 1 ;
                               outbuf [ outptr ] := 38 ;
                             end ;
                           if bytestart [ curname + 2 ] - bytestart [ curname ] = 1 then
                             begin
                               if outptr = linelength then breakout ;
                               outptr := outptr + 1 ;
                               outbuf [ outptr ] := bytemem [ curname mod 2 , bytestart [ curname ] ] ;
                             end
                           else outname ( curname ) ;
                         end ;
             128 :
                   begin
                     begin
                       if outptr = linelength then breakout ;
                       outptr := outptr + 1 ;
                       outbuf [ outptr ] := 92 ;
                       if outptr = linelength then breakout ;
                       outptr := outptr + 1 ;
                       outbuf [ outptr ] := 88 ;
                     end ;
                     curxref := xref [ curname ] ;
                     if xmem [ curxref ] . numfield >= 10240 then
                       begin
                         outmod ( xmem [ curxref ] . numfield - 10240 ) ;
                         if phasethree then
                           begin
                             curxref := xmem [ curxref ] . xlinkfield ;
                             while xmem [ curxref ] . numfield >= 10240 do
                               begin
                                 begin
                                   if outptr = linelength then breakout ;
                                   outptr := outptr + 1 ;
                                   outbuf [ outptr ] := 44 ;
                                   if outptr = linelength then breakout ;
                                   outptr := outptr + 1 ;
                                   outbuf [ outptr ] := 32 ;
                                 end ;
                                 outmod ( xmem [ curxref ] . numfield - 10240 ) ;
                                 curxref := xmem [ curxref ] . xlinkfield ;
                               end ;
                           end ;
                       end
                     else
                       begin
                         if outptr = linelength then breakout ;
                         outptr := outptr + 1 ;
                         outbuf [ outptr ] := 48 ;
                       end ;
                     begin
                       if outptr = linelength then breakout ;
                       outptr := outptr + 1 ;
                       outbuf [ outptr ] := 58 ;
                     end ;
                     k := bytestart [ curname ] ;
                     w := curname mod 2 ;
                     klimit := bytestart [ curname + 2 ] ;
                     curmodname := curname ;
                     while k < klimit do
                       begin
                         b := bytemem [ w , k ] ;
                         k := k + 1 ;
                         if b = 64 then
                           begin
                             if bytemem [ w , k ] <> 64 then
                               begin
                                 begin
                                   writeln ( termout ) ;
                                   write ( termout , '! Illegal control code in section name:' ) ;
                                 end ;
                                 begin
                                   writeln ( termout ) ;
                                   write ( termout , '<' ) ;
                                 end ;
                                 printid ( curmodname ) ;
                                 write ( termout , '> ' ) ;
                                 history := 2 ;
                               end ;
                             k := k + 1 ;
                           end ;
                         if b <> 124 then
                           begin
                             if outptr = linelength then breakout ;
                             outptr := outptr + 1 ;
                             outbuf [ outptr ] := b ;
                           end
                         else
                           begin
                             j := limit + 1 ;
                             buffer [ j ] := 124 ;
                             stringdelimiter := 0 ;
                             while true do
                               begin
                                 if k >= klimit then
                                   begin
                                     begin
                                       writeln ( termout ) ;
                                       write ( termout , '! Pascal text in section name didn''t end:' ) ;
                                     end ;
                                     begin
                                       writeln ( termout ) ;
                                       write ( termout , '<' ) ;
                                     end ;
                                     printid ( curmodname ) ;
                                     write ( termout , '> ' ) ;
                                     history := 2 ;
                                     goto 31 ;
                                   end ;
                                 b := bytemem [ w , k ] ;
                                 k := k + 1 ;
                                 if b = 64 then
                                   begin
                                     if j > longbufsize - 4 then
                                       begin
                                         writeln ( termout ) ;
                                         write ( termout , '! Sorry, ' , 'buffer' , ' capacity exceeded' ) ;
                                         error ;
                                         history := 3 ;
                                         jumpout ;
                                       end ;
                                     buffer [ j + 1 ] := 64 ;
                                     buffer [ j + 2 ] := bytemem [ w , k ] ;
                                     j := j + 2 ;
                                     k := k + 1 ;
                                   end
                                 else
                                   begin
                                     if ( b = 34 ) or ( b = 39 ) then if stringdelimiter = 0 then stringdelimiter := b
                                     else if stringdelimiter = b then stringdelimiter := 0 ;
                                     if ( b <> 124 ) or ( stringdelimiter <> 0 ) then
                                       begin
                                         if j > longbufsize - 3 then
                                           begin
                                             writeln ( termout ) ;
                                             write ( termout , '! Sorry, ' , 'buffer' , ' capacity exceeded' ) ;
                                             error ;
                                             history := 3 ;
                                             jumpout ;
                                           end ;
                                         j := j + 1 ;
                                         buffer [ j ] := b ;
                                       end
                                     else goto 31 ;
                                   end ;
                               end ;
                             31 : ;
                             saveloc := loc ;
                             savelimit := limit ;
                             loc := limit + 2 ;
                             limit := j + 1 ;
                             buffer [ limit ] := 124 ;
                             outputPascal ;
                             loc := saveloc ;
                             limit := savelimit ;
                           end ;
                       end ;
                     begin
                       if outptr = linelength then breakout ;
                       outptr := outptr + 1 ;
                       outbuf [ outptr ] := 92 ;
                       if outptr = linelength then breakout ;
                       outptr := outptr + 1 ;
                       outbuf [ outptr ] := 88 ;
                     end ;
                   end ;
             131 , 133 , 132 :
                               begin
                                 begin
                                   if outptr = linelength then breakout ;
                                   outptr := outptr + 1 ;
                                   outbuf [ outptr ] := 92 ;
                                   if outptr = linelength then breakout ;
                                   outptr := outptr + 1 ;
                                   outbuf [ outptr ] := 109 ;
                                   if outptr = linelength then breakout ;
                                   outptr := outptr + 1 ;
                                   outbuf [ outptr ] := 97 ;
                                   if outptr = linelength then breakout ;
                                   outptr := outptr + 1 ;
                                   outbuf [ outptr ] := 116 ;
                                   if outptr = linelength then breakout ;
                                   outptr := outptr + 1 ;
                                   outbuf [ outptr ] := 104 ;
                                 end ;
                                 if a = 131 then
                                   begin
                                     if outptr = linelength then breakout ;
                                     outptr := outptr + 1 ;
                                     outbuf [ outptr ] := 98 ;
                                     if outptr = linelength then breakout ;
                                     outptr := outptr + 1 ;
                                     outbuf [ outptr ] := 105 ;
                                     if outptr = linelength then breakout ;
                                     outptr := outptr + 1 ;
                                     outbuf [ outptr ] := 110 ;
                                   end
                                 else if a = 132 then
                                        begin
                                          if outptr = linelength then breakout ;
                                          outptr := outptr + 1 ;
                                          outbuf [ outptr ] := 114 ;
                                          if outptr = linelength then breakout ;
                                          outptr := outptr + 1 ;
                                          outbuf [ outptr ] := 101 ;
                                          if outptr = linelength then breakout ;
                                          outptr := outptr + 1 ;
                                          outbuf [ outptr ] := 108 ;
                                        end
                                 else
                                   begin
                                     if outptr = linelength then breakout ;
                                     outptr := outptr + 1 ;
                                     outbuf [ outptr ] := 111 ;
                                     if outptr = linelength then breakout ;
                                     outptr := outptr + 1 ;
                                     outbuf [ outptr ] := 112 ;
                                   end ;
                                 begin
                                   if outptr = linelength then breakout ;
                                   outptr := outptr + 1 ;
                                   outbuf [ outptr ] := 123 ;
                                 end ;
                               end ;
             135 :
                   begin
                     repeat
                       a := getoutput ;
                     until ( a < 139 ) or ( a > 142 ) ;
                     goto 21 ;
                   end ;
             134 :
                   begin
                     repeat
                       a := getoutput ;
                     until ( ( a < 139 ) and ( a <> 32 ) ) or ( a > 142 ) ;
                     goto 21 ;
                   end ;
             136 , 137 , 138 , 139 , 140 , 141 , 142 : if a < 140 then
                                                         begin
                                                           if curstate . modefield = 1 then
                                                             begin
                                                               begin
                                                                 if outptr = linelength then breakout ;
                                                                 outptr := outptr + 1 ;
                                                                 outbuf [ outptr ] := 92 ;
                                                                 if outptr = linelength then breakout ;
                                                                 outptr := outptr + 1 ;
                                                                 outbuf [ outptr ] := a - 87 ;
                                                               end ;
                                                               if a = 138 then
                                                                 begin
                                                                   if outptr = linelength then breakout ;
                                                                   outptr := outptr + 1 ;
                                                                   outbuf [ outptr ] := getoutput ;
                                                                 end
                                                             end
                                                           else if a = 138 then b := getoutput
                                                         end
                                                       else
                                                         begin
                                                           b := a ;
                                                           savemode := curstate . modefield ;
                                                           while true do
                                                             begin
                                                               a := getoutput ;
                                                               if ( a = 135 ) or ( a = 134 ) then goto 21 ;
                                                               if ( ( a <> 32 ) and ( a < 140 ) ) or ( a > 142 ) then
                                                                 begin
                                                                   if savemode = 1 then
                                                                     begin
                                                                       if outptr > 3 then if ( outbuf [ outptr ] = 80 ) and ( outbuf [ outptr - 1 ] = 92 ) and ( outbuf [ outptr - 2 ] = 89 ) and ( outbuf [ outptr - 3 ] = 92 ) then goto 21 ;
                                                                       begin
                                                                         if outptr = linelength then breakout ;
                                                                         outptr := outptr + 1 ;
                                                                         outbuf [ outptr ] := 92 ;
                                                                         if outptr = linelength then breakout ;
                                                                         outptr := outptr + 1 ;
                                                                         outbuf [ outptr ] := b - 87 ;
                                                                       end ;
                                                                       if a <> 143 then finishline ;
                                                                     end
                                                                   else if ( a <> 143 ) and ( curstate . modefield = 0 ) then
                                                                          begin
                                                                            if outptr = linelength then breakout ;
                                                                            outptr := outptr + 1 ;
                                                                            outbuf [ outptr ] := 32 ;
                                                                          end ;
                                                                   goto 21 ;
                                                                 end ;
                                                               if a > b then b := a ;
                                                             end ;
                                                         end ;
             others :
                      begin
                        if outptr = linelength then breakout ;
                        outptr := outptr + 1 ;
                        outbuf [ outptr ] := a ;
                      end
           end ;
    end ;
  10 :
end ;
procedure finishPascal ;

var p : textpointer ;
begin
  begin
    if outptr = linelength then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 92 ;
    if outptr = linelength then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 80 ;
  end ;
  begin
    if tokptr + 2 > maxtoks then
      begin
        writeln ( termout ) ;
        write ( termout , '! Sorry, ' , 'token' , ' capacity exceeded' ) ;
        error ;
        history := 3 ;
        jumpout ;
      end ;
    tokmem [ tokptr ] := 141 ;
    tokptr := tokptr + 1 ;
  end ;
  appcomment ;
  p := translate ;
  tokmem [ tokptr ] := p + 40960 ;
  tokptr := tokptr + 1 ;
  makeoutput ;
  if outptr > 1 then if outbuf [ outptr - 1 ] = 92 then if outbuf [ outptr ] = 54 then outptr := outptr - 2
  else if outbuf [ outptr ] = 55 then outbuf [ outptr ] := 89 ;
  begin
    if outptr = linelength then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 92 ;
    if outptr = linelength then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 112 ;
    if outptr = linelength then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 97 ;
    if outptr = linelength then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 114 ;
  end ;
  finishline ;
  tokptr := 1 ;
  textptr := 1 ;
  scrapptr := 0 ;
end ;
procedure footnote ( flag : sixteenbits ) ;

label 30 , 10 ;

var q : xrefnumber ;
begin
  if xmem [ curxref ] . numfield <= flag then goto 10 ;
  finishline ;
  begin
    if outptr = linelength then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 92 ;
  end ;
  if flag = 0 then
    begin
      if outptr = linelength then breakout ;
      outptr := outptr + 1 ;
      outbuf [ outptr ] := 85 ;
    end
  else
    begin
      if outptr = linelength then breakout ;
      outptr := outptr + 1 ;
      outbuf [ outptr ] := 65 ;
    end ;
  q := curxref ;
  if xmem [ xmem [ q ] . xlinkfield ] . numfield > flag then
    begin
      if outptr = linelength then breakout ;
      outptr := outptr + 1 ;
      outbuf [ outptr ] := 115 ;
    end ;
  while true do
    begin
      outmod ( xmem [ curxref ] . numfield - flag ) ;
      curxref := xmem [ curxref ] . xlinkfield ;
      if xmem [ curxref ] . numfield <= flag then goto 30 ;
      if xmem [ xmem [ curxref ] . xlinkfield ] . numfield > flag then
        begin
          if outptr = linelength then breakout ;
          outptr := outptr + 1 ;
          outbuf [ outptr ] := 44 ;
          if outptr = linelength then breakout ;
          outptr := outptr + 1 ;
          outbuf [ outptr ] := 32 ;
        end
      else
        begin
          begin
            if outptr = linelength then breakout ;
            outptr := outptr + 1 ;
            outbuf [ outptr ] := 92 ;
            if outptr = linelength then breakout ;
            outptr := outptr + 1 ;
            outbuf [ outptr ] := 69 ;
            if outptr = linelength then breakout ;
            outptr := outptr + 1 ;
            outbuf [ outptr ] := 84 ;
          end ;
          if curxref <> xmem [ q ] . xlinkfield then
            begin
              if outptr = linelength then breakout ;
              outptr := outptr + 1 ;
              outbuf [ outptr ] := 115 ;
            end ;
        end ;
    end ;
  30 : ;
  begin
    if outptr = linelength then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 46 ;
  end ;
  10 :
end ;
procedure unbucket ( d : eightbits ) ;

var c : ASCIIcode ;
begin
  for c := 229 downto 0 do
    if bucket [ collate [ c ] ] > 0 then
      begin
        if scrapptr > maxscraps then
          begin
            writeln ( termout ) ;
            write ( termout , '! Sorry, ' , 'sorting' , ' capacity exceeded' ) ;
            error ;
            history := 3 ;
            jumpout ;
          end ;
        scrapptr := scrapptr + 1 ;
        if c = 0 then cat [ scrapptr ] := 255
        else cat [ scrapptr ] := d ;
        trans [ scrapptr ] := bucket [ collate [ c ] ] ;
        bucket [ collate [ c ] ] := 0 ;
      end ;
end ;
procedure modprint ( p : namepointer ) ;
begin
  if p > 0 then
    begin
      modprint ( link [ p ] ) ;
      begin
        if outptr = linelength then breakout ;
        outptr := outptr + 1 ;
        outbuf [ outptr ] := 92 ;
        if outptr = linelength then breakout ;
        outptr := outptr + 1 ;
        outbuf [ outptr ] := 58 ;
      end ;
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
    end ;
end ;
procedure PhaseI ;
begin
  phaseone := true ;
  phasethree := false ;
  resetinput ;
  modulecount := 0 ;
  skiplimbo ;
  changeexists := false ;
  while not inputhasended do
    begin
      modulecount := modulecount + 1 ;
      if modulecount = maxmodules then
        begin
          writeln ( termout ) ;
          write ( termout , '! Sorry, ' , 'section number' , ' capacity exceeded' ) ;
          error ;
          history := 3 ;
          jumpout ;
        end ;
      changedmodule [ modulecount ] := changing ;
      if buffer [ loc - 1 ] = 42 then
        begin
          write ( termout , '*' , modulecount : 1 ) ;
          break ( termout ) ;
        end ;
      repeat
        nextcontrol := skipTeX ;
        case nextcontrol of 
          126 : xrefswitch := 10240 ;
          125 : xrefswitch := 0 ;
          124 : Pascalxref ;
          131 , 132 , 133 , 146 :
                                  begin
                                    loc := loc - 2 ;
                                    nextcontrol := getnext ;
                                    if nextcontrol <> 146 then newxref ( idlookup ( nextcontrol - 130 ) ) ;
                                  end ;
          others :
        end ;
      until nextcontrol >= 143 ;
      while nextcontrol <= 144 do
        begin
          xrefswitch := 10240 ;
          if nextcontrol = 144 then nextcontrol := getnext
          else
            begin
              nextcontrol := getnext ;
              if nextcontrol = 130 then
                begin
                  lhs := idlookup ( 0 ) ;
                  ilk [ lhs ] := 0 ;
                  newxref ( lhs ) ;
                  nextcontrol := getnext ;
                  if nextcontrol = 30 then
                    begin
                      nextcontrol := getnext ;
                      if nextcontrol = 130 then
                        begin
                          rhs := idlookup ( 0 ) ;
                          ilk [ lhs ] := ilk [ rhs ] ;
                          ilk [ rhs ] := 0 ;
                          newxref ( rhs ) ;
                          ilk [ rhs ] := ilk [ lhs ] ;
                          nextcontrol := getnext ;
                        end ;
                    end ;
                end ;
            end ;
          outerxref ;
        end ;
      if nextcontrol <= 146 then
        begin
          if nextcontrol = 145 then modxrefswitch := 0
          else modxrefswitch := 10240 ;
          repeat
            if nextcontrol = 146 then newmodxref ( curmodule ) ;
            nextcontrol := getnext ;
            outerxref ;
          until nextcontrol > 146 ;
        end ;
      if changedmodule [ modulecount ] then changeexists := true ;
    end ;
  changedmodule [ modulecount ] := changeexists ;
  phaseone := false ;
  modcheck ( ilk [ 0 ] ) ; ;
end ;
procedure PhaseII ;
begin
  resetinput ;
  begin
    writeln ( termout ) ;
    write ( termout , 'Writing the output file...' ) ;
  end ;
  modulecount := 0 ;
  copylimbo ;
  finishline ;
  flushbuffer ( 0 , false , false ) ;
  while not inputhasended do
    begin
      modulecount := modulecount + 1 ;
      begin
        if outptr = linelength then breakout ;
        outptr := outptr + 1 ;
        outbuf [ outptr ] := 92 ;
      end ;
      if buffer [ loc - 1 ] <> 42 then
        begin
          if outptr = linelength then breakout ;
          outptr := outptr + 1 ;
          outbuf [ outptr ] := 77 ;
        end
      else
        begin
          begin
            if outptr = linelength then breakout ;
            outptr := outptr + 1 ;
            outbuf [ outptr ] := 78 ;
          end ;
          write ( termout , '*' , modulecount : 1 ) ;
          break ( termout ) ;
        end ;
      outmod ( modulecount ) ;
      begin
        if outptr = linelength then breakout ;
        outptr := outptr + 1 ;
        outbuf [ outptr ] := 46 ;
        if outptr = linelength then breakout ;
        outptr := outptr + 1 ;
        outbuf [ outptr ] := 32 ;
      end ;
      saveline := outline ;
      saveplace := outptr ;
      repeat
        nextcontrol := copyTeX ;
        case nextcontrol of 
          124 :
                begin
                  stackptr := 0 ;
                  curstate . modefield := 1 ;
                  outputPascal ;
                end ;
          64 :
               begin
                 if outptr = linelength then breakout ;
                 outptr := outptr + 1 ;
                 outbuf [ outptr ] := 64 ;
               end ;
          12 :
               begin
                 begin
                   if outptr = linelength then breakout ;
                   outptr := outptr + 1 ;
                   outbuf [ outptr ] := 92 ;
                   if outptr = linelength then breakout ;
                   outptr := outptr + 1 ;
                   outbuf [ outptr ] := 79 ;
                   if outptr = linelength then breakout ;
                   outptr := outptr + 1 ;
                   outbuf [ outptr ] := 123 ;
                 end ;
                 while ( buffer [ loc ] >= 48 ) and ( buffer [ loc ] <= 55 ) do
                   begin
                     begin
                       if outptr = linelength then breakout ;
                       outptr := outptr + 1 ;
                       outbuf [ outptr ] := buffer [ loc ] ;
                     end ;
                     loc := loc + 1 ;
                   end ;
                 begin
                   if outptr = linelength then breakout ;
                   outptr := outptr + 1 ;
                   outbuf [ outptr ] := 125 ;
                 end ;
               end ;
          13 :
               begin
                 begin
                   if outptr = linelength then breakout ;
                   outptr := outptr + 1 ;
                   outbuf [ outptr ] := 92 ;
                   if outptr = linelength then breakout ;
                   outptr := outptr + 1 ;
                   outbuf [ outptr ] := 72 ;
                   if outptr = linelength then breakout ;
                   outptr := outptr + 1 ;
                   outbuf [ outptr ] := 123 ;
                 end ;
                 while ( ( buffer [ loc ] >= 48 ) and ( buffer [ loc ] <= 57 ) ) or ( ( buffer [ loc ] >= 65 ) and ( buffer [ loc ] <= 70 ) ) do
                   begin
                     begin
                       if outptr = linelength then breakout ;
                       outptr := outptr + 1 ;
                       outbuf [ outptr ] := buffer [ loc ] ;
                     end ;
                     loc := loc + 1 ;
                   end ;
                 begin
                   if outptr = linelength then breakout ;
                   outptr := outptr + 1 ;
                   outbuf [ outptr ] := 125 ;
                 end ;
               end ;
          134 , 131 , 132 , 133 , 146 :
                                        begin
                                          loc := loc - 2 ;
                                          nextcontrol := getnext ;
                                          if nextcontrol = 134 then
                                            begin
                                              if not phaseone then
                                                begin
                                                  writeln ( termout ) ;
                                                  write ( termout , '! TeX string should be in Pascal text only' ) ;
                                                  error ;
                                                end ;
                                            end ;
                                        end ;
          9 , 10 , 135 , 137 , 138 , 139 , 140 , 141 , 136 , 142 :
                                                                   begin
                                                                     if not phaseone then
                                                                       begin
                                                                         writeln ( termout ) ;
                                                                         write ( termout , '! You can''t do that in TeX text' ) ;
                                                                         error ;
                                                                       end ;
                                                                   end ;
          others :
        end ;
      until nextcontrol >= 143 ;
      if nextcontrol <= 144 then
        begin
          if ( saveline <> outline ) or ( saveplace <> outptr ) then
            begin
              if outptr = linelength then breakout ;
              outptr := outptr + 1 ;
              outbuf [ outptr ] := 92 ;
              if outptr = linelength then breakout ;
              outptr := outptr + 1 ;
              outbuf [ outptr ] := 89 ;
            end ;
          saveline := outline ;
          saveplace := outptr ;
        end ;
      while nextcontrol <= 144 do
        begin
          stackptr := 0 ;
          curstate . modefield := 1 ;
          if nextcontrol = 144 then
            begin
              begin
                tokmem [ tokptr ] := 92 ;
                tokptr := tokptr + 1 ;
                tokmem [ tokptr ] := 68 ;
                tokptr := tokptr + 1 ;
                scrapptr := scrapptr + 1 ;
                cat [ scrapptr ] := 3 ;
                trans [ scrapptr ] := textptr ;
                textptr := textptr + 1 ;
                tokstart [ textptr ] := tokptr ;
              end ;
              nextcontrol := getnext ;
              if nextcontrol <> 130 then
                begin
                  if not phaseone then
                    begin
                      writeln ( termout ) ;
                      write ( termout , '! Improper macro definition' ) ;
                      error ;
                    end ;
                end
              else
                begin
                  tokmem [ tokptr ] := 10240 + idlookup ( 0 ) ;
                  tokptr := tokptr + 1 ;
                  scrapptr := scrapptr + 1 ;
                  cat [ scrapptr ] := 2 ;
                  trans [ scrapptr ] := textptr ;
                  textptr := textptr + 1 ;
                  tokstart [ textptr ] := tokptr ;
                end ;
              nextcontrol := getnext ;
            end
          else
            begin
              begin
                tokmem [ tokptr ] := 92 ;
                tokptr := tokptr + 1 ;
                tokmem [ tokptr ] := 70 ;
                tokptr := tokptr + 1 ;
                scrapptr := scrapptr + 1 ;
                cat [ scrapptr ] := 3 ;
                trans [ scrapptr ] := textptr ;
                textptr := textptr + 1 ;
                tokstart [ textptr ] := tokptr ;
              end ;
              nextcontrol := getnext ;
              if nextcontrol = 130 then
                begin
                  begin
                    tokmem [ tokptr ] := 10240 + idlookup ( 0 ) ;
                    tokptr := tokptr + 1 ;
                    scrapptr := scrapptr + 1 ;
                    cat [ scrapptr ] := 2 ;
                    trans [ scrapptr ] := textptr ;
                    textptr := textptr + 1 ;
                    tokstart [ textptr ] := tokptr ;
                  end ;
                  nextcontrol := getnext ;
                  if nextcontrol = 30 then
                    begin
                      begin
                        tokmem [ tokptr ] := 92 ;
                        tokptr := tokptr + 1 ;
                        tokmem [ tokptr ] := 83 ;
                        tokptr := tokptr + 1 ;
                        scrapptr := scrapptr + 1 ;
                        cat [ scrapptr ] := 2 ;
                        trans [ scrapptr ] := textptr ;
                        textptr := textptr + 1 ;
                        tokstart [ textptr ] := tokptr ;
                      end ;
                      nextcontrol := getnext ;
                      if nextcontrol = 130 then
                        begin
                          begin
                            tokmem [ tokptr ] := 10240 + idlookup ( 0 ) ;
                            tokptr := tokptr + 1 ;
                            scrapptr := scrapptr + 1 ;
                            cat [ scrapptr ] := 2 ;
                            trans [ scrapptr ] := textptr ;
                            textptr := textptr + 1 ;
                            tokstart [ textptr ] := tokptr ;
                          end ;
                          begin
                            scrapptr := scrapptr + 1 ;
                            cat [ scrapptr ] := 9 ;
                            trans [ scrapptr ] := 0 ;
                          end ;
                          nextcontrol := getnext ;
                        end ;
                    end ;
                end ;
              if scrapptr <> 5 then
                begin
                  if not phaseone then
                    begin
                      writeln ( termout ) ;
                      write ( termout , '! Improper format definition' ) ;
                      error ;
                    end ;
                end ;
            end ;
          outerparse ;
          finishPascal ;
        end ;
      thismodule := 0 ;
      if nextcontrol <= 146 then
        begin
          if ( saveline <> outline ) or ( saveplace <> outptr ) then
            begin
              if outptr = linelength then breakout ;
              outptr := outptr + 1 ;
              outbuf [ outptr ] := 92 ;
              if outptr = linelength then breakout ;
              outptr := outptr + 1 ;
              outbuf [ outptr ] := 89 ;
            end ;
          stackptr := 0 ;
          curstate . modefield := 1 ;
          if nextcontrol = 145 then nextcontrol := getnext
          else
            begin
              thismodule := curmodule ;
              repeat
                nextcontrol := getnext ;
              until nextcontrol <> 43 ;
              if ( nextcontrol <> 61 ) and ( nextcontrol <> 30 ) then
                begin
                  if not phaseone then
                    begin
                      writeln ( termout ) ;
                      write ( termout , '! You need an = sign after the section name' ) ;
                      error ;
                    end ;
                end
              else nextcontrol := getnext ;
              if outptr > 1 then if ( outbuf [ outptr ] = 89 ) and ( outbuf [ outptr - 1 ] = 92 ) then
                                   begin
                                     tokmem [ tokptr ] := 139 ;
                                     tokptr := tokptr + 1 ;
                                   end ;
              begin
                tokmem [ tokptr ] := 30720 + thismodule ;
                tokptr := tokptr + 1 ;
                scrapptr := scrapptr + 1 ;
                cat [ scrapptr ] := 22 ;
                trans [ scrapptr ] := textptr ;
                textptr := textptr + 1 ;
                tokstart [ textptr ] := tokptr ;
              end ;
              curxref := xref [ thismodule ] ;
              if xmem [ curxref ] . numfield <> modulecount + 10240 then
                begin
                  begin
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
                  end ;
                  thismodule := 0 ;
                end ;
              begin
                tokmem [ tokptr ] := 92 ;
                tokptr := tokptr + 1 ;
                tokmem [ tokptr ] := 83 ;
                tokptr := tokptr + 1 ;
                scrapptr := scrapptr + 1 ;
                cat [ scrapptr ] := 2 ;
                trans [ scrapptr ] := textptr ;
                textptr := textptr + 1 ;
                tokstart [ textptr ] := tokptr ;
              end ;
              begin
                tokmem [ tokptr ] := 141 ;
                tokptr := tokptr + 1 ;
                scrapptr := scrapptr + 1 ;
                cat [ scrapptr ] := 9 ;
                trans [ scrapptr ] := textptr ;
                textptr := textptr + 1 ;
                tokstart [ textptr ] := tokptr ;
              end ; ;
            end ;
          while nextcontrol <= 146 do
            begin
              outerparse ;
              if nextcontrol < 146 then
                begin
                  begin
                    if not phaseone then
                      begin
                        writeln ( termout ) ;
                        write ( termout , '! You can''t do that in Pascal text' ) ;
                        error ;
                      end ;
                  end ;
                  nextcontrol := getnext ;
                end
              else if nextcontrol = 146 then
                     begin
                       begin
                         tokmem [ tokptr ] := 30720 + curmodule ;
                         tokptr := tokptr + 1 ;
                         scrapptr := scrapptr + 1 ;
                         cat [ scrapptr ] := 22 ;
                         trans [ scrapptr ] := textptr ;
                         textptr := textptr + 1 ;
                         tokstart [ textptr ] := tokptr ;
                       end ;
                       nextcontrol := getnext ;
                     end ;
            end ;
          finishPascal ;
        end ;
      if thismodule > 0 then
        begin
          firstxref := xref [ thismodule ] ;
          thisxref := xmem [ firstxref ] . xlinkfield ;
          if xmem [ thisxref ] . numfield > 10240 then
            begin
              midxref := thisxref ;
              curxref := 0 ;
              repeat
                nextxref := xmem [ thisxref ] . xlinkfield ;
                xmem [ thisxref ] . xlinkfield := curxref ;
                curxref := thisxref ;
                thisxref := nextxref ;
              until xmem [ thisxref ] . numfield <= 10240 ;
              xmem [ firstxref ] . xlinkfield := curxref ;
            end
          else midxref := 0 ;
          curxref := 0 ;
          while thisxref <> 0 do
            begin
              nextxref := xmem [ thisxref ] . xlinkfield ;
              xmem [ thisxref ] . xlinkfield := curxref ;
              curxref := thisxref ;
              thisxref := nextxref ;
            end ;
          if midxref > 0 then xmem [ midxref ] . xlinkfield := curxref
          else xmem [ firstxref ] . xlinkfield := curxref ;
          curxref := xmem [ firstxref ] . xlinkfield ;
          footnote ( 10240 ) ;
          footnote ( 0 ) ;
        end ;
      begin
        if outptr = linelength then breakout ;
        outptr := outptr + 1 ;
        outbuf [ outptr ] := 92 ;
        if outptr = linelength then breakout ;
        outptr := outptr + 1 ;
        outbuf [ outptr ] := 102 ;
        if outptr = linelength then breakout ;
        outptr := outptr + 1 ;
        outbuf [ outptr ] := 105 ;
      end ;
      finishline ;
      flushbuffer ( 0 , false , false ) ; ;
    end ;
end ;
begin
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
  begin
    writeln ( termout ) ;
    write ( termout , 'Writing the index...' ) ;
  end ;
  if changeexists then
    begin
      finishline ;
      begin
        kmodule := 1 ;
        begin
          if outptr = linelength then breakout ;
          outptr := outptr + 1 ;
          outbuf [ outptr ] := 92 ;
          if outptr = linelength then breakout ;
          outptr := outptr + 1 ;
          outbuf [ outptr ] := 99 ;
          if outptr = linelength then breakout ;
          outptr := outptr + 1 ;
          outbuf [ outptr ] := 104 ;
          if outptr = linelength then breakout ;
          outptr := outptr + 1 ;
          outbuf [ outptr ] := 32 ;
        end ;
        while kmodule < modulecount do
          begin
            if changedmodule [ kmodule ] then
              begin
                outmod ( kmodule ) ;
                begin
                  if outptr = linelength then breakout ;
                  outptr := outptr + 1 ;
                  outbuf [ outptr ] := 44 ;
                  if outptr = linelength then breakout ;
                  outptr := outptr + 1 ;
                  outbuf [ outptr ] := 32 ;
                end ;
              end ;
            kmodule := kmodule + 1 ;
          end ;
        outmod ( kmodule ) ;
        begin
          if outptr = linelength then breakout ;
          outptr := outptr + 1 ;
          outbuf [ outptr ] := 46 ;
        end ;
      end ;
    end ;
  finishline ;
  begin
    if outptr = linelength then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 92 ;
    if outptr = linelength then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 105 ;
    if outptr = linelength then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 110 ;
    if outptr = linelength then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 120 ;
  end ;
  finishline ;
  for c := 0 to 255 do
    bucket [ c ] := 0 ;
  for h := 0 to hashsize - 1 do
    begin
      nextname := hash [ h ] ;
      while nextname <> 0 do
        begin
          curname := nextname ;
          nextname := link [ curname ] ;
          if xref [ curname ] <> 0 then
            begin
              c := bytemem [ curname mod 2 , bytestart [ curname ] ] ;
              if ( c <= 90 ) and ( c >= 65 ) then c := c + 32 ;
              blink [ curname ] := bucket [ c ] ;
              bucket [ c ] := curname ;
            end ;
        end ;
    end ;
  scrapptr := 0 ;
  unbucket ( 1 ) ;
  while scrapptr > 0 do
    begin
      curdepth := cat [ scrapptr ] ;
      if ( blink [ trans [ scrapptr ] ] = 0 ) or ( curdepth = 255 ) then
        begin
          curname := trans [ scrapptr ] ;
          repeat
            begin
              if outptr = linelength then breakout ;
              outptr := outptr + 1 ;
              outbuf [ outptr ] := 92 ;
              if outptr = linelength then breakout ;
              outptr := outptr + 1 ;
              outbuf [ outptr ] := 58 ;
            end ;
            case ilk [ curname ] of 
              0 : if bytestart [ curname + 2 ] - bytestart [ curname ] = 1 then
                    begin
                      if outptr = linelength then breakout ;
                      outptr := outptr + 1 ;
                      outbuf [ outptr ] := 92 ;
                      if outptr = linelength then breakout ;
                      outptr := outptr + 1 ;
                      outbuf [ outptr ] := 124 ;
                    end
                  else
                    begin
                      if outptr = linelength then breakout ;
                      outptr := outptr + 1 ;
                      outbuf [ outptr ] := 92 ;
                      if outptr = linelength then breakout ;
                      outptr := outptr + 1 ;
                      outbuf [ outptr ] := 92 ;
                    end ;
              1 : ;
              2 :
                  begin
                    if outptr = linelength then breakout ;
                    outptr := outptr + 1 ;
                    outbuf [ outptr ] := 92 ;
                    if outptr = linelength then breakout ;
                    outptr := outptr + 1 ;
                    outbuf [ outptr ] := 57 ;
                  end ;
              3 :
                  begin
                    if outptr = linelength then breakout ;
                    outptr := outptr + 1 ;
                    outbuf [ outptr ] := 92 ;
                    if outptr = linelength then breakout ;
                    outptr := outptr + 1 ;
                    outbuf [ outptr ] := 46 ;
                  end ;
              others :
                       begin
                         if outptr = linelength then breakout ;
                         outptr := outptr + 1 ;
                         outbuf [ outptr ] := 92 ;
                         if outptr = linelength then breakout ;
                         outptr := outptr + 1 ;
                         outbuf [ outptr ] := 38 ;
                       end
            end ;
            outname ( curname ) ;
            thisxref := xref [ curname ] ;
            curxref := 0 ;
            repeat
              nextxref := xmem [ thisxref ] . xlinkfield ;
              xmem [ thisxref ] . xlinkfield := curxref ;
              curxref := thisxref ;
              thisxref := nextxref ;
            until thisxref = 0 ;
            repeat
              begin
                if outptr = linelength then breakout ;
                outptr := outptr + 1 ;
                outbuf [ outptr ] := 44 ;
                if outptr = linelength then breakout ;
                outptr := outptr + 1 ;
                outbuf [ outptr ] := 32 ;
              end ;
              curval := xmem [ curxref ] . numfield ;
              if curval < 10240 then outmod ( curval )
              else
                begin
                  begin
                    if outptr = linelength then breakout ;
                    outptr := outptr + 1 ;
                    outbuf [ outptr ] := 92 ;
                    if outptr = linelength then breakout ;
                    outptr := outptr + 1 ;
                    outbuf [ outptr ] := 91 ;
                  end ;
                  outmod ( curval - 10240 ) ;
                  begin
                    if outptr = linelength then breakout ;
                    outptr := outptr + 1 ;
                    outbuf [ outptr ] := 93 ;
                  end ;
                end ;
              curxref := xmem [ curxref ] . xlinkfield ;
            until curxref = 0 ;
            begin
              if outptr = linelength then breakout ;
              outptr := outptr + 1 ;
              outbuf [ outptr ] := 46 ;
            end ;
            finishline ;
            curname := blink [ curname ] ;
          until curname = 0 ;
          scrapptr := scrapptr - 1 ;
        end
      else
        begin
          nextname := trans [ scrapptr ] ;
          repeat
            curname := nextname ;
            nextname := blink [ curname ] ;
            curbyte := bytestart [ curname ] + curdepth ;
            curbank := curname mod 2 ;
            if curbyte = bytestart [ curname + 2 ] then c := 0
            else
              begin
                c := bytemem [ curbank , curbyte ] ;
                if ( c <= 90 ) and ( c >= 65 ) then c := c + 32 ;
              end ;
            blink [ curname ] := bucket [ c ] ;
            bucket [ c ] := curname ;
          until nextname = 0 ;
          scrapptr := scrapptr - 1 ;
          unbucket ( curdepth + 1 ) ;
        end ;
    end ;
  begin
    if outptr = linelength then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 92 ;
    if outptr = linelength then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 102 ;
    if outptr = linelength then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 105 ;
    if outptr = linelength then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 110 ;
  end ;
  finishline ;
  modprint ( ilk [ 0 ] ) ;
  begin
    if outptr = linelength then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 92 ;
    if outptr = linelength then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 99 ;
    if outptr = linelength then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 111 ;
    if outptr = linelength then breakout ;
    outptr := outptr + 1 ;
    outbuf [ outptr ] := 110 ;
  end ;
  finishline ;
  write ( termout , 'Done.' ) ; ;
  if changelimit <> 0 then
    begin
      for ii := 0 to changelimit do
        buffer [ ii ] := changebuffer [ ii ] ;
      limit := changelimit ;
      changing := true ;
      line := otherline ;
      loc := changelimit ;
      begin
        if not phaseone then
          begin
            writeln ( termout ) ;
            write ( termout , '! Change file entry did not match' ) ;
            error ;
          end ;
      end ;
    end ;
  9999 : case history of 
           0 :
               begin
                 writeln ( termout ) ;
                 write ( termout , '(No errors were found.)' ) ;
               end ;
           1 :
               begin
                 writeln ( termout ) ;
                 write ( termout , '(Did you see the warning message above?)' ) ;
               end ;
           2 :
               begin
                 writeln ( termout ) ;
                 write ( termout , '(Pardon me, but I think I spotted something wrong.)' ) ;
               end ;
           3 :
               begin
                 writeln ( termout ) ;
                 write ( termout , '(That was a fatal error, my friend.)' ) ;
               end ;
         end ;
end .
