
Program MF ;

Label 1 , 9998 , 9999 ;

Const memmax = 30000 ;
  maxinternal = 100 ;
  bufsize = 500 ;
  errorline = 72 ;
  halferrorline = 42 ;
  maxprintline = 79 ;
  screenwidth = 768 ;
  screendepth = 1024 ;
  stacksize = 30 ;
  maxstrings = 2000 ;
  stringvacancies = 8000 ;
  poolsize = 32000 ;
  movesize = 5000 ;
  maxwiggle = 300 ;
  gfbufsize = 800 ;
  filenamesize = 40 ;
  poolname = 'MFbases:MF.POOL                         ' ;
  pathsize = 300 ;
  bistacksize = 785 ;
  headersize = 100 ;
  ligtablesize = 5000 ;
  maxkerns = 500 ;
  maxfontdimen = 50 ;

Type ASCIIcode = 0 .. 255 ;
  eightbits = 0 .. 255 ;
  alphafile = packed file Of char ;
  bytefile = packed file Of eightbits ;
  poolpointer = 0 .. poolsize ;
  strnumber = 0 .. maxstrings ;
  packedASCIIcode = 0 .. 255 ;
  scaled = integer ;
  smallnumber = 0 .. 63 ;
  fraction = integer ;
  angle = integer ;
  quarterword = 0 .. 255 ;
  halfword = 0 .. 65535 ;
  twochoices = 1 .. 2 ;
  threechoices = 1 .. 3 ;
  twohalves = packed Record
    rh : halfword ;
    Case twochoices Of 
      1 : ( lh : halfword ) ;
      2 : ( b0 : quarterword ; b1 : quarterword ) ;
  End ;
  fourquarters = packed Record
    b0 : quarterword ;
    b1 : quarterword ;
    b2 : quarterword ;
    b3 : quarterword ;
  End ;
  memoryword = Record
    Case threechoices Of 
      1 : ( int : integer ) ;
      2 : ( hh : twohalves ) ;
      3 : ( qqqq : fourquarters ) ;
  End ;
  wordfile = file Of memoryword ;
  commandcode = 1 .. 85 ;
  screenrow = 0 .. screendepth ;
  screencol = 0 .. screenwidth ;
  transspec = array [ screencol ] Of screencol ;
  pixelcolor = 0 .. 1 ;
  windownumber = 0 .. 15 ;
  instaterecord = Record
    indexfield : quarterword ;
    startfield , locfield , limitfield , namefield : halfword ;
  End ;
  gfindex = 0 .. gfbufsize ;

Var bad : integer ;
  xord : array [ char ] Of ASCIIcode ;
  xchr : array [ ASCIIcode ] Of char ;
  nameoffile : packed array [ 1 .. filenamesize ] Of char ;
  namelength : 0 .. filenamesize ;
  buffer : array [ 0 .. bufsize ] Of ASCIIcode ;
  first : 0 .. bufsize ;
  last : 0 .. bufsize ;
  maxbufstack : 0 .. bufsize ;
  termin : alphafile ;
  termout : alphafile ;
  strpool : packed array [ poolpointer ] Of packedASCIIcode ;
  strstart : array [ strnumber ] Of poolpointer ;
  poolptr : poolpointer ;
  strptr : strnumber ;
  initpoolptr : poolpointer ;
  initstrptr : strnumber ;
  maxpoolptr : poolpointer ;
  maxstrptr : strnumber ;
  strref : array [ strnumber ] Of 0 .. 127 ;
  poolfile : alphafile ;
  logfile : alphafile ;
  selector : 0 .. 5 ;
  dig : array [ 0 .. 22 ] Of 0 .. 15 ;
  tally : integer ;
  termoffset : 0 .. maxprintline ;
  fileoffset : 0 .. maxprintline ;
  trickbuf : array [ 0 .. errorline ] Of ASCIIcode ;
  trickcount : integer ;
  firstcount : integer ;
  interaction : 0 .. 3 ;
  deletionsallowed : boolean ;
  history : 0 .. 3 ;
  errorcount : - 1 .. 100 ;
  helpline : array [ 0 .. 5 ] Of strnumber ;
  helpptr : 0 .. 6 ;
  useerrhelp : boolean ;
  errhelp : strnumber ;
  interrupt : integer ;
  OKtointerrupt : boolean ;
  aritherror : boolean ;
  twotothe : array [ 0 .. 30 ] Of integer ;
  speclog : array [ 1 .. 28 ] Of integer ;
  specatan : array [ 1 .. 26 ] Of angle ;
  nsin , ncos : fraction ;
  randoms : array [ 0 .. 54 ] Of fraction ;
  jrandom : 0 .. 54 ;
  mem : array [ 0 .. memmax ] Of memoryword ;
  lomemmax : halfword ;
  himemmin : halfword ;
  varused , dynused : integer ;
  avail : halfword ;
  memend : halfword ;
  rover : halfword ;
  internal : array [ 1 .. maxinternal ] Of scaled ;
  intname : array [ 1 .. maxinternal ] Of strnumber ;
  intptr : 41 .. maxinternal ;
  oldsetting : 0 .. 5 ;
  charclass : array [ ASCIIcode ] Of 0 .. 20 ;
  hashused : halfword ;
  stcount : integer ;
  hash : array [ 1 .. 2369 ] Of twohalves ;
  eqtb : array [ 1 .. 2369 ] Of twohalves ;
  gpointer : halfword ;
  bignodesize : array [ 13 .. 14 ] Of smallnumber ;
  saveptr : halfword ;
  pathtail : halfword ;
  deltax , deltay , delta : array [ 0 .. pathsize ] Of scaled ;
  psi : array [ 1 .. pathsize ] Of angle ;
  theta : array [ 0 .. pathsize ] Of angle ;
  uu : array [ 0 .. pathsize ] Of fraction ;
  vv : array [ 0 .. pathsize ] Of angle ;
  ww : array [ 0 .. pathsize ] Of fraction ;
  st , ct , sf , cf : fraction ;
  move : array [ 0 .. movesize ] Of integer ;
  moveptr : 0 .. movesize ;
  bisectstack : array [ 0 .. bistacksize ] Of integer ;
  bisectptr : 0 .. bistacksize ;
  curedges : halfword ;
  curwt : integer ;
  tracex : integer ;
  tracey : integer ;
  traceyy : integer ;
  octant : 1 .. 8 ;
  curx , cury : scaled ;
  octantdir : array [ 1 .. 8 ] Of strnumber ;
  curspec : halfword ;
  turningnumber : integer ;
  curpen : halfword ;
  curpathtype : 0 .. 1 ;
  maxallowed : scaled ;
  before , after : array [ 0 .. maxwiggle ] Of scaled ;
  nodetoround : array [ 0 .. maxwiggle ] Of halfword ;
  curroundingptr : 0 .. maxwiggle ;
  maxroundingptr : 0 .. maxwiggle ;
  curgran : scaled ;
  octantnumber : array [ 1 .. 8 ] Of 1 .. 8 ;
  octantcode : array [ 1 .. 8 ] Of 1 .. 8 ;
  revturns : boolean ;
  ycorr , xycorr , zcorr : array [ 1 .. 8 ] Of 0 .. 1 ;
  xcorr : array [ 1 .. 8 ] Of - 1 .. 1 ;
  m0 , n0 , m1 , n1 : integer ;
  d0 , d1 : 0 .. 1 ;
  envmove : array [ 0 .. movesize ] Of integer ;
  tolstep : 0 .. 6 ;
  curt , curtt : integer ;
  timetogo : integer ;
  maxt : integer ;
  delx , dely : integer ;
  tol : integer ;
  uv , xy : 0 .. bistacksize ;
  threel : integer ;
  apprt , apprtt : integer ;
  screenstarted : boolean ;
  screenOK : boolean ;
  windowopen : array [ windownumber ] Of boolean ;
  leftcol : array [ windownumber ] Of screencol ;
  rightcol : array [ windownumber ] Of screencol ;
  toprow : array [ windownumber ] Of screenrow ;
  botrow : array [ windownumber ] Of screenrow ;
  mwindow : array [ windownumber ] Of integer ;
  nwindow : array [ windownumber ] Of integer ;
  windowtime : array [ windownumber ] Of integer ;
  rowtransition : transspec ;
  serialno : integer ;
  fixneeded : boolean ;
  watchcoefs : boolean ;
  depfinal : halfword ;
  curcmd : eightbits ;
  curmod : integer ;
  cursym : halfword ;
  inputstack : array [ 0 .. stacksize ] Of instaterecord ;
  inputptr : 0 .. stacksize ;
  maxinstack : 0 .. stacksize ;
  curinput : instaterecord ;
  inopen : 0 .. 6 ;
  openparens : 0 .. 6 ;
  inputfile : array [ 1 .. 6 ] Of alphafile ;
  line : integer ;
  linestack : array [ 1 .. 6 ] Of integer ;
  paramstack : array [ 0 .. 150 ] Of halfword ;
  paramptr : 0 .. 150 ;
  maxparamstack : integer ;
  fileptr : 0 .. stacksize ;
  scannerstatus : 0 .. 6 ;
  warninginfo : integer ;
  forceeof : boolean ;
  bgloc , egloc : 1 .. 2369 ;
  condptr : halfword ;
  iflimit : 0 .. 4 ;
  curif : smallnumber ;
  ifline : integer ;
  loopptr : halfword ;
  curname : strnumber ;
  curarea : strnumber ;
  curext : strnumber ;
  areadelimiter : poolpointer ;
  extdelimiter : poolpointer ;
  MFbasedefault : packed array [ 1 .. 18 ] Of char ;
  jobname : strnumber ;
  logopened : boolean ;
  logname : strnumber ;
  gfext : strnumber ;
  gffile : bytefile ;
  outputfilename : strnumber ;
  curtype : smallnumber ;
  curexp : integer ;
  maxc : array [ 17 .. 18 ] Of integer ;
  maxptr : array [ 17 .. 18 ] Of halfword ;
  maxlink : array [ 17 .. 18 ] Of halfword ;
  varflag : 0 .. 85 ;
  txx , txy , tyx , tyy , tx , ty : scaled ;
  startsym : halfword ;
  longhelpseen : boolean ;
  tfmfile : bytefile ;
  metricfilename : strnumber ;
  bc , ec : eightbits ;
  tfmwidth : array [ eightbits ] Of scaled ;
  tfmheight : array [ eightbits ] Of scaled ;
  tfmdepth : array [ eightbits ] Of scaled ;
  tfmitalcorr : array [ eightbits ] Of scaled ;
  charexists : array [ eightbits ] Of boolean ;
  chartag : array [ eightbits ] Of 0 .. 3 ;
  charremainder : array [ eightbits ] Of 0 .. ligtablesize ;
  headerbyte : array [ 1 .. headersize ] Of - 1 .. 255 ;
  ligkern : array [ 0 .. ligtablesize ] Of fourquarters ;
  nl : 0 .. 32511 ;
  kern : array [ 0 .. maxkerns ] Of scaled ;
  nk : 0 .. maxkerns ;
  exten : array [ eightbits ] Of fourquarters ;
  ne : 0 .. 256 ;
  param : array [ 1 .. maxfontdimen ] Of scaled ;
  np : 0 .. maxfontdimen ;
  nw , nh , nd , ni : 0 .. 256 ;
  skiptable : array [ eightbits ] Of 0 .. ligtablesize ;
  lkstarted : boolean ;
  bchar : integer ;
  bchlabel : 0 .. ligtablesize ;
  ll , lll : 0 .. ligtablesize ;
  labelloc : array [ 0 .. 256 ] Of - 1 .. ligtablesize ;
  labelchar : array [ 1 .. 256 ] Of eightbits ;
  labelptr : 0 .. 256 ;
  perturbation : scaled ;
  excess : integer ;
  dimenhead : array [ 1 .. 4 ] Of halfword ;
  maxtfmdimen : scaled ;
  tfmchanged : integer ;
  gfminm , gfmaxm , gfminn , gfmaxn : integer ;
  gfprevptr : integer ;
  totalchars : integer ;
  charptr : array [ eightbits ] Of integer ;
  gfdx , gfdy : array [ eightbits ] Of integer ;
  gfbuf : array [ gfindex ] Of eightbits ;
  halfbuf : gfindex ;
  gflimit : gfindex ;
  gfptr : gfindex ;
  gfoffset : integer ;
  bocc , bocp : integer ;
  baseident : strnumber ;
  basefile : wordfile ;
  readyalready : integer ;
Procedure initialize ;

Var i : integer ;
  k : integer ;
Begin
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
  For i := 0 To 31 Do
    xchr [ i ] := ' ' ;
  For i := 127 To 255 Do
    xchr [ i ] := ' ' ;
  For i := 0 To 255 Do
    xord [ chr ( i ) ] := 127 ;
  For i := 128 To 255 Do
    xord [ xchr [ i ] ] := i ;
  For i := 0 To 126 Do
    xord [ xchr [ i ] ] := i ;
  interaction := 3 ;
  deletionsallowed := true ;
  errorcount := 0 ;
  helpptr := 0 ;
  useerrhelp := false ;
  errhelp := 0 ;
  interrupt := 0 ;
  OKtointerrupt := true ;
  aritherror := false ;
  twotothe [ 0 ] := 1 ;
  For k := 1 To 30 Do
    twotothe [ k ] := 2 * twotothe [ k - 1 ] ;
  speclog [ 1 ] := 93032640 ;
  speclog [ 2 ] := 38612034 ;
  speclog [ 3 ] := 17922280 ;
  speclog [ 4 ] := 8662214 ;
  speclog [ 5 ] := 4261238 ;
  speclog [ 6 ] := 2113709 ;
  speclog [ 7 ] := 1052693 ;
  speclog [ 8 ] := 525315 ;
  speclog [ 9 ] := 262400 ;
  speclog [ 10 ] := 131136 ;
  speclog [ 11 ] := 65552 ;
  speclog [ 12 ] := 32772 ;
  speclog [ 13 ] := 16385 ;
  For k := 14 To 27 Do
    speclog [ k ] := twotothe [ 27 - k ] ;
  speclog [ 28 ] := 1 ;
  specatan [ 1 ] := 27855475 ;
  specatan [ 2 ] := 14718068 ;
  specatan [ 3 ] := 7471121 ;
  specatan [ 4 ] := 3750058 ;
  specatan [ 5 ] := 1876857 ;
  specatan [ 6 ] := 938658 ;
  specatan [ 7 ] := 469357 ;
  specatan [ 8 ] := 234682 ;
  specatan [ 9 ] := 117342 ;
  specatan [ 10 ] := 58671 ;
  specatan [ 11 ] := 29335 ;
  specatan [ 12 ] := 14668 ;
  specatan [ 13 ] := 7334 ;
  specatan [ 14 ] := 3667 ;
  specatan [ 15 ] := 1833 ;
  specatan [ 16 ] := 917 ;
  specatan [ 17 ] := 458 ;
  specatan [ 18 ] := 229 ;
  specatan [ 19 ] := 115 ;
  specatan [ 20 ] := 57 ;
  specatan [ 21 ] := 29 ;
  specatan [ 22 ] := 14 ;
  specatan [ 23 ] := 7 ;
  specatan [ 24 ] := 4 ;
  specatan [ 25 ] := 2 ;
  specatan [ 26 ] := 1 ;
  For k := 1 To 41 Do
    internal [ k ] := 0 ;
  intptr := 41 ;
  For k := 48 To 57 Do
    charclass [ k ] := 0 ;
  charclass [ 46 ] := 1 ;
  charclass [ 32 ] := 2 ;
  charclass [ 37 ] := 3 ;
  charclass [ 34 ] := 4 ;
  charclass [ 44 ] := 5 ;
  charclass [ 59 ] := 6 ;
  charclass [ 40 ] := 7 ;
  charclass [ 41 ] := 8 ;
  For k := 65 To 90 Do
    charclass [ k ] := 9 ;
  For k := 97 To 122 Do
    charclass [ k ] := 9 ;
  charclass [ 95 ] := 9 ;
  charclass [ 60 ] := 10 ;
  charclass [ 61 ] := 10 ;
  charclass [ 62 ] := 10 ;
  charclass [ 58 ] := 10 ;
  charclass [ 124 ] := 10 ;
  charclass [ 96 ] := 11 ;
  charclass [ 39 ] := 11 ;
  charclass [ 43 ] := 12 ;
  charclass [ 45 ] := 12 ;
  charclass [ 47 ] := 13 ;
  charclass [ 42 ] := 13 ;
  charclass [ 92 ] := 13 ;
  charclass [ 33 ] := 14 ;
  charclass [ 63 ] := 14 ;
  charclass [ 35 ] := 15 ;
  charclass [ 38 ] := 15 ;
  charclass [ 64 ] := 15 ;
  charclass [ 36 ] := 15 ;
  charclass [ 94 ] := 16 ;
  charclass [ 126 ] := 16 ;
  charclass [ 91 ] := 17 ;
  charclass [ 93 ] := 18 ;
  charclass [ 123 ] := 19 ;
  charclass [ 125 ] := 19 ;
  For k := 0 To 31 Do
    charclass [ k ] := 20 ;
  For k := 127 To 255 Do
    charclass [ k ] := 20 ;
  hash [ 1 ] . lh := 0 ;
  hash [ 1 ] . rh := 0 ;
  eqtb [ 1 ] . lh := 41 ;
  eqtb [ 1 ] . rh := 0 ;
  For k := 2 To 2369 Do
    Begin
      hash [ k ] := hash [ 1 ] ;
      eqtb [ k ] := eqtb [ 1 ] ;
    End ;
  bignodesize [ 13 ] := 12 ;
  bignodesize [ 14 ] := 4 ;
  saveptr := 0 ;
  octantdir [ 1 ] := 548 ;
  octantdir [ 5 ] := 549 ;
  octantdir [ 6 ] := 550 ;
  octantdir [ 2 ] := 551 ;
  octantdir [ 4 ] := 552 ;
  octantdir [ 8 ] := 553 ;
  octantdir [ 7 ] := 554 ;
  octantdir [ 3 ] := 555 ;
  maxroundingptr := 0 ;
  octantcode [ 1 ] := 1 ;
  octantcode [ 2 ] := 5 ;
  octantcode [ 3 ] := 6 ;
  octantcode [ 4 ] := 2 ;
  octantcode [ 5 ] := 4 ;
  octantcode [ 6 ] := 8 ;
  octantcode [ 7 ] := 7 ;
  octantcode [ 8 ] := 3 ;
  For k := 1 To 8 Do
    octantnumber [ octantcode [ k ] ] := k ;
  revturns := false ;
  xcorr [ 1 ] := 0 ;
  ycorr [ 1 ] := 0 ;
  xycorr [ 1 ] := 0 ;
  xcorr [ 5 ] := 0 ;
  ycorr [ 5 ] := 0 ;
  xycorr [ 5 ] := 1 ;
  xcorr [ 6 ] := - 1 ;
  ycorr [ 6 ] := 1 ;
  xycorr [ 6 ] := 0 ;
  xcorr [ 2 ] := 1 ;
  ycorr [ 2 ] := 0 ;
  xycorr [ 2 ] := 1 ;
  xcorr [ 4 ] := 0 ;
  ycorr [ 4 ] := 1 ;
  xycorr [ 4 ] := 1 ;
  xcorr [ 8 ] := 0 ;
  ycorr [ 8 ] := 1 ;
  xycorr [ 8 ] := 0 ;
  xcorr [ 7 ] := 1 ;
  ycorr [ 7 ] := 0 ;
  xycorr [ 7 ] := 1 ;
  xcorr [ 3 ] := - 1 ;
  ycorr [ 3 ] := 1 ;
  xycorr [ 3 ] := 0 ;
  For k := 1 To 8 Do
    zcorr [ k ] := xycorr [ k ] - xcorr [ k ] ;
  screenstarted := false ;
  screenOK := false ;
  For k := 0 To 15 Do
    Begin
      windowopen [ k ] := false ;
      windowtime [ k ] := 0 ;
    End ;
  fixneeded := false ;
  watchcoefs := true ;
  condptr := 0 ;
  iflimit := 0 ;
  curif := 0 ;
  ifline := 0 ;
  loopptr := 0 ;
  MFbasedefault := 'MFbases:plain.base' ;
  curexp := 0 ;
  varflag := 0 ;
  startsym := 0 ;
  longhelpseen := false ;
  For k := 0 To 255 Do
    Begin
      tfmwidth [ k ] := 0 ;
      tfmheight [ k ] := 0 ;
      tfmdepth [ k ] := 0 ;
      tfmitalcorr [ k ] := 0 ;
      charexists [ k ] := false ;
      chartag [ k ] := 0 ;
      charremainder [ k ] := 0 ;
      skiptable [ k ] := ligtablesize ;
    End ;
  For k := 1 To headersize Do
    headerbyte [ k ] := - 1 ;
  bc := 255 ;
  ec := 0 ;
  nl := 0 ;
  nk := 0 ;
  ne := 0 ;
  np := 0 ;
  internal [ 41 ] := - 65536 ;
  bchlabel := ligtablesize ;
  labelloc [ 0 ] := - 1 ;
  labelptr := 0 ;
  gfprevptr := 0 ;
  totalchars := 0 ;
  halfbuf := gfbufsize Div 2 ;
  gflimit := gfbufsize ;
  gfptr := 0 ;
  gfoffset := 0 ;
  baseident := 0 ;
End ;
Procedure println ;
Begin
  Case selector Of 
    3 :
        Begin
          writeln ( termout ) ;
          writeln ( logfile ) ;
          termoffset := 0 ;
          fileoffset := 0 ;
        End ;
    2 :
        Begin
          writeln ( logfile ) ;
          fileoffset := 0 ;
        End ;
    1 :
        Begin
          writeln ( termout ) ;
          termoffset := 0 ;
        End ;
    0 , 4 , 5 : ;
  End ;
End ;
Procedure printchar ( s : ASCIIcode ) ;
Begin
  Case selector Of 
    3 :
        Begin
          write ( termout , xchr [ s ] ) ;
          write ( logfile , xchr [ s ] ) ;
          termoffset := termoffset + 1 ;
          fileoffset := fileoffset + 1 ;
          If termoffset = maxprintline Then
            Begin
              writeln ( termout ) ;
              termoffset := 0 ;
            End ;
          If fileoffset = maxprintline Then
            Begin
              writeln ( logfile ) ;
              fileoffset := 0 ;
            End ;
        End ;
    2 :
        Begin
          write ( logfile , xchr [ s ] ) ;
          fileoffset := fileoffset + 1 ;
          If fileoffset = maxprintline Then println ;
        End ;
    1 :
        Begin
          write ( termout , xchr [ s ] ) ;
          termoffset := termoffset + 1 ;
          If termoffset = maxprintline Then println ;
        End ;
    0 : ;
    4 : If tally < trickcount Then trickbuf [ tally mod errorline ] := s ;
    5 :
        Begin
          If poolptr < poolsize Then
            Begin
              strpool [ poolptr ] := s ;
              poolptr := poolptr + 1 ;
            End ;
        End ;
  End ;
  tally := tally + 1 ;
End ;
Procedure print ( s : integer ) ;

Var j : poolpointer ;
Begin
  If ( s < 0 ) Or ( s >= strptr ) Then s := 259 ;
  If ( s < 256 ) And ( selector > 4 ) Then printchar ( s )
  Else
    Begin
      j := strstart [ s ] ;
      While j < strstart [ s + 1 ] Do
        Begin
          printchar ( strpool [ j ] ) ;
          j := j + 1 ;
        End ;
    End ;
End ;
Procedure slowprint ( s : integer ) ;

Var j : poolpointer ;
Begin
  If ( s < 0 ) Or ( s >= strptr ) Then s := 259 ;
  If ( s < 256 ) And ( selector > 4 ) Then printchar ( s )
  Else
    Begin
      j := strstart [ s ] ;
      While j < strstart [ s + 1 ] Do
        Begin
          print ( strpool [ j ] ) ;
          j := j + 1 ;
        End ;
    End ;
End ;
Procedure printnl ( s : strnumber ) ;
Begin
  If ( ( termoffset > 0 ) And ( odd ( selector ) ) ) Or ( ( fileoffset > 0 ) And ( selector >= 2 ) ) Then println ;
  print ( s ) ;
End ;
Procedure printthedigs ( k : eightbits ) ;
Begin
  While k > 0 Do
    Begin
      k := k - 1 ;
      printchar ( 48 + dig [ k ] ) ;
    End ;
End ;
Procedure printint ( n : integer ) ;

Var k : 0 .. 23 ;
  m : integer ;
Begin
  k := 0 ;
  If n < 0 Then
    Begin
      printchar ( 45 ) ;
      If n > - 100000000 Then n := - n
      Else
        Begin
          m := - 1 - n ;
          n := m Div 10 ;
          m := ( m Mod 10 ) + 1 ;
          k := 1 ;
          If m < 10 Then dig [ 0 ] := m
          Else
            Begin
              dig [ 0 ] := 0 ;
              n := n + 1 ;
            End ;
        End ;
    End ;
  Repeat
    dig [ k ] := n Mod 10 ;
    n := n Div 10 ;
    k := k + 1 ;
  Until n = 0 ;
  printthedigs ( k ) ;
End ;
Procedure printscaled ( s : scaled ) ;

Var delta : scaled ;
Begin
  If s < 0 Then
    Begin
      printchar ( 45 ) ;
      s := - s ;
    End ;
  printint ( s Div 65536 ) ;
  s := 10 * ( s Mod 65536 ) + 5 ;
  If s <> 5 Then
    Begin
      delta := 10 ;
      printchar ( 46 ) ;
      Repeat
        If delta > 65536 Then s := s + 32768 - ( delta Div 2 ) ;
        printchar ( 48 + ( s Div 65536 ) ) ;
        s := 10 * ( s Mod 65536 ) ;
        delta := delta * 10 ;
      Until s <= delta ;
    End ;
End ;
Procedure printtwo ( x , y : scaled ) ;
Begin
  printchar ( 40 ) ;
  printscaled ( x ) ;
  printchar ( 44 ) ;
  printscaled ( y ) ;
  printchar ( 41 ) ;
End ;
Procedure printtype ( t : smallnumber ) ;
Begin
  Case t Of 
    1 : print ( 324 ) ;
    2 : print ( 325 ) ;
    3 : print ( 326 ) ;
    4 : print ( 327 ) ;
    5 : print ( 328 ) ;
    6 : print ( 329 ) ;
    7 : print ( 330 ) ;
    8 : print ( 331 ) ;
    9 : print ( 332 ) ;
    10 : print ( 333 ) ;
    11 : print ( 334 ) ;
    12 : print ( 335 ) ;
    13 : print ( 336 ) ;
    14 : print ( 337 ) ;
    16 : print ( 338 ) ;
    17 : print ( 339 ) ;
    18 : print ( 340 ) ;
    15 : print ( 341 ) ;
    19 : print ( 342 ) ;
    20 : print ( 343 ) ;
    21 : print ( 344 ) ;
    22 : print ( 345 ) ;
    23 : print ( 346 ) ;
    others : print ( 347 )
  End ;
End ;
Procedure begindiagnostic ;
Begin
  oldsetting := selector ;
  If ( internal [ 13 ] <= 0 ) And ( selector = 3 ) Then
    Begin
      selector := selector - 1 ;
      If history = 0 Then history := 1 ;
    End ;
End ;
Procedure enddiagnostic ( blankline : boolean ) ;
Begin
  printnl ( 285 ) ;
  If blankline Then println ;
  selector := oldsetting ;
End ;
Procedure printdiagnostic ( s , t : strnumber ; nuline : boolean ) ;
Begin
  begindiagnostic ;
  If nuline Then printnl ( s )
  Else print ( s ) ;
  print ( 265 ) ;
  printint ( line ) ;
  print ( t ) ;
  printchar ( 58 ) ;
End ;
Procedure printfilename ( n , a , e : integer ) ;
Begin
  slowprint ( a ) ;
  slowprint ( n ) ;
  slowprint ( e ) ;
End ;
Procedure normalizeselector ;
forward ;
Procedure getnext ;
forward ;
Procedure terminput ;
forward ;
Procedure showcontext ;
forward ;
Procedure beginfilereading ;
forward ;
Procedure openlogfile ;
forward ;
Procedure closefilesandterminate ;
forward ;
Procedure clearforerrorprompt ;
forward ;
Procedure flushstring ( s : strnumber ) ;
Begin
  If s < strptr - 1 Then strref [ s ] := 0
  Else Repeat
         strptr := strptr - 1 ;
    Until strref [ strptr - 1 ] <> 0 ;
  poolptr := strstart [ strptr ] ;
End ;
Procedure jumpout ;
Begin
  goto 9998 ;
End ;
Procedure error ;

Label 22 , 10 ;

Var c : ASCIIcode ;
  s1 , s2 , s3 : integer ;
  j : poolpointer ;
Begin
  If history < 2 Then history := 2 ;
  printchar ( 46 ) ;
  showcontext ;
  If interaction = 3 Then While true Do
                            Begin
                              22 : clearforerrorprompt ;
                              Begin ;
                                print ( 263 ) ;
                                terminput ;
                              End ;
                              If last = first Then goto 10 ;
                              c := buffer [ first ] ;
                              If c >= 97 Then c := c - 32 ;
                              Case c Of 
                                48 , 49 , 50 , 51 , 52 , 53 , 54 , 55 , 56 , 57 : If deletionsallowed Then
                                                                                    Begin
                                                                                      s1 := curcmd ;
                                                                                      s2 := curmod ;
                                                                                      s3 := cursym ;
                                                                                      OKtointerrupt := false ;
                                                                                      If ( last > first + 1 ) And ( buffer [ first + 1 ] >= 48 ) And ( buffer [ first + 1 ] <= 57 ) Then c := c * 10 + buffer [ first + 1 ] - 48 * 11
                                                                                      Else c := c - 48 ;
                                                                                      While c > 0 Do
                                                                                        Begin
                                                                                          getnext ;
                                                                                          If curcmd = 39 Then
                                                                                            Begin
                                                                                              If strref [ curmod ] < 127 Then If strref [ curmod ] > 1 Then strref [ curmod ] := strref [ curmod ] - 1
                                                                                              Else flushstring ( curmod ) ;
                                                                                            End ;
                                                                                          c := c - 1 ;
                                                                                        End ;
                                                                                      curcmd := s1 ;
                                                                                      curmod := s2 ;
                                                                                      cursym := s3 ;
                                                                                      OKtointerrupt := true ;
                                                                                      Begin
                                                                                        helpptr := 2 ;
                                                                                        helpline [ 1 ] := 278 ;
                                                                                        helpline [ 0 ] := 279 ;
                                                                                      End ;
                                                                                      showcontext ;
                                                                                      goto 22 ;
                                                                                    End ;
                                69 : If fileptr > 0 Then
                                       Begin
                                         printnl ( 264 ) ;
                                         slowprint ( inputstack [ fileptr ] . namefield ) ;
                                         print ( 265 ) ;
                                         printint ( line ) ;
                                         interaction := 2 ;
                                         jumpout ;
                                       End ;
                                72 :
                                     Begin
                                       If useerrhelp Then
                                         Begin
                                           j := strstart [ errhelp ] ;
                                           While j < strstart [ errhelp + 1 ] Do
                                             Begin
                                               If strpool [ j ] <> 37 Then print ( strpool [ j ] )
                                               Else If j + 1 = strstart [ errhelp + 1 ] Then println
                                               Else If strpool [ j + 1 ] <> 37 Then println
                                               Else
                                                 Begin
                                                   j := j + 1 ;
                                                   printchar ( 37 ) ;
                                                 End ;
                                               j := j + 1 ;
                                             End ;
                                           useerrhelp := false ;
                                         End
                                       Else
                                         Begin
                                           If helpptr = 0 Then
                                             Begin
                                               helpptr := 2 ;
                                               helpline [ 1 ] := 280 ;
                                               helpline [ 0 ] := 281 ;
                                             End ;
                                           Repeat
                                             helpptr := helpptr - 1 ;
                                             print ( helpline [ helpptr ] ) ;
                                             println ;
                                           Until helpptr = 0 ;
                                         End ;
                                       Begin
                                         helpptr := 4 ;
                                         helpline [ 3 ] := 282 ;
                                         helpline [ 2 ] := 281 ;
                                         helpline [ 1 ] := 283 ;
                                         helpline [ 0 ] := 284 ;
                                       End ;
                                       goto 22 ;
                                     End ;
                                73 :
                                     Begin
                                       beginfilereading ;
                                       If last > first + 1 Then
                                         Begin
                                           curinput . locfield := first + 1 ;
                                           buffer [ first ] := 32 ;
                                         End
                                       Else
                                         Begin
                                           Begin ;
                                             print ( 277 ) ;
                                             terminput ;
                                           End ;
                                           curinput . locfield := first ;
                                         End ;
                                       first := last + 1 ;
                                       curinput . limitfield := last ;
                                       goto 10 ;
                                     End ;
                                81 , 82 , 83 :
                                               Begin
                                                 errorcount := 0 ;
                                                 interaction := 0 + c - 81 ;
                                                 print ( 272 ) ;
                                                 Case c Of 
                                                   81 :
                                                        Begin
                                                          print ( 273 ) ;
                                                          selector := selector - 1 ;
                                                        End ;
                                                   82 : print ( 274 ) ;
                                                   83 : print ( 275 ) ;
                                                 End ;
                                                 print ( 276 ) ;
                                                 println ;
                                                 break ( termout ) ;
                                                 goto 10 ;
                                               End ;
                                88 :
                                     Begin
                                       interaction := 2 ;
                                       jumpout ;
                                     End ;
                                others :
                              End ;
                              Begin
                                print ( 266 ) ;
                                printnl ( 267 ) ;
                                printnl ( 268 ) ;
                                If fileptr > 0 Then print ( 269 ) ;
                                If deletionsallowed Then printnl ( 270 ) ;
                                printnl ( 271 ) ;
                              End ;
                            End ;
  errorcount := errorcount + 1 ;
  If errorcount = 100 Then
    Begin
      printnl ( 262 ) ;
      history := 3 ;
      jumpout ;
    End ;
  If interaction > 0 Then selector := selector - 1 ;
  If useerrhelp Then
    Begin
      printnl ( 285 ) ;
      j := strstart [ errhelp ] ;
      While j < strstart [ errhelp + 1 ] Do
        Begin
          If strpool [ j ] <> 37 Then print ( strpool [ j ] )
          Else If j + 1 = strstart [ errhelp + 1 ] Then println
          Else If strpool [ j + 1 ] <> 37 Then println
          Else
            Begin
              j := j + 1 ;
              printchar ( 37 ) ;
            End ;
          j := j + 1 ;
        End ;
    End
  Else While helpptr > 0 Do
         Begin
           helpptr := helpptr - 1 ;
           printnl ( helpline [ helpptr ] ) ;
         End ;
  println ;
  If interaction > 0 Then selector := selector + 1 ;
  println ;
  10 :
End ;
Procedure fatalerror ( s : strnumber ) ;
Begin
  normalizeselector ;
  Begin
    If interaction = 3 Then ;
    printnl ( 261 ) ;
    print ( 286 ) ;
  End ;
  Begin
    helpptr := 1 ;
    helpline [ 0 ] := s ;
  End ;
  Begin
    If interaction = 3 Then interaction := 2 ;
    If logopened Then error ;
    history := 3 ;
    jumpout ;
  End ;
End ;
Procedure overflow ( s : strnumber ; n : integer ) ;
Begin
  normalizeselector ;
  Begin
    If interaction = 3 Then ;
    printnl ( 261 ) ;
    print ( 287 ) ;
  End ;
  print ( s ) ;
  printchar ( 61 ) ;
  printint ( n ) ;
  printchar ( 93 ) ;
  Begin
    helpptr := 2 ;
    helpline [ 1 ] := 288 ;
    helpline [ 0 ] := 289 ;
  End ;
  Begin
    If interaction = 3 Then interaction := 2 ;
    If logopened Then error ;
    history := 3 ;
    jumpout ;
  End ;
End ;
Procedure confusion ( s : strnumber ) ;
Begin
  normalizeselector ;
  If history < 2 Then
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 261 ) ;
        print ( 290 ) ;
      End ;
      print ( s ) ;
      printchar ( 41 ) ;
      Begin
        helpptr := 1 ;
        helpline [ 0 ] := 291 ;
      End ;
    End
  Else
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 261 ) ;
        print ( 292 ) ;
      End ;
      Begin
        helpptr := 2 ;
        helpline [ 1 ] := 293 ;
        helpline [ 0 ] := 294 ;
      End ;
    End ;
  Begin
    If interaction = 3 Then interaction := 2 ;
    If logopened Then error ;
    history := 3 ;
    jumpout ;
  End ;
End ;
Function aopenin ( Var f : alphafile ) : boolean ;
Begin
  reset ( f , nameoffile , '/O' ) ;
  aopenin := erstat ( f ) = 0 ;
End ;
Function aopenout ( Var f : alphafile ) : boolean ;
Begin
  rewrite ( f , nameoffile , '/O' ) ;
  aopenout := erstat ( f ) = 0 ;
End ;
Function bopenout ( Var f : bytefile ) : boolean ;
Begin
  rewrite ( f , nameoffile , '/O' ) ;
  bopenout := erstat ( f ) = 0 ;
End ;
Function wopenin ( Var f : wordfile ) : boolean ;
Begin
  reset ( f , nameoffile , '/O' ) ;
  wopenin := erstat ( f ) = 0 ;
End ;
Function wopenout ( Var f : wordfile ) : boolean ;
Begin
  rewrite ( f , nameoffile , '/O' ) ;
  wopenout := erstat ( f ) = 0 ;
End ;
Procedure aclose ( Var f : alphafile ) ;
Begin
  close ( f ) ;
End ;
Procedure bclose ( Var f : bytefile ) ;
Begin
  close ( f ) ;
End ;
Procedure wclose ( Var f : wordfile ) ;
Begin
  close ( f ) ;
End ;
Function inputln ( Var f : alphafile ; bypasseoln : boolean ) : boolean ;

Var lastnonblank : 0 .. bufsize ;
Begin
  If bypasseoln Then If Not eof ( f ) Then get ( f ) ;
  last := first ;
  If eof ( f ) Then inputln := false
  Else
    Begin
      lastnonblank := first ;
      While Not eoln ( f ) Do
        Begin
          If last >= maxbufstack Then
            Begin
              maxbufstack := last + 1 ;
              If maxbufstack = bufsize Then If baseident = 0 Then
                                              Begin
                                                writeln ( termout , 'Buffer size exceeded!' ) ;
                                                goto 9999 ;
                                              End
              Else
                Begin
                  curinput . locfield := first ;
                  curinput . limitfield := last - 1 ;
                  overflow ( 256 , bufsize ) ;
                End ;
            End ;
          buffer [ last ] := xord [ f ^ ] ;
          get ( f ) ;
          last := last + 1 ;
          If buffer [ last - 1 ] <> 32 Then lastnonblank := last ;
        End ;
      last := lastnonblank ;
      inputln := true ;
    End ;
End ;
Function initterminal : boolean ;

Label 10 ;
Begin
  reset ( termin , 'TTY:' , '/O/I' ) ;
  While true Do
    Begin ;
      write ( termout , '**' ) ;
      break ( termout ) ;
      If Not inputln ( termin , true ) Then
        Begin
          writeln ( termout ) ;
          write ( termout , '! End of file on the terminal... why?' ) ;
          initterminal := false ;
          goto 10 ;
        End ;
      curinput . locfield := first ;
      While ( curinput . locfield < last ) And ( buffer [ curinput . locfield ] = 32 ) Do
        curinput . locfield := curinput . locfield + 1 ;
      If curinput . locfield < last Then
        Begin
          initterminal := true ;
          goto 10 ;
        End ;
      writeln ( termout , 'Please type the name of your input file.' ) ;
    End ;
  10 :
End ;
Function makestring : strnumber ;
Begin
  If strptr = maxstrptr Then
    Begin
      If strptr = maxstrings Then overflow ( 258 , maxstrings - initstrptr ) ;
      maxstrptr := maxstrptr + 1 ;
    End ;
  strref [ strptr ] := 1 ;
  strptr := strptr + 1 ;
  strstart [ strptr ] := poolptr ;
  makestring := strptr - 1 ;
End ;
Function streqbuf ( s : strnumber ; k : integer ) : boolean ;

Label 45 ;

Var j : poolpointer ;
  result : boolean ;
Begin
  j := strstart [ s ] ;
  While j < strstart [ s + 1 ] Do
    Begin
      If strpool [ j ] <> buffer [ k ] Then
        Begin
          result := false ;
          goto 45 ;
        End ;
      j := j + 1 ;
      k := k + 1 ;
    End ;
  result := true ;
  45 : streqbuf := result ;
End ;
Function strvsstr ( s , t : strnumber ) : integer ;

Label 10 ;

Var j , k : poolpointer ;
  ls , lt : integer ;
  l : integer ;
Begin
  ls := ( strstart [ s + 1 ] - strstart [ s ] ) ;
  lt := ( strstart [ t + 1 ] - strstart [ t ] ) ;
  If ls <= lt Then l := ls
  Else l := lt ;
  j := strstart [ s ] ;
  k := strstart [ t ] ;
  While l > 0 Do
    Begin
      If strpool [ j ] <> strpool [ k ] Then
        Begin
          strvsstr := strpool [ j ] - strpool [ k ] ;
          goto 10 ;
        End ;
      j := j + 1 ;
      k := k + 1 ;
      l := l - 1 ;
    End ;
  strvsstr := ls - lt ;
  10 :
End ;
Function getstringsstarted : boolean ;

Label 30 , 10 ;

Var k , l : 0 .. 255 ;
  m , n : char ;
  g : strnumber ;
  a : integer ;
  c : boolean ;
Begin
  poolptr := 0 ;
  strptr := 0 ;
  maxpoolptr := 0 ;
  maxstrptr := 0 ;
  strstart [ 0 ] := 0 ;
  For k := 0 To 255 Do
    Begin
      If ( ( k < 32 ) Or ( k > 126 ) ) Then
        Begin
          Begin
            strpool [ poolptr ] := 94 ;
            poolptr := poolptr + 1 ;
          End ;
          Begin
            strpool [ poolptr ] := 94 ;
            poolptr := poolptr + 1 ;
          End ;
          If k < 64 Then
            Begin
              strpool [ poolptr ] := k + 64 ;
              poolptr := poolptr + 1 ;
            End
          Else If k < 128 Then
                 Begin
                   strpool [ poolptr ] := k - 64 ;
                   poolptr := poolptr + 1 ;
                 End
          Else
            Begin
              l := k Div 16 ;
              If l < 10 Then
                Begin
                  strpool [ poolptr ] := l + 48 ;
                  poolptr := poolptr + 1 ;
                End
              Else
                Begin
                  strpool [ poolptr ] := l + 87 ;
                  poolptr := poolptr + 1 ;
                End ;
              l := k Mod 16 ;
              If l < 10 Then
                Begin
                  strpool [ poolptr ] := l + 48 ;
                  poolptr := poolptr + 1 ;
                End
              Else
                Begin
                  strpool [ poolptr ] := l + 87 ;
                  poolptr := poolptr + 1 ;
                End ;
            End ;
        End
      Else
        Begin
          strpool [ poolptr ] := k ;
          poolptr := poolptr + 1 ;
        End ;
      g := makestring ;
      strref [ g ] := 127 ;
    End ;
  nameoffile := poolname ;
  If aopenin ( poolfile ) Then
    Begin
      c := false ;
      Repeat
        Begin
          If eof ( poolfile ) Then
            Begin ;
              writeln ( termout , '! MF.POOL has no check sum.' ) ;
              aclose ( poolfile ) ;
              getstringsstarted := false ;
              goto 10 ;
            End ;
          read ( poolfile , m , n ) ;
          If m = '*' Then
            Begin
              a := 0 ;
              k := 1 ;
              While true Do
                Begin
                  If ( xord [ n ] < 48 ) Or ( xord [ n ] > 57 ) Then
                    Begin ;
                      writeln ( termout , '! MF.POOL check sum doesn''t have nine digits.' ) ;
                      aclose ( poolfile ) ;
                      getstringsstarted := false ;
                      goto 10 ;
                    End ;
                  a := 10 * a + xord [ n ] - 48 ;
                  If k = 9 Then goto 30 ;
                  k := k + 1 ;
                  read ( poolfile , n ) ;
                End ;
              30 : If a <> 166307429 Then
                     Begin ;
                       writeln ( termout , '! MF.POOL doesn''t match; TANGLE me again.' ) ;
                       aclose ( poolfile ) ;
                       getstringsstarted := false ;
                       goto 10 ;
                     End ;
              c := true ;
            End
          Else
            Begin
              If ( xord [ m ] < 48 ) Or ( xord [ m ] > 57 ) Or ( xord [ n ] < 48 ) Or ( xord [ n ] > 57 ) Then
                Begin ;
                  writeln ( termout , '! MF.POOL line doesn''t begin with two digits.' ) ;
                  aclose ( poolfile ) ;
                  getstringsstarted := false ;
                  goto 10 ;
                End ;
              l := xord [ m ] * 10 + xord [ n ] - 48 * 11 ;
              If poolptr + l + stringvacancies > poolsize Then
                Begin ;
                  writeln ( termout , '! You have to increase POOLSIZE.' ) ;
                  aclose ( poolfile ) ;
                  getstringsstarted := false ;
                  goto 10 ;
                End ;
              For k := 1 To l Do
                Begin
                  If eoln ( poolfile ) Then m := ' '
                  Else read ( poolfile , m ) ;
                  Begin
                    strpool [ poolptr ] := xord [ m ] ;
                    poolptr := poolptr + 1 ;
                  End ;
                End ;
              readln ( poolfile ) ;
              g := makestring ;
              strref [ g ] := 127 ;
            End ;
        End ;
      Until c ;
      aclose ( poolfile ) ;
      getstringsstarted := true ;
    End
  Else
    Begin ;
      writeln ( termout , '! I can''t read MF.POOL.' ) ;
      aclose ( poolfile ) ;
      getstringsstarted := false ;
      goto 10 ;
    End ;
  10 :
End ;
Procedure printdd ( n : integer ) ;
Begin
  n := abs ( n ) Mod 100 ;
  printchar ( 48 + ( n Div 10 ) ) ;
  printchar ( 48 + ( n Mod 10 ) ) ;
End ;
Procedure terminput ;

Var k : 0 .. bufsize ;
Begin
  break ( termout ) ;
  If Not inputln ( termin , true ) Then fatalerror ( 260 ) ;
  termoffset := 0 ;
  selector := selector - 1 ;
  If last <> first Then For k := first To last - 1 Do
                          print ( buffer [ k ] ) ;
  println ;
  buffer [ last ] := 37 ;
  selector := selector + 1 ;
End ;
Procedure normalizeselector ;
Begin
  If logopened Then selector := 3
  Else selector := 1 ;
  If jobname = 0 Then openlogfile ;
  If interaction = 0 Then selector := selector - 1 ;
End ;
Procedure pauseforinstructions ;
Begin
  If OKtointerrupt Then
    Begin
      interaction := 3 ;
      If ( selector = 2 ) Or ( selector = 0 ) Then selector := selector + 1 ;
      Begin
        If interaction = 3 Then ;
        printnl ( 261 ) ;
        print ( 295 ) ;
      End ;
      Begin
        helpptr := 3 ;
        helpline [ 2 ] := 296 ;
        helpline [ 1 ] := 297 ;
        helpline [ 0 ] := 298 ;
      End ;
      deletionsallowed := false ;
      error ;
      deletionsallowed := true ;
      interrupt := 0 ;
    End ;
End ;
Procedure missingerr ( s : strnumber ) ;
Begin
  Begin
    If interaction = 3 Then ;
    printnl ( 261 ) ;
    print ( 299 ) ;
  End ;
  print ( s ) ;
  print ( 300 ) ;
End ;
Procedure cleararith ;
Begin
  Begin
    If interaction = 3 Then ;
    printnl ( 261 ) ;
    print ( 301 ) ;
  End ;
  Begin
    helpptr := 4 ;
    helpline [ 3 ] := 302 ;
    helpline [ 2 ] := 303 ;
    helpline [ 1 ] := 304 ;
    helpline [ 0 ] := 305 ;
  End ;
  error ;
  aritherror := false ;
End ;
Function slowadd ( x , y : integer ) : integer ;
Begin
  If x >= 0 Then If y <= 2147483647 - x Then slowadd := x + y
  Else
    Begin
      aritherror := true ;
      slowadd := 2147483647 ;
    End
  Else If - y <= 2147483647 + x Then slowadd := x + y
  Else
    Begin
      aritherror := true ;
      slowadd := - 2147483647 ;
    End ;
End ;
Function rounddecimals ( k : smallnumber ) : scaled ;

Var a : integer ;
Begin
  a := 0 ;
  While k > 0 Do
    Begin
      k := k - 1 ;
      a := ( a + dig [ k ] * 131072 ) Div 10 ;
    End ;
  rounddecimals := ( a + 1 ) Div 2 ;
End ;
Function makefraction ( p , q : integer ) : fraction ;

Var f : integer ;
  n : integer ;
  negative : boolean ;
  becareful : integer ;
Begin
  If p >= 0 Then negative := false
  Else
    Begin
      p := - p ;
      negative := true ;
    End ;
  If q <= 0 Then
    Begin
      q := - q ;
      negative := Not negative ;
    End ;
  n := p Div q ;
  p := p Mod q ;
  If n >= 8 Then
    Begin
      aritherror := true ;
      If negative Then makefraction := - 2147483647
      Else makefraction := 2147483647 ;
    End
  Else
    Begin
      n := ( n - 1 ) * 268435456 ;
      f := 1 ;
      Repeat
        becareful := p - q ;
        p := becareful + p ;
        If p >= 0 Then f := f + f + 1
        Else
          Begin
            f := f + f ;
            p := p + q ;
          End ;
      Until f >= 268435456 ;
      becareful := p - q ;
      If becareful + p >= 0 Then f := f + 1 ;
      If negative Then makefraction := - ( f + n )
      Else makefraction := f + n ;
    End ;
End ;
Function takefraction ( q : integer ; f : fraction ) : integer ;

Var p : integer ;
  negative : boolean ;
  n : integer ;
  becareful : integer ;
Begin
  If f >= 0 Then negative := false
  Else
    Begin
      f := - f ;
      negative := true ;
    End ;
  If q < 0 Then
    Begin
      q := - q ;
      negative := Not negative ;
    End ; ;
  If f < 268435456 Then n := 0
  Else
    Begin
      n := f Div 268435456 ;
      f := f Mod 268435456 ;
      If q <= 2147483647 Div n Then n := n * q
      Else
        Begin
          aritherror := true ;
          n := 2147483647 ;
        End ;
    End ;
  f := f + 268435456 ;
  p := 134217728 ;
  If q < 1073741824 Then Repeat
                           If odd ( f ) Then p := ( p + q ) Div 2
                           Else p := ( p ) Div 2 ;
                           f := ( f ) Div 2 ;
    Until f = 1
  Else Repeat
         If odd ( f ) Then p := p + ( q - p ) Div 2
         Else p := ( p ) Div 2 ;
         f := ( f ) Div 2 ;
    Until f = 1 ;
  becareful := n - 2147483647 ;
  If becareful + p > 0 Then
    Begin
      aritherror := true ;
      n := 2147483647 - p ;
    End ;
  If negative Then takefraction := - ( n + p )
  Else takefraction := n + p ;
End ;
Function takescaled ( q : integer ; f : scaled ) : integer ;

Var p : integer ;
  negative : boolean ;
  n : integer ;
  becareful : integer ;
Begin
  If f >= 0 Then negative := false
  Else
    Begin
      f := - f ;
      negative := true ;
    End ;
  If q < 0 Then
    Begin
      q := - q ;
      negative := Not negative ;
    End ; ;
  If f < 65536 Then n := 0
  Else
    Begin
      n := f Div 65536 ;
      f := f Mod 65536 ;
      If q <= 2147483647 Div n Then n := n * q
      Else
        Begin
          aritherror := true ;
          n := 2147483647 ;
        End ;
    End ;
  f := f + 65536 ;
  p := 32768 ;
  If q < 1073741824 Then Repeat
                           If odd ( f ) Then p := ( p + q ) Div 2
                           Else p := ( p ) Div 2 ;
                           f := ( f ) Div 2 ;
    Until f = 1
  Else Repeat
         If odd ( f ) Then p := p + ( q - p ) Div 2
         Else p := ( p ) Div 2 ;
         f := ( f ) Div 2 ;
    Until f = 1 ;
  becareful := n - 2147483647 ;
  If becareful + p > 0 Then
    Begin
      aritherror := true ;
      n := 2147483647 - p ;
    End ;
  If negative Then takescaled := - ( n + p )
  Else takescaled := n + p ;
End ;
Function makescaled ( p , q : integer ) : scaled ;

Var f : integer ;
  n : integer ;
  negative : boolean ;
  becareful : integer ;
Begin
  If p >= 0 Then negative := false
  Else
    Begin
      p := - p ;
      negative := true ;
    End ;
  If q <= 0 Then
    Begin
      q := - q ;
      negative := Not negative ;
    End ;
  n := p Div q ;
  p := p Mod q ;
  If n >= 32768 Then
    Begin
      aritherror := true ;
      If negative Then makescaled := - 2147483647
      Else makescaled := 2147483647 ;
    End
  Else
    Begin
      n := ( n - 1 ) * 65536 ;
      f := 1 ;
      Repeat
        becareful := p - q ;
        p := becareful + p ;
        If p >= 0 Then f := f + f + 1
        Else
          Begin
            f := f + f ;
            p := p + q ;
          End ;
      Until f >= 65536 ;
      becareful := p - q ;
      If becareful + p >= 0 Then f := f + 1 ;
      If negative Then makescaled := - ( f + n )
      Else makescaled := f + n ;
    End ;
End ;
Function velocity ( st , ct , sf , cf : fraction ; t : scaled ) : fraction ;

Var acc , num , denom : integer ;
Begin
  acc := takefraction ( st - ( sf Div 16 ) , sf - ( st Div 16 ) ) ;
  acc := takefraction ( acc , ct - cf ) ;
  num := 536870912 + takefraction ( acc , 379625062 ) ;
  denom := 805306368 + takefraction ( ct , 497706707 ) + takefraction ( cf , 307599661 ) ;
  If t <> 65536 Then num := makescaled ( num , t ) ;
  If num Div 4 >= denom Then velocity := 1073741824
  Else velocity := makefraction ( num , denom ) ;
End ;
Function abvscd ( a , b , c , d : integer ) : integer ;

Label 10 ;

Var q , r : integer ;
Begin
  If a < 0 Then
    Begin
      a := - a ;
      b := - b ;
    End ;
  If c < 0 Then
    Begin
      c := - c ;
      d := - d ;
    End ;
  If d <= 0 Then
    Begin
      If b >= 0 Then If ( ( a = 0 ) Or ( b = 0 ) ) And ( ( c = 0 ) Or ( d = 0 ) ) Then
                       Begin
                         abvscd := 0 ;
                         goto 10 ;
                       End
      Else
        Begin
          abvscd := 1 ;
          goto 10 ;
        End ;
      If d = 0 Then If a = 0 Then
                      Begin
                        abvscd := 0 ;
                        goto 10 ;
                      End
      Else
        Begin
          abvscd := - 1 ;
          goto 10 ;
        End ;
      q := a ;
      a := c ;
      c := q ;
      q := - b ;
      b := - d ;
      d := q ;
    End
  Else If b <= 0 Then
         Begin
           If b < 0 Then If a > 0 Then
                           Begin
                             abvscd := - 1 ;
                             goto 10 ;
                           End ;
           If c = 0 Then
             Begin
               abvscd := 0 ;
               goto 10 ;
             End
           Else
             Begin
               abvscd := - 1 ;
               goto 10 ;
             End ;
         End ;
  While true Do
    Begin
      q := a Div d ;
      r := c Div b ;
      If q <> r Then If q > r Then
                       Begin
                         abvscd := 1 ;
                         goto 10 ;
                       End
      Else
        Begin
          abvscd := - 1 ;
          goto 10 ;
        End ;
      q := a Mod d ;
      r := c Mod b ;
      If r = 0 Then If q = 0 Then
                      Begin
                        abvscd := 0 ;
                        goto 10 ;
                      End
      Else
        Begin
          abvscd := 1 ;
          goto 10 ;
        End ;
      If q = 0 Then
        Begin
          abvscd := - 1 ;
          goto 10 ;
        End ;
      a := b ;
      b := q ;
      c := d ;
      d := r ;
    End ;
  10 :
End ;
Function floorscaled ( x : scaled ) : scaled ;

Var becareful : integer ;
Begin
  If x >= 0 Then floorscaled := x - ( x Mod 65536 )
  Else
    Begin
      becareful := x + 1 ;
      floorscaled := x + ( ( - becareful ) Mod 65536 ) - 65535 ;
    End ;
End ;
Function floorunscaled ( x : scaled ) : integer ;

Var becareful : integer ;
Begin
  If x >= 0 Then floorunscaled := x Div 65536
  Else
    Begin
      becareful := x + 1 ;
      floorunscaled := - ( 1 + ( ( - becareful ) Div 65536 ) ) ;
    End ;
End ;
Function roundunscaled ( x : scaled ) : integer ;

Var becareful : integer ;
Begin
  If x >= 32768 Then roundunscaled := 1 + ( ( x - 32768 ) Div 65536 )
  Else If x >= - 32768 Then roundunscaled := 0
  Else
    Begin
      becareful := x + 1 ;
      roundunscaled := - ( 1 + ( ( - becareful - 32768 ) Div 65536 ) ) ;
    End ;
End ;
Function roundfraction ( x : fraction ) : scaled ;

Var becareful : integer ;
Begin
  If x >= 2048 Then roundfraction := 1 + ( ( x - 2048 ) Div 4096 )
  Else If x >= - 2048 Then roundfraction := 0
  Else
    Begin
      becareful := x + 1 ;
      roundfraction := - ( 1 + ( ( - becareful - 2048 ) Div 4096 ) ) ;
    End ;
End ;
Function squarert ( x : scaled ) : scaled ;

Var k : smallnumber ;
  y , q : integer ;
Begin
  If x <= 0 Then
    Begin
      If x < 0 Then
        Begin
          Begin
            If interaction = 3 Then ;
            printnl ( 261 ) ;
            print ( 306 ) ;
          End ;
          printscaled ( x ) ;
          print ( 307 ) ;
          Begin
            helpptr := 2 ;
            helpline [ 1 ] := 308 ;
            helpline [ 0 ] := 309 ;
          End ;
          error ;
        End ;
      squarert := 0 ;
    End
  Else
    Begin
      k := 23 ;
      q := 2 ;
      While x < 536870912 Do
        Begin
          k := k - 1 ;
          x := x + x + x + x ;
        End ;
      If x < 1073741824 Then y := 0
      Else
        Begin
          x := x - 1073741824 ;
          y := 1 ;
        End ;
      Repeat
        x := x + x ;
        y := y + y ;
        If x >= 1073741824 Then
          Begin
            x := x - 1073741824 ;
            y := y + 1 ;
          End ;
        x := x + x ;
        y := y + y - q ;
        q := q + q ;
        If x >= 1073741824 Then
          Begin
            x := x - 1073741824 ;
            y := y + 1 ;
          End ;
        If y > q Then
          Begin
            y := y - q ;
            q := q + 2 ;
          End
        Else If y <= 0 Then
               Begin
                 q := q - 2 ;
                 y := y + q ;
               End ;
        k := k - 1 ;
      Until k = 0 ;
      squarert := ( q ) Div 2 ;
    End ;
End ;
Function pythadd ( a , b : integer ) : integer ;

Label 30 ;

Var r : fraction ;
  big : boolean ;
Begin
  a := abs ( a ) ;
  b := abs ( b ) ;
  If a < b Then
    Begin
      r := b ;
      b := a ;
      a := r ;
    End ;
  If b > 0 Then
    Begin
      If a < 536870912 Then big := false
      Else
        Begin
          a := a Div 4 ;
          b := b Div 4 ;
          big := true ;
        End ;
      While true Do
        Begin
          r := makefraction ( b , a ) ;
          r := takefraction ( r , r ) ;
          If r = 0 Then goto 30 ;
          r := makefraction ( r , 1073741824 + r ) ;
          a := a + takefraction ( a + a , r ) ;
          b := takefraction ( b , r ) ;
        End ;
      30 : ;
      If big Then If a < 536870912 Then a := a + a + a + a
      Else
        Begin
          aritherror := true ;
          a := 2147483647 ;
        End ;
    End ;
  pythadd := a ;
End ;
Function pythsub ( a , b : integer ) : integer ;

Label 30 ;

Var r : fraction ;
  big : boolean ;
Begin
  a := abs ( a ) ;
  b := abs ( b ) ;
  If a <= b Then
    Begin
      If a < b Then
        Begin
          Begin
            If interaction = 3 Then ;
            printnl ( 261 ) ;
            print ( 310 ) ;
          End ;
          printscaled ( a ) ;
          print ( 311 ) ;
          printscaled ( b ) ;
          print ( 307 ) ;
          Begin
            helpptr := 2 ;
            helpline [ 1 ] := 308 ;
            helpline [ 0 ] := 309 ;
          End ;
          error ;
        End ;
      a := 0 ;
    End
  Else
    Begin
      If a < 1073741824 Then big := false
      Else
        Begin
          a := ( a ) Div 2 ;
          b := ( b ) Div 2 ;
          big := true ;
        End ;
      While true Do
        Begin
          r := makefraction ( b , a ) ;
          r := takefraction ( r , r ) ;
          If r = 0 Then goto 30 ;
          r := makefraction ( r , 1073741824 - r ) ;
          a := a - takefraction ( a + a , r ) ;
          b := takefraction ( b , r ) ;
        End ;
      30 : ;
      If big Then a := a + a ;
    End ;
  pythsub := a ;
End ;
Function mlog ( x : scaled ) : scaled ;

Var y , z : integer ;
  k : integer ;
Begin
  If x <= 0 Then
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 261 ) ;
        print ( 312 ) ;
      End ;
      printscaled ( x ) ;
      print ( 307 ) ;
      Begin
        helpptr := 2 ;
        helpline [ 1 ] := 313 ;
        helpline [ 0 ] := 309 ;
      End ;
      error ;
      mlog := 0 ;
    End
  Else
    Begin
      y := 1302456860 ;
      z := 6581195 ;
      While x < 1073741824 Do
        Begin
          x := x + x ;
          y := y - 93032639 ;
          z := z - 48782 ;
        End ;
      y := y + ( z Div 65536 ) ;
      k := 2 ;
      While x > 1073741828 Do
        Begin
          z := ( ( x - 1 ) Div twotothe [ k ] ) + 1 ;
          While x < 1073741824 + z Do
            Begin
              z := ( z + 1 ) Div 2 ;
              k := k + 1 ;
            End ;
          y := y + speclog [ k ] ;
          x := x - z ;
        End ;
      mlog := y Div 8 ;
    End ;
End ;
Function mexp ( x : scaled ) : scaled ;

Var k : smallnumber ;
  y , z : integer ;
Begin
  If x > 174436200 Then
    Begin
      aritherror := true ;
      mexp := 2147483647 ;
    End
  Else If x < - 197694359 Then mexp := 0
  Else
    Begin
      If x <= 0 Then
        Begin
          z := - 8 * x ;
          y := 1048576 ;
        End
      Else
        Begin
          If x <= 127919879 Then z := 1023359037 - 8 * x
          Else z := 8 * ( 174436200 - x ) ;
          y := 2147483647 ;
        End ;
      k := 1 ;
      While z > 0 Do
        Begin
          While z >= speclog [ k ] Do
            Begin
              z := z - speclog [ k ] ;
              y := y - 1 - ( ( y - twotothe [ k - 1 ] ) Div twotothe [ k ] ) ;
            End ;
          k := k + 1 ;
        End ;
      If x <= 127919879 Then mexp := ( y + 8 ) Div 16
      Else mexp := y ;
    End ;
End ;
Function narg ( x , y : integer ) : angle ;

Var z : angle ;
  t : integer ;
  k : smallnumber ;
  octant : 1 .. 8 ;
Begin
  If x >= 0 Then octant := 1
  Else
    Begin
      x := - x ;
      octant := 2 ;
    End ;
  If y < 0 Then
    Begin
      y := - y ;
      octant := octant + 2 ;
    End ;
  If x < y Then
    Begin
      t := y ;
      y := x ;
      x := t ;
      octant := octant + 4 ;
    End ;
  If x = 0 Then
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 261 ) ;
        print ( 314 ) ;
      End ;
      Begin
        helpptr := 2 ;
        helpline [ 1 ] := 315 ;
        helpline [ 0 ] := 309 ;
      End ;
      error ;
      narg := 0 ;
    End
  Else
    Begin
      While x >= 536870912 Do
        Begin
          x := ( x ) Div 2 ;
          y := ( y ) Div 2 ;
        End ;
      z := 0 ;
      If y > 0 Then
        Begin
          While x < 268435456 Do
            Begin
              x := x + x ;
              y := y + y ;
            End ;
          k := 0 ;
          Repeat
            y := y + y ;
            k := k + 1 ;
            If y > x Then
              Begin
                z := z + specatan [ k ] ;
                t := x ;
                x := x + ( y Div twotothe [ k + k ] ) ;
                y := y - t ;
              End ;
          Until k = 15 ;
          Repeat
            y := y + y ;
            k := k + 1 ;
            If y > x Then
              Begin
                z := z + specatan [ k ] ;
                y := y - x ;
              End ;
          Until k = 26 ;
        End ;
      Case octant Of 
        1 : narg := z ;
        5 : narg := 94371840 - z ;
        6 : narg := 94371840 + z ;
        2 : narg := 188743680 - z ;
        4 : narg := z - 188743680 ;
        8 : narg := - z - 94371840 ;
        7 : narg := z - 94371840 ;
        3 : narg := - z ;
      End ;
    End ;
End ;
Procedure nsincos ( z : angle ) ;

Var k : smallnumber ;
  q : 0 .. 7 ;
  r : fraction ;
  x , y , t : integer ;
Begin
  While z < 0 Do
    z := z + 377487360 ;
  z := z Mod 377487360 ;
  q := z Div 47185920 ;
  z := z Mod 47185920 ;
  x := 268435456 ;
  y := x ;
  If Not odd ( q ) Then z := 47185920 - z ;
  k := 1 ;
  While z > 0 Do
    Begin
      If z >= specatan [ k ] Then
        Begin
          z := z - specatan [ k ] ;
          t := x ;
          x := t + y Div twotothe [ k ] ;
          y := y - t Div twotothe [ k ] ;
        End ;
      k := k + 1 ;
    End ;
  If y < 0 Then y := 0 ;
  Case q Of 
    0 : ;
    1 :
        Begin
          t := x ;
          x := y ;
          y := t ;
        End ;
    2 :
        Begin
          t := x ;
          x := - y ;
          y := t ;
        End ;
    3 : x := - x ;
    4 :
        Begin
          x := - x ;
          y := - y ;
        End ;
    5 :
        Begin
          t := x ;
          x := - y ;
          y := - t ;
        End ;
    6 :
        Begin
          t := x ;
          x := y ;
          y := - t ;
        End ;
    7 : y := - y ;
  End ;
  r := pythadd ( x , y ) ;
  ncos := makefraction ( x , r ) ;
  nsin := makefraction ( y , r ) ;
End ;
Procedure newrandoms ;

Var k : 0 .. 54 ;
  x : fraction ;
Begin
  For k := 0 To 23 Do
    Begin
      x := randoms [ k ] - randoms [ k + 31 ] ;
      If x < 0 Then x := x + 268435456 ;
      randoms [ k ] := x ;
    End ;
  For k := 24 To 54 Do
    Begin
      x := randoms [ k ] - randoms [ k - 24 ] ;
      If x < 0 Then x := x + 268435456 ;
      randoms [ k ] := x ;
    End ;
  jrandom := 54 ;
End ;
Procedure initrandoms ( seed : scaled ) ;

Var j , jj , k : fraction ;
  i : 0 .. 54 ;
Begin
  j := abs ( seed ) ;
  While j >= 268435456 Do
    j := ( j ) Div 2 ;
  k := 1 ;
  For i := 0 To 54 Do
    Begin
      jj := k ;
      k := j - k ;
      j := jj ;
      If k < 0 Then k := k + 268435456 ;
      randoms [ ( i * 21 ) mod 55 ] := j ;
    End ;
  newrandoms ;
  newrandoms ;
  newrandoms ;
End ;
Function unifrand ( x : scaled ) : scaled ;

Var y : scaled ;
Begin
  If jrandom = 0 Then newrandoms
  Else jrandom := jrandom - 1 ;
  y := takefraction ( abs ( x ) , randoms [ jrandom ] ) ;
  If y = abs ( x ) Then unifrand := 0
  Else If x > 0 Then unifrand := y
  Else unifrand := - y ;
End ;
Function normrand : scaled ;

Var x , u , l : integer ;
Begin
  Repeat
    Repeat
      If jrandom = 0 Then newrandoms
      Else jrandom := jrandom - 1 ;
      x := takefraction ( 112429 , randoms [ jrandom ] - 134217728 ) ;
      If jrandom = 0 Then newrandoms
      Else jrandom := jrandom - 1 ;
      u := randoms [ jrandom ] ;
    Until abs ( x ) < u ;
    x := makefraction ( x , u ) ;
    l := 139548960 - mlog ( u ) ;
  Until abvscd ( 1024 , l , x , x ) >= 0 ;
  normrand := x ;
End ;
Procedure printcapsule ;
forward ;
Procedure showtokenlist ( p , q : integer ; l , nulltally : integer ) ;

Label 10 ;

Var Class , c : smallnumber ;
  r , v : integer ;
  Begin
    Class := 3 ;
      tally := nulltally ;
      While ( p <> 0 ) And ( tally < l ) Do
        Begin
          If p = q Then
            Begin
              firstcount := tally ;
              trickcount := tally + 1 + errorline - halferrorline ;
              If trickcount < errorline Then trickcount := errorline ;
            End ;
          c := 9 ;
          If ( p < 0 ) Or ( p > memend ) Then
            Begin
              print ( 493 ) ;
              goto 10 ;
            End ;
          If p < himemmin Then If mem [ p ] . hh . b1 = 12 Then If mem [ p ] . hh . b0 = 16 Then
                                                                  Begin
                                                                    If Class = 0 Then printchar ( 32 ) ;
                                                                    v := mem [ p + 1 ] . int ;
                                                                    If v < 0 Then
                                                                      Begin
                                                                        If Class = 17 Then printchar ( 32 ) ;
                                                                        printchar ( 91 ) ;
                                                                        printscaled ( v ) ;
                                                                        printchar ( 93 ) ;
                                                                        c := 18 ;
                                                                      End
                                                                    Else
                                                                      Begin
                                                                        printscaled ( v ) ;
                                                                        c := 0 ;
                                                                      End ;
                                                                  End
          Else If mem [ p ] . hh . b0 <> 4 Then print ( 496 )
          Else
            Begin
              printchar ( 34 ) ;
              slowprint ( mem [ p + 1 ] . int ) ;
              printchar ( 34 ) ;
              c := 4 ;
            End
          Else If ( mem [ p ] . hh . b1 <> 11 ) Or ( mem [ p ] . hh . b0 < 1 ) Or ( mem [ p ] . hh . b0 > 19 ) Then print ( 496 )
          Else
            Begin
              gpointer := p ;
              printcapsule ;
              c := 8 ;
            End
          Else
            Begin
              r := mem [ p ] . hh . lh ;
              If r >= 2370 Then
                Begin
                  If r < 2520 Then
                    Begin
                      print ( 498 ) ;
                      r := r - ( 2370 ) ;
                    End
                  Else If r < 2670 Then
                         Begin
                           print ( 499 ) ;
                           r := r - ( 2520 ) ;
                         End
                  Else
                    Begin
                      print ( 500 ) ;
                      r := r - ( 2670 ) ;
                    End ;
                  printint ( r ) ;
                  printchar ( 41 ) ;
                  c := 8 ;
                End
              Else If r < 1 Then If r = 0 Then
                                   Begin
                                     If Class = 17 Then printchar ( 32 ) ;
                                     print ( 497 ) ;
                                     c := 18 ;
                                   End
              Else print ( 494 )
              Else
                Begin
                  r := hash [ r ] . rh ;
                  If ( r < 0 ) Or ( r >= strptr ) Then print ( 495 )
                  Else
                    Begin
                      c := charclass [ strpool [ strstart [ r ] ] ] ;
                      If c = Class Then Case c Of 
                                          9 : printchar ( 46 ) ;
                                          5 , 6 , 7 , 8 : ;
                                          others : printchar ( 32 )
                        End ;
                      slowprint ( r ) ;
                    End ;
                End ;
            End ;
          Class := c ;
            p := mem [ p ] . hh . rh ;
          End ;
          If p <> 0 Then print ( 492 ) ;
          10 :
        End ;
      Procedure runaway ;
      Begin
        If scannerstatus > 2 Then
          Begin
            printnl ( 637 ) ;
            Case scannerstatus Of 
              3 : print ( 638 ) ;
              4 , 5 : print ( 639 ) ;
              6 : print ( 640 ) ;
            End ;
            println ;
            showtokenlist ( mem [ 29998 ] . hh . rh , 0 , errorline - 10 , 0 ) ;
          End ;
      End ;
      Function getavail : halfword ;

      Var p : halfword ;
      Begin
        p := avail ;
        If p <> 0 Then avail := mem [ avail ] . hh . rh
        Else If memend < memmax Then
               Begin
                 memend := memend + 1 ;
                 p := memend ;
               End
        Else
          Begin
            himemmin := himemmin - 1 ;
            p := himemmin ;
            If himemmin <= lomemmax Then
              Begin
                runaway ;
                overflow ( 316 , memmax + 1 ) ;
              End ;
          End ;
        mem [ p ] . hh . rh := 0 ;
        getavail := p ;
      End ;
      Function getnode ( s : integer ) : halfword ;

      Label 40 , 10 , 20 ;

      Var p : halfword ;
        q : halfword ;
        r : integer ;
        t , tt : integer ;
      Begin
        20 : p := rover ;
        Repeat
          q := p + mem [ p ] . hh . lh ;
          While ( mem [ q ] . hh . rh = 65535 ) Do
            Begin
              t := mem [ q + 1 ] . hh . rh ;
              tt := mem [ q + 1 ] . hh . lh ;
              If q = rover Then rover := t ;
              mem [ t + 1 ] . hh . lh := tt ;
              mem [ tt + 1 ] . hh . rh := t ;
              q := q + mem [ q ] . hh . lh ;
            End ;
          r := q - s ;
          If r > p + 1 Then
            Begin
              mem [ p ] . hh . lh := r - p ;
              rover := p ;
              goto 40 ;
            End ;
          If r = p Then If mem [ p + 1 ] . hh . rh <> p Then
                          Begin
                            rover := mem [ p + 1 ] . hh . rh ;
                            t := mem [ p + 1 ] . hh . lh ;
                            mem [ rover + 1 ] . hh . lh := t ;
                            mem [ t + 1 ] . hh . rh := rover ;
                            goto 40 ;
                          End ;
          mem [ p ] . hh . lh := q - p ;
          p := mem [ p + 1 ] . hh . rh ;
        Until p = rover ;
        If s = 1073741824 Then
          Begin
            getnode := 65535 ;
            goto 10 ;
          End ;
        If lomemmax + 2 < himemmin Then If lomemmax + 2 <= 65535 Then
                                          Begin
                                            If himemmin - lomemmax >= 1998 Then t := lomemmax + 1000
                                            Else t := lomemmax + 1 + ( himemmin - lomemmax ) Div 2 ;
                                            If t > 65535 Then t := 65535 ;
                                            p := mem [ rover + 1 ] . hh . lh ;
                                            q := lomemmax ;
                                            mem [ p + 1 ] . hh . rh := q ;
                                            mem [ rover + 1 ] . hh . lh := q ;
                                            mem [ q + 1 ] . hh . rh := rover ;
                                            mem [ q + 1 ] . hh . lh := p ;
                                            mem [ q ] . hh . rh := 65535 ;
                                            mem [ q ] . hh . lh := t - lomemmax ;
                                            lomemmax := t ;
                                            mem [ lomemmax ] . hh . rh := 0 ;
                                            mem [ lomemmax ] . hh . lh := 0 ;
                                            rover := q ;
                                            goto 20 ;
                                          End ;
        overflow ( 316 , memmax + 1 ) ;
        40 : mem [ r ] . hh . rh := 0 ;
        getnode := r ;
        10 :
      End ;
      Procedure freenode ( p : halfword ; s : halfword ) ;

      Var q : halfword ;
      Begin
        mem [ p ] . hh . lh := s ;
        mem [ p ] . hh . rh := 65535 ;
        q := mem [ rover + 1 ] . hh . lh ;
        mem [ p + 1 ] . hh . lh := q ;
        mem [ p + 1 ] . hh . rh := rover ;
        mem [ rover + 1 ] . hh . lh := p ;
        mem [ q + 1 ] . hh . rh := p ;
      End ;
      Procedure sortavail ;

      Var p , q , r : halfword ;
        oldrover : halfword ;
      Begin
        p := getnode ( 1073741824 ) ;
        p := mem [ rover + 1 ] . hh . rh ;
        mem [ rover + 1 ] . hh . rh := 65535 ;
        oldrover := rover ;
        While p <> oldrover Do
          If p < rover Then
            Begin
              q := p ;
              p := mem [ q + 1 ] . hh . rh ;
              mem [ q + 1 ] . hh . rh := rover ;
              rover := q ;
            End
          Else
            Begin
              q := rover ;
              While mem [ q + 1 ] . hh . rh < p Do
                q := mem [ q + 1 ] . hh . rh ;
              r := mem [ p + 1 ] . hh . rh ;
              mem [ p + 1 ] . hh . rh := mem [ q + 1 ] . hh . rh ;
              mem [ q + 1 ] . hh . rh := p ;
              p := r ;
            End ;
        p := rover ;
        While mem [ p + 1 ] . hh . rh <> 65535 Do
          Begin
            mem [ mem [ p + 1 ] . hh . rh + 1 ] . hh . lh := p ;
            p := mem [ p + 1 ] . hh . rh ;
          End ;
        mem [ p + 1 ] . hh . rh := rover ;
        mem [ rover + 1 ] . hh . lh := p ;
      End ;
      Procedure flushlist ( p : halfword ) ;

      Label 30 ;

      Var q , r : halfword ;
      Begin
        If p >= himemmin Then If p <> 30000 Then
                                Begin
                                  r := p ;
                                  Repeat
                                    q := r ;
                                    r := mem [ r ] . hh . rh ;
                                    If r < himemmin Then goto 30 ;
                                  Until r = 30000 ;
                                  30 : mem [ q ] . hh . rh := avail ;
                                  avail := p ;
                                End ;
      End ;
      Procedure flushnodelist ( p : halfword ) ;

      Var q : halfword ;
      Begin
        While p <> 0 Do
          Begin
            q := p ;
            p := mem [ p ] . hh . rh ;
            If q < himemmin Then freenode ( q , 2 )
            Else
              Begin
                mem [ q ] . hh . rh := avail ;
                avail := q ;
              End ;
          End ;
      End ;
      Procedure printop ( c : quarterword ) ;
      Begin
        If c <= 15 Then printtype ( c )
        Else Case c Of 
               30 : print ( 348 ) ;
               31 : print ( 349 ) ;
               32 : print ( 350 ) ;
               33 : print ( 351 ) ;
               34 : print ( 352 ) ;
               35 : print ( 353 ) ;
               36 : print ( 354 ) ;
               37 : print ( 355 ) ;
               38 : print ( 356 ) ;
               39 : print ( 357 ) ;
               40 : print ( 358 ) ;
               41 : print ( 359 ) ;
               42 : print ( 360 ) ;
               43 : print ( 361 ) ;
               44 : print ( 362 ) ;
               45 : print ( 363 ) ;
               46 : print ( 364 ) ;
               47 : print ( 365 ) ;
               48 : print ( 366 ) ;
               49 : print ( 367 ) ;
               50 : print ( 368 ) ;
               51 : print ( 369 ) ;
               52 : print ( 370 ) ;
               53 : print ( 371 ) ;
               54 : print ( 372 ) ;
               55 : print ( 373 ) ;
               56 : print ( 374 ) ;
               57 : print ( 375 ) ;
               58 : print ( 376 ) ;
               59 : print ( 377 ) ;
               60 : print ( 378 ) ;
               61 : print ( 379 ) ;
               62 : print ( 380 ) ;
               63 : print ( 381 ) ;
               64 : print ( 382 ) ;
               65 : print ( 383 ) ;
               66 : print ( 384 ) ;
               67 : print ( 385 ) ;
               68 : print ( 386 ) ;
               69 : printchar ( 43 ) ;
               70 : printchar ( 45 ) ;
               71 : printchar ( 42 ) ;
               72 : printchar ( 47 ) ;
               73 : print ( 387 ) ;
               74 : print ( 311 ) ;
               75 : print ( 388 ) ;
               76 : print ( 389 ) ;
               77 : printchar ( 60 ) ;
               78 : print ( 390 ) ;
               79 : printchar ( 62 ) ;
               80 : print ( 391 ) ;
               81 : printchar ( 61 ) ;
               82 : print ( 392 ) ;
               83 : print ( 38 ) ;
               84 : print ( 393 ) ;
               85 : print ( 394 ) ;
               86 : print ( 395 ) ;
               87 : print ( 396 ) ;
               88 : print ( 397 ) ;
               89 : print ( 398 ) ;
               90 : print ( 399 ) ;
               91 : print ( 400 ) ;
               92 : print ( 401 ) ;
               94 : print ( 402 ) ;
               95 : print ( 403 ) ;
               96 : print ( 404 ) ;
               97 : print ( 405 ) ;
               98 : print ( 406 ) ;
               99 : print ( 407 ) ;
               100 : print ( 408 ) ;
               others : print ( 409 )
          End ;
      End ;
      Procedure fixdateandtime ;
      Begin
        internal [ 17 ] := 12 * 60 * 65536 ;
        internal [ 16 ] := 4 * 65536 ;
        internal [ 15 ] := 7 * 65536 ;
        internal [ 14 ] := 1776 * 65536 ;
      End ;
      Function idlookup ( j , l : integer ) : halfword ;

      Label 40 ;

      Var h : integer ;
        p : halfword ;
        k : halfword ;
      Begin
        If l = 1 Then
          Begin
            p := buffer [ j ] + 1 ;
            hash [ p ] . rh := p - 1 ;
            goto 40 ;
          End ;
        h := buffer [ j ] ;
        For k := j + 1 To j + l - 1 Do
          Begin
            h := h + h + buffer [ k ] ;
            While h >= 1777 Do
              h := h - 1777 ;
          End ;
        p := h + 257 ;
        While true Do
          Begin
            If hash [ p ] . rh > 0 Then If ( strstart [ hash [ p ] . rh + 1 ] - strstart [ hash [ p ] . rh ] ) = l Then If streqbuf ( hash [ p ] . rh , j ) Then goto 40 ;
            If hash [ p ] . lh = 0 Then
              Begin
                If hash [ p ] . rh > 0 Then
                  Begin
                    Repeat
                      If ( hashused = 257 ) Then overflow ( 457 , 2100 ) ;
                      hashused := hashused - 1 ;
                    Until hash [ hashused ] . rh = 0 ;
                    hash [ p ] . lh := hashused ;
                    p := hashused ;
                  End ;
                Begin
                  If poolptr + l > maxpoolptr Then
                    Begin
                      If poolptr + l > poolsize Then overflow ( 257 , poolsize - initpoolptr ) ;
                      maxpoolptr := poolptr + l ;
                    End ;
                End ;
                For k := j To j + l - 1 Do
                  Begin
                    strpool [ poolptr ] := buffer [ k ] ;
                    poolptr := poolptr + 1 ;
                  End ;
                hash [ p ] . rh := makestring ;
                strref [ hash [ p ] . rh ] := 127 ;
                goto 40 ;
              End ;
            p := hash [ p ] . lh ;
          End ;
        40 : idlookup := p ;
      End ;
      Procedure primitive ( s : strnumber ; c : halfword ; o : halfword ) ;

      Var k : poolpointer ;
        j : smallnumber ;
        l : smallnumber ;
      Begin
        k := strstart [ s ] ;
        l := strstart [ s + 1 ] - k ;
        For j := 0 To l - 1 Do
          buffer [ j ] := strpool [ k + j ] ;
        cursym := idlookup ( 0 , l ) ;
        If s >= 256 Then
          Begin
            flushstring ( strptr - 1 ) ;
            hash [ cursym ] . rh := s ;
          End ;
        eqtb [ cursym ] . lh := c ;
        eqtb [ cursym ] . rh := o ;
      End ;
      Function newnumtok ( v : scaled ) : halfword ;

      Var p : halfword ;
      Begin
        p := getnode ( 2 ) ;
        mem [ p + 1 ] . int := v ;
        mem [ p ] . hh . b0 := 16 ;
        mem [ p ] . hh . b1 := 12 ;
        newnumtok := p ;
      End ;
      Procedure tokenrecycle ;
      forward ;
      Procedure flushtokenlist ( p : halfword ) ;

      Var q : halfword ;
      Begin
        While p <> 0 Do
          Begin
            q := p ;
            p := mem [ p ] . hh . rh ;
            If q >= himemmin Then
              Begin
                mem [ q ] . hh . rh := avail ;
                avail := q ;
              End
            Else
              Begin
                Case mem [ q ] . hh . b0 Of 
                  1 , 2 , 16 : ;
                  4 :
                      Begin
                        If strref [ mem [ q + 1 ] . int ] < 127 Then If strref [ mem [ q + 1 ] . int ] > 1 Then strref [ mem [ q + 1 ] . int ] := strref [ mem [ q + 1 ] . int ] - 1
                        Else flushstring ( mem [ q + 1 ] . int ) ;
                      End ;
                  3 , 5 , 7 , 12 , 10 , 6 , 9 , 8 , 11 , 14 , 13 , 17 , 18 , 19 :
                                                                                  Begin
                                                                                    gpointer := q ;
                                                                                    tokenrecycle ;
                                                                                  End ;
                  others : confusion ( 491 )
                End ;
                freenode ( q , 2 ) ;
              End ;
          End ;
      End ;
      Procedure deletemacref ( p : halfword ) ;
      Begin
        If mem [ p ] . hh . lh = 0 Then flushtokenlist ( p )
        Else mem [ p ] . hh . lh := mem [ p ] . hh . lh - 1 ;
      End ;
      Procedure printcmdmod ( c , m : integer ) ;
      Begin
        Case c Of 
          18 : print ( 462 ) ;
          77 : print ( 461 ) ;
          59 : print ( 464 ) ;
          72 : print ( 463 ) ;
          79 : print ( 460 ) ;
          32 : print ( 465 ) ;
          81 : print ( 58 ) ;
          82 : print ( 44 ) ;
          57 : print ( 466 ) ;
          19 : print ( 467 ) ;
          60 : print ( 468 ) ;
          27 : print ( 469 ) ;
          11 : print ( 470 ) ;
          80 : print ( 459 ) ;
          84 : print ( 453 ) ;
          26 : print ( 471 ) ;
          6 : print ( 472 ) ;
          9 : print ( 473 ) ;
          70 : print ( 474 ) ;
          73 : print ( 475 ) ;
          13 : print ( 476 ) ;
          46 : print ( 123 ) ;
          63 : print ( 91 ) ;
          14 : print ( 477 ) ;
          15 : print ( 478 ) ;
          69 : print ( 479 ) ;
          28 : print ( 480 ) ;
          47 : print ( 409 ) ;
          24 : print ( 481 ) ;
          7 : printchar ( 92 ) ;
          65 : print ( 125 ) ;
          64 : print ( 93 ) ;
          12 : print ( 482 ) ;
          8 : print ( 483 ) ;
          83 : print ( 59 ) ;
          17 : print ( 484 ) ;
          78 : print ( 485 ) ;
          74 : print ( 486 ) ;
          35 : print ( 487 ) ;
          58 : print ( 488 ) ;
          71 : print ( 489 ) ;
          75 : print ( 490 ) ;
          16 : If m <= 2 Then If m = 1 Then print ( 654 )
               Else If m < 1 Then print ( 454 )
               Else print ( 655 )
               Else If m = 53 Then print ( 656 )
               Else If m = 44 Then print ( 657 )
               Else print ( 658 ) ;
          4 : If m <= 1 Then If m = 1 Then print ( 661 )
              Else print ( 455 )
              Else If m = 2370 Then print ( 659 )
              Else print ( 660 ) ;
          61 : Case m Of 
                 1 : print ( 663 ) ;
                 2 : printchar ( 64 ) ;
                 3 : print ( 664 ) ;
                 others : print ( 662 )
               End ;
          56 : If m >= 2370 Then If m = 2370 Then print ( 675 )
               Else If m = 2520 Then print ( 676 )
               Else print ( 677 )
               Else If m < 2 Then print ( 678 )
               Else If m = 2 Then print ( 679 )
               Else print ( 680 ) ;
          3 : If m = 0 Then print ( 690 )
              Else print ( 616 ) ;
          1 , 2 : Case m Of 
                    1 : print ( 717 ) ;
                    2 : print ( 452 ) ;
                    3 : print ( 718 ) ;
                    others : print ( 719 )
                  End ;
          33 , 34 , 37 , 55 , 45 , 50 , 36 , 43 , 54 , 48 , 51 , 52 : printop ( m ) ;
          30 : printtype ( m ) ;
          85 : If m = 0 Then print ( 912 )
               Else print ( 913 ) ;
          23 : Case m Of 
                 0 : print ( 273 ) ;
                 1 : print ( 274 ) ;
                 2 : print ( 275 ) ;
                 others : print ( 919 )
               End ;
          21 : If m = 0 Then print ( 920 )
               Else print ( 921 ) ;
          22 : Case m Of 
                 0 : print ( 935 ) ;
                 1 : print ( 936 ) ;
                 2 : print ( 937 ) ;
                 3 : print ( 938 ) ;
                 others : print ( 939 )
               End ;
          31 , 62 :
                    Begin
                      If c = 31 Then print ( 942 )
                      Else print ( 943 ) ;
                      print ( 944 ) ;
                      slowprint ( hash [ m ] . rh ) ;
                    End ;
          41 : If m = 0 Then print ( 945 )
               Else print ( 946 ) ;
          10 : print ( 947 ) ;
          53 , 44 , 49 :
                         Begin
                           printcmdmod ( 16 , c ) ;
                           print ( 948 ) ;
                           println ;
                           showtokenlist ( mem [ mem [ m ] . hh . rh ] . hh . rh , 0 , 1000 , 0 ) ;
                         End ;
          5 : print ( 949 ) ;
          40 : slowprint ( intname [ m ] ) ;
          68 : If m = 1 Then print ( 956 )
               Else If m = 0 Then print ( 957 )
               Else print ( 958 ) ;
          66 : If m = 6 Then print ( 959 )
               Else print ( 960 ) ;
          67 : If m = 0 Then print ( 961 )
               Else print ( 962 ) ;
          25 : If m < 1 Then print ( 992 )
               Else If m = 1 Then print ( 993 )
               Else print ( 994 ) ;
          20 : Case m Of 
                 0 : print ( 1004 ) ;
                 1 : print ( 1005 ) ;
                 2 : print ( 1006 ) ;
                 3 : print ( 1007 ) ;
                 others : print ( 1008 )
               End ;
          76 : Case m Of 
                 0 : print ( 1026 ) ;
                 1 : print ( 1027 ) ;
                 2 : print ( 1029 ) ;
                 3 : print ( 1031 ) ;
                 5 : print ( 1028 ) ;
                 6 : print ( 1030 ) ;
                 7 : print ( 1032 ) ;
                 11 : print ( 1033 ) ;
                 others : print ( 1034 )
               End ;
          29 : If m = 16 Then print ( 1059 )
               Else print ( 1058 ) ;
          others : print ( 602 )
        End ;
      End ;
      Procedure showmacro ( p : halfword ; q , l : integer ) ;

      Label 10 ;

      Var r : halfword ;
      Begin
        p := mem [ p ] . hh . rh ;
        While mem [ p ] . hh . lh > 7 Do
          Begin
            r := mem [ p ] . hh . rh ;
            mem [ p ] . hh . rh := 0 ;
            showtokenlist ( p , 0 , l , 0 ) ;
            mem [ p ] . hh . rh := r ;
            p := r ;
            If l > 0 Then l := l - tally
            Else goto 10 ;
          End ;
        tally := 0 ;
        Case mem [ p ] . hh . lh Of 
          0 : print ( 501 ) ;
          1 , 2 , 3 :
                      Begin
                        printchar ( 60 ) ;
                        printcmdmod ( 56 , mem [ p ] . hh . lh ) ;
                        print ( 502 ) ;
                      End ;
          4 : print ( 503 ) ;
          5 : print ( 504 ) ;
          6 : print ( 505 ) ;
          7 : print ( 506 ) ;
        End ;
        showtokenlist ( mem [ p ] . hh . rh , q , l - tally , 0 ) ;
        10 :
      End ;
      Procedure initbignode ( p : halfword ) ;

      Var q : halfword ;
        s : smallnumber ;
      Begin
        s := bignodesize [ mem [ p ] . hh . b0 ] ;
        q := getnode ( s ) ;
        Repeat
          s := s - 2 ;
          Begin
            If serialno > 2147483583 Then overflow ( 587 , serialno Div 64 ) ;
            mem [ q + s ] . hh . b0 := 19 ;
            serialno := serialno + 64 ;
            mem [ q + s + 1 ] . int := serialno ;
          End ;
          mem [ q + s ] . hh . b1 := ( s ) Div 2 + 5 ;
          mem [ q + s ] . hh . rh := 0 ;
        Until s = 0 ;
        mem [ q ] . hh . rh := p ;
        mem [ p + 1 ] . int := q ;
      End ;
      Function idtransform : halfword ;

      Var p , q , r : halfword ;
      Begin
        p := getnode ( 2 ) ;
        mem [ p ] . hh . b0 := 13 ;
        mem [ p ] . hh . b1 := 11 ;
        mem [ p + 1 ] . int := 0 ;
        initbignode ( p ) ;
        q := mem [ p + 1 ] . int ;
        r := q + 12 ;
        Repeat
          r := r - 2 ;
          mem [ r ] . hh . b0 := 16 ;
          mem [ r + 1 ] . int := 0 ;
        Until r = q ;
        mem [ q + 5 ] . int := 65536 ;
        mem [ q + 11 ] . int := 65536 ;
        idtransform := p ;
      End ;
      Procedure newroot ( x : halfword ) ;

      Var p : halfword ;
      Begin
        p := getnode ( 2 ) ;
        mem [ p ] . hh . b0 := 0 ;
        mem [ p ] . hh . b1 := 0 ;
        mem [ p ] . hh . rh := x ;
        eqtb [ x ] . rh := p ;
      End ;
      Procedure printvariablename ( p : halfword ) ;

      Label 40 , 10 ;

      Var q : halfword ;
        r : halfword ;
      Begin
        While mem [ p ] . hh . b1 >= 5 Do
          Begin
            Case mem [ p ] . hh . b1 Of 
              5 : printchar ( 120 ) ;
              6 : printchar ( 121 ) ;
              7 : print ( 509 ) ;
              8 : print ( 510 ) ;
              9 : print ( 511 ) ;
              10 : print ( 512 ) ;
              11 :
                   Begin
                     print ( 513 ) ;
                     printint ( p - 0 ) ;
                     goto 10 ;
                   End ;
            End ;
            print ( 514 ) ;
            p := mem [ p - 2 * ( mem [ p ] . hh . b1 - 5 ) ] . hh . rh ;
          End ;
        q := 0 ;
        While mem [ p ] . hh . b1 > 1 Do
          Begin
            If mem [ p ] . hh . b1 = 3 Then
              Begin
                r := newnumtok ( mem [ p + 2 ] . int ) ;
                Repeat
                  p := mem [ p ] . hh . rh ;
                Until mem [ p ] . hh . b1 = 4 ;
              End
            Else If mem [ p ] . hh . b1 = 2 Then
                   Begin
                     p := mem [ p ] . hh . rh ;
                     goto 40 ;
                   End
            Else
              Begin
                If mem [ p ] . hh . b1 <> 4 Then confusion ( 508 ) ;
                r := getavail ;
                mem [ r ] . hh . lh := mem [ p + 2 ] . hh . lh ;
              End ;
            mem [ r ] . hh . rh := q ;
            q := r ;
            40 : p := mem [ p + 2 ] . hh . rh ;
          End ;
        r := getavail ;
        mem [ r ] . hh . lh := mem [ p ] . hh . rh ;
        mem [ r ] . hh . rh := q ;
        If mem [ p ] . hh . b1 = 1 Then print ( 507 ) ;
        showtokenlist ( r , 0 , 2147483647 , tally ) ;
        flushtokenlist ( r ) ;
        10 :
      End ;
      Function interesting ( p : halfword ) : boolean ;

      Var t : smallnumber ;
      Begin
        If internal [ 3 ] > 0 Then interesting := true
        Else
          Begin
            t := mem [ p ] . hh . b1 ;
            If t >= 5 Then If t <> 11 Then t := mem [ mem [ p - 2 * ( t - 5 ) ] . hh . rh ] . hh . b1 ;
            interesting := ( t <> 11 ) ;
          End ;
      End ;
      Function newstructure ( p : halfword ) : halfword ;

      Var q , r : halfword ;
      Begin
        Case mem [ p ] . hh . b1 Of 
          0 :
              Begin
                q := mem [ p ] . hh . rh ;
                r := getnode ( 2 ) ;
                eqtb [ q ] . rh := r ;
              End ;
          3 :
              Begin
                q := p ;
                Repeat
                  q := mem [ q ] . hh . rh ;
                Until mem [ q ] . hh . b1 = 4 ;
                q := mem [ q + 2 ] . hh . rh ;
                r := q + 1 ;
                Repeat
                  q := r ;
                  r := mem [ r ] . hh . rh ;
                Until r = p ;
                r := getnode ( 3 ) ;
                mem [ q ] . hh . rh := r ;
                mem [ r + 2 ] . int := mem [ p + 2 ] . int ;
              End ;
          4 :
              Begin
                q := mem [ p + 2 ] . hh . rh ;
                r := mem [ q + 1 ] . hh . lh ;
                Repeat
                  q := r ;
                  r := mem [ r ] . hh . rh ;
                Until r = p ;
                r := getnode ( 3 ) ;
                mem [ q ] . hh . rh := r ;
                mem [ r + 2 ] := mem [ p + 2 ] ;
                If mem [ p + 2 ] . hh . lh = 0 Then
                  Begin
                    q := mem [ p + 2 ] . hh . rh + 1 ;
                    While mem [ q ] . hh . rh <> p Do
                      q := mem [ q ] . hh . rh ;
                    mem [ q ] . hh . rh := r ;
                  End ;
              End ;
          others : confusion ( 515 )
        End ;
        mem [ r ] . hh . rh := mem [ p ] . hh . rh ;
        mem [ r ] . hh . b0 := 21 ;
        mem [ r ] . hh . b1 := mem [ p ] . hh . b1 ;
        mem [ r + 1 ] . hh . lh := p ;
        mem [ p ] . hh . b1 := 2 ;
        q := getnode ( 3 ) ;
        mem [ p ] . hh . rh := q ;
        mem [ r + 1 ] . hh . rh := q ;
        mem [ q + 2 ] . hh . rh := r ;
        mem [ q ] . hh . b0 := 0 ;
        mem [ q ] . hh . b1 := 4 ;
        mem [ q ] . hh . rh := 17 ;
        mem [ q + 2 ] . hh . lh := 0 ;
        newstructure := r ;
      End ;
      Function findvariable ( t : halfword ) : halfword ;

      Label 10 ;

      Var p , q , r , s : halfword ;
        pp , qq , rr , ss : halfword ;
        n : integer ;
        saveword : memoryword ;
      Begin
        p := mem [ t ] . hh . lh ;
        t := mem [ t ] . hh . rh ;
        If eqtb [ p ] . lh Mod 86 <> 41 Then
          Begin
            findvariable := 0 ;
            goto 10 ;
          End ;
        If eqtb [ p ] . rh = 0 Then newroot ( p ) ;
        p := eqtb [ p ] . rh ;
        pp := p ;
        While t <> 0 Do
          Begin
            If mem [ pp ] . hh . b0 <> 21 Then
              Begin
                If mem [ pp ] . hh . b0 > 21 Then
                  Begin
                    findvariable := 0 ;
                    goto 10 ;
                  End ;
                ss := newstructure ( pp ) ;
                If p = pp Then p := ss ;
                pp := ss ;
              End ;
            If mem [ p ] . hh . b0 <> 21 Then p := newstructure ( p ) ;
            If t < himemmin Then
              Begin
                n := mem [ t + 1 ] . int ;
                pp := mem [ mem [ pp + 1 ] . hh . lh ] . hh . rh ;
                q := mem [ mem [ p + 1 ] . hh . lh ] . hh . rh ;
                saveword := mem [ q + 2 ] ;
                mem [ q + 2 ] . int := 2147483647 ;
                s := p + 1 ;
                Repeat
                  r := s ;
                  s := mem [ s ] . hh . rh ;
                Until n <= mem [ s + 2 ] . int ;
                If n = mem [ s + 2 ] . int Then p := s
                Else
                  Begin
                    p := getnode ( 3 ) ;
                    mem [ r ] . hh . rh := p ;
                    mem [ p ] . hh . rh := s ;
                    mem [ p + 2 ] . int := n ;
                    mem [ p ] . hh . b1 := 3 ;
                    mem [ p ] . hh . b0 := 0 ;
                  End ;
                mem [ q + 2 ] := saveword ;
              End
            Else
              Begin
                n := mem [ t ] . hh . lh ;
                ss := mem [ pp + 1 ] . hh . lh ;
                Repeat
                  rr := ss ;
                  ss := mem [ ss ] . hh . rh ;
                Until n <= mem [ ss + 2 ] . hh . lh ;
                If n < mem [ ss + 2 ] . hh . lh Then
                  Begin
                    qq := getnode ( 3 ) ;
                    mem [ rr ] . hh . rh := qq ;
                    mem [ qq ] . hh . rh := ss ;
                    mem [ qq + 2 ] . hh . lh := n ;
                    mem [ qq ] . hh . b1 := 4 ;
                    mem [ qq ] . hh . b0 := 0 ;
                    mem [ qq + 2 ] . hh . rh := pp ;
                    ss := qq ;
                  End ;
                If p = pp Then
                  Begin
                    p := ss ;
                    pp := ss ;
                  End
                Else
                  Begin
                    pp := ss ;
                    s := mem [ p + 1 ] . hh . lh ;
                    Repeat
                      r := s ;
                      s := mem [ s ] . hh . rh ;
                    Until n <= mem [ s + 2 ] . hh . lh ;
                    If n = mem [ s + 2 ] . hh . lh Then p := s
                    Else
                      Begin
                        q := getnode ( 3 ) ;
                        mem [ r ] . hh . rh := q ;
                        mem [ q ] . hh . rh := s ;
                        mem [ q + 2 ] . hh . lh := n ;
                        mem [ q ] . hh . b1 := 4 ;
                        mem [ q ] . hh . b0 := 0 ;
                        mem [ q + 2 ] . hh . rh := p ;
                        p := q ;
                      End ;
                  End ;
              End ;
            t := mem [ t ] . hh . rh ;
          End ;
        If mem [ pp ] . hh . b0 >= 21 Then If mem [ pp ] . hh . b0 = 21 Then pp := mem [ pp + 1 ] . hh . lh
        Else
          Begin
            findvariable := 0 ;
            goto 10 ;
          End ;
        If mem [ p ] . hh . b0 = 21 Then p := mem [ p + 1 ] . hh . lh ;
        If mem [ p ] . hh . b0 = 0 Then
          Begin
            If mem [ pp ] . hh . b0 = 0 Then
              Begin
                mem [ pp ] . hh . b0 := 15 ;
                mem [ pp + 1 ] . int := 0 ;
              End ;
            mem [ p ] . hh . b0 := mem [ pp ] . hh . b0 ;
            mem [ p + 1 ] . int := 0 ;
          End ;
        findvariable := p ;
        10 :
      End ;
      Procedure printpath ( h : halfword ; s : strnumber ; nuline : boolean ) ;

      Label 30 , 31 ;

      Var p , q : halfword ;
      Begin
        printdiagnostic ( 517 , s , nuline ) ;
        println ;
        p := h ;
        Repeat
          q := mem [ p ] . hh . rh ;
          If ( p = 0 ) Or ( q = 0 ) Then
            Begin
              printnl ( 259 ) ;
              goto 30 ;
            End ;
          printtwo ( mem [ p + 1 ] . int , mem [ p + 2 ] . int ) ;
          Case mem [ p ] . hh . b1 Of 
            0 :
                Begin
                  If mem [ p ] . hh . b0 = 4 Then print ( 518 ) ;
                  If ( mem [ q ] . hh . b0 <> 0 ) Or ( q <> h ) Then q := 0 ;
                  goto 31 ;
                End ;
            1 :
                Begin
                  print ( 524 ) ;
                  printtwo ( mem [ p + 5 ] . int , mem [ p + 6 ] . int ) ;
                  print ( 523 ) ;
                  If mem [ q ] . hh . b0 <> 1 Then print ( 525 )
                  Else printtwo ( mem [ q + 3 ] . int , mem [ q + 4 ] . int ) ;
                  goto 31 ;
                End ;
            4 : If ( mem [ p ] . hh . b0 <> 1 ) And ( mem [ p ] . hh . b0 <> 4 ) Then print ( 518 ) ;
            3 , 2 :
                    Begin
                      If mem [ p ] . hh . b0 = 4 Then print ( 525 ) ;
                      If mem [ p ] . hh . b1 = 3 Then
                        Begin
                          print ( 521 ) ;
                          printscaled ( mem [ p + 5 ] . int ) ;
                        End
                      Else
                        Begin
                          nsincos ( mem [ p + 5 ] . int ) ;
                          printchar ( 123 ) ;
                          printscaled ( ncos ) ;
                          printchar ( 44 ) ;
                          printscaled ( nsin ) ;
                        End ;
                      printchar ( 125 ) ;
                    End ;
            others : print ( 259 )
          End ;
          If mem [ q ] . hh . b0 <= 1 Then print ( 519 )
          Else If ( mem [ p + 6 ] . int <> 65536 ) Or ( mem [ q + 4 ] . int <> 65536 ) Then
                 Begin
                   print ( 522 ) ;
                   If mem [ p + 6 ] . int < 0 Then print ( 464 ) ;
                   printscaled ( abs ( mem [ p + 6 ] . int ) ) ;
                   If mem [ p + 6 ] . int <> mem [ q + 4 ] . int Then
                     Begin
                       print ( 523 ) ;
                       If mem [ q + 4 ] . int < 0 Then print ( 464 ) ;
                       printscaled ( abs ( mem [ q + 4 ] . int ) ) ;
                     End ;
                 End ;
          31 : ;
          p := q ;
          If ( p <> h ) Or ( mem [ h ] . hh . b0 <> 0 ) Then
            Begin
              printnl ( 520 ) ;
              If mem [ p ] . hh . b0 = 2 Then
                Begin
                  nsincos ( mem [ p + 3 ] . int ) ;
                  printchar ( 123 ) ;
                  printscaled ( ncos ) ;
                  printchar ( 44 ) ;
                  printscaled ( nsin ) ;
                  printchar ( 125 ) ;
                End
              Else If mem [ p ] . hh . b0 = 3 Then
                     Begin
                       print ( 521 ) ;
                       printscaled ( mem [ p + 3 ] . int ) ;
                       printchar ( 125 ) ;
                     End ;
            End ;
        Until p = h ;
        If mem [ h ] . hh . b0 <> 0 Then print ( 386 ) ;
        30 : enddiagnostic ( true ) ;
      End ;
      Procedure printweight ( q : halfword ; xoff : integer ) ;

      Var w , m : integer ;
        d : integer ;
      Begin
        d := mem [ q ] . hh . lh - 0 ;
        w := d Mod 8 ;
        m := ( d Div 8 ) - mem [ curedges + 3 ] . hh . lh ;
        If fileoffset > maxprintline - 9 Then printnl ( 32 )
        Else printchar ( 32 ) ;
        printint ( m + xoff ) ;
        While w > 4 Do
          Begin
            printchar ( 43 ) ;
            w := w - 1 ;
          End ;
        While w < 4 Do
          Begin
            printchar ( 45 ) ;
            w := w + 1 ;
          End ;
      End ;
      Procedure printedges ( s : strnumber ; nuline : boolean ; xoff , yoff : integer ) ;

      Var p , q , r : halfword ;
        n : integer ;
      Begin
        printdiagnostic ( 532 , s , nuline ) ;
        p := mem [ curedges ] . hh . lh ;
        n := mem [ curedges + 1 ] . hh . rh - 4096 ;
        While p <> curedges Do
          Begin
            q := mem [ p + 1 ] . hh . lh ;
            r := mem [ p + 1 ] . hh . rh ;
            If ( q > 1 ) Or ( r <> 30000 ) Then
              Begin
                printnl ( 533 ) ;
                printint ( n + yoff ) ;
                printchar ( 58 ) ;
                While q > 1 Do
                  Begin
                    printweight ( q , xoff ) ;
                    q := mem [ q ] . hh . rh ;
                  End ;
                print ( 534 ) ;
                While r <> 30000 Do
                  Begin
                    printweight ( r , xoff ) ;
                    r := mem [ r ] . hh . rh ;
                  End ;
              End ;
            p := mem [ p ] . hh . lh ;
            n := n - 1 ;
          End ;
        enddiagnostic ( true ) ;
      End ;
      Procedure unskew ( x , y : scaled ; octant : smallnumber ) ;
      Begin
        Case octant Of 
          1 :
              Begin
                curx := x + y ;
                cury := y ;
              End ;
          5 :
              Begin
                curx := y ;
                cury := x + y ;
              End ;
          6 :
              Begin
                curx := - y ;
                cury := x + y ;
              End ;
          2 :
              Begin
                curx := - x - y ;
                cury := y ;
              End ;
          4 :
              Begin
                curx := - x - y ;
                cury := - y ;
              End ;
          8 :
              Begin
                curx := - y ;
                cury := - x - y ;
              End ;
          7 :
              Begin
                curx := y ;
                cury := - x - y ;
              End ;
          3 :
              Begin
                curx := x + y ;
                cury := - y ;
              End ;
        End ;
      End ;
      Procedure printpen ( p : halfword ; s : strnumber ; nuline : boolean ) ;

      Var nothingprinted : boolean ;
        k : 1 .. 8 ;
        h : halfword ;
        m , n : integer ;
        w , ww : halfword ;
      Begin
        printdiagnostic ( 569 , s , nuline ) ;
        nothingprinted := true ;
        println ;
        For k := 1 To 8 Do
          Begin
            octant := octantcode [ k ] ;
            h := p + octant ;
            n := mem [ h ] . hh . lh ;
            w := mem [ h ] . hh . rh ;
            If Not odd ( k ) Then w := mem [ w ] . hh . lh ;
            For m := 1 To n + 1 Do
              Begin
                If odd ( k ) Then ww := mem [ w ] . hh . rh
                Else ww := mem [ w ] . hh . lh ;
                If ( mem [ ww + 1 ] . int <> mem [ w + 1 ] . int ) Or ( mem [ ww + 2 ] . int <> mem [ w + 2 ] . int ) Then
                  Begin
                    If nothingprinted Then nothingprinted := false
                    Else printnl ( 571 ) ;
                    unskew ( mem [ ww + 1 ] . int , mem [ ww + 2 ] . int , octant ) ;
                    printtwo ( curx , cury ) ;
                  End ;
                w := ww ;
              End ;
          End ;
        If nothingprinted Then
          Begin
            w := mem [ p + 1 ] . hh . rh ;
            printtwo ( mem [ w + 1 ] . int + mem [ w + 2 ] . int , mem [ w + 2 ] . int ) ;
          End ;
        printnl ( 570 ) ;
        enddiagnostic ( true ) ;
      End ;
      Procedure printdependency ( p : halfword ; t : smallnumber ) ;

      Label 10 ;

      Var v : integer ;
        pp , q : halfword ;
      Begin
        pp := p ;
        While true Do
          Begin
            v := abs ( mem [ p + 1 ] . int ) ;
            q := mem [ p ] . hh . lh ;
            If q = 0 Then
              Begin
                If ( v <> 0 ) Or ( p = pp ) Then
                  Begin
                    If mem [ p + 1 ] . int > 0 Then If p <> pp Then printchar ( 43 ) ;
                    printscaled ( mem [ p + 1 ] . int ) ;
                  End ;
                goto 10 ;
              End ;
            If mem [ p + 1 ] . int < 0 Then printchar ( 45 )
            Else If p <> pp Then printchar ( 43 ) ;
            If t = 17 Then v := roundfraction ( v ) ;
            If v <> 65536 Then printscaled ( v ) ;
            If mem [ q ] . hh . b0 <> 19 Then confusion ( 588 ) ;
            printvariablename ( q ) ;
            v := mem [ q + 1 ] . int Mod 64 ;
            While v > 0 Do
              Begin
                print ( 589 ) ;
                v := v - 2 ;
              End ;
            p := mem [ p ] . hh . rh ;
          End ;
        10 :
      End ;
      Procedure printdp ( t : smallnumber ; p : halfword ; verbosity : smallnumber ) ;

      Var q : halfword ;
      Begin
        q := mem [ p ] . hh . rh ;
        If ( mem [ q ] . hh . lh = 0 ) Or ( verbosity > 0 ) Then printdependency ( p , t )
        Else print ( 764 ) ;
      End ;
      Function stashcurexp : halfword ;

      Var p : halfword ;
      Begin
        Case curtype Of 
          3 , 5 , 7 , 12 , 10 , 13 , 14 , 17 , 18 , 19 : p := curexp ;
          others :
                   Begin
                     p := getnode ( 2 ) ;
                     mem [ p ] . hh . b1 := 11 ;
                     mem [ p ] . hh . b0 := curtype ;
                     mem [ p + 1 ] . int := curexp ;
                   End
        End ;
        curtype := 1 ;
        mem [ p ] . hh . rh := 1 ;
        stashcurexp := p ;
      End ;
      Procedure unstashcurexp ( p : halfword ) ;
      Begin
        curtype := mem [ p ] . hh . b0 ;
        Case curtype Of 
          3 , 5 , 7 , 12 , 10 , 13 , 14 , 17 , 18 , 19 : curexp := p ;
          others :
                   Begin
                     curexp := mem [ p + 1 ] . int ;
                     freenode ( p , 2 ) ;
                   End
        End ;
      End ;
      Procedure printexp ( p : halfword ; verbosity : smallnumber ) ;

      Var restorecurexp : boolean ;
        t : smallnumber ;
        v : integer ;
        q : halfword ;
      Begin
        If p <> 0 Then restorecurexp := false
        Else
          Begin
            p := stashcurexp ;
            restorecurexp := true ;
          End ;
        t := mem [ p ] . hh . b0 ;
        If t < 17 Then v := mem [ p + 1 ] . int
        Else If t < 19 Then v := mem [ p + 1 ] . hh . rh ;
        Case t Of 
          1 : print ( 324 ) ;
          2 : If v = 30 Then print ( 348 )
              Else print ( 349 ) ;
          3 , 5 , 7 , 12 , 10 , 15 :
                                     Begin
                                       printtype ( t ) ;
                                       If v <> 0 Then
                                         Begin
                                           printchar ( 32 ) ;
                                           While ( mem [ v ] . hh . b1 = 11 ) And ( v <> p ) Do
                                             v := mem [ v + 1 ] . int ;
                                           printvariablename ( v ) ;
                                         End ;
                                     End ;
          4 :
              Begin
                printchar ( 34 ) ;
                slowprint ( v ) ;
                printchar ( 34 ) ;
              End ;
          6 , 8 , 9 , 11 : If verbosity <= 1 Then printtype ( t )
                           Else
                             Begin
                               If selector = 3 Then If internal [ 13 ] <= 0 Then
                                                      Begin
                                                        selector := 1 ;
                                                        printtype ( t ) ;
                                                        print ( 762 ) ;
                                                        selector := 3 ;
                                                      End ;
                               Case t Of 
                                 6 : printpen ( v , 285 , false ) ;
                                 8 : printpath ( v , 763 , false ) ;
                                 9 : printpath ( v , 285 , false ) ;
                                 11 :
                                      Begin
                                        curedges := v ;
                                        printedges ( 285 , false , 0 , 0 ) ;
                                      End ;
                               End ;
                             End ;
          13 , 14 : If v = 0 Then printtype ( t )
                    Else
                      Begin
                        printchar ( 40 ) ;
                        q := v + bignodesize [ t ] ;
                        Repeat
                          If mem [ v ] . hh . b0 = 16 Then printscaled ( mem [ v + 1 ] . int )
                          Else If mem [ v ] . hh . b0 = 19 Then printvariablename ( v )
                          Else printdp ( mem [ v ] . hh . b0 , mem [ v + 1 ] . hh . rh , verbosity ) ;
                          v := v + 2 ;
                          If v <> q Then printchar ( 44 ) ;
                        Until v = q ;
                        printchar ( 41 ) ;
                      End ;
          16 : printscaled ( v ) ;
          17 , 18 : printdp ( t , v , verbosity ) ;
          19 : printvariablename ( p ) ;
          others : confusion ( 761 )
        End ;
        If restorecurexp Then unstashcurexp ( p ) ;
      End ;
      Procedure disperr ( p : halfword ; s : strnumber ) ;
      Begin
        If interaction = 3 Then ;
        printnl ( 765 ) ;
        printexp ( p , 1 ) ;
        If s <> 285 Then
          Begin
            printnl ( 261 ) ;
            print ( s ) ;
          End ;
      End ;
      Function pplusfq ( p : halfword ; f : integer ; q : halfword ; t , tt : smallnumber ) : halfword ;

      Label 30 ;

      Var pp , qq : halfword ;
        r , s : halfword ;
        threshold : integer ;
        v : integer ;
      Begin
        If t = 17 Then threshold := 2685
        Else threshold := 8 ;
        r := 29999 ;
        pp := mem [ p ] . hh . lh ;
        qq := mem [ q ] . hh . lh ;
        While true Do
          If pp = qq Then If pp = 0 Then goto 30
          Else
            Begin
              If tt = 17 Then v := mem [ p + 1 ] . int + takefraction ( f , mem [ q + 1 ] . int )
              Else v := mem [ p + 1 ] . int + takescaled ( f , mem [ q + 1 ] . int ) ;
              mem [ p + 1 ] . int := v ;
              s := p ;
              p := mem [ p ] . hh . rh ;
              If abs ( v ) < threshold Then freenode ( s , 2 )
              Else
                Begin
                  If abs ( v ) >= 626349397 Then If watchcoefs Then
                                                   Begin
                                                     mem [ qq ] . hh . b0 := 0 ;
                                                     fixneeded := true ;
                                                   End ;
                  mem [ r ] . hh . rh := s ;
                  r := s ;
                End ;
              pp := mem [ p ] . hh . lh ;
              q := mem [ q ] . hh . rh ;
              qq := mem [ q ] . hh . lh ;
            End
          Else If mem [ pp + 1 ] . int < mem [ qq + 1 ] . int Then
                 Begin
                   If tt = 17 Then v := takefraction ( f , mem [ q + 1 ] . int )
                   Else v := takescaled ( f , mem [ q + 1 ] . int ) ;
                   If abs ( v ) > ( threshold ) Div 2 Then
                     Begin
                       s := getnode ( 2 ) ;
                       mem [ s ] . hh . lh := qq ;
                       mem [ s + 1 ] . int := v ;
                       If abs ( v ) >= 626349397 Then If watchcoefs Then
                                                        Begin
                                                          mem [ qq ] . hh . b0 := 0 ;
                                                          fixneeded := true ;
                                                        End ;
                       mem [ r ] . hh . rh := s ;
                       r := s ;
                     End ;
                   q := mem [ q ] . hh . rh ;
                   qq := mem [ q ] . hh . lh ;
                 End
          Else
            Begin
              mem [ r ] . hh . rh := p ;
              r := p ;
              p := mem [ p ] . hh . rh ;
              pp := mem [ p ] . hh . lh ;
            End ;
        30 : If t = 17 Then mem [ p + 1 ] . int := slowadd ( mem [ p + 1 ] . int , takefraction ( mem [ q + 1 ] . int , f ) )
             Else mem [ p + 1 ] . int := slowadd ( mem [ p + 1 ] . int , takescaled ( mem [ q + 1 ] . int , f ) ) ;
        mem [ r ] . hh . rh := p ;
        depfinal := p ;
        pplusfq := mem [ 29999 ] . hh . rh ;
      End ;
      Function poverv ( p : halfword ; v : scaled ; t0 , t1 : smallnumber ) : halfword ;

      Var r , s : halfword ;
        w : integer ;
        threshold : integer ;
        scalingdown : boolean ;
      Begin
        If t0 <> t1 Then scalingdown := true
        Else scalingdown := false ;
        If t1 = 17 Then threshold := 1342
        Else threshold := 4 ;
        r := 29999 ;
        While mem [ p ] . hh . lh <> 0 Do
          Begin
            If scalingdown Then If abs ( v ) < 524288 Then w := makescaled ( mem [ p + 1 ] . int , v * 4096 )
            Else w := makescaled ( roundfraction ( mem [ p + 1 ] . int ) , v )
            Else w := makescaled ( mem [ p + 1 ] . int , v ) ;
            If abs ( w ) <= threshold Then
              Begin
                s := mem [ p ] . hh . rh ;
                freenode ( p , 2 ) ;
                p := s ;
              End
            Else
              Begin
                If abs ( w ) >= 626349397 Then
                  Begin
                    fixneeded := true ;
                    mem [ mem [ p ] . hh . lh ] . hh . b0 := 0 ;
                  End ;
                mem [ r ] . hh . rh := p ;
                r := p ;
                mem [ p + 1 ] . int := w ;
                p := mem [ p ] . hh . rh ;
              End ;
          End ;
        mem [ r ] . hh . rh := p ;
        mem [ p + 1 ] . int := makescaled ( mem [ p + 1 ] . int , v ) ;
        poverv := mem [ 29999 ] . hh . rh ;
      End ;
      Procedure valtoobig ( x : scaled ) ;
      Begin
        If internal [ 40 ] > 0 Then
          Begin
            Begin
              If interaction = 3 Then ;
              printnl ( 261 ) ;
              print ( 590 ) ;
            End ;
            printscaled ( x ) ;
            printchar ( 41 ) ;
            Begin
              helpptr := 4 ;
              helpline [ 3 ] := 591 ;
              helpline [ 2 ] := 592 ;
              helpline [ 1 ] := 593 ;
              helpline [ 0 ] := 594 ;
            End ;
            error ;
          End ;
      End ;
      Procedure makeknown ( p , q : halfword ) ;

      Var t : 17 .. 18 ;
      Begin
        mem [ mem [ q ] . hh . rh + 1 ] . hh . lh := mem [ p + 1 ] . hh . lh ;
        mem [ mem [ p + 1 ] . hh . lh ] . hh . rh := mem [ q ] . hh . rh ;
        t := mem [ p ] . hh . b0 ;
        mem [ p ] . hh . b0 := 16 ;
        mem [ p + 1 ] . int := mem [ q + 1 ] . int ;
        freenode ( q , 2 ) ;
        If abs ( mem [ p + 1 ] . int ) >= 268435456 Then valtoobig ( mem [ p + 1 ] . int ) ;
        If internal [ 2 ] > 0 Then If interesting ( p ) Then
                                     Begin
                                       begindiagnostic ;
                                       printnl ( 595 ) ;
                                       printvariablename ( p ) ;
                                       printchar ( 61 ) ;
                                       printscaled ( mem [ p + 1 ] . int ) ;
                                       enddiagnostic ( false ) ;
                                     End ;
        If curexp = p Then If curtype = t Then
                             Begin
                               curtype := 16 ;
                               curexp := mem [ p + 1 ] . int ;
                               freenode ( p , 2 ) ;
                             End ;
      End ;
      Procedure fixdependencies ;

      Label 30 ;

      Var p , q , r , s , t : halfword ;
        x : halfword ;
      Begin
        r := mem [ 13 ] . hh . rh ;
        s := 0 ;
        While r <> 13 Do
          Begin
            t := r ;
            r := t + 1 ;
            While true Do
              Begin
                q := mem [ r ] . hh . rh ;
                x := mem [ q ] . hh . lh ;
                If x = 0 Then goto 30 ;
                If mem [ x ] . hh . b0 <= 1 Then
                  Begin
                    If mem [ x ] . hh . b0 < 1 Then
                      Begin
                        p := getavail ;
                        mem [ p ] . hh . rh := s ;
                        s := p ;
                        mem [ s ] . hh . lh := x ;
                        mem [ x ] . hh . b0 := 1 ;
                      End ;
                    mem [ q + 1 ] . int := mem [ q + 1 ] . int Div 4 ;
                    If mem [ q + 1 ] . int = 0 Then
                      Begin
                        mem [ r ] . hh . rh := mem [ q ] . hh . rh ;
                        freenode ( q , 2 ) ;
                        q := r ;
                      End ;
                  End ;
                r := q ;
              End ;
            30 : ;
            r := mem [ q ] . hh . rh ;
            If q = mem [ t + 1 ] . hh . rh Then makeknown ( t , q ) ;
          End ;
        While s <> 0 Do
          Begin
            p := mem [ s ] . hh . rh ;
            x := mem [ s ] . hh . lh ;
            Begin
              mem [ s ] . hh . rh := avail ;
              avail := s ;
            End ;
            s := p ;
            mem [ x ] . hh . b0 := 19 ;
            mem [ x + 1 ] . int := mem [ x + 1 ] . int + 2 ;
          End ;
        fixneeded := false ;
      End ;
      Procedure tossknotlist ( p : halfword ) ;

      Var q : halfword ;
        r : halfword ;
      Begin
        q := p ;
        Repeat
          r := mem [ q ] . hh . rh ;
          freenode ( q , 7 ) ;
          q := r ;
        Until q = p ;
      End ;
      Procedure tossedges ( h : halfword ) ;

      Var p , q : halfword ;
      Begin
        q := mem [ h ] . hh . rh ;
        While q <> h Do
          Begin
            flushlist ( mem [ q + 1 ] . hh . rh ) ;
            If mem [ q + 1 ] . hh . lh > 1 Then flushlist ( mem [ q + 1 ] . hh . lh ) ;
            p := q ;
            q := mem [ q ] . hh . rh ;
            freenode ( p , 2 ) ;
          End ;
        freenode ( h , 6 ) ;
      End ;
      Procedure tosspen ( p : halfword ) ;

      Var k : 1 .. 8 ;
        w , ww : halfword ;
      Begin
        If p <> 3 Then
          Begin
            For k := 1 To 8 Do
              Begin
                w := mem [ p + k ] . hh . rh ;
                Repeat
                  ww := mem [ w ] . hh . rh ;
                  freenode ( w , 3 ) ;
                  w := ww ;
                Until w = mem [ p + k ] . hh . rh ;
              End ;
            freenode ( p , 10 ) ;
          End ;
      End ;
      Procedure ringdelete ( p : halfword ) ;

      Var q : halfword ;
      Begin
        q := mem [ p + 1 ] . int ;
        If q <> 0 Then If q <> p Then
                         Begin
                           While mem [ q + 1 ] . int <> p Do
                             q := mem [ q + 1 ] . int ;
                           mem [ q + 1 ] . int := mem [ p + 1 ] . int ;
                         End ;
      End ;
      Procedure recyclevalue ( p : halfword ) ;

      Label 30 ;

      Var t : smallnumber ;
        v : integer ;
        vv : integer ;
        q , r , s , pp : halfword ;
      Begin
        t := mem [ p ] . hh . b0 ;
        If t < 17 Then v := mem [ p + 1 ] . int ;
        Case t Of 
          0 , 1 , 2 , 16 , 15 : ;
          3 , 5 , 7 , 12 , 10 : ringdelete ( p ) ;
          4 :
              Begin
                If strref [ v ] < 127 Then If strref [ v ] > 1 Then strref [ v ] := strref [ v ] - 1
                Else flushstring ( v ) ;
              End ;
          6 : If mem [ v ] . hh . lh = 0 Then tosspen ( v )
              Else mem [ v ] . hh . lh := mem [ v ] . hh . lh - 1 ;
          9 , 8 : tossknotlist ( v ) ;
          11 : tossedges ( v ) ;
          14 , 13 : If v <> 0 Then
                      Begin
                        q := v + bignodesize [ t ] ;
                        Repeat
                          q := q - 2 ;
                          recyclevalue ( q ) ;
                        Until q = v ;
                        freenode ( v , bignodesize [ t ] ) ;
                      End ;
          17 , 18 :
                    Begin
                      q := mem [ p + 1 ] . hh . rh ;
                      While mem [ q ] . hh . lh <> 0 Do
                        q := mem [ q ] . hh . rh ;
                      mem [ mem [ p + 1 ] . hh . lh ] . hh . rh := mem [ q ] . hh . rh ;
                      mem [ mem [ q ] . hh . rh + 1 ] . hh . lh := mem [ p + 1 ] . hh . lh ;
                      mem [ q ] . hh . rh := 0 ;
                      flushnodelist ( mem [ p + 1 ] . hh . rh ) ;
                    End ;
          19 :
               Begin
                 maxc [ 17 ] := 0 ;
                 maxc [ 18 ] := 0 ;
                 maxlink [ 17 ] := 0 ;
                 maxlink [ 18 ] := 0 ;
                 q := mem [ 13 ] . hh . rh ;
                 While q <> 13 Do
                   Begin
                     s := q + 1 ;
                     While true Do
                       Begin
                         r := mem [ s ] . hh . rh ;
                         If mem [ r ] . hh . lh = 0 Then goto 30 ;
                         If mem [ r ] . hh . lh <> p Then s := r
                         Else
                           Begin
                             t := mem [ q ] . hh . b0 ;
                             mem [ s ] . hh . rh := mem [ r ] . hh . rh ;
                             mem [ r ] . hh . lh := q ;
                             If abs ( mem [ r + 1 ] . int ) > maxc [ t ] Then
                               Begin
                                 If maxc [ t ] > 0 Then
                                   Begin
                                     mem [ maxptr [ t ] ] . hh . rh := maxlink [ t ] ;
                                     maxlink [ t ] := maxptr [ t ] ;
                                   End ;
                                 maxc [ t ] := abs ( mem [ r + 1 ] . int ) ;
                                 maxptr [ t ] := r ;
                               End
                             Else
                               Begin
                                 mem [ r ] . hh . rh := maxlink [ t ] ;
                                 maxlink [ t ] := r ;
                               End ;
                           End ;
                       End ;
                     30 : q := mem [ r ] . hh . rh ;
                   End ;
                 If ( maxc [ 17 ] > 0 ) Or ( maxc [ 18 ] > 0 ) Then
                   Begin
                     If ( maxc [ 17 ] Div 4096 >= maxc [ 18 ] ) Then t := 17
                     Else t := 18 ;
                     s := maxptr [ t ] ;
                     pp := mem [ s ] . hh . lh ;
                     v := mem [ s + 1 ] . int ;
                     If t = 17 Then mem [ s + 1 ] . int := - 268435456
                     Else mem [ s + 1 ] . int := - 65536 ;
                     r := mem [ pp + 1 ] . hh . rh ;
                     mem [ s ] . hh . rh := r ;
                     While mem [ r ] . hh . lh <> 0 Do
                       r := mem [ r ] . hh . rh ;
                     q := mem [ r ] . hh . rh ;
                     mem [ r ] . hh . rh := 0 ;
                     mem [ q + 1 ] . hh . lh := mem [ pp + 1 ] . hh . lh ;
                     mem [ mem [ pp + 1 ] . hh . lh ] . hh . rh := q ;
                     Begin
                       If serialno > 2147483583 Then overflow ( 587 , serialno Div 64 ) ;
                       mem [ pp ] . hh . b0 := 19 ;
                       serialno := serialno + 64 ;
                       mem [ pp + 1 ] . int := serialno ;
                     End ;
                     If curexp = pp Then If curtype = t Then curtype := 19 ;
                     If internal [ 2 ] > 0 Then If interesting ( p ) Then
                                                  Begin
                                                    begindiagnostic ;
                                                    printnl ( 767 ) ;
                                                    If v > 0 Then printchar ( 45 ) ;
                                                    If t = 17 Then vv := roundfraction ( maxc [ 17 ] )
                                                    Else vv := maxc [ 18 ] ;
                                                    If vv <> 65536 Then printscaled ( vv ) ;
                                                    printvariablename ( p ) ;
                                                    While mem [ p + 1 ] . int Mod 64 > 0 Do
                                                      Begin
                                                        print ( 589 ) ;
                                                        mem [ p + 1 ] . int := mem [ p + 1 ] . int - 2 ;
                                                      End ;
                                                    If t = 17 Then printchar ( 61 )
                                                    Else print ( 768 ) ;
                                                    printdependency ( s , t ) ;
                                                    enddiagnostic ( false ) ;
                                                  End ;
                     t := 35 - t ;
                     If maxc [ t ] > 0 Then
                       Begin
                         mem [ maxptr [ t ] ] . hh . rh := maxlink [ t ] ;
                         maxlink [ t ] := maxptr [ t ] ;
                       End ;
                     If t <> 17 Then For t := 17 To 18 Do
                                       Begin
                                         r := maxlink [ t ] ;
                                         While r <> 0 Do
                                           Begin
                                             q := mem [ r ] . hh . lh ;
                                             mem [ q + 1 ] . hh . rh := pplusfq ( mem [ q + 1 ] . hh . rh , makefraction ( mem [ r + 1 ] . int , - v ) , s , t , 17 ) ;
                                             If mem [ q + 1 ] . hh . rh = depfinal Then makeknown ( q , depfinal ) ;
                                             q := r ;
                                             r := mem [ r ] . hh . rh ;
                                             freenode ( q , 2 ) ;
                                           End ;
                                       End
                                       Else For t := 17 To 18 Do
                                              Begin
                                                r := maxlink [ t ] ;
                                                While r <> 0 Do
                                                  Begin
                                                    q := mem [ r ] . hh . lh ;
                                                    If t = 17 Then
                                                      Begin
                                                        If curexp = q Then If curtype = 17 Then curtype := 18 ;
                                                        mem [ q + 1 ] . hh . rh := poverv ( mem [ q + 1 ] . hh . rh , 65536 , 17 , 18 ) ;
                                                        mem [ q ] . hh . b0 := 18 ;
                                                        mem [ r + 1 ] . int := roundfraction ( mem [ r + 1 ] . int ) ;
                                                      End ;
                                                    mem [ q + 1 ] . hh . rh := pplusfq ( mem [ q + 1 ] . hh . rh , makescaled ( mem [ r + 1 ] . int , - v ) , s , 18 , 18 ) ;
                                                    If mem [ q + 1 ] . hh . rh = depfinal Then makeknown ( q , depfinal ) ;
                                                    q := r ;
                                                    r := mem [ r ] . hh . rh ;
                                                    freenode ( q , 2 ) ;
                                                  End ;
                                              End ;
                     flushnodelist ( s ) ;
                     If fixneeded Then fixdependencies ;
                     Begin
                       If aritherror Then cleararith ;
                     End ;
                   End ;
               End ;
          20 , 21 : confusion ( 766 ) ;
          22 , 23 : deletemacref ( mem [ p + 1 ] . int ) ;
        End ;
        mem [ p ] . hh . b0 := 0 ;
      End ;
      Procedure flushcurexp ( v : scaled ) ;
      Begin
        Case curtype Of 
          3 , 5 , 7 , 12 , 10 , 13 , 14 , 17 , 18 , 19 :
                                                         Begin
                                                           recyclevalue ( curexp ) ;
                                                           freenode ( curexp , 2 ) ;
                                                         End ;
          6 : If mem [ curexp ] . hh . lh = 0 Then tosspen ( curexp )
              Else mem [ curexp ] . hh . lh := mem [ curexp ] . hh . lh - 1 ;
          4 :
              Begin
                If strref [ curexp ] < 127 Then If strref [ curexp ] > 1 Then strref [ curexp ] := strref [ curexp ] - 1
                Else flushstring ( curexp ) ;
              End ;
          8 , 9 : tossknotlist ( curexp ) ;
          11 : tossedges ( curexp ) ;
          others :
        End ;
        curtype := 16 ;
        curexp := v ;
      End ;
      Procedure flusherror ( v : scaled ) ;
      Begin
        error ;
        flushcurexp ( v ) ;
      End ;
      Procedure backerror ;
      forward ;
      Procedure getxnext ;
      forward ;
      Procedure putgeterror ;
      Begin
        backerror ;
        getxnext ;
      End ;
      Procedure putgetflusherror ( v : scaled ) ;
      Begin
        putgeterror ;
        flushcurexp ( v ) ;
      End ;
      Procedure flushbelowvariable ( p : halfword ) ;

      Var q , r : halfword ;
      Begin
        If mem [ p ] . hh . b0 <> 21 Then recyclevalue ( p )
        Else
          Begin
            q := mem [ p + 1 ] . hh . rh ;
            While mem [ q ] . hh . b1 = 3 Do
              Begin
                flushbelowvariable ( q ) ;
                r := q ;
                q := mem [ q ] . hh . rh ;
                freenode ( r , 3 ) ;
              End ;
            r := mem [ p + 1 ] . hh . lh ;
            q := mem [ r ] . hh . rh ;
            recyclevalue ( r ) ;
            If mem [ p ] . hh . b1 <= 1 Then freenode ( r , 2 )
            Else freenode ( r , 3 ) ;
            Repeat
              flushbelowvariable ( q ) ;
              r := q ;
              q := mem [ q ] . hh . rh ;
              freenode ( r , 3 ) ;
            Until q = 17 ;
            mem [ p ] . hh . b0 := 0 ;
          End ;
      End ;
      Procedure flushvariable ( p , t : halfword ; discardsuffixes : boolean ) ;

      Label 10 ;

      Var q , r : halfword ;
        n : halfword ;
      Begin
        While t <> 0 Do
          Begin
            If mem [ p ] . hh . b0 <> 21 Then goto 10 ;
            n := mem [ t ] . hh . lh ;
            t := mem [ t ] . hh . rh ;
            If n = 0 Then
              Begin
                r := p + 1 ;
                q := mem [ r ] . hh . rh ;
                While mem [ q ] . hh . b1 = 3 Do
                  Begin
                    flushvariable ( q , t , discardsuffixes ) ;
                    If t = 0 Then If mem [ q ] . hh . b0 = 21 Then r := q
                    Else
                      Begin
                        mem [ r ] . hh . rh := mem [ q ] . hh . rh ;
                        freenode ( q , 3 ) ;
                      End
                    Else r := q ;
                    q := mem [ r ] . hh . rh ;
                  End ;
              End ;
            p := mem [ p + 1 ] . hh . lh ;
            Repeat
              r := p ;
              p := mem [ p ] . hh . rh ;
            Until mem [ p + 2 ] . hh . lh >= n ;
            If mem [ p + 2 ] . hh . lh <> n Then goto 10 ;
          End ;
        If discardsuffixes Then flushbelowvariable ( p )
        Else
          Begin
            If mem [ p ] . hh . b0 = 21 Then p := mem [ p + 1 ] . hh . lh ;
            recyclevalue ( p ) ;
          End ;
        10 :
      End ;
      Function undtype ( p : halfword ) : smallnumber ;
      Begin
        Case mem [ p ] . hh . b0 Of 
          0 , 1 : undtype := 0 ;
          2 , 3 : undtype := 3 ;
          4 , 5 : undtype := 5 ;
          6 , 7 , 8 : undtype := 7 ;
          9 , 10 : undtype := 10 ;
          11 , 12 : undtype := 12 ;
          13 , 14 , 15 : undtype := mem [ p ] . hh . b0 ;
          16 , 17 , 18 , 19 : undtype := 15 ;
        End ;
      End ;
      Procedure clearsymbol ( p : halfword ; saving : boolean ) ;

      Var q : halfword ;
      Begin
        q := eqtb [ p ] . rh ;
        Case eqtb [ p ] . lh Mod 86 Of 
          10 , 53 , 44 , 49 : If Not saving Then deletemacref ( q ) ;
          41 : If q <> 0 Then If saving Then mem [ q ] . hh . b1 := 1
               Else
                 Begin
                   flushbelowvariable ( q ) ;
                   freenode ( q , 2 ) ;
                 End ;
          others :
        End ;
        eqtb [ p ] := eqtb [ 2369 ] ;
      End ;
      Procedure savevariable ( q : halfword ) ;

      Var p : halfword ;
      Begin
        If saveptr <> 0 Then
          Begin
            p := getnode ( 2 ) ;
            mem [ p ] . hh . lh := q ;
            mem [ p ] . hh . rh := saveptr ;
            mem [ p + 1 ] . hh := eqtb [ q ] ;
            saveptr := p ;
          End ;
        clearsymbol ( q , ( saveptr <> 0 ) ) ;
      End ;
      Procedure saveinternal ( q : halfword ) ;

      Var p : halfword ;
      Begin
        If saveptr <> 0 Then
          Begin
            p := getnode ( 2 ) ;
            mem [ p ] . hh . lh := 2369 + q ;
            mem [ p ] . hh . rh := saveptr ;
            mem [ p + 1 ] . int := internal [ q ] ;
            saveptr := p ;
          End ;
      End ;
      Procedure unsave ;

      Var q : halfword ;
        p : halfword ;
      Begin
        While mem [ saveptr ] . hh . lh <> 0 Do
          Begin
            q := mem [ saveptr ] . hh . lh ;
            If q > 2369 Then
              Begin
                If internal [ 8 ] > 0 Then
                  Begin
                    begindiagnostic ;
                    printnl ( 516 ) ;
                    slowprint ( intname [ q - ( 2369 ) ] ) ;
                    printchar ( 61 ) ;
                    printscaled ( mem [ saveptr + 1 ] . int ) ;
                    printchar ( 125 ) ;
                    enddiagnostic ( false ) ;
                  End ;
                internal [ q - ( 2369 ) ] := mem [ saveptr + 1 ] . int ;
              End
            Else
              Begin
                If internal [ 8 ] > 0 Then
                  Begin
                    begindiagnostic ;
                    printnl ( 516 ) ;
                    slowprint ( hash [ q ] . rh ) ;
                    printchar ( 125 ) ;
                    enddiagnostic ( false ) ;
                  End ;
                clearsymbol ( q , false ) ;
                eqtb [ q ] := mem [ saveptr + 1 ] . hh ;
                If eqtb [ q ] . lh Mod 86 = 41 Then
                  Begin
                    p := eqtb [ q ] . rh ;
                    If p <> 0 Then mem [ p ] . hh . b1 := 0 ;
                  End ;
              End ;
            p := mem [ saveptr ] . hh . rh ;
            freenode ( saveptr , 2 ) ;
            saveptr := p ;
          End ;
        p := mem [ saveptr ] . hh . rh ;
        Begin
          mem [ saveptr ] . hh . rh := avail ;
          avail := saveptr ;
        End ;
        saveptr := p ;
      End ;
      Function copyknot ( p : halfword ) : halfword ;

      Var q : halfword ;
        k : 0 .. 6 ;
      Begin
        q := getnode ( 7 ) ;
        For k := 0 To 6 Do
          mem [ q + k ] := mem [ p + k ] ;
        copyknot := q ;
      End ;
      Function copypath ( p : halfword ) : halfword ;

      Label 10 ;

      Var q , pp , qq : halfword ;
      Begin
        q := getnode ( 7 ) ;
        qq := q ;
        pp := p ;
        While true Do
          Begin
            mem [ qq ] . hh . b0 := mem [ pp ] . hh . b0 ;
            mem [ qq ] . hh . b1 := mem [ pp ] . hh . b1 ;
            mem [ qq + 1 ] . int := mem [ pp + 1 ] . int ;
            mem [ qq + 2 ] . int := mem [ pp + 2 ] . int ;
            mem [ qq + 3 ] . int := mem [ pp + 3 ] . int ;
            mem [ qq + 4 ] . int := mem [ pp + 4 ] . int ;
            mem [ qq + 5 ] . int := mem [ pp + 5 ] . int ;
            mem [ qq + 6 ] . int := mem [ pp + 6 ] . int ;
            If mem [ pp ] . hh . rh = p Then
              Begin
                mem [ qq ] . hh . rh := q ;
                copypath := q ;
                goto 10 ;
              End ;
            mem [ qq ] . hh . rh := getnode ( 7 ) ;
            qq := mem [ qq ] . hh . rh ;
            pp := mem [ pp ] . hh . rh ;
          End ;
        10 :
      End ;
      Function htapypoc ( p : halfword ) : halfword ;

      Label 10 ;

      Var q , pp , qq , rr : halfword ;
      Begin
        q := getnode ( 7 ) ;
        qq := q ;
        pp := p ;
        While true Do
          Begin
            mem [ qq ] . hh . b1 := mem [ pp ] . hh . b0 ;
            mem [ qq ] . hh . b0 := mem [ pp ] . hh . b1 ;
            mem [ qq + 1 ] . int := mem [ pp + 1 ] . int ;
            mem [ qq + 2 ] . int := mem [ pp + 2 ] . int ;
            mem [ qq + 5 ] . int := mem [ pp + 3 ] . int ;
            mem [ qq + 6 ] . int := mem [ pp + 4 ] . int ;
            mem [ qq + 3 ] . int := mem [ pp + 5 ] . int ;
            mem [ qq + 4 ] . int := mem [ pp + 6 ] . int ;
            If mem [ pp ] . hh . rh = p Then
              Begin
                mem [ q ] . hh . rh := qq ;
                pathtail := pp ;
                htapypoc := q ;
                goto 10 ;
              End ;
            rr := getnode ( 7 ) ;
            mem [ rr ] . hh . rh := qq ;
            qq := rr ;
            pp := mem [ pp ] . hh . rh ;
          End ;
        10 :
      End ;
      Function curlratio ( gamma , atension , btension : scaled ) : fraction ;

      Var alpha , beta , num , denom , ff : fraction ;
      Begin
        alpha := makefraction ( 65536 , atension ) ;
        beta := makefraction ( 65536 , btension ) ;
        If alpha <= beta Then
          Begin
            ff := makefraction ( alpha , beta ) ;
            ff := takefraction ( ff , ff ) ;
            gamma := takefraction ( gamma , ff ) ;
            beta := beta Div 4096 ;
            denom := takefraction ( gamma , alpha ) + 196608 - beta ;
            num := takefraction ( gamma , 805306368 - alpha ) + beta ;
          End
        Else
          Begin
            ff := makefraction ( beta , alpha ) ;
            ff := takefraction ( ff , ff ) ;
            beta := takefraction ( beta , ff ) Div 4096 ;
            denom := takefraction ( gamma , alpha ) + ( ff Div 1365 ) - beta ;
            num := takefraction ( gamma , 805306368 - alpha ) + beta ;
          End ;
        If num >= denom + denom + denom + denom Then curlratio := 1073741824
        Else curlratio := makefraction ( num , denom ) ;
      End ;
      Procedure setcontrols ( p , q : halfword ; k : integer ) ;

      Var rr , ss : fraction ;
        lt , rt : scaled ;
        sine : fraction ;
      Begin
        lt := abs ( mem [ q + 4 ] . int ) ;
        rt := abs ( mem [ p + 6 ] . int ) ;
        rr := velocity ( st , ct , sf , cf , rt ) ;
        ss := velocity ( sf , cf , st , ct , lt ) ;
        If ( mem [ p + 6 ] . int < 0 ) Or ( mem [ q + 4 ] . int < 0 ) Then If ( ( st >= 0 ) And ( sf >= 0 ) ) Or ( ( st <= 0 ) And ( sf <= 0 ) ) Then
                                                                             Begin
                                                                               sine := takefraction ( abs ( st ) , cf ) + takefraction ( abs ( sf ) , ct ) ;
                                                                               If sine > 0 Then
                                                                                 Begin
                                                                                   sine := takefraction ( sine , 268500992 ) ;
                                                                                   If mem [ p + 6 ] . int < 0 Then If abvscd ( abs ( sf ) , 268435456 , rr , sine ) < 0 Then rr := makefraction ( abs ( sf ) , sine ) ;
                                                                                   If mem [ q + 4 ] . int < 0 Then If abvscd ( abs ( st ) , 268435456 , ss , sine ) < 0 Then ss := makefraction ( abs ( st ) , sine ) ;
                                                                                 End ;
                                                                             End ;
        mem [ p + 5 ] . int := mem [ p + 1 ] . int + takefraction ( takefraction ( deltax [ k ] , ct ) - takefraction ( deltay [ k ] , st ) , rr ) ;
        mem [ p + 6 ] . int := mem [ p + 2 ] . int + takefraction ( takefraction ( deltay [ k ] , ct ) + takefraction ( deltax [ k ] , st ) , rr ) ;
        mem [ q + 3 ] . int := mem [ q + 1 ] . int - takefraction ( takefraction ( deltax [ k ] , cf ) + takefraction ( deltay [ k ] , sf ) , ss ) ;
        mem [ q + 4 ] . int := mem [ q + 2 ] . int - takefraction ( takefraction ( deltay [ k ] , cf ) - takefraction ( deltax [ k ] , sf ) , ss ) ;
        mem [ p ] . hh . b1 := 1 ;
        mem [ q ] . hh . b0 := 1 ;
      End ;
      Procedure solvechoices ( p , q : halfword ; n : halfword ) ;

      Label 40 , 10 ;

      Var k : 0 .. pathsize ;
        r , s , t : halfword ;
        aa , bb , cc , ff , acc : fraction ;
        dd , ee : scaled ;
        lt , rt : scaled ;
      Begin
        k := 0 ;
        s := p ;
        While true Do
          Begin
            t := mem [ s ] . hh . rh ;
            If k = 0 Then Case mem [ s ] . hh . b1 Of 
                            2 : If mem [ t ] . hh . b0 = 2 Then
                                  Begin
                                    aa := narg ( deltax [ 0 ] , deltay [ 0 ] ) ;
                                    nsincos ( mem [ p + 5 ] . int - aa ) ;
                                    ct := ncos ;
                                    st := nsin ;
                                    nsincos ( mem [ q + 3 ] . int - aa ) ;
                                    cf := ncos ;
                                    sf := - nsin ;
                                    setcontrols ( p , q , 0 ) ;
                                    goto 10 ;
                                  End
                                Else
                                  Begin
                                    vv [ 0 ] := mem [ s + 5 ] . int - narg ( deltax [ 0 ] , deltay [ 0 ] ) ;
                                    If abs ( vv [ 0 ] ) > 188743680 Then If vv [ 0 ] > 0 Then vv [ 0 ] := vv [ 0 ] - 377487360
                                    Else vv [ 0 ] := vv [ 0 ] + 377487360 ;
                                    uu [ 0 ] := 0 ;
                                    ww [ 0 ] := 0 ;
                                  End ;
                            3 : If mem [ t ] . hh . b0 = 3 Then
                                  Begin
                                    mem [ p ] . hh . b1 := 1 ;
                                    mem [ q ] . hh . b0 := 1 ;
                                    lt := abs ( mem [ q + 4 ] . int ) ;
                                    rt := abs ( mem [ p + 6 ] . int ) ;
                                    If rt = 65536 Then
                                      Begin
                                        If deltax [ 0 ] >= 0 Then mem [ p + 5 ] . int := mem [ p + 1 ] . int + ( ( deltax [ 0 ] + 1 ) Div 3 )
                                        Else mem [ p + 5 ] . int := mem [ p + 1 ] . int + ( ( deltax [ 0 ] - 1 ) Div 3 ) ;
                                        If deltay [ 0 ] >= 0 Then mem [ p + 6 ] . int := mem [ p + 2 ] . int + ( ( deltay [ 0 ] + 1 ) Div 3 )
                                        Else mem [ p + 6 ] . int := mem [ p + 2 ] . int + ( ( deltay [ 0 ] - 1 ) Div 3 ) ;
                                      End
                                    Else
                                      Begin
                                        ff := makefraction ( 65536 , 3 * rt ) ;
                                        mem [ p + 5 ] . int := mem [ p + 1 ] . int + takefraction ( deltax [ 0 ] , ff ) ;
                                        mem [ p + 6 ] . int := mem [ p + 2 ] . int + takefraction ( deltay [ 0 ] , ff ) ;
                                      End ;
                                    If lt = 65536 Then
                                      Begin
                                        If deltax [ 0 ] >= 0 Then mem [ q + 3 ] . int := mem [ q + 1 ] . int - ( ( deltax [ 0 ] + 1 ) Div 3 )
                                        Else mem [ q + 3 ] . int := mem [ q + 1 ] . int - ( ( deltax [ 0 ] - 1 ) Div 3 ) ;
                                        If deltay [ 0 ] >= 0 Then mem [ q + 4 ] . int := mem [ q + 2 ] . int - ( ( deltay [ 0 ] + 1 ) Div 3 )
                                        Else mem [ q + 4 ] . int := mem [ q + 2 ] . int - ( ( deltay [ 0 ] - 1 ) Div 3 ) ;
                                      End
                                    Else
                                      Begin
                                        ff := makefraction ( 65536 , 3 * lt ) ;
                                        mem [ q + 3 ] . int := mem [ q + 1 ] . int - takefraction ( deltax [ 0 ] , ff ) ;
                                        mem [ q + 4 ] . int := mem [ q + 2 ] . int - takefraction ( deltay [ 0 ] , ff ) ;
                                      End ;
                                    goto 10 ;
                                  End
                                Else
                                  Begin
                                    cc := mem [ s + 5 ] . int ;
                                    lt := abs ( mem [ t + 4 ] . int ) ;
                                    rt := abs ( mem [ s + 6 ] . int ) ;
                                    If ( rt = 65536 ) And ( lt = 65536 ) Then uu [ 0 ] := makefraction ( cc + cc + 65536 , cc + 131072 )
                                    Else uu [ 0 ] := curlratio ( cc , rt , lt ) ;
                                    vv [ 0 ] := - takefraction ( psi [ 1 ] , uu [ 0 ] ) ;
                                    ww [ 0 ] := 0 ;
                                  End ;
                            4 :
                                Begin
                                  uu [ 0 ] := 0 ;
                                  vv [ 0 ] := 0 ;
                                  ww [ 0 ] := 268435456 ;
                                End ;
              End
            Else Case mem [ s ] . hh . b0 Of 
                   5 , 4 :
                           Begin
                             If abs ( mem [ r + 6 ] . int ) = 65536 Then
                               Begin
                                 aa := 134217728 ;
                                 dd := 2 * delta [ k ] ;
                               End
                             Else
                               Begin
                                 aa := makefraction ( 65536 , 3 * abs ( mem [ r + 6 ] . int ) - 65536 ) ;
                                 dd := takefraction ( delta [ k ] , 805306368 - makefraction ( 65536 , abs ( mem [ r + 6 ] . int ) ) ) ;
                               End ;
                             If abs ( mem [ t + 4 ] . int ) = 65536 Then
                               Begin
                                 bb := 134217728 ;
                                 ee := 2 * delta [ k - 1 ] ;
                               End
                             Else
                               Begin
                                 bb := makefraction ( 65536 , 3 * abs ( mem [ t + 4 ] . int ) - 65536 ) ;
                                 ee := takefraction ( delta [ k - 1 ] , 805306368 - makefraction ( 65536 , abs ( mem [ t + 4 ] . int ) ) ) ;
                               End ;
                             cc := 268435456 - takefraction ( uu [ k - 1 ] , aa ) ;
                             dd := takefraction ( dd , cc ) ;
                             lt := abs ( mem [ s + 4 ] . int ) ;
                             rt := abs ( mem [ s + 6 ] . int ) ;
                             If lt <> rt Then If lt < rt Then
                                                Begin
                                                  ff := makefraction ( lt , rt ) ;
                                                  ff := takefraction ( ff , ff ) ;
                                                  dd := takefraction ( dd , ff ) ;
                                                End
                             Else
                               Begin
                                 ff := makefraction ( rt , lt ) ;
                                 ff := takefraction ( ff , ff ) ;
                                 ee := takefraction ( ee , ff ) ;
                               End ;
                             ff := makefraction ( ee , ee + dd ) ;
                             uu [ k ] := takefraction ( ff , bb ) ;
                             acc := - takefraction ( psi [ k + 1 ] , uu [ k ] ) ;
                             If mem [ r ] . hh . b1 = 3 Then
                               Begin
                                 ww [ k ] := 0 ;
                                 vv [ k ] := acc - takefraction ( psi [ 1 ] , 268435456 - ff ) ;
                               End
                             Else
                               Begin
                                 ff := makefraction ( 268435456 - ff , cc ) ;
                                 acc := acc - takefraction ( psi [ k ] , ff ) ;
                                 ff := takefraction ( ff , aa ) ;
                                 vv [ k ] := acc - takefraction ( vv [ k - 1 ] , ff ) ;
                                 If ww [ k - 1 ] = 0 Then ww [ k ] := 0
                                 Else ww [ k ] := - takefraction ( ww [ k - 1 ] , ff ) ;
                               End ;
                             If mem [ s ] . hh . b0 = 5 Then
                               Begin
                                 aa := 0 ;
                                 bb := 268435456 ;
                                 Repeat
                                   k := k - 1 ;
                                   If k = 0 Then k := n ;
                                   aa := vv [ k ] - takefraction ( aa , uu [ k ] ) ;
                                   bb := ww [ k ] - takefraction ( bb , uu [ k ] ) ;
                                 Until k = n ;
                                 aa := makefraction ( aa , 268435456 - bb ) ;
                                 theta [ n ] := aa ;
                                 vv [ 0 ] := aa ;
                                 For k := 1 To n - 1 Do
                                   vv [ k ] := vv [ k ] + takefraction ( aa , ww [ k ] ) ;
                                 goto 40 ;
                               End ;
                           End ;
                   3 :
                       Begin
                         cc := mem [ s + 3 ] . int ;
                         lt := abs ( mem [ s + 4 ] . int ) ;
                         rt := abs ( mem [ r + 6 ] . int ) ;
                         If ( rt = 65536 ) And ( lt = 65536 ) Then ff := makefraction ( cc + cc + 65536 , cc + 131072 )
                         Else ff := curlratio ( cc , lt , rt ) ;
                         theta [ n ] := - makefraction ( takefraction ( vv [ n - 1 ] , ff ) , 268435456 - takefraction ( ff , uu [ n - 1 ] ) ) ;
                         goto 40 ;
                       End ;
                   2 :
                       Begin
                         theta [ n ] := mem [ s + 3 ] . int - narg ( deltax [ n - 1 ] , deltay [ n - 1 ] ) ;
                         If abs ( theta [ n ] ) > 188743680 Then If theta [ n ] > 0 Then theta [ n ] := theta [ n ] - 377487360
                         Else theta [ n ] := theta [ n ] + 377487360 ;
                         goto 40 ;
                       End ;
              End ;
            r := s ;
            s := t ;
            k := k + 1 ;
          End ;
        40 : For k := n - 1 Downto 0 Do
               theta [ k ] := vv [ k ] - takefraction ( theta [ k + 1 ] , uu [ k ] ) ;
        s := p ;
        k := 0 ;
        Repeat
          t := mem [ s ] . hh . rh ;
          nsincos ( theta [ k ] ) ;
          st := nsin ;
          ct := ncos ;
          nsincos ( - psi [ k + 1 ] - theta [ k + 1 ] ) ;
          sf := nsin ;
          cf := ncos ;
          setcontrols ( s , t , k ) ;
          k := k + 1 ;
          s := t ;
        Until k = n ;
        10 :
      End ;
      Procedure makechoices ( knots : halfword ) ;

      Label 30 ;

      Var h : halfword ;
        p , q : halfword ;
        k , n : 0 .. pathsize ;
        s , t : halfword ;
        delx , dely : scaled ;
        sine , cosine : fraction ;
      Begin
        Begin
          If aritherror Then cleararith ;
        End ;
        If internal [ 4 ] > 0 Then printpath ( knots , 526 , true ) ;
        p := knots ;
        Repeat
          q := mem [ p ] . hh . rh ;
          If mem [ p + 1 ] . int = mem [ q + 1 ] . int Then If mem [ p + 2 ] . int = mem [ q + 2 ] . int Then If mem [ p ] . hh . b1 > 1 Then
                                                                                                                Begin
                                                                                                                  mem [ p ] . hh . b1 := 1 ;
                                                                                                                  If mem [ p ] . hh . b0 = 4 Then
                                                                                                                    Begin
                                                                                                                      mem [ p ] . hh . b0 := 3 ;
                                                                                                                      mem [ p + 3 ] . int := 65536 ;
                                                                                                                    End ;
                                                                                                                  mem [ q ] . hh . b0 := 1 ;
                                                                                                                  If mem [ q ] . hh . b1 = 4 Then
                                                                                                                    Begin
                                                                                                                      mem [ q ] . hh . b1 := 3 ;
                                                                                                                      mem [ q + 5 ] . int := 65536 ;
                                                                                                                    End ;
                                                                                                                  mem [ p + 5 ] . int := mem [ p + 1 ] . int ;
                                                                                                                  mem [ q + 3 ] . int := mem [ p + 1 ] . int ;
                                                                                                                  mem [ p + 6 ] . int := mem [ p + 2 ] . int ;
                                                                                                                  mem [ q + 4 ] . int := mem [ p + 2 ] . int ;
                                                                                                                End ;
          p := q ;
        Until p = knots ;
        h := knots ;
        While true Do
          Begin
            If mem [ h ] . hh . b0 <> 4 Then goto 30 ;
            If mem [ h ] . hh . b1 <> 4 Then goto 30 ;
            h := mem [ h ] . hh . rh ;
            If h = knots Then
              Begin
                mem [ h ] . hh . b0 := 5 ;
                goto 30 ;
              End ;
          End ;
        30 : ;
        p := h ;
        Repeat
          q := mem [ p ] . hh . rh ;
          If mem [ p ] . hh . b1 >= 2 Then
            Begin
              While ( mem [ q ] . hh . b0 = 4 ) And ( mem [ q ] . hh . b1 = 4 ) Do
                q := mem [ q ] . hh . rh ;
              k := 0 ;
              s := p ;
              n := pathsize ;
              Repeat
                t := mem [ s ] . hh . rh ;
                deltax [ k ] := mem [ t + 1 ] . int - mem [ s + 1 ] . int ;
                deltay [ k ] := mem [ t + 2 ] . int - mem [ s + 2 ] . int ;
                delta [ k ] := pythadd ( deltax [ k ] , deltay [ k ] ) ;
                If k > 0 Then
                  Begin
                    sine := makefraction ( deltay [ k - 1 ] , delta [ k - 1 ] ) ;
                    cosine := makefraction ( deltax [ k - 1 ] , delta [ k - 1 ] ) ;
                    psi [ k ] := narg ( takefraction ( deltax [ k ] , cosine ) + takefraction ( deltay [ k ] , sine ) , takefraction ( deltay [ k ] , cosine ) - takefraction ( deltax [ k ] , sine ) ) ;
                  End ;
                k := k + 1 ;
                s := t ;
                If k = pathsize Then overflow ( 531 , pathsize ) ;
                If s = q Then n := k ;
              Until ( k >= n ) And ( mem [ s ] . hh . b0 <> 5 ) ;
              If k = n Then psi [ n ] := 0
              Else psi [ k ] := psi [ 1 ] ;
              If mem [ q ] . hh . b0 = 4 Then
                Begin
                  delx := mem [ q + 5 ] . int - mem [ q + 1 ] . int ;
                  dely := mem [ q + 6 ] . int - mem [ q + 2 ] . int ;
                  If ( delx = 0 ) And ( dely = 0 ) Then
                    Begin
                      mem [ q ] . hh . b0 := 3 ;
                      mem [ q + 3 ] . int := 65536 ;
                    End
                  Else
                    Begin
                      mem [ q ] . hh . b0 := 2 ;
                      mem [ q + 3 ] . int := narg ( delx , dely ) ;
                    End ;
                End ;
              If ( mem [ p ] . hh . b1 = 4 ) And ( mem [ p ] . hh . b0 = 1 ) Then
                Begin
                  delx := mem [ p + 1 ] . int - mem [ p + 3 ] . int ;
                  dely := mem [ p + 2 ] . int - mem [ p + 4 ] . int ;
                  If ( delx = 0 ) And ( dely = 0 ) Then
                    Begin
                      mem [ p ] . hh . b1 := 3 ;
                      mem [ p + 5 ] . int := 65536 ;
                    End
                  Else
                    Begin
                      mem [ p ] . hh . b1 := 2 ;
                      mem [ p + 5 ] . int := narg ( delx , dely ) ;
                    End ;
                End ;
              solvechoices ( p , q , n ) ;
            End ;
          p := q ;
        Until p = h ;
        If internal [ 4 ] > 0 Then printpath ( knots , 527 , true ) ;
        If aritherror Then
          Begin
            Begin
              If interaction = 3 Then ;
              printnl ( 261 ) ;
              print ( 528 ) ;
            End ;
            Begin
              helpptr := 2 ;
              helpline [ 1 ] := 529 ;
              helpline [ 0 ] := 530 ;
            End ;
            putgeterror ;
            aritherror := false ;
          End ;
      End ;
      Procedure makemoves ( xx0 , xx1 , xx2 , xx3 , yy0 , yy1 , yy2 , yy3 : scaled ; xicorr , etacorr : smallnumber ) ;

      Label 22 , 30 , 10 ;

      Var x1 , x2 , x3 , m , r , y1 , y2 , y3 , n , s , l : integer ;
        q , t , u , x2a , x3a , y2a , y3a : integer ;
      Begin
        If ( xx3 < xx0 ) Or ( yy3 < yy0 ) Then confusion ( 109 ) ;
        l := 16 ;
        bisectptr := 0 ;
        x1 := xx1 - xx0 ;
        x2 := xx2 - xx1 ;
        x3 := xx3 - xx2 ;
        If xx0 >= xicorr Then r := ( xx0 - xicorr ) Mod 65536
        Else r := 65535 - ( ( - xx0 + xicorr - 1 ) Mod 65536 ) ;
        m := ( xx3 - xx0 + r ) Div 65536 ;
        y1 := yy1 - yy0 ;
        y2 := yy2 - yy1 ;
        y3 := yy3 - yy2 ;
        If yy0 >= etacorr Then s := ( yy0 - etacorr ) Mod 65536
        Else s := 65535 - ( ( - yy0 + etacorr - 1 ) Mod 65536 ) ;
        n := ( yy3 - yy0 + s ) Div 65536 ;
        If ( xx3 - xx0 >= 268435456 ) Or ( yy3 - yy0 >= 268435456 ) Then
          Begin
            x1 := ( x1 + xicorr ) Div 2 ;
            x2 := ( x2 + xicorr ) Div 2 ;
            x3 := ( x3 + xicorr ) Div 2 ;
            r := ( r + xicorr ) Div 2 ;
            y1 := ( y1 + etacorr ) Div 2 ;
            y2 := ( y2 + etacorr ) Div 2 ;
            y3 := ( y3 + etacorr ) Div 2 ;
            s := ( s + etacorr ) Div 2 ;
            l := 15 ;
          End ;
        While true Do
          Begin
            22 : If m = 0 Then While n > 0 Do
                                 Begin
                                   moveptr := moveptr + 1 ;
                                   move [ moveptr ] := 1 ;
                                   n := n - 1 ;
                                 End
                                 Else If n = 0 Then move [ moveptr ] := move [ moveptr ] + m
                                 Else If m + n = 2 Then
                                        Begin
                                          r := twotothe [ l ] - r ;
                                          s := twotothe [ l ] - s ;
                                          While l < 30 Do
                                            Begin
                                              x3a := x3 ;
                                              x2a := ( x2 + x3 + xicorr ) Div 2 ;
                                              x2 := ( x1 + x2 + xicorr ) Div 2 ;
                                              x3 := ( x2 + x2a + xicorr ) Div 2 ;
                                              t := x1 + x2 + x3 ;
                                              r := r + r - xicorr ;
                                              y3a := y3 ;
                                              y2a := ( y2 + y3 + etacorr ) Div 2 ;
                                              y2 := ( y1 + y2 + etacorr ) Div 2 ;
                                              y3 := ( y2 + y2a + etacorr ) Div 2 ;
                                              u := y1 + y2 + y3 ;
                                              s := s + s - etacorr ;
                                              If t < r Then If u < s Then
                                                              Begin
                                                                x1 := x3 ;
                                                                x2 := x2a ;
                                                                x3 := x3a ;
                                                                r := r - t ;
                                                                y1 := y3 ;
                                                                y2 := y2a ;
                                                                y3 := y3a ;
                                                                s := s - u ;
                                                              End
                                              Else
                                                Begin
                                                  Begin
                                                    moveptr := moveptr + 1 ;
                                                    move [ moveptr ] := 2 ;
                                                  End ;
                                                  goto 30 ;
                                                End
                                              Else If u < s Then
                                                     Begin
                                                       Begin
                                                         move [ moveptr ] := move [ moveptr ] + 1 ;
                                                         moveptr := moveptr + 1 ;
                                                         move [ moveptr ] := 1 ;
                                                       End ;
                                                       goto 30 ;
                                                     End ;
                                              l := l + 1 ;
                                            End ;
                                          r := r - xicorr ;
                                          s := s - etacorr ;
                                          If abvscd ( x1 + x2 + x3 , s , y1 + y2 + y3 , r ) - xicorr >= 0 Then
                                            Begin
                                              move [ moveptr ] := move [ moveptr ] + 1 ;
                                              moveptr := moveptr + 1 ;
                                              move [ moveptr ] := 1 ;
                                            End
                                          Else
                                            Begin
                                              moveptr := moveptr + 1 ;
                                              move [ moveptr ] := 2 ;
                                            End ;
                                          30 :
                                        End
                                 Else
                                   Begin
                                     l := l + 1 ;
                                     bisectstack [ bisectptr + 10 ] := l ;
                                     bisectstack [ bisectptr + 2 ] := x3 ;
                                     bisectstack [ bisectptr + 1 ] := ( x2 + x3 + xicorr ) Div 2 ;
                                     x2 := ( x1 + x2 + xicorr ) Div 2 ;
                                     x3 := ( x2 + bisectstack [ bisectptr + 1 ] + xicorr ) Div 2 ;
                                     bisectstack [ bisectptr ] := x3 ;
                                     r := r + r + xicorr ;
                                     t := x1 + x2 + x3 + r ;
                                     q := t Div twotothe [ l ] ;
                                     bisectstack [ bisectptr + 3 ] := t Mod twotothe [ l ] ;
                                     bisectstack [ bisectptr + 4 ] := m - q ;
                                     m := q ;
                                     bisectstack [ bisectptr + 7 ] := y3 ;
                                     bisectstack [ bisectptr + 6 ] := ( y2 + y3 + etacorr ) Div 2 ;
                                     y2 := ( y1 + y2 + etacorr ) Div 2 ;
                                     y3 := ( y2 + bisectstack [ bisectptr + 6 ] + etacorr ) Div 2 ;
                                     bisectstack [ bisectptr + 5 ] := y3 ;
                                     s := s + s + etacorr ;
                                     u := y1 + y2 + y3 + s ;
                                     q := u Div twotothe [ l ] ;
                                     bisectstack [ bisectptr + 8 ] := u Mod twotothe [ l ] ;
                                     bisectstack [ bisectptr + 9 ] := n - q ;
                                     n := q ;
                                     bisectptr := bisectptr + 11 ;
                                     goto 22 ;
                                   End ;
            If bisectptr = 0 Then goto 10 ;
            bisectptr := bisectptr - 11 ;
            x1 := bisectstack [ bisectptr ] ;
            x2 := bisectstack [ bisectptr + 1 ] ;
            x3 := bisectstack [ bisectptr + 2 ] ;
            r := bisectstack [ bisectptr + 3 ] ;
            m := bisectstack [ bisectptr + 4 ] ;
            y1 := bisectstack [ bisectptr + 5 ] ;
            y2 := bisectstack [ bisectptr + 6 ] ;
            y3 := bisectstack [ bisectptr + 7 ] ;
            s := bisectstack [ bisectptr + 8 ] ;
            n := bisectstack [ bisectptr + 9 ] ;
            l := bisectstack [ bisectptr + 10 ] ;
          End ;
        10 :
      End ;
      Procedure smoothmoves ( b , t : integer ) ;

      Var k : 1 .. movesize ;
        a , aa , aaa : integer ;
      Begin
        If t - b >= 3 Then
          Begin
            k := b + 2 ;
            aa := move [ k - 1 ] ;
            aaa := move [ k - 2 ] ;
            Repeat
              a := move [ k ] ;
              If abs ( a - aa ) > 1 Then If a > aa Then
                                           Begin
                                             If aaa >= aa Then If a >= move [ k + 1 ] Then
                                                                 Begin
                                                                   move [ k - 1 ] := move [ k - 1 ] + 1 ;
                                                                   move [ k ] := a - 1 ;
                                                                 End ;
                                           End
              Else
                Begin
                  If aaa <= aa Then If a <= move [ k + 1 ] Then
                                      Begin
                                        move [ k - 1 ] := move [ k - 1 ] - 1 ;
                                        move [ k ] := a + 1 ;
                                      End ;
                End ;
              k := k + 1 ;
              aaa := aa ;
              aa := a ;
            Until k = t ;
          End ;
      End ;
      Procedure initedges ( h : halfword ) ;
      Begin
        mem [ h ] . hh . lh := h ;
        mem [ h ] . hh . rh := h ;
        mem [ h + 1 ] . hh . lh := 8191 ;
        mem [ h + 1 ] . hh . rh := 1 ;
        mem [ h + 2 ] . hh . lh := 8191 ;
        mem [ h + 2 ] . hh . rh := 1 ;
        mem [ h + 3 ] . hh . lh := 4096 ;
        mem [ h + 3 ] . hh . rh := 0 ;
        mem [ h + 4 ] . int := 0 ;
        mem [ h + 5 ] . hh . rh := h ;
        mem [ h + 5 ] . hh . lh := 0 ;
      End ;
      Procedure fixoffset ;

      Var p , q : halfword ;
        delta : integer ;
      Begin
        delta := 8 * ( mem [ curedges + 3 ] . hh . lh - 4096 ) ;
        mem [ curedges + 3 ] . hh . lh := 4096 ;
        q := mem [ curedges ] . hh . rh ;
        While q <> curedges Do
          Begin
            p := mem [ q + 1 ] . hh . rh ;
            While p <> 30000 Do
              Begin
                mem [ p ] . hh . lh := mem [ p ] . hh . lh - delta ;
                p := mem [ p ] . hh . rh ;
              End ;
            p := mem [ q + 1 ] . hh . lh ;
            While p > 1 Do
              Begin
                mem [ p ] . hh . lh := mem [ p ] . hh . lh - delta ;
                p := mem [ p ] . hh . rh ;
              End ;
            q := mem [ q ] . hh . rh ;
          End ;
      End ;
      Procedure edgeprep ( ml , mr , nl , nr : integer ) ;

      Var delta : halfword ;
        p , q : halfword ;
      Begin
        ml := ml + 4096 ;
        mr := mr + 4096 ;
        nl := nl + 4096 ;
        nr := nr + 4095 ;
        If ml < mem [ curedges + 2 ] . hh . lh Then mem [ curedges + 2 ] . hh . lh := ml ;
        If mr > mem [ curedges + 2 ] . hh . rh Then mem [ curedges + 2 ] . hh . rh := mr ;
        If Not ( abs ( mem [ curedges + 2 ] . hh . lh + mem [ curedges + 3 ] . hh . lh - 8192 ) < 4096 ) Or Not ( abs ( mem [ curedges + 2 ] . hh . rh + mem [ curedges + 3 ] . hh . lh - 8192 ) < 4096 ) Then fixoffset ;
        If mem [ curedges ] . hh . rh = curedges Then
          Begin
            mem [ curedges + 1 ] . hh . lh := nr + 1 ;
            mem [ curedges + 1 ] . hh . rh := nr ;
          End ;
        If nl < mem [ curedges + 1 ] . hh . lh Then
          Begin
            delta := mem [ curedges + 1 ] . hh . lh - nl ;
            mem [ curedges + 1 ] . hh . lh := nl ;
            p := mem [ curedges ] . hh . rh ;
            Repeat
              q := getnode ( 2 ) ;
              mem [ q + 1 ] . hh . rh := 30000 ;
              mem [ q + 1 ] . hh . lh := 1 ;
              mem [ p ] . hh . lh := q ;
              mem [ q ] . hh . rh := p ;
              p := q ;
              delta := delta - 1 ;
            Until delta = 0 ;
            mem [ p ] . hh . lh := curedges ;
            mem [ curedges ] . hh . rh := p ;
            If mem [ curedges + 5 ] . hh . rh = curedges Then mem [ curedges + 5 ] . hh . lh := nl - 1 ;
          End ;
        If nr > mem [ curedges + 1 ] . hh . rh Then
          Begin
            delta := nr - mem [ curedges + 1 ] . hh . rh ;
            mem [ curedges + 1 ] . hh . rh := nr ;
            p := mem [ curedges ] . hh . lh ;
            Repeat
              q := getnode ( 2 ) ;
              mem [ q + 1 ] . hh . rh := 30000 ;
              mem [ q + 1 ] . hh . lh := 1 ;
              mem [ p ] . hh . rh := q ;
              mem [ q ] . hh . lh := p ;
              p := q ;
              delta := delta - 1 ;
            Until delta = 0 ;
            mem [ p ] . hh . rh := curedges ;
            mem [ curedges ] . hh . lh := p ;
            If mem [ curedges + 5 ] . hh . rh = curedges Then mem [ curedges + 5 ] . hh . lh := nr + 1 ;
          End ;
      End ;
      Function copyedges ( h : halfword ) : halfword ;

      Var p , r : halfword ;
        hh , pp , qq , rr , ss : halfword ;
      Begin
        hh := getnode ( 6 ) ;
        mem [ hh + 1 ] := mem [ h + 1 ] ;
        mem [ hh + 2 ] := mem [ h + 2 ] ;
        mem [ hh + 3 ] := mem [ h + 3 ] ;
        mem [ hh + 4 ] := mem [ h + 4 ] ;
        mem [ hh + 5 ] . hh . lh := mem [ hh + 1 ] . hh . rh + 1 ;
        mem [ hh + 5 ] . hh . rh := hh ;
        p := mem [ h ] . hh . rh ;
        qq := hh ;
        While p <> h Do
          Begin
            pp := getnode ( 2 ) ;
            mem [ qq ] . hh . rh := pp ;
            mem [ pp ] . hh . lh := qq ;
            r := mem [ p + 1 ] . hh . rh ;
            rr := pp + 1 ;
            While r <> 30000 Do
              Begin
                ss := getavail ;
                mem [ rr ] . hh . rh := ss ;
                rr := ss ;
                mem [ rr ] . hh . lh := mem [ r ] . hh . lh ;
                r := mem [ r ] . hh . rh ;
              End ;
            mem [ rr ] . hh . rh := 30000 ;
            r := mem [ p + 1 ] . hh . lh ;
            rr := 29999 ;
            While r > 1 Do
              Begin
                ss := getavail ;
                mem [ rr ] . hh . rh := ss ;
                rr := ss ;
                mem [ rr ] . hh . lh := mem [ r ] . hh . lh ;
                r := mem [ r ] . hh . rh ;
              End ;
            mem [ rr ] . hh . rh := r ;
            mem [ pp + 1 ] . hh . lh := mem [ 29999 ] . hh . rh ;
            p := mem [ p ] . hh . rh ;
            qq := pp ;
          End ;
        mem [ qq ] . hh . rh := hh ;
        mem [ hh ] . hh . lh := qq ;
        copyedges := hh ;
      End ;
      Procedure yreflectedges ;

      Var p , q , r : halfword ;
      Begin
        p := mem [ curedges + 1 ] . hh . lh ;
        mem [ curedges + 1 ] . hh . lh := 8191 - mem [ curedges + 1 ] . hh . rh ;
        mem [ curedges + 1 ] . hh . rh := 8191 - p ;
        mem [ curedges + 5 ] . hh . lh := 8191 - mem [ curedges + 5 ] . hh . lh ;
        p := mem [ curedges ] . hh . rh ;
        q := curedges ;
        Repeat
          r := mem [ p ] . hh . rh ;
          mem [ p ] . hh . rh := q ;
          mem [ q ] . hh . lh := p ;
          q := p ;
          p := r ;
        Until q = curedges ;
        mem [ curedges + 4 ] . int := 0 ;
      End ;
      Procedure xreflectedges ;

      Var p , q , r , s : halfword ;
        m : integer ;
      Begin
        p := mem [ curedges + 2 ] . hh . lh ;
        mem [ curedges + 2 ] . hh . lh := 8192 - mem [ curedges + 2 ] . hh . rh ;
        mem [ curedges + 2 ] . hh . rh := 8192 - p ;
        m := ( 4096 + mem [ curedges + 3 ] . hh . lh ) * 8 + 8 ;
        mem [ curedges + 3 ] . hh . lh := 4096 ;
        p := mem [ curedges ] . hh . rh ;
        Repeat
          q := mem [ p + 1 ] . hh . rh ;
          r := 30000 ;
          While q <> 30000 Do
            Begin
              s := mem [ q ] . hh . rh ;
              mem [ q ] . hh . rh := r ;
              r := q ;
              mem [ r ] . hh . lh := m - mem [ q ] . hh . lh ;
              q := s ;
            End ;
          mem [ p + 1 ] . hh . rh := r ;
          q := mem [ p + 1 ] . hh . lh ;
          While q > 1 Do
            Begin
              mem [ q ] . hh . lh := m - mem [ q ] . hh . lh ;
              q := mem [ q ] . hh . rh ;
            End ;
          p := mem [ p ] . hh . rh ;
        Until p = curedges ;
        mem [ curedges + 4 ] . int := 0 ;
      End ;
      Procedure yscaleedges ( s : integer ) ;

      Var p , q , pp , r , rr , ss : halfword ;
        t : integer ;
      Begin
        If ( s * ( mem [ curedges + 1 ] . hh . rh - 4095 ) >= 4096 ) Or ( s * ( mem [ curedges + 1 ] . hh . lh - 4096 ) <= - 4096 ) Then
          Begin
            Begin
              If interaction = 3 Then ;
              printnl ( 261 ) ;
              print ( 535 ) ;
            End ;
            Begin
              helpptr := 3 ;
              helpline [ 2 ] := 536 ;
              helpline [ 1 ] := 537 ;
              helpline [ 0 ] := 538 ;
            End ;
            putgeterror ;
          End
        Else
          Begin
            mem [ curedges + 1 ] . hh . rh := s * ( mem [ curedges + 1 ] . hh . rh - 4095 ) + 4095 ;
            mem [ curedges + 1 ] . hh . lh := s * ( mem [ curedges + 1 ] . hh . lh - 4096 ) + 4096 ;
            p := curedges ;
            Repeat
              q := p ;
              p := mem [ p ] . hh . rh ;
              For t := 2 To s Do
                Begin
                  pp := getnode ( 2 ) ;
                  mem [ q ] . hh . rh := pp ;
                  mem [ p ] . hh . lh := pp ;
                  mem [ pp ] . hh . rh := p ;
                  mem [ pp ] . hh . lh := q ;
                  q := pp ;
                  r := mem [ p + 1 ] . hh . rh ;
                  rr := pp + 1 ;
                  While r <> 30000 Do
                    Begin
                      ss := getavail ;
                      mem [ rr ] . hh . rh := ss ;
                      rr := ss ;
                      mem [ rr ] . hh . lh := mem [ r ] . hh . lh ;
                      r := mem [ r ] . hh . rh ;
                    End ;
                  mem [ rr ] . hh . rh := 30000 ;
                  r := mem [ p + 1 ] . hh . lh ;
                  rr := 29999 ;
                  While r > 1 Do
                    Begin
                      ss := getavail ;
                      mem [ rr ] . hh . rh := ss ;
                      rr := ss ;
                      mem [ rr ] . hh . lh := mem [ r ] . hh . lh ;
                      r := mem [ r ] . hh . rh ;
                    End ;
                  mem [ rr ] . hh . rh := r ;
                  mem [ pp + 1 ] . hh . lh := mem [ 29999 ] . hh . rh ;
                End ;
            Until mem [ p ] . hh . rh = curedges ;
            mem [ curedges + 4 ] . int := 0 ;
          End ;
      End ;
      Procedure xscaleedges ( s : integer ) ;

      Var p , q : halfword ;
        t : 0 .. 65535 ;
        w : 0 .. 7 ;
        delta : integer ;
      Begin
        If ( s * ( mem [ curedges + 2 ] . hh . rh - 4096 ) >= 4096 ) Or ( s * ( mem [ curedges + 2 ] . hh . lh - 4096 ) <= - 4096 ) Then
          Begin
            Begin
              If interaction = 3 Then ;
              printnl ( 261 ) ;
              print ( 535 ) ;
            End ;
            Begin
              helpptr := 3 ;
              helpline [ 2 ] := 539 ;
              helpline [ 1 ] := 537 ;
              helpline [ 0 ] := 538 ;
            End ;
            putgeterror ;
          End
        Else If ( mem [ curedges + 2 ] . hh . rh <> 4096 ) Or ( mem [ curedges + 2 ] . hh . lh <> 4096 ) Then
               Begin
                 mem [ curedges + 2 ] . hh . rh := s * ( mem [ curedges + 2 ] . hh . rh - 4096 ) + 4096 ;
                 mem [ curedges + 2 ] . hh . lh := s * ( mem [ curedges + 2 ] . hh . lh - 4096 ) + 4096 ;
                 delta := 8 * ( 4096 - s * mem [ curedges + 3 ] . hh . lh ) + 0 ;
                 mem [ curedges + 3 ] . hh . lh := 4096 ;
                 q := mem [ curedges ] . hh . rh ;
                 Repeat
                   p := mem [ q + 1 ] . hh . rh ;
                   While p <> 30000 Do
                     Begin
                       t := mem [ p ] . hh . lh - 0 ;
                       w := t Mod 8 ;
                       mem [ p ] . hh . lh := ( t - w ) * s + w + delta ;
                       p := mem [ p ] . hh . rh ;
                     End ;
                   p := mem [ q + 1 ] . hh . lh ;
                   While p > 1 Do
                     Begin
                       t := mem [ p ] . hh . lh - 0 ;
                       w := t Mod 8 ;
                       mem [ p ] . hh . lh := ( t - w ) * s + w + delta ;
                       p := mem [ p ] . hh . rh ;
                     End ;
                   q := mem [ q ] . hh . rh ;
                 Until q = curedges ;
                 mem [ curedges + 4 ] . int := 0 ;
               End ;
      End ;
      Procedure negateedges ( h : halfword ) ;

      Label 30 ;

      Var p , q , r , s , t , u : halfword ;
      Begin
        p := mem [ h ] . hh . rh ;
        While p <> h Do
          Begin
            q := mem [ p + 1 ] . hh . lh ;
            While q > 1 Do
              Begin
                mem [ q ] . hh . lh := 8 - 2 * ( ( mem [ q ] . hh . lh - 0 ) Mod 8 ) + mem [ q ] . hh . lh ;
                q := mem [ q ] . hh . rh ;
              End ;
            q := mem [ p + 1 ] . hh . rh ;
            If q <> 30000 Then
              Begin
                Repeat
                  mem [ q ] . hh . lh := 8 - 2 * ( ( mem [ q ] . hh . lh - 0 ) Mod 8 ) + mem [ q ] . hh . lh ;
                  q := mem [ q ] . hh . rh ;
                Until q = 30000 ;
                u := p + 1 ;
                q := mem [ u ] . hh . rh ;
                r := q ;
                s := mem [ r ] . hh . rh ;
                While true Do
                  If mem [ s ] . hh . lh > mem [ r ] . hh . lh Then
                    Begin
                      mem [ u ] . hh . rh := q ;
                      If s = 30000 Then goto 30 ;
                      u := r ;
                      q := s ;
                      r := q ;
                      s := mem [ r ] . hh . rh ;
                    End
                  Else
                    Begin
                      t := s ;
                      s := mem [ t ] . hh . rh ;
                      mem [ t ] . hh . rh := q ;
                      q := t ;
                    End ;
                30 : mem [ r ] . hh . rh := 30000 ;
              End ;
            p := mem [ p ] . hh . rh ;
          End ;
        mem [ h + 4 ] . int := 0 ;
      End ;
      Procedure sortedges ( h : halfword ) ;

      Label 30 ;

      Var k : halfword ;
        p , q , r , s : halfword ;
      Begin
        r := mem [ h + 1 ] . hh . lh ;
        mem [ h + 1 ] . hh . lh := 0 ;
        p := mem [ r ] . hh . rh ;
        mem [ r ] . hh . rh := 30000 ;
        mem [ 29999 ] . hh . rh := r ;
        While p > 1 Do
          Begin
            k := mem [ p ] . hh . lh ;
            q := 29999 ;
            Repeat
              r := q ;
              q := mem [ r ] . hh . rh ;
            Until k <= mem [ q ] . hh . lh ;
            mem [ r ] . hh . rh := p ;
            r := mem [ p ] . hh . rh ;
            mem [ p ] . hh . rh := q ;
            p := r ;
          End ;
        Begin
          r := h + 1 ;
          q := mem [ r ] . hh . rh ;
          p := mem [ 29999 ] . hh . rh ;
          While true Do
            Begin
              k := mem [ p ] . hh . lh ;
              While k > mem [ q ] . hh . lh Do
                Begin
                  r := q ;
                  q := mem [ r ] . hh . rh ;
                End ;
              mem [ r ] . hh . rh := p ;
              s := mem [ p ] . hh . rh ;
              mem [ p ] . hh . rh := q ;
              If s = 30000 Then goto 30 ;
              r := p ;
              p := s ;
            End ;
          30 :
        End ;
      End ;
      Procedure culledges ( wlo , whi , wout , win : integer ) ;

      Label 30 ;

      Var p , q , r , s : halfword ;
        w : integer ;
        d : integer ;
        m : integer ;
        mm : integer ;
        ww : integer ;
        prevw : integer ;
        n , minn , maxn : halfword ;
        mind , maxd : halfword ;
      Begin
        mind := 65535 ;
        maxd := 0 ;
        minn := 65535 ;
        maxn := 0 ;
        p := mem [ curedges ] . hh . rh ;
        n := mem [ curedges + 1 ] . hh . lh ;
        While p <> curedges Do
          Begin
            If mem [ p + 1 ] . hh . lh > 1 Then sortedges ( p ) ;
            If mem [ p + 1 ] . hh . rh <> 30000 Then
              Begin
                r := 29999 ;
                q := mem [ p + 1 ] . hh . rh ;
                ww := 0 ;
                m := 1000000 ;
                prevw := 0 ;
                While true Do
                  Begin
                    If q = 30000 Then mm := 1000000
                    Else
                      Begin
                        d := mem [ q ] . hh . lh - 0 ;
                        mm := d Div 8 ;
                        ww := ww + ( d Mod 8 ) - 4 ;
                      End ;
                    If mm > m Then
                      Begin
                        If w <> prevw Then
                          Begin
                            s := getavail ;
                            mem [ r ] . hh . rh := s ;
                            mem [ s ] . hh . lh := 8 * m + 4 + w - prevw ;
                            r := s ;
                            prevw := w ;
                          End ;
                        If q = 30000 Then goto 30 ;
                      End ;
                    m := mm ;
                    If ww >= wlo Then If ww <= whi Then w := win
                    Else w := wout
                    Else w := wout ;
                    s := mem [ q ] . hh . rh ;
                    Begin
                      mem [ q ] . hh . rh := avail ;
                      avail := q ;
                    End ;
                    q := s ;
                  End ;
                30 : mem [ r ] . hh . rh := 30000 ;
                mem [ p + 1 ] . hh . rh := mem [ 29999 ] . hh . rh ;
                If r <> 29999 Then
                  Begin
                    If minn = 65535 Then minn := n ;
                    maxn := n ;
                    If mind > mem [ mem [ 29999 ] . hh . rh ] . hh . lh Then mind := mem [ mem [ 29999 ] . hh . rh ] . hh . lh ;
                    If maxd < mem [ r ] . hh . lh Then maxd := mem [ r ] . hh . lh ;
                  End ;
              End ;
            p := mem [ p ] . hh . rh ;
            n := n + 1 ;
          End ;
        If minn > maxn Then
          Begin
            p := mem [ curedges ] . hh . rh ;
            While p <> curedges Do
              Begin
                q := mem [ p ] . hh . rh ;
                freenode ( p , 2 ) ;
                p := q ;
              End ;
            initedges ( curedges ) ;
          End
        Else
          Begin
            n := mem [ curedges + 1 ] . hh . lh ;
            mem [ curedges + 1 ] . hh . lh := minn ;
            While minn > n Do
              Begin
                p := mem [ curedges ] . hh . rh ;
                mem [ curedges ] . hh . rh := mem [ p ] . hh . rh ;
                mem [ mem [ p ] . hh . rh ] . hh . lh := curedges ;
                freenode ( p , 2 ) ;
                n := n + 1 ;
              End ;
            n := mem [ curedges + 1 ] . hh . rh ;
            mem [ curedges + 1 ] . hh . rh := maxn ;
            mem [ curedges + 5 ] . hh . lh := maxn + 1 ;
            mem [ curedges + 5 ] . hh . rh := curedges ;
            While maxn < n Do
              Begin
                p := mem [ curedges ] . hh . lh ;
                mem [ curedges ] . hh . lh := mem [ p ] . hh . lh ;
                mem [ mem [ p ] . hh . lh ] . hh . rh := curedges ;
                freenode ( p , 2 ) ;
                n := n - 1 ;
              End ;
            mem [ curedges + 2 ] . hh . lh := ( ( mind - 0 ) Div 8 ) - mem [ curedges + 3 ] . hh . lh + 4096 ;
            mem [ curedges + 2 ] . hh . rh := ( ( maxd - 0 ) Div 8 ) - mem [ curedges + 3 ] . hh . lh + 4096 ;
          End ;
        mem [ curedges + 4 ] . int := 0 ;
      End ;
      Procedure xyswapedges ;

      Label 30 ;

      Var mmagic , nmagic : integer ;
        p , q , r , s : halfword ;
        mspread : integer ;
        j , jj : 0 .. movesize ;
        m , mm : integer ;
        pd , rd : integer ;
        pm , rm : integer ;
        w : integer ;
        ww : integer ;
        dw : integer ;
        extras : integer ;
        xw : - 3 .. 3 ;
        k : integer ;
      Begin
        mspread := mem [ curedges + 2 ] . hh . rh - mem [ curedges + 2 ] . hh . lh ;
        If mspread > movesize Then overflow ( 540 , movesize ) ;
        For j := 0 To mspread Do
          move [ j ] := 30000 ;
        p := getnode ( 2 ) ;
        mem [ p + 1 ] . hh . rh := 30000 ;
        mem [ p + 1 ] . hh . lh := 0 ;
        mem [ p ] . hh . lh := curedges ;
        mem [ mem [ curedges ] . hh . rh ] . hh . lh := p ;
        p := getnode ( 2 ) ;
        mem [ p + 1 ] . hh . rh := 30000 ;
        mem [ p ] . hh . lh := mem [ curedges ] . hh . lh ; ;
        mmagic := mem [ curedges + 2 ] . hh . lh + mem [ curedges + 3 ] . hh . lh - 4096 ;
        nmagic := 8 * mem [ curedges + 1 ] . hh . rh + 12 ;
        Repeat
          q := mem [ p ] . hh . lh ;
          If mem [ q + 1 ] . hh . lh > 1 Then sortedges ( q ) ;
          r := mem [ p + 1 ] . hh . rh ;
          freenode ( p , 2 ) ;
          p := r ;
          pd := mem [ p ] . hh . lh - 0 ;
          pm := pd Div 8 ;
          r := mem [ q + 1 ] . hh . rh ;
          rd := mem [ r ] . hh . lh - 0 ;
          rm := rd Div 8 ;
          w := 0 ;
          While true Do
            Begin
              If pm < rm Then mm := pm
              Else mm := rm ;
              If w <> 0 Then If m <> mm Then
                               Begin
                                 If mm - mmagic >= movesize Then confusion ( 510 ) ;
                                 extras := ( abs ( w ) - 1 ) Div 3 ;
                                 If extras > 0 Then
                                   Begin
                                     If w > 0 Then xw := + 3
                                     Else xw := - 3 ;
                                     ww := w - extras * xw ;
                                   End
                                 Else ww := w ;
                                 Repeat
                                   j := m - mmagic ;
                                   For k := 1 To extras Do
                                     Begin
                                       s := getavail ;
                                       mem [ s ] . hh . lh := nmagic + xw ;
                                       mem [ s ] . hh . rh := move [ j ] ;
                                       move [ j ] := s ;
                                     End ;
                                   s := getavail ;
                                   mem [ s ] . hh . lh := nmagic + ww ;
                                   mem [ s ] . hh . rh := move [ j ] ;
                                   move [ j ] := s ;
                                   m := m + 1 ;
                                 Until m = mm ;
                               End ;
              If pd < rd Then
                Begin
                  dw := ( pd Mod 8 ) - 4 ;
                  s := mem [ p ] . hh . rh ;
                  Begin
                    mem [ p ] . hh . rh := avail ;
                    avail := p ;
                  End ;
                  p := s ;
                  pd := mem [ p ] . hh . lh - 0 ;
                  pm := pd Div 8 ;
                End
              Else
                Begin
                  If r = 30000 Then goto 30 ;
                  dw := - ( ( rd Mod 8 ) - 4 ) ;
                  r := mem [ r ] . hh . rh ;
                  rd := mem [ r ] . hh . lh - 0 ;
                  rm := rd Div 8 ;
                End ;
              m := mm ;
              w := w + dw ;
            End ;
          30 : ;
          p := q ;
          nmagic := nmagic - 8 ;
        Until mem [ p ] . hh . lh = curedges ;
        freenode ( p , 2 ) ;
        move [ mspread ] := 0 ;
        j := 0 ;
        While move [ j ] = 30000 Do
          j := j + 1 ;
        If j = mspread Then initedges ( curedges )
        Else
          Begin
            mm := mem [ curedges + 2 ] . hh . lh ;
            mem [ curedges + 2 ] . hh . lh := mem [ curedges + 1 ] . hh . lh ;
            mem [ curedges + 2 ] . hh . rh := mem [ curedges + 1 ] . hh . rh + 1 ;
            mem [ curedges + 3 ] . hh . lh := 4096 ;
            jj := mspread - 1 ;
            While move [ jj ] = 30000 Do
              jj := jj - 1 ;
            mem [ curedges + 1 ] . hh . lh := j + mm ;
            mem [ curedges + 1 ] . hh . rh := jj + mm ;
            q := curedges ;
            Repeat
              p := getnode ( 2 ) ;
              mem [ q ] . hh . rh := p ;
              mem [ p ] . hh . lh := q ;
              mem [ p + 1 ] . hh . rh := move [ j ] ;
              mem [ p + 1 ] . hh . lh := 0 ;
              j := j + 1 ;
              q := p ;
            Until j > jj ;
            mem [ q ] . hh . rh := curedges ;
            mem [ curedges ] . hh . lh := q ;
            mem [ curedges + 5 ] . hh . lh := mem [ curedges + 1 ] . hh . rh + 1 ;
            mem [ curedges + 5 ] . hh . rh := curedges ;
            mem [ curedges + 4 ] . int := 0 ;
          End ; ;
      End ;
      Procedure mergeedges ( h : halfword ) ;

      Label 30 ;

      Var p , q , r , pp , qq , rr : halfword ;
        n : integer ;
        k : halfword ;
        delta : integer ;
      Begin
        If mem [ h ] . hh . rh <> h Then
          Begin
            If ( mem [ h + 2 ] . hh . lh < mem [ curedges + 2 ] . hh . lh ) Or ( mem [ h + 2 ] . hh . rh > mem [ curedges + 2 ] . hh . rh ) Or ( mem [ h + 1 ] . hh . lh < mem [ curedges + 1 ] . hh . lh ) Or ( mem [ h + 1 ] . hh . rh > mem [ curedges + 1 ] . hh . rh ) Then edgeprep ( mem [ h + 2 ] . hh . lh - 4096 , mem [ h + 2 ] . hh . rh - 4096 , mem [ h + 1 ] . hh . lh - 4096 , mem [ h + 1 ] . hh . rh - 4095 ) ;
            If mem [ h + 3 ] . hh . lh <> mem [ curedges + 3 ] . hh . lh Then
              Begin
                pp := mem [ h ] . hh . rh ;
                delta := 8 * ( mem [ curedges + 3 ] . hh . lh - mem [ h + 3 ] . hh . lh ) ;
                Repeat
                  qq := mem [ pp + 1 ] . hh . rh ;
                  While qq <> 30000 Do
                    Begin
                      mem [ qq ] . hh . lh := mem [ qq ] . hh . lh + delta ;
                      qq := mem [ qq ] . hh . rh ;
                    End ;
                  qq := mem [ pp + 1 ] . hh . lh ;
                  While qq > 1 Do
                    Begin
                      mem [ qq ] . hh . lh := mem [ qq ] . hh . lh + delta ;
                      qq := mem [ qq ] . hh . rh ;
                    End ;
                  pp := mem [ pp ] . hh . rh ;
                Until pp = h ;
              End ;
            n := mem [ curedges + 1 ] . hh . lh ;
            p := mem [ curedges ] . hh . rh ;
            pp := mem [ h ] . hh . rh ;
            While n < mem [ h + 1 ] . hh . lh Do
              Begin
                n := n + 1 ;
                p := mem [ p ] . hh . rh ;
              End ;
            Repeat
              qq := mem [ pp + 1 ] . hh . lh ;
              If qq > 1 Then If mem [ p + 1 ] . hh . lh <= 1 Then mem [ p + 1 ] . hh . lh := qq
              Else
                Begin
                  While mem [ qq ] . hh . rh > 1 Do
                    qq := mem [ qq ] . hh . rh ;
                  mem [ qq ] . hh . rh := mem [ p + 1 ] . hh . lh ;
                  mem [ p + 1 ] . hh . lh := mem [ pp + 1 ] . hh . lh ;
                End ;
              mem [ pp + 1 ] . hh . lh := 0 ;
              qq := mem [ pp + 1 ] . hh . rh ;
              If qq <> 30000 Then
                Begin
                  If mem [ p + 1 ] . hh . lh = 1 Then mem [ p + 1 ] . hh . lh := 0 ;
                  mem [ pp + 1 ] . hh . rh := 30000 ;
                  r := p + 1 ;
                  q := mem [ r ] . hh . rh ;
                  If q = 30000 Then mem [ p + 1 ] . hh . rh := qq
                  Else While true Do
                         Begin
                           k := mem [ qq ] . hh . lh ;
                           While k > mem [ q ] . hh . lh Do
                             Begin
                               r := q ;
                               q := mem [ r ] . hh . rh ;
                             End ;
                           mem [ r ] . hh . rh := qq ;
                           rr := mem [ qq ] . hh . rh ;
                           mem [ qq ] . hh . rh := q ;
                           If rr = 30000 Then goto 30 ;
                           r := qq ;
                           qq := rr ;
                         End ;
                End ;
              30 : ;
              pp := mem [ pp ] . hh . rh ;
              p := mem [ p ] . hh . rh ;
            Until pp = h ;
          End ;
      End ;
      Function totalweight ( h : halfword ) : integer ;

      Var p , q : halfword ;
        n : integer ;
        m : 0 .. 65535 ;
      Begin
        n := 0 ;
        p := mem [ h ] . hh . rh ;
        While p <> h Do
          Begin
            q := mem [ p + 1 ] . hh . rh ;
            While q <> 30000 Do
              Begin
                m := mem [ q ] . hh . lh - 0 ;
                n := n - ( ( m Mod 8 ) - 4 ) * ( m Div 8 ) ;
                q := mem [ q ] . hh . rh ;
              End ;
            q := mem [ p + 1 ] . hh . lh ;
            While q > 1 Do
              Begin
                m := mem [ q ] . hh . lh - 0 ;
                n := n - ( ( m Mod 8 ) - 4 ) * ( m Div 8 ) ;
                q := mem [ q ] . hh . rh ;
              End ;
            p := mem [ p ] . hh . rh ;
          End ;
        totalweight := n ;
      End ;
      Procedure beginedgetracing ;
      Begin
        printdiagnostic ( 541 , 285 , true ) ;
        print ( 542 ) ;
        printint ( curwt ) ;
        printchar ( 41 ) ;
        tracex := - 4096 ;
      End ;
      Procedure traceacorner ;
      Begin
        If fileoffset > maxprintline - 13 Then printnl ( 285 ) ;
        printchar ( 40 ) ;
        printint ( tracex ) ;
        printchar ( 44 ) ;
        printint ( traceyy ) ;
        printchar ( 41 ) ;
        tracey := traceyy ;
      End ;
      Procedure endedgetracing ;
      Begin
        If tracex = - 4096 Then printnl ( 543 )
        Else
          Begin
            traceacorner ;
            printchar ( 46 ) ;
          End ;
        enddiagnostic ( true ) ;
      End ;
      Procedure tracenewedge ( r : halfword ; n : integer ) ;

      Var d : integer ;
        w : - 3 .. 3 ;
        m , n0 , n1 : integer ;
      Begin
        d := mem [ r ] . hh . lh - 0 ;
        w := ( d Mod 8 ) - 4 ;
        m := ( d Div 8 ) - mem [ curedges + 3 ] . hh . lh ;
        If w = curwt Then
          Begin
            n0 := n + 1 ;
            n1 := n ;
          End
        Else
          Begin
            n0 := n ;
            n1 := n + 1 ;
          End ;
        If m <> tracex Then
          Begin
            If tracex = - 4096 Then
              Begin
                printnl ( 285 ) ;
                traceyy := n0 ;
              End
            Else If traceyy <> n0 Then printchar ( 63 )
            Else traceacorner ;
            tracex := m ;
            traceacorner ;
          End
        Else
          Begin
            If n0 <> traceyy Then printchar ( 33 ) ;
            If ( ( n0 < n1 ) And ( tracey > traceyy ) ) Or ( ( n0 > n1 ) And ( tracey < traceyy ) ) Then traceacorner ;
          End ;
        traceyy := n1 ;
      End ;
      Procedure lineedges ( x0 , y0 , x1 , y1 : scaled ) ;

      Label 30 , 31 ;

      Var m0 , n0 , m1 , n1 : integer ;
        delx , dely : scaled ;
        yt : scaled ;
        tx : scaled ;
        p , r : halfword ;
        base : integer ;
        n : integer ;
      Begin
        n0 := roundunscaled ( y0 ) ;
        n1 := roundunscaled ( y1 ) ;
        If n0 <> n1 Then
          Begin
            m0 := roundunscaled ( x0 ) ;
            m1 := roundunscaled ( x1 ) ;
            delx := x1 - x0 ;
            dely := y1 - y0 ;
            yt := n0 * 65536 - 32768 ;
            y0 := y0 - yt ;
            y1 := y1 - yt ;
            If n0 < n1 Then
              Begin
                base := 8 * mem [ curedges + 3 ] . hh . lh + 4 - curwt ;
                If m0 <= m1 Then edgeprep ( m0 , m1 , n0 , n1 )
                Else edgeprep ( m1 , m0 , n0 , n1 ) ;
                n := mem [ curedges + 5 ] . hh . lh - 4096 ;
                p := mem [ curedges + 5 ] . hh . rh ;
                If n <> n0 Then If n < n0 Then Repeat
                                                 n := n + 1 ;
                                                 p := mem [ p ] . hh . rh ;
                                  Until n = n0
                Else Repeat
                       n := n - 1 ;
                       p := mem [ p ] . hh . lh ;
                  Until n = n0 ;
                y0 := 65536 - y0 ;
                While true Do
                  Begin
                    r := getavail ;
                    mem [ r ] . hh . rh := mem [ p + 1 ] . hh . lh ;
                    mem [ p + 1 ] . hh . lh := r ;
                    tx := takefraction ( delx , makefraction ( y0 , dely ) ) ;
                    If abvscd ( delx , y0 , dely , tx ) < 0 Then tx := tx - 1 ;
                    mem [ r ] . hh . lh := 8 * roundunscaled ( x0 + tx ) + base ;
                    y1 := y1 - 65536 ;
                    If internal [ 10 ] > 0 Then tracenewedge ( r , n ) ;
                    If y1 < 65536 Then goto 30 ;
                    p := mem [ p ] . hh . rh ;
                    y0 := y0 + 65536 ;
                    n := n + 1 ;
                  End ;
                30 :
              End
            Else
              Begin
                base := 8 * mem [ curedges + 3 ] . hh . lh + 4 + curwt ;
                If m0 <= m1 Then edgeprep ( m0 , m1 , n1 , n0 )
                Else edgeprep ( m1 , m0 , n1 , n0 ) ;
                n0 := n0 - 1 ;
                n := mem [ curedges + 5 ] . hh . lh - 4096 ;
                p := mem [ curedges + 5 ] . hh . rh ;
                If n <> n0 Then If n < n0 Then Repeat
                                                 n := n + 1 ;
                                                 p := mem [ p ] . hh . rh ;
                                  Until n = n0
                Else Repeat
                       n := n - 1 ;
                       p := mem [ p ] . hh . lh ;
                  Until n = n0 ;
                While true Do
                  Begin
                    r := getavail ;
                    mem [ r ] . hh . rh := mem [ p + 1 ] . hh . lh ;
                    mem [ p + 1 ] . hh . lh := r ;
                    tx := takefraction ( delx , makefraction ( y0 , dely ) ) ;
                    If abvscd ( delx , y0 , dely , tx ) < 0 Then tx := tx + 1 ;
                    mem [ r ] . hh . lh := 8 * roundunscaled ( x0 - tx ) + base ;
                    y1 := y1 + 65536 ;
                    If internal [ 10 ] > 0 Then tracenewedge ( r , n ) ;
                    If y1 >= 0 Then goto 31 ;
                    p := mem [ p ] . hh . lh ;
                    y0 := y0 + 65536 ;
                    n := n - 1 ;
                  End ;
                31 :
              End ;
            mem [ curedges + 5 ] . hh . rh := p ;
            mem [ curedges + 5 ] . hh . lh := n + 4096 ;
          End ;
      End ;
      Procedure movetoedges ( m0 , n0 , m1 , n1 : integer ) ;

      Label 60 , 61 , 62 , 63 , 30 ;

      Var delta : 0 .. movesize ;
        k : 0 .. movesize ;
        p , r : halfword ;
        dx : integer ;
        edgeandweight : integer ;
        j : integer ;
        n : integer ;
      Begin
        delta := n1 - n0 ;
        Case octant Of 
          1 :
              Begin
                dx := 8 ;
                edgeprep ( m0 , m1 , n0 , n1 ) ;
                goto 60 ;
              End ;
          5 :
              Begin
                dx := 8 ;
                edgeprep ( n0 , n1 , m0 , m1 ) ;
                goto 62 ;
              End ;
          6 :
              Begin
                dx := - 8 ;
                edgeprep ( - n1 , - n0 , m0 , m1 ) ;
                n0 := - n0 ;
                goto 62 ;
              End ;
          2 :
              Begin
                dx := - 8 ;
                edgeprep ( - m1 , - m0 , n0 , n1 ) ;
                m0 := - m0 ;
                goto 60 ;
              End ;
          4 :
              Begin
                dx := - 8 ;
                edgeprep ( - m1 , - m0 , - n1 , - n0 ) ;
                m0 := - m0 ;
                goto 61 ;
              End ;
          8 :
              Begin
                dx := - 8 ;
                edgeprep ( - n1 , - n0 , - m1 , - m0 ) ;
                n0 := - n0 ;
                goto 63 ;
              End ;
          7 :
              Begin
                dx := 8 ;
                edgeprep ( n0 , n1 , - m1 , - m0 ) ;
                goto 63 ;
              End ;
          3 :
              Begin
                dx := 8 ;
                edgeprep ( m0 , m1 , - n1 , - n0 ) ;
                goto 61 ;
              End ;
        End ; ;
        60 : n := mem [ curedges + 5 ] . hh . lh - 4096 ;
        p := mem [ curedges + 5 ] . hh . rh ;
        If n <> n0 Then If n < n0 Then Repeat
                                         n := n + 1 ;
                                         p := mem [ p ] . hh . rh ;
                          Until n = n0
        Else Repeat
               n := n - 1 ;
               p := mem [ p ] . hh . lh ;
          Until n = n0 ;
        If delta > 0 Then
          Begin
            k := 0 ;
            edgeandweight := 8 * ( m0 + mem [ curedges + 3 ] . hh . lh ) + 4 - curwt ;
            Repeat
              edgeandweight := edgeandweight + dx * move [ k ] ;
              Begin
                r := avail ;
                If r = 0 Then r := getavail
                Else
                  Begin
                    avail := mem [ r ] . hh . rh ;
                    mem [ r ] . hh . rh := 0 ;
                  End ;
              End ;
              mem [ r ] . hh . rh := mem [ p + 1 ] . hh . lh ;
              mem [ r ] . hh . lh := edgeandweight ;
              If internal [ 10 ] > 0 Then tracenewedge ( r , n ) ;
              mem [ p + 1 ] . hh . lh := r ;
              p := mem [ p ] . hh . rh ;
              k := k + 1 ;
              n := n + 1 ;
            Until k = delta ;
          End ;
        goto 30 ;
        61 : n0 := - n0 - 1 ;
        n := mem [ curedges + 5 ] . hh . lh - 4096 ;
        p := mem [ curedges + 5 ] . hh . rh ;
        If n <> n0 Then If n < n0 Then Repeat
                                         n := n + 1 ;
                                         p := mem [ p ] . hh . rh ;
                          Until n = n0
        Else Repeat
               n := n - 1 ;
               p := mem [ p ] . hh . lh ;
          Until n = n0 ;
        If delta > 0 Then
          Begin
            k := 0 ;
            edgeandweight := 8 * ( m0 + mem [ curedges + 3 ] . hh . lh ) + 4 + curwt ;
            Repeat
              edgeandweight := edgeandweight + dx * move [ k ] ;
              Begin
                r := avail ;
                If r = 0 Then r := getavail
                Else
                  Begin
                    avail := mem [ r ] . hh . rh ;
                    mem [ r ] . hh . rh := 0 ;
                  End ;
              End ;
              mem [ r ] . hh . rh := mem [ p + 1 ] . hh . lh ;
              mem [ r ] . hh . lh := edgeandweight ;
              If internal [ 10 ] > 0 Then tracenewedge ( r , n ) ;
              mem [ p + 1 ] . hh . lh := r ;
              p := mem [ p ] . hh . lh ;
              k := k + 1 ;
              n := n - 1 ;
            Until k = delta ;
          End ;
        goto 30 ;
        62 : edgeandweight := 8 * ( n0 + mem [ curedges + 3 ] . hh . lh ) + 4 - curwt ;
        n0 := m0 ;
        k := 0 ;
        n := mem [ curedges + 5 ] . hh . lh - 4096 ;
        p := mem [ curedges + 5 ] . hh . rh ;
        If n <> n0 Then If n < n0 Then Repeat
                                         n := n + 1 ;
                                         p := mem [ p ] . hh . rh ;
                          Until n = n0
        Else Repeat
               n := n - 1 ;
               p := mem [ p ] . hh . lh ;
          Until n = n0 ;
        Repeat
          j := move [ k ] ;
          While j > 0 Do
            Begin
              Begin
                r := avail ;
                If r = 0 Then r := getavail
                Else
                  Begin
                    avail := mem [ r ] . hh . rh ;
                    mem [ r ] . hh . rh := 0 ;
                  End ;
              End ;
              mem [ r ] . hh . rh := mem [ p + 1 ] . hh . lh ;
              mem [ r ] . hh . lh := edgeandweight ;
              If internal [ 10 ] > 0 Then tracenewedge ( r , n ) ;
              mem [ p + 1 ] . hh . lh := r ;
              p := mem [ p ] . hh . rh ;
              j := j - 1 ;
              n := n + 1 ;
            End ;
          edgeandweight := edgeandweight + dx ;
          k := k + 1 ;
        Until k > delta ;
        goto 30 ;
        63 : edgeandweight := 8 * ( n0 + mem [ curedges + 3 ] . hh . lh ) + 4 + curwt ;
        n0 := - m0 - 1 ;
        k := 0 ;
        n := mem [ curedges + 5 ] . hh . lh - 4096 ;
        p := mem [ curedges + 5 ] . hh . rh ;
        If n <> n0 Then If n < n0 Then Repeat
                                         n := n + 1 ;
                                         p := mem [ p ] . hh . rh ;
                          Until n = n0
        Else Repeat
               n := n - 1 ;
               p := mem [ p ] . hh . lh ;
          Until n = n0 ;
        Repeat
          j := move [ k ] ;
          While j > 0 Do
            Begin
              Begin
                r := avail ;
                If r = 0 Then r := getavail
                Else
                  Begin
                    avail := mem [ r ] . hh . rh ;
                    mem [ r ] . hh . rh := 0 ;
                  End ;
              End ;
              mem [ r ] . hh . rh := mem [ p + 1 ] . hh . lh ;
              mem [ r ] . hh . lh := edgeandweight ;
              If internal [ 10 ] > 0 Then tracenewedge ( r , n ) ;
              mem [ p + 1 ] . hh . lh := r ;
              p := mem [ p ] . hh . lh ;
              j := j - 1 ;
              n := n - 1 ;
            End ;
          edgeandweight := edgeandweight + dx ;
          k := k + 1 ;
        Until k > delta ;
        goto 30 ;
        30 : mem [ curedges + 5 ] . hh . lh := n + 4096 ;
        mem [ curedges + 5 ] . hh . rh := p ;
      End ;
      Procedure skew ( x , y : scaled ; octant : smallnumber ) ;
      Begin
        Case octant Of 
          1 :
              Begin
                curx := x - y ;
                cury := y ;
              End ;
          5 :
              Begin
                curx := y - x ;
                cury := x ;
              End ;
          6 :
              Begin
                curx := y + x ;
                cury := - x ;
              End ;
          2 :
              Begin
                curx := - x - y ;
                cury := y ;
              End ;
          4 :
              Begin
                curx := - x + y ;
                cury := - y ;
              End ;
          8 :
              Begin
                curx := - y + x ;
                cury := - x ;
              End ;
          7 :
              Begin
                curx := - y - x ;
                cury := x ;
              End ;
          3 :
              Begin
                curx := x + y ;
                cury := - y ;
              End ;
        End ;
      End ;
      Procedure abnegate ( x , y : scaled ; octantbefore , octantafter : smallnumber ) ;
      Begin
        If odd ( octantbefore ) = odd ( octantafter ) Then curx := x
        Else curx := - x ;
        If ( octantbefore > 2 ) = ( octantafter > 2 ) Then cury := y
        Else cury := - y ;
      End ;
      Function crossingpoint ( a , b , c : integer ) : fraction ;

      Label 10 ;

      Var d : integer ;
        x , xx , x0 , x1 , x2 : integer ;
      Begin
        If a < 0 Then
          Begin
            crossingpoint := 0 ;
            goto 10 ;
          End ;
        If c >= 0 Then
          Begin
            If b >= 0 Then If c > 0 Then
                             Begin
                               crossingpoint := 268435457 ;
                               goto 10 ;
                             End
            Else If ( a = 0 ) And ( b = 0 ) Then
                   Begin
                     crossingpoint := 268435457 ;
                     goto 10 ;
                   End
            Else
              Begin
                crossingpoint := 268435456 ;
                goto 10 ;
              End ;
            If a = 0 Then
              Begin
                crossingpoint := 0 ;
                goto 10 ;
              End ;
          End
        Else If a = 0 Then If b <= 0 Then
                             Begin
                               crossingpoint := 0 ;
                               goto 10 ;
                             End ;
        d := 1 ;
        x0 := a ;
        x1 := a - b ;
        x2 := b - c ;
        Repeat
          x := ( x1 + x2 ) Div 2 ;
          If x1 - x0 > x0 Then
            Begin
              x2 := x ;
              x0 := x0 + x0 ;
              d := d + d ;
            End
          Else
            Begin
              xx := x1 + x - x0 ;
              If xx > x0 Then
                Begin
                  x2 := x ;
                  x0 := x0 + x0 ;
                  d := d + d ;
                End
              Else
                Begin
                  x0 := x0 - xx ;
                  If x <= x0 Then If x + x2 <= x0 Then
                                    Begin
                                      crossingpoint := 268435457 ;
                                      goto 10 ;
                                    End ;
                  x1 := x ;
                  d := d + d + 1 ;
                End ;
            End ;
        Until d >= 268435456 ;
        crossingpoint := d - 268435456 ;
        10 :
      End ;
      Procedure printspec ( s : strnumber ) ;

      Label 45 , 30 ;

      Var p , q : halfword ;
        octant : smallnumber ;
      Begin
        printdiagnostic ( 544 , s , true ) ;
        p := curspec ;
        octant := mem [ p + 3 ] . int ;
        println ;
        unskew ( mem [ curspec + 1 ] . int , mem [ curspec + 2 ] . int , octant ) ;
        printtwo ( curx , cury ) ;
        print ( 545 ) ;
        While true Do
          Begin
            print ( octantdir [ octant ] ) ;
            printchar ( 39 ) ;
            While true Do
              Begin
                q := mem [ p ] . hh . rh ;
                If mem [ p ] . hh . b1 = 0 Then goto 45 ;
                Begin
                  printnl ( 556 ) ;
                  unskew ( mem [ p + 5 ] . int , mem [ p + 6 ] . int , octant ) ;
                  printtwo ( curx , cury ) ;
                  print ( 523 ) ;
                  unskew ( mem [ q + 3 ] . int , mem [ q + 4 ] . int , octant ) ;
                  printtwo ( curx , cury ) ;
                  printnl ( 520 ) ;
                  unskew ( mem [ q + 1 ] . int , mem [ q + 2 ] . int , octant ) ;
                  printtwo ( curx , cury ) ;
                  print ( 557 ) ;
                  printint ( mem [ q ] . hh . b0 - 1 ) ;
                End ;
                p := q ;
              End ;
            45 : If q = curspec Then goto 30 ;
            p := q ;
            octant := mem [ p + 3 ] . int ;
            printnl ( 546 ) ;
          End ;
        30 : printnl ( 547 ) ;
        enddiagnostic ( true ) ;
      End ;
      Procedure printstrange ( s : strnumber ) ;

      Var p : halfword ;
        f : halfword ;
        q : halfword ;
        t : integer ;
      Begin
        If interaction = 3 Then ;
        printnl ( 62 ) ;
        p := curspec ;
        t := 256 ;
        Repeat
          p := mem [ p ] . hh . rh ;
          If mem [ p ] . hh . b0 <> 0 Then
            Begin
              If mem [ p ] . hh . b0 < t Then f := p ;
              t := mem [ p ] . hh . b0 ;
            End ;
        Until p = curspec ;
        p := curspec ;
        q := p ;
        Repeat
          p := mem [ p ] . hh . rh ;
          If mem [ p ] . hh . b0 = 0 Then q := p ;
        Until p = f ;
        t := 0 ;
        Repeat
          If mem [ p ] . hh . b0 <> 0 Then
            Begin
              If mem [ p ] . hh . b0 <> t Then
                Begin
                  t := mem [ p ] . hh . b0 ;
                  printchar ( 32 ) ;
                  printint ( t - 1 ) ;
                End ;
              If q <> 0 Then
                Begin
                  If mem [ mem [ q ] . hh . rh ] . hh . b0 = 0 Then
                    Begin
                      print ( 558 ) ;
                      print ( octantdir [ mem [ q + 3 ] . int ] ) ;
                      q := mem [ q ] . hh . rh ;
                      While mem [ mem [ q ] . hh . rh ] . hh . b0 = 0 Do
                        Begin
                          printchar ( 32 ) ;
                          print ( octantdir [ mem [ q + 3 ] . int ] ) ;
                          q := mem [ q ] . hh . rh ;
                        End ;
                      printchar ( 41 ) ;
                    End ;
                  printchar ( 32 ) ;
                  print ( octantdir [ mem [ q + 3 ] . int ] ) ;
                  q := 0 ;
                End ;
            End
          Else If q = 0 Then q := p ;
          p := mem [ p ] . hh . rh ;
        Until p = f ;
        printchar ( 32 ) ;
        printint ( mem [ p ] . hh . b0 - 1 ) ;
        If q <> 0 Then If mem [ mem [ q ] . hh . rh ] . hh . b0 = 0 Then
                         Begin
                           print ( 558 ) ;
                           print ( octantdir [ mem [ q + 3 ] . int ] ) ;
                           q := mem [ q ] . hh . rh ;
                           While mem [ mem [ q ] . hh . rh ] . hh . b0 = 0 Do
                             Begin
                               printchar ( 32 ) ;
                               print ( octantdir [ mem [ q + 3 ] . int ] ) ;
                               q := mem [ q ] . hh . rh ;
                             End ;
                           printchar ( 41 ) ;
                         End ;
        Begin
          If interaction = 3 Then ;
          printnl ( 261 ) ;
          print ( s ) ;
        End ;
      End ;
      Procedure removecubic ( p : halfword ) ;

      Var q : halfword ;
      Begin
        q := mem [ p ] . hh . rh ;
        mem [ p ] . hh . b1 := mem [ q ] . hh . b1 ;
        mem [ p ] . hh . rh := mem [ q ] . hh . rh ;
        mem [ p + 1 ] . int := mem [ q + 1 ] . int ;
        mem [ p + 2 ] . int := mem [ q + 2 ] . int ;
        mem [ p + 5 ] . int := mem [ q + 5 ] . int ;
        mem [ p + 6 ] . int := mem [ q + 6 ] . int ;
        freenode ( q , 7 ) ;
      End ;
      Procedure splitcubic ( p : halfword ; t : fraction ; xq , yq : scaled ) ;

      Var v : scaled ;
        q , r : halfword ;
      Begin
        q := mem [ p ] . hh . rh ;
        r := getnode ( 7 ) ;
        mem [ p ] . hh . rh := r ;
        mem [ r ] . hh . rh := q ;
        mem [ r ] . hh . b0 := mem [ q ] . hh . b0 ;
        mem [ r ] . hh . b1 := mem [ p ] . hh . b1 ;
        v := mem [ p + 5 ] . int - takefraction ( mem [ p + 5 ] . int - mem [ q + 3 ] . int , t ) ;
        mem [ p + 5 ] . int := mem [ p + 1 ] . int - takefraction ( mem [ p + 1 ] . int - mem [ p + 5 ] . int , t ) ;
        mem [ q + 3 ] . int := mem [ q + 3 ] . int - takefraction ( mem [ q + 3 ] . int - xq , t ) ;
        mem [ r + 3 ] . int := mem [ p + 5 ] . int - takefraction ( mem [ p + 5 ] . int - v , t ) ;
        mem [ r + 5 ] . int := v - takefraction ( v - mem [ q + 3 ] . int , t ) ;
        mem [ r + 1 ] . int := mem [ r + 3 ] . int - takefraction ( mem [ r + 3 ] . int - mem [ r + 5 ] . int , t ) ;
        v := mem [ p + 6 ] . int - takefraction ( mem [ p + 6 ] . int - mem [ q + 4 ] . int , t ) ;
        mem [ p + 6 ] . int := mem [ p + 2 ] . int - takefraction ( mem [ p + 2 ] . int - mem [ p + 6 ] . int , t ) ;
        mem [ q + 4 ] . int := mem [ q + 4 ] . int - takefraction ( mem [ q + 4 ] . int - yq , t ) ;
        mem [ r + 4 ] . int := mem [ p + 6 ] . int - takefraction ( mem [ p + 6 ] . int - v , t ) ;
        mem [ r + 6 ] . int := v - takefraction ( v - mem [ q + 4 ] . int , t ) ;
        mem [ r + 2 ] . int := mem [ r + 4 ] . int - takefraction ( mem [ r + 4 ] . int - mem [ r + 6 ] . int , t ) ;
      End ;
      Procedure quadrantsubdivide ;

      Label 22 , 10 ;

      Var p , q , r , s , pp , qq : halfword ;
        firstx , firsty : scaled ;
        del1 , del2 , del3 , del , dmax : scaled ;
        t : fraction ;
        destx , desty : scaled ;
        constantx : boolean ;
      Begin
        p := curspec ;
        firstx := mem [ curspec + 1 ] . int ;
        firsty := mem [ curspec + 2 ] . int ;
        Repeat
          22 : q := mem [ p ] . hh . rh ;
          If q = curspec Then
            Begin
              destx := firstx ;
              desty := firsty ;
            End
          Else
            Begin
              destx := mem [ q + 1 ] . int ;
              desty := mem [ q + 2 ] . int ;
            End ;
          del1 := mem [ p + 5 ] . int - mem [ p + 1 ] . int ;
          del2 := mem [ q + 3 ] . int - mem [ p + 5 ] . int ;
          del3 := destx - mem [ q + 3 ] . int ;
          If del1 <> 0 Then del := del1
          Else If del2 <> 0 Then del := del2
          Else del := del3 ;
          If del <> 0 Then
            Begin
              dmax := abs ( del1 ) ;
              If abs ( del2 ) > dmax Then dmax := abs ( del2 ) ;
              If abs ( del3 ) > dmax Then dmax := abs ( del3 ) ;
              While dmax < 134217728 Do
                Begin
                  dmax := dmax + dmax ;
                  del1 := del1 + del1 ;
                  del2 := del2 + del2 ;
                  del3 := del3 + del3 ;
                End ;
            End ;
          If del = 0 Then constantx := true
          Else
            Begin
              constantx := false ;
              If del < 0 Then
                Begin
                  mem [ p + 1 ] . int := - mem [ p + 1 ] . int ;
                  mem [ p + 5 ] . int := - mem [ p + 5 ] . int ;
                  mem [ q + 3 ] . int := - mem [ q + 3 ] . int ;
                  del1 := - del1 ;
                  del2 := - del2 ;
                  del3 := - del3 ;
                  destx := - destx ;
                  mem [ p ] . hh . b1 := 2 ;
                End ;
              t := crossingpoint ( del1 , del2 , del3 ) ;
              If t < 268435456 Then
                Begin
                  splitcubic ( p , t , destx , desty ) ;
                  r := mem [ p ] . hh . rh ;
                  If mem [ r ] . hh . b1 > 1 Then mem [ r ] . hh . b1 := 1
                  Else mem [ r ] . hh . b1 := 2 ;
                  If mem [ r + 1 ] . int < mem [ p + 1 ] . int Then mem [ r + 1 ] . int := mem [ p + 1 ] . int ;
                  mem [ r + 3 ] . int := mem [ r + 1 ] . int ;
                  If mem [ p + 5 ] . int > mem [ r + 1 ] . int Then mem [ p + 5 ] . int := mem [ r + 1 ] . int ;
                  mem [ r + 1 ] . int := - mem [ r + 1 ] . int ;
                  mem [ r + 5 ] . int := mem [ r + 1 ] . int ;
                  mem [ q + 3 ] . int := - mem [ q + 3 ] . int ;
                  destx := - destx ;
                  del2 := del2 - takefraction ( del2 - del3 , t ) ;
                  If del2 > 0 Then del2 := 0 ;
                  t := crossingpoint ( 0 , - del2 , - del3 ) ;
                  If t < 268435456 Then
                    Begin
                      splitcubic ( r , t , destx , desty ) ;
                      s := mem [ r ] . hh . rh ;
                      If mem [ s + 1 ] . int < destx Then mem [ s + 1 ] . int := destx ;
                      If mem [ s + 1 ] . int < mem [ r + 1 ] . int Then mem [ s + 1 ] . int := mem [ r + 1 ] . int ;
                      mem [ s ] . hh . b1 := mem [ p ] . hh . b1 ;
                      mem [ s + 3 ] . int := mem [ s + 1 ] . int ;
                      If mem [ q + 3 ] . int < destx Then mem [ q + 3 ] . int := - destx
                      Else If mem [ q + 3 ] . int > mem [ s + 1 ] . int Then mem [ q + 3 ] . int := - mem [ s + 1 ] . int
                      Else mem [ q + 3 ] . int := - mem [ q + 3 ] . int ;
                      mem [ s + 1 ] . int := - mem [ s + 1 ] . int ;
                      mem [ s + 5 ] . int := mem [ s + 1 ] . int ;
                    End
                  Else
                    Begin
                      If mem [ r + 1 ] . int > destx Then
                        Begin
                          mem [ r + 1 ] . int := destx ;
                          mem [ r + 3 ] . int := - mem [ r + 1 ] . int ;
                          mem [ r + 5 ] . int := mem [ r + 1 ] . int ;
                        End ;
                      If mem [ q + 3 ] . int > destx Then mem [ q + 3 ] . int := destx
                      Else If mem [ q + 3 ] . int < mem [ r + 1 ] . int Then mem [ q + 3 ] . int := mem [ r + 1 ] . int ;
                    End ;
                End ;
            End ;
          pp := p ;
          Repeat
            qq := mem [ pp ] . hh . rh ;
            abnegate ( mem [ qq + 1 ] . int , mem [ qq + 2 ] . int , mem [ qq ] . hh . b1 , mem [ pp ] . hh . b1 ) ;
            destx := curx ;
            desty := cury ;
            del1 := mem [ pp + 6 ] . int - mem [ pp + 2 ] . int ;
            del2 := mem [ qq + 4 ] . int - mem [ pp + 6 ] . int ;
            del3 := desty - mem [ qq + 4 ] . int ;
            If del1 <> 0 Then del := del1
            Else If del2 <> 0 Then del := del2
            Else del := del3 ;
            If del <> 0 Then
              Begin
                dmax := abs ( del1 ) ;
                If abs ( del2 ) > dmax Then dmax := abs ( del2 ) ;
                If abs ( del3 ) > dmax Then dmax := abs ( del3 ) ;
                While dmax < 134217728 Do
                  Begin
                    dmax := dmax + dmax ;
                    del1 := del1 + del1 ;
                    del2 := del2 + del2 ;
                    del3 := del3 + del3 ;
                  End ;
              End ;
            If del <> 0 Then
              Begin
                If del < 0 Then
                  Begin
                    mem [ pp + 2 ] . int := - mem [ pp + 2 ] . int ;
                    mem [ pp + 6 ] . int := - mem [ pp + 6 ] . int ;
                    mem [ qq + 4 ] . int := - mem [ qq + 4 ] . int ;
                    del1 := - del1 ;
                    del2 := - del2 ;
                    del3 := - del3 ;
                    desty := - desty ;
                    mem [ pp ] . hh . b1 := mem [ pp ] . hh . b1 + 2 ;
                  End ;
                t := crossingpoint ( del1 , del2 , del3 ) ;
                If t < 268435456 Then
                  Begin
                    splitcubic ( pp , t , destx , desty ) ;
                    r := mem [ pp ] . hh . rh ;
                    If mem [ r ] . hh . b1 > 2 Then mem [ r ] . hh . b1 := mem [ r ] . hh . b1 - 2
                    Else mem [ r ] . hh . b1 := mem [ r ] . hh . b1 + 2 ;
                    If mem [ r + 2 ] . int < mem [ pp + 2 ] . int Then mem [ r + 2 ] . int := mem [ pp + 2 ] . int ;
                    mem [ r + 4 ] . int := mem [ r + 2 ] . int ;
                    If mem [ pp + 6 ] . int > mem [ r + 2 ] . int Then mem [ pp + 6 ] . int := mem [ r + 2 ] . int ;
                    mem [ r + 2 ] . int := - mem [ r + 2 ] . int ;
                    mem [ r + 6 ] . int := mem [ r + 2 ] . int ;
                    mem [ qq + 4 ] . int := - mem [ qq + 4 ] . int ;
                    desty := - desty ;
                    If mem [ r + 1 ] . int < mem [ pp + 1 ] . int Then mem [ r + 1 ] . int := mem [ pp + 1 ] . int
                    Else If mem [ r + 1 ] . int > destx Then mem [ r + 1 ] . int := destx ;
                    If mem [ r + 3 ] . int > mem [ r + 1 ] . int Then
                      Begin
                        mem [ r + 3 ] . int := mem [ r + 1 ] . int ;
                        If mem [ pp + 5 ] . int > mem [ r + 1 ] . int Then mem [ pp + 5 ] . int := mem [ r + 1 ] . int ;
                      End ;
                    If mem [ r + 5 ] . int < mem [ r + 1 ] . int Then
                      Begin
                        mem [ r + 5 ] . int := mem [ r + 1 ] . int ;
                        If mem [ qq + 3 ] . int < mem [ r + 1 ] . int Then mem [ qq + 3 ] . int := mem [ r + 1 ] . int ;
                      End ;
                    del2 := del2 - takefraction ( del2 - del3 , t ) ;
                    If del2 > 0 Then del2 := 0 ;
                    t := crossingpoint ( 0 , - del2 , - del3 ) ;
                    If t < 268435456 Then
                      Begin
                        splitcubic ( r , t , destx , desty ) ;
                        s := mem [ r ] . hh . rh ;
                        If mem [ s + 2 ] . int < desty Then mem [ s + 2 ] . int := desty ;
                        If mem [ s + 2 ] . int < mem [ r + 2 ] . int Then mem [ s + 2 ] . int := mem [ r + 2 ] . int ;
                        mem [ s ] . hh . b1 := mem [ pp ] . hh . b1 ;
                        mem [ s + 4 ] . int := mem [ s + 2 ] . int ;
                        If mem [ qq + 4 ] . int < desty Then mem [ qq + 4 ] . int := - desty
                        Else If mem [ qq + 4 ] . int > mem [ s + 2 ] . int Then mem [ qq + 4 ] . int := - mem [ s + 2 ] . int
                        Else mem [ qq + 4 ] . int := - mem [ qq + 4 ] . int ;
                        mem [ s + 2 ] . int := - mem [ s + 2 ] . int ;
                        mem [ s + 6 ] . int := mem [ s + 2 ] . int ;
                        If mem [ s + 1 ] . int < mem [ r + 1 ] . int Then mem [ s + 1 ] . int := mem [ r + 1 ] . int
                        Else If mem [ s + 1 ] . int > destx Then mem [ s + 1 ] . int := destx ;
                        If mem [ s + 3 ] . int > mem [ s + 1 ] . int Then
                          Begin
                            mem [ s + 3 ] . int := mem [ s + 1 ] . int ;
                            If mem [ r + 5 ] . int > mem [ s + 1 ] . int Then mem [ r + 5 ] . int := mem [ s + 1 ] . int ;
                          End ;
                        If mem [ s + 5 ] . int < mem [ s + 1 ] . int Then
                          Begin
                            mem [ s + 5 ] . int := mem [ s + 1 ] . int ;
                            If mem [ qq + 3 ] . int < mem [ s + 1 ] . int Then mem [ qq + 3 ] . int := mem [ s + 1 ] . int ;
                          End ;
                      End
                    Else
                      Begin
                        If mem [ r + 2 ] . int > desty Then
                          Begin
                            mem [ r + 2 ] . int := desty ;
                            mem [ r + 4 ] . int := - mem [ r + 2 ] . int ;
                            mem [ r + 6 ] . int := mem [ r + 2 ] . int ;
                          End ;
                        If mem [ qq + 4 ] . int > desty Then mem [ qq + 4 ] . int := desty
                        Else If mem [ qq + 4 ] . int < mem [ r + 2 ] . int Then mem [ qq + 4 ] . int := mem [ r + 2 ] . int ;
                      End ;
                  End ;
              End
            Else If constantx Then
                   Begin
                     If q <> p Then
                       Begin
                         removecubic ( p ) ;
                         If curspec <> q Then goto 22
                         Else
                           Begin
                             curspec := p ;
                             goto 10 ;
                           End ;
                       End ;
                   End
            Else If Not odd ( mem [ pp ] . hh . b1 ) Then
                   Begin
                     mem [ pp + 2 ] . int := - mem [ pp + 2 ] . int ;
                     mem [ pp + 6 ] . int := - mem [ pp + 6 ] . int ;
                     mem [ qq + 4 ] . int := - mem [ qq + 4 ] . int ;
                     del1 := - del1 ;
                     del2 := - del2 ;
                     del3 := - del3 ;
                     desty := - desty ;
                     mem [ pp ] . hh . b1 := mem [ pp ] . hh . b1 + 2 ;
                   End ;
            pp := qq ;
          Until pp = q ;
          If constantx Then
            Begin
              pp := p ;
              Repeat
                qq := mem [ pp ] . hh . rh ;
                If mem [ pp ] . hh . b1 > 2 Then
                  Begin
                    mem [ pp ] . hh . b1 := mem [ pp ] . hh . b1 + 1 ;
                    mem [ pp + 1 ] . int := - mem [ pp + 1 ] . int ;
                    mem [ pp + 5 ] . int := - mem [ pp + 5 ] . int ;
                    mem [ qq + 3 ] . int := - mem [ qq + 3 ] . int ;
                  End ;
                pp := qq ;
              Until pp = q ;
            End ;
          p := q ;
        Until p = curspec ;
        10 :
      End ;
      Procedure octantsubdivide ;

      Var p , q , r , s : halfword ;
        del1 , del2 , del3 , del , dmax : scaled ;
        t : fraction ;
        destx , desty : scaled ;
      Begin
        p := curspec ;
        Repeat
          q := mem [ p ] . hh . rh ;
          mem [ p + 1 ] . int := mem [ p + 1 ] . int - mem [ p + 2 ] . int ;
          mem [ p + 5 ] . int := mem [ p + 5 ] . int - mem [ p + 6 ] . int ;
          mem [ q + 3 ] . int := mem [ q + 3 ] . int - mem [ q + 4 ] . int ;
          If q = curspec Then
            Begin
              unskew ( mem [ q + 1 ] . int , mem [ q + 2 ] . int , mem [ q ] . hh . b1 ) ;
              skew ( curx , cury , mem [ p ] . hh . b1 ) ;
              destx := curx ;
              desty := cury ;
            End
          Else
            Begin
              abnegate ( mem [ q + 1 ] . int , mem [ q + 2 ] . int , mem [ q ] . hh . b1 , mem [ p ] . hh . b1 ) ;
              destx := curx - cury ;
              desty := cury ;
            End ;
          del1 := mem [ p + 5 ] . int - mem [ p + 1 ] . int ;
          del2 := mem [ q + 3 ] . int - mem [ p + 5 ] . int ;
          del3 := destx - mem [ q + 3 ] . int ;
          If del1 <> 0 Then del := del1
          Else If del2 <> 0 Then del := del2
          Else del := del3 ;
          If del <> 0 Then
            Begin
              dmax := abs ( del1 ) ;
              If abs ( del2 ) > dmax Then dmax := abs ( del2 ) ;
              If abs ( del3 ) > dmax Then dmax := abs ( del3 ) ;
              While dmax < 134217728 Do
                Begin
                  dmax := dmax + dmax ;
                  del1 := del1 + del1 ;
                  del2 := del2 + del2 ;
                  del3 := del3 + del3 ;
                End ;
            End ;
          If del <> 0 Then
            Begin
              If del < 0 Then
                Begin
                  mem [ p + 2 ] . int := mem [ p + 1 ] . int + mem [ p + 2 ] . int ;
                  mem [ p + 1 ] . int := - mem [ p + 1 ] . int ;
                  mem [ p + 6 ] . int := mem [ p + 5 ] . int + mem [ p + 6 ] . int ;
                  mem [ p + 5 ] . int := - mem [ p + 5 ] . int ;
                  mem [ q + 4 ] . int := mem [ q + 3 ] . int + mem [ q + 4 ] . int ;
                  mem [ q + 3 ] . int := - mem [ q + 3 ] . int ;
                  del1 := - del1 ;
                  del2 := - del2 ;
                  del3 := - del3 ;
                  desty := destx + desty ;
                  destx := - destx ;
                  mem [ p ] . hh . b1 := mem [ p ] . hh . b1 + 4 ;
                End ;
              t := crossingpoint ( del1 , del2 , del3 ) ;
              If t < 268435456 Then
                Begin
                  splitcubic ( p , t , destx , desty ) ;
                  r := mem [ p ] . hh . rh ;
                  If mem [ r ] . hh . b1 > 4 Then mem [ r ] . hh . b1 := mem [ r ] . hh . b1 - 4
                  Else mem [ r ] . hh . b1 := mem [ r ] . hh . b1 + 4 ;
                  If mem [ r + 2 ] . int < mem [ p + 2 ] . int Then mem [ r + 2 ] . int := mem [ p + 2 ] . int
                  Else If mem [ r + 2 ] . int > desty Then mem [ r + 2 ] . int := desty ;
                  If mem [ p + 1 ] . int + mem [ r + 2 ] . int > destx + desty Then mem [ r + 2 ] . int := destx + desty - mem [ p + 1 ] . int ;
                  If mem [ r + 4 ] . int > mem [ r + 2 ] . int Then
                    Begin
                      mem [ r + 4 ] . int := mem [ r + 2 ] . int ;
                      If mem [ p + 6 ] . int > mem [ r + 2 ] . int Then mem [ p + 6 ] . int := mem [ r + 2 ] . int ;
                    End ;
                  If mem [ r + 6 ] . int < mem [ r + 2 ] . int Then
                    Begin
                      mem [ r + 6 ] . int := mem [ r + 2 ] . int ;
                      If mem [ q + 4 ] . int < mem [ r + 2 ] . int Then mem [ q + 4 ] . int := mem [ r + 2 ] . int ;
                    End ;
                  If mem [ r + 1 ] . int < mem [ p + 1 ] . int Then mem [ r + 1 ] . int := mem [ p + 1 ] . int
                  Else If mem [ r + 1 ] . int + mem [ r + 2 ] . int > destx + desty Then mem [ r + 1 ] . int := destx + desty - mem [ r + 2 ] . int ;
                  mem [ r + 3 ] . int := mem [ r + 1 ] . int ;
                  If mem [ p + 5 ] . int > mem [ r + 1 ] . int Then mem [ p + 5 ] . int := mem [ r + 1 ] . int ;
                  mem [ r + 2 ] . int := mem [ r + 2 ] . int + mem [ r + 1 ] . int ;
                  mem [ r + 6 ] . int := mem [ r + 6 ] . int + mem [ r + 1 ] . int ;
                  mem [ r + 1 ] . int := - mem [ r + 1 ] . int ;
                  mem [ r + 5 ] . int := mem [ r + 1 ] . int ;
                  mem [ q + 4 ] . int := mem [ q + 4 ] . int + mem [ q + 3 ] . int ;
                  mem [ q + 3 ] . int := - mem [ q + 3 ] . int ;
                  desty := desty + destx ;
                  destx := - destx ;
                  If mem [ r + 6 ] . int < mem [ r + 2 ] . int Then
                    Begin
                      mem [ r + 6 ] . int := mem [ r + 2 ] . int ;
                      If mem [ q + 4 ] . int < mem [ r + 2 ] . int Then mem [ q + 4 ] . int := mem [ r + 2 ] . int ;
                    End ;
                  del2 := del2 - takefraction ( del2 - del3 , t ) ;
                  If del2 > 0 Then del2 := 0 ;
                  t := crossingpoint ( 0 , - del2 , - del3 ) ;
                  If t < 268435456 Then
                    Begin
                      splitcubic ( r , t , destx , desty ) ;
                      s := mem [ r ] . hh . rh ;
                      If mem [ s + 2 ] . int < mem [ r + 2 ] . int Then mem [ s + 2 ] . int := mem [ r + 2 ] . int
                      Else If mem [ s + 2 ] . int > desty Then mem [ s + 2 ] . int := desty ;
                      If mem [ r + 1 ] . int + mem [ s + 2 ] . int > destx + desty Then mem [ s + 2 ] . int := destx + desty - mem [ r + 1 ] . int ;
                      If mem [ s + 4 ] . int > mem [ s + 2 ] . int Then
                        Begin
                          mem [ s + 4 ] . int := mem [ s + 2 ] . int ;
                          If mem [ r + 6 ] . int > mem [ s + 2 ] . int Then mem [ r + 6 ] . int := mem [ s + 2 ] . int ;
                        End ;
                      If mem [ s + 6 ] . int < mem [ s + 2 ] . int Then
                        Begin
                          mem [ s + 6 ] . int := mem [ s + 2 ] . int ;
                          If mem [ q + 4 ] . int < mem [ s + 2 ] . int Then mem [ q + 4 ] . int := mem [ s + 2 ] . int ;
                        End ;
                      If mem [ s + 1 ] . int + mem [ s + 2 ] . int > destx + desty Then mem [ s + 1 ] . int := destx + desty - mem [ s + 2 ] . int
                      Else
                        Begin
                          If mem [ s + 1 ] . int < destx Then mem [ s + 1 ] . int := destx ;
                          If mem [ s + 1 ] . int < mem [ r + 1 ] . int Then mem [ s + 1 ] . int := mem [ r + 1 ] . int ;
                        End ;
                      mem [ s ] . hh . b1 := mem [ p ] . hh . b1 ;
                      mem [ s + 3 ] . int := mem [ s + 1 ] . int ;
                      If mem [ q + 3 ] . int < destx Then
                        Begin
                          mem [ q + 4 ] . int := mem [ q + 4 ] . int + destx ;
                          mem [ q + 3 ] . int := - destx ;
                        End
                      Else If mem [ q + 3 ] . int > mem [ s + 1 ] . int Then
                             Begin
                               mem [ q + 4 ] . int := mem [ q + 4 ] . int + mem [ s + 1 ] . int ;
                               mem [ q + 3 ] . int := - mem [ s + 1 ] . int ;
                             End
                      Else
                        Begin
                          mem [ q + 4 ] . int := mem [ q + 4 ] . int + mem [ q + 3 ] . int ;
                          mem [ q + 3 ] . int := - mem [ q + 3 ] . int ;
                        End ;
                      mem [ s + 2 ] . int := mem [ s + 2 ] . int + mem [ s + 1 ] . int ;
                      mem [ s + 6 ] . int := mem [ s + 6 ] . int + mem [ s + 1 ] . int ;
                      mem [ s + 1 ] . int := - mem [ s + 1 ] . int ;
                      mem [ s + 5 ] . int := mem [ s + 1 ] . int ;
                      If mem [ s + 6 ] . int < mem [ s + 2 ] . int Then
                        Begin
                          mem [ s + 6 ] . int := mem [ s + 2 ] . int ;
                          If mem [ q + 4 ] . int < mem [ s + 2 ] . int Then mem [ q + 4 ] . int := mem [ s + 2 ] . int ;
                        End ;
                    End
                  Else
                    Begin
                      If mem [ r + 1 ] . int > destx Then
                        Begin
                          mem [ r + 1 ] . int := destx ;
                          mem [ r + 3 ] . int := - mem [ r + 1 ] . int ;
                          mem [ r + 5 ] . int := mem [ r + 1 ] . int ;
                        End ;
                      If mem [ q + 3 ] . int > destx Then mem [ q + 3 ] . int := destx
                      Else If mem [ q + 3 ] . int < mem [ r + 1 ] . int Then mem [ q + 3 ] . int := mem [ r + 1 ] . int ;
                    End ;
                End ;
            End ;
          p := q ;
        Until p = curspec ;
      End ;
      Procedure makesafe ;

      Var k : 0 .. maxwiggle ;
        allsafe : boolean ;
        nexta : scaled ;
        deltaa , deltab : scaled ;
      Begin
        before [ curroundingptr ] := before [ 0 ] ;
        nodetoround [ curroundingptr ] := nodetoround [ 0 ] ;
        Repeat
          after [ curroundingptr ] := after [ 0 ] ;
          allsafe := true ;
          nexta := after [ 0 ] ;
          For k := 0 To curroundingptr - 1 Do
            Begin
              deltab := before [ k + 1 ] - before [ k ] ;
              If deltab >= 0 Then deltaa := after [ k + 1 ] - nexta
              Else deltaa := nexta - after [ k + 1 ] ;
              nexta := after [ k + 1 ] ;
              If ( deltaa < 0 ) Or ( deltaa > abs ( deltab + deltab ) ) Then
                Begin
                  allsafe := false ;
                  after [ k ] := before [ k ] ;
                  If k = curroundingptr - 1 Then after [ 0 ] := before [ 0 ]
                  Else after [ k + 1 ] := before [ k + 1 ] ;
                End ;
            End ;
        Until allsafe ;
      End ;
      Procedure beforeandafter ( b , a : scaled ; p : halfword ) ;
      Begin
        If curroundingptr = maxroundingptr Then If maxroundingptr < maxwiggle Then maxroundingptr := maxroundingptr + 1
        Else overflow ( 568 , maxwiggle ) ;
        after [ curroundingptr ] := a ;
        before [ curroundingptr ] := b ;
        nodetoround [ curroundingptr ] := p ;
        curroundingptr := curroundingptr + 1 ;
      End ;
      Function goodval ( b , o : scaled ) : scaled ;

      Var a : scaled ;
      Begin
        a := b + o ;
        If a >= 0 Then a := a - ( a Mod curgran ) - o
        Else a := a + ( ( - ( a + 1 ) ) Mod curgran ) - curgran + 1 - o ;
        If b - a < a + curgran - b Then goodval := a
        Else goodval := a + curgran ;
      End ;
      Function compromise ( u , v : scaled ) : scaled ;
      Begin
        compromise := ( goodval ( u + u , - u - v ) ) Div 2 ;
      End ;
      Procedure xyround ;

      Var p , q : halfword ;
        b , a : scaled ;
        penedge : scaled ;
        alpha : fraction ;
      Begin
        curgran := abs ( internal [ 37 ] ) ;
        If curgran = 0 Then curgran := 65536 ;
        p := curspec ;
        curroundingptr := 0 ;
        Repeat
          q := mem [ p ] . hh . rh ;
          If odd ( mem [ p ] . hh . b1 ) <> odd ( mem [ q ] . hh . b1 ) Then
            Begin
              If odd ( mem [ q ] . hh . b1 ) Then b := mem [ q + 1 ] . int
              Else b := - mem [ q + 1 ] . int ;
              If ( abs ( mem [ q + 1 ] . int - mem [ q + 5 ] . int ) < 655 ) Or ( abs ( mem [ q + 1 ] . int + mem [ q + 3 ] . int ) < 655 ) Then
                Begin
                  If curpen = 3 Then penedge := 0
                  Else If curpathtype = 0 Then penedge := compromise ( mem [ mem [ curpen + 5 ] . hh . rh + 2 ] . int , mem [ mem [ curpen + 7 ] . hh . rh + 2 ] . int )
                  Else If odd ( mem [ q ] . hh . b1 ) Then penedge := mem [ mem [ curpen + 7 ] . hh . rh + 2 ] . int
                  Else penedge := mem [ mem [ curpen + 5 ] . hh . rh + 2 ] . int ;
                  a := goodval ( b , penedge ) ;
                End
              Else a := b ;
              If abs ( a ) > maxallowed Then If a > 0 Then a := maxallowed
              Else a := - maxallowed ;
              beforeandafter ( b , a , q ) ;
            End ;
          p := q ;
        Until p = curspec ;
        If curroundingptr > 0 Then
          Begin
            makesafe ;
            Repeat
              curroundingptr := curroundingptr - 1 ;
              If ( after [ curroundingptr ] <> before [ curroundingptr ] ) Or ( after [ curroundingptr + 1 ] <> before [ curroundingptr + 1 ] ) Then
                Begin
                  p := nodetoround [ curroundingptr ] ;
                  If odd ( mem [ p ] . hh . b1 ) Then
                    Begin
                      b := before [ curroundingptr ] ;
                      a := after [ curroundingptr ] ;
                    End
                  Else
                    Begin
                      b := - before [ curroundingptr ] ;
                      a := - after [ curroundingptr ] ;
                    End ;
                  If before [ curroundingptr ] = before [ curroundingptr + 1 ] Then alpha := 268435456
                  Else alpha := makefraction ( after [ curroundingptr + 1 ] - after [ curroundingptr ] , before [ curroundingptr + 1 ] - before [ curroundingptr ] ) ;
                  Repeat
                    mem [ p + 1 ] . int := takefraction ( alpha , mem [ p + 1 ] . int - b ) + a ;
                    mem [ p + 5 ] . int := takefraction ( alpha , mem [ p + 5 ] . int - b ) + a ;
                    p := mem [ p ] . hh . rh ;
                    mem [ p + 3 ] . int := takefraction ( alpha , mem [ p + 3 ] . int - b ) + a ;
                  Until p = nodetoround [ curroundingptr + 1 ] ;
                End ;
            Until curroundingptr = 0 ;
          End ;
        p := curspec ;
        curroundingptr := 0 ;
        Repeat
          q := mem [ p ] . hh . rh ;
          If ( mem [ p ] . hh . b1 > 2 ) <> ( mem [ q ] . hh . b1 > 2 ) Then
            Begin
              If mem [ q ] . hh . b1 <= 2 Then b := mem [ q + 2 ] . int
              Else b := - mem [ q + 2 ] . int ;
              If ( abs ( mem [ q + 2 ] . int - mem [ q + 6 ] . int ) < 655 ) Or ( abs ( mem [ q + 2 ] . int + mem [ q + 4 ] . int ) < 655 ) Then
                Begin
                  If curpen = 3 Then penedge := 0
                  Else If curpathtype = 0 Then penedge := compromise ( mem [ mem [ curpen + 2 ] . hh . rh + 2 ] . int , mem [ mem [ curpen + 1 ] . hh . rh + 2 ] . int )
                  Else If mem [ q ] . hh . b1 <= 2 Then penedge := mem [ mem [ curpen + 1 ] . hh . rh + 2 ] . int
                  Else penedge := mem [ mem [ curpen + 2 ] . hh . rh + 2 ] . int ;
                  a := goodval ( b , penedge ) ;
                End
              Else a := b ;
              If abs ( a ) > maxallowed Then If a > 0 Then a := maxallowed
              Else a := - maxallowed ;
              beforeandafter ( b , a , q ) ;
            End ;
          p := q ;
        Until p = curspec ;
        If curroundingptr > 0 Then
          Begin
            makesafe ;
            Repeat
              curroundingptr := curroundingptr - 1 ;
              If ( after [ curroundingptr ] <> before [ curroundingptr ] ) Or ( after [ curroundingptr + 1 ] <> before [ curroundingptr + 1 ] ) Then
                Begin
                  p := nodetoround [ curroundingptr ] ;
                  If mem [ p ] . hh . b1 <= 2 Then
                    Begin
                      b := before [ curroundingptr ] ;
                      a := after [ curroundingptr ] ;
                    End
                  Else
                    Begin
                      b := - before [ curroundingptr ] ;
                      a := - after [ curroundingptr ] ;
                    End ;
                  If before [ curroundingptr ] = before [ curroundingptr + 1 ] Then alpha := 268435456
                  Else alpha := makefraction ( after [ curroundingptr + 1 ] - after [ curroundingptr ] , before [ curroundingptr + 1 ] - before [ curroundingptr ] ) ;
                  Repeat
                    mem [ p + 2 ] . int := takefraction ( alpha , mem [ p + 2 ] . int - b ) + a ;
                    mem [ p + 6 ] . int := takefraction ( alpha , mem [ p + 6 ] . int - b ) + a ;
                    p := mem [ p ] . hh . rh ;
                    mem [ p + 4 ] . int := takefraction ( alpha , mem [ p + 4 ] . int - b ) + a ;
                  Until p = nodetoround [ curroundingptr + 1 ] ;
                End ;
            Until curroundingptr = 0 ;
          End ;
      End ;
      Procedure diaground ;

      Var p , q , pp : halfword ;
        b , a , bb , aa , d , c , dd , cc : scaled ;
        penedge : scaled ;
        alpha , beta : fraction ;
        nexta : scaled ;
        allsafe : boolean ;
        k : 0 .. maxwiggle ;
        firstx , firsty : scaled ;
      Begin
        p := curspec ;
        curroundingptr := 0 ;
        Repeat
          q := mem [ p ] . hh . rh ;
          If mem [ p ] . hh . b1 <> mem [ q ] . hh . b1 Then
            Begin
              If mem [ q ] . hh . b1 > 4 Then b := - mem [ q + 1 ] . int
              Else b := mem [ q + 1 ] . int ;
              If abs ( mem [ q ] . hh . b1 - mem [ p ] . hh . b1 ) = 4 Then If ( abs ( mem [ q + 1 ] . int - mem [ q + 5 ] . int ) < 655 ) Or ( abs ( mem [ q + 1 ] . int + mem [ q + 3 ] . int ) < 655 ) Then
                                                                              Begin
                                                                                If curpen = 3 Then penedge := 0
                                                                                Else If curpathtype = 0 Then Case mem [ q ] . hh . b1 Of 
                                                                                                               1 , 5 : penedge := compromise ( mem [ mem [ mem [ curpen + 1 ] . hh . rh ] . hh . lh + 1 ] . int , - mem [ mem [ mem [ curpen + 4 ] . hh . rh ] . hh . lh + 1 ] . int ) ;
                                                                                                               4 , 8 : penedge := - compromise ( mem [ mem [ mem [ curpen + 1 ] . hh . rh ] . hh . lh + 1 ] . int , - mem [ mem [ mem [ curpen + 4 ] . hh . rh ] . hh . lh + 1 ] . int ) ;
                                                                                                               6 , 2 : penedge := compromise ( mem [ mem [ mem [ curpen + 2 ] . hh . rh ] . hh . lh + 1 ] . int , - mem [ mem [ mem [ curpen + 3 ] . hh . rh ] . hh . lh + 1 ] . int ) ;
                                                                                                               7 , 3 : penedge := - compromise ( mem [ mem [ mem [ curpen + 2 ] . hh . rh ] . hh . lh + 1 ] . int , - mem [ mem [ mem [ curpen + 3 ] . hh . rh ] . hh . lh + 1 ] . int ) ;
                                                                                       End
                                                                                Else If mem [ q ] . hh . b1 <= 4 Then penedge := mem [ mem [ mem [ curpen + mem [ q ] . hh . b1 ] . hh . rh ] . hh . lh + 1 ] . int
                                                                                Else penedge := - mem [ mem [ mem [ curpen + mem [ q ] . hh . b1 ] . hh . rh ] . hh . lh + 1 ] . int ;
                                                                                If odd ( mem [ q ] . hh . b1 ) Then a := goodval ( b , penedge + ( curgran ) Div 2 )
                                                                                Else a := goodval ( b - 1 , penedge + ( curgran ) Div 2 ) ;
                                                                              End
              Else a := b
              Else a := b ;
              beforeandafter ( b , a , q ) ;
            End ;
          p := q ;
        Until p = curspec ;
        If curroundingptr > 0 Then
          Begin
            p := nodetoround [ 0 ] ;
            firstx := mem [ p + 1 ] . int ;
            firsty := mem [ p + 2 ] . int ;
            before [ curroundingptr ] := before [ 0 ] ;
            nodetoround [ curroundingptr ] := nodetoround [ 0 ] ;
            Repeat
              after [ curroundingptr ] := after [ 0 ] ;
              allsafe := true ;
              nexta := after [ 0 ] ;
              For k := 0 To curroundingptr - 1 Do
                Begin
                  a := nexta ;
                  b := before [ k ] ;
                  nexta := after [ k + 1 ] ;
                  aa := nexta ;
                  bb := before [ k + 1 ] ;
                  If ( a <> b ) Or ( aa <> bb ) Then
                    Begin
                      p := nodetoround [ k ] ;
                      pp := nodetoround [ k + 1 ] ;
                      If aa = bb Then
                        Begin
                          If pp = nodetoround [ 0 ] Then unskew ( firstx , firsty , mem [ pp ] . hh . b1 )
                          Else unskew ( mem [ pp + 1 ] . int , mem [ pp + 2 ] . int , mem [ pp ] . hh . b1 ) ;
                          skew ( curx , cury , mem [ p ] . hh . b1 ) ;
                          bb := curx ;
                          aa := bb ;
                          dd := cury ;
                          cc := dd ;
                          If mem [ p ] . hh . b1 > 4 Then
                            Begin
                              b := - b ;
                              a := - a ;
                            End ;
                        End
                      Else
                        Begin
                          If mem [ p ] . hh . b1 > 4 Then
                            Begin
                              bb := - bb ;
                              aa := - aa ;
                              b := - b ;
                              a := - a ;
                            End ;
                          If pp = nodetoround [ 0 ] Then dd := firsty - bb
                          Else dd := mem [ pp + 2 ] . int - bb ;
                          If odd ( aa - bb ) Then If mem [ p ] . hh . b1 > 4 Then cc := dd - ( aa - bb + 1 ) Div 2
                          Else cc := dd - ( aa - bb - 1 ) Div 2
                          Else cc := dd - ( aa - bb ) Div 2 ;
                        End ;
                      d := mem [ p + 2 ] . int ;
                      If odd ( a - b ) Then If mem [ p ] . hh . b1 > 4 Then c := d - ( a - b - 1 ) Div 2
                      Else c := d - ( a - b + 1 ) Div 2
                      Else c := d - ( a - b ) Div 2 ;
                      If ( aa < a ) Or ( cc < c ) Or ( aa - a > 2 * ( bb - b ) ) Or ( cc - c > 2 * ( dd - d ) ) Then
                        Begin
                          allsafe := false ;
                          after [ k ] := before [ k ] ;
                          If k = curroundingptr - 1 Then after [ 0 ] := before [ 0 ]
                          Else after [ k + 1 ] := before [ k + 1 ] ;
                        End ;
                    End ;
                End ;
            Until allsafe ;
            For k := 0 To curroundingptr - 1 Do
              Begin
                a := after [ k ] ;
                b := before [ k ] ;
                aa := after [ k + 1 ] ;
                bb := before [ k + 1 ] ;
                If ( a <> b ) Or ( aa <> bb ) Then
                  Begin
                    p := nodetoround [ k ] ;
                    pp := nodetoround [ k + 1 ] ;
                    If aa = bb Then
                      Begin
                        If pp = nodetoround [ 0 ] Then unskew ( firstx , firsty , mem [ pp ] . hh . b1 )
                        Else unskew ( mem [ pp + 1 ] . int , mem [ pp + 2 ] . int , mem [ pp ] . hh . b1 ) ;
                        skew ( curx , cury , mem [ p ] . hh . b1 ) ;
                        bb := curx ;
                        aa := bb ;
                        dd := cury ;
                        cc := dd ;
                        If mem [ p ] . hh . b1 > 4 Then
                          Begin
                            b := - b ;
                            a := - a ;
                          End ;
                      End
                    Else
                      Begin
                        If mem [ p ] . hh . b1 > 4 Then
                          Begin
                            bb := - bb ;
                            aa := - aa ;
                            b := - b ;
                            a := - a ;
                          End ;
                        If pp = nodetoround [ 0 ] Then dd := firsty - bb
                        Else dd := mem [ pp + 2 ] . int - bb ;
                        If odd ( aa - bb ) Then If mem [ p ] . hh . b1 > 4 Then cc := dd - ( aa - bb + 1 ) Div 2
                        Else cc := dd - ( aa - bb - 1 ) Div 2
                        Else cc := dd - ( aa - bb ) Div 2 ;
                      End ;
                    d := mem [ p + 2 ] . int ;
                    If odd ( a - b ) Then If mem [ p ] . hh . b1 > 4 Then c := d - ( a - b - 1 ) Div 2
                    Else c := d - ( a - b + 1 ) Div 2
                    Else c := d - ( a - b ) Div 2 ;
                    If b = bb Then alpha := 268435456
                    Else alpha := makefraction ( aa - a , bb - b ) ;
                    If d = dd Then beta := 268435456
                    Else beta := makefraction ( cc - c , dd - d ) ;
                    Repeat
                      mem [ p + 1 ] . int := takefraction ( alpha , mem [ p + 1 ] . int - b ) + a ;
                      mem [ p + 2 ] . int := takefraction ( beta , mem [ p + 2 ] . int - d ) + c ;
                      mem [ p + 5 ] . int := takefraction ( alpha , mem [ p + 5 ] . int - b ) + a ;
                      mem [ p + 6 ] . int := takefraction ( beta , mem [ p + 6 ] . int - d ) + c ;
                      p := mem [ p ] . hh . rh ;
                      mem [ p + 3 ] . int := takefraction ( alpha , mem [ p + 3 ] . int - b ) + a ;
                      mem [ p + 4 ] . int := takefraction ( beta , mem [ p + 4 ] . int - d ) + c ;
                    Until p = pp ;
                  End ;
              End ;
          End ;
      End ;
      Procedure newboundary ( p : halfword ; octant : smallnumber ) ;

      Var q , r : halfword ;
      Begin
        q := mem [ p ] . hh . rh ;
        r := getnode ( 7 ) ;
        mem [ r ] . hh . rh := q ;
        mem [ p ] . hh . rh := r ;
        mem [ r ] . hh . b0 := mem [ q ] . hh . b0 ;
        mem [ r + 3 ] . int := mem [ q + 3 ] . int ;
        mem [ r + 4 ] . int := mem [ q + 4 ] . int ;
        mem [ r ] . hh . b1 := 0 ;
        mem [ q ] . hh . b0 := 0 ;
        mem [ r + 5 ] . int := octant ;
        mem [ q + 3 ] . int := mem [ q ] . hh . b1 ;
        unskew ( mem [ q + 1 ] . int , mem [ q + 2 ] . int , mem [ q ] . hh . b1 ) ;
        skew ( curx , cury , octant ) ;
        mem [ r + 1 ] . int := curx ;
        mem [ r + 2 ] . int := cury ;
      End ;
      Function makespec ( h : halfword ; safetymargin : scaled ; tracing : integer ) : halfword ;

      Label 22 , 30 ;

      Var p , q , r , s : halfword ;
        k : integer ;
        chopped : integer ;
        o1 , o2 : smallnumber ;
        clockwise : boolean ;
        dx1 , dy1 , dx2 , dy2 : integer ;
        dmax , del : integer ;
      Begin
        curspec := h ;
        If tracing > 0 Then printpath ( curspec , 559 , true ) ;
        maxallowed := 268402687 - safetymargin ;
        p := curspec ;
        k := 1 ;
        chopped := 0 ;
        dmax := ( maxallowed ) Div 2 ;
        Repeat
          If abs ( mem [ p + 3 ] . int ) >= dmax Then If abs ( mem [ p + 3 ] . int ) > maxallowed Then
                                                        Begin
                                                          chopped := 1 ;
                                                          If mem [ p + 3 ] . int > 0 Then mem [ p + 3 ] . int := maxallowed
                                                          Else mem [ p + 3 ] . int := - maxallowed ;
                                                        End
          Else If chopped = 0 Then chopped := - 1 ;
          If abs ( mem [ p + 4 ] . int ) >= dmax Then If abs ( mem [ p + 4 ] . int ) > maxallowed Then
                                                        Begin
                                                          chopped := 1 ;
                                                          If mem [ p + 4 ] . int > 0 Then mem [ p + 4 ] . int := maxallowed
                                                          Else mem [ p + 4 ] . int := - maxallowed ;
                                                        End
          Else If chopped = 0 Then chopped := - 1 ;
          If abs ( mem [ p + 1 ] . int ) >= dmax Then If abs ( mem [ p + 1 ] . int ) > maxallowed Then
                                                        Begin
                                                          chopped := 1 ;
                                                          If mem [ p + 1 ] . int > 0 Then mem [ p + 1 ] . int := maxallowed
                                                          Else mem [ p + 1 ] . int := - maxallowed ;
                                                        End
          Else If chopped = 0 Then chopped := - 1 ;
          If abs ( mem [ p + 2 ] . int ) >= dmax Then If abs ( mem [ p + 2 ] . int ) > maxallowed Then
                                                        Begin
                                                          chopped := 1 ;
                                                          If mem [ p + 2 ] . int > 0 Then mem [ p + 2 ] . int := maxallowed
                                                          Else mem [ p + 2 ] . int := - maxallowed ;
                                                        End
          Else If chopped = 0 Then chopped := - 1 ;
          If abs ( mem [ p + 5 ] . int ) >= dmax Then If abs ( mem [ p + 5 ] . int ) > maxallowed Then
                                                        Begin
                                                          chopped := 1 ;
                                                          If mem [ p + 5 ] . int > 0 Then mem [ p + 5 ] . int := maxallowed
                                                          Else mem [ p + 5 ] . int := - maxallowed ;
                                                        End
          Else If chopped = 0 Then chopped := - 1 ;
          If abs ( mem [ p + 6 ] . int ) >= dmax Then If abs ( mem [ p + 6 ] . int ) > maxallowed Then
                                                        Begin
                                                          chopped := 1 ;
                                                          If mem [ p + 6 ] . int > 0 Then mem [ p + 6 ] . int := maxallowed
                                                          Else mem [ p + 6 ] . int := - maxallowed ;
                                                        End
          Else If chopped = 0 Then chopped := - 1 ;
          p := mem [ p ] . hh . rh ;
          mem [ p ] . hh . b0 := k ;
          If k < 255 Then k := k + 1
          Else k := 1 ;
        Until p = curspec ;
        If chopped > 0 Then
          Begin
            Begin
              If interaction = 3 Then ;
              printnl ( 261 ) ;
              print ( 563 ) ;
            End ;
            Begin
              helpptr := 4 ;
              helpline [ 3 ] := 564 ;
              helpline [ 2 ] := 565 ;
              helpline [ 1 ] := 566 ;
              helpline [ 0 ] := 567 ;
            End ;
            putgeterror ;
          End ;
        quadrantsubdivide ;
        If ( internal [ 36 ] > 0 ) And ( chopped = 0 ) Then xyround ;
        octantsubdivide ;
        If ( internal [ 36 ] > 65536 ) And ( chopped = 0 ) Then diaground ;
        p := curspec ;
        Repeat
          22 : q := mem [ p ] . hh . rh ;
          If p <> q Then
            Begin
              If mem [ p + 1 ] . int = mem [ p + 5 ] . int Then If mem [ p + 2 ] . int = mem [ p + 6 ] . int Then If mem [ p + 1 ] . int = mem [ q + 3 ] . int Then If mem [ p + 2 ] . int = mem [ q + 4 ] . int Then
                                                                                                                                                                      Begin
                                                                                                                                                                        unskew ( mem [ q + 1 ] . int , mem [ q + 2 ] . int , mem [ q ] . hh . b1 ) ;
                                                                                                                                                                        skew ( curx , cury , mem [ p ] . hh . b1 ) ;
                                                                                                                                                                        If mem [ p + 1 ] . int = curx Then If mem [ p + 2 ] . int = cury Then
                                                                                                                                                                                                             Begin
                                                                                                                                                                                                               removecubic ( p ) ;
                                                                                                                                                                                                               If q <> curspec Then goto 22 ;
                                                                                                                                                                                                               curspec := p ;
                                                                                                                                                                                                               q := p ;
                                                                                                                                                                                                             End ;
                                                                                                                                                                      End ;
            End ;
          p := q ;
        Until p = curspec ; ;
        turningnumber := 0 ;
        p := curspec ;
        q := mem [ p ] . hh . rh ;
        Repeat
          r := mem [ q ] . hh . rh ;
          If ( mem [ p ] . hh . b1 <> mem [ q ] . hh . b1 ) Or ( q = r ) Then
            Begin
              newboundary ( p , mem [ p ] . hh . b1 ) ;
              s := mem [ p ] . hh . rh ;
              o1 := octantnumber [ mem [ p ] . hh . b1 ] ;
              o2 := octantnumber [ mem [ q ] . hh . b1 ] ;
              Case o2 - o1 Of 
                1 , - 7 , 7 , - 1 : goto 30 ;
                2 , - 6 : clockwise := false ;
                3 , - 5 , 4 , - 4 , 5 , - 3 :
                                              Begin
                                                dx1 := mem [ s + 1 ] . int - mem [ s + 3 ] . int ;
                                                dy1 := mem [ s + 2 ] . int - mem [ s + 4 ] . int ;
                                                If dx1 = 0 Then If dy1 = 0 Then
                                                                  Begin
                                                                    dx1 := mem [ s + 1 ] . int - mem [ p + 5 ] . int ;
                                                                    dy1 := mem [ s + 2 ] . int - mem [ p + 6 ] . int ;
                                                                    If dx1 = 0 Then If dy1 = 0 Then
                                                                                      Begin
                                                                                        dx1 := mem [ s + 1 ] . int - mem [ p + 1 ] . int ;
                                                                                        dy1 := mem [ s + 2 ] . int - mem [ p + 2 ] . int ;
                                                                                      End ;
                                                                  End ;
                                                dmax := abs ( dx1 ) ;
                                                If abs ( dy1 ) > dmax Then dmax := abs ( dy1 ) ;
                                                While dmax < 268435456 Do
                                                  Begin
                                                    dmax := dmax + dmax ;
                                                    dx1 := dx1 + dx1 ;
                                                    dy1 := dy1 + dy1 ;
                                                  End ;
                                                dx2 := mem [ q + 5 ] . int - mem [ q + 1 ] . int ;
                                                dy2 := mem [ q + 6 ] . int - mem [ q + 2 ] . int ;
                                                If dx2 = 0 Then If dy2 = 0 Then
                                                                  Begin
                                                                    dx2 := mem [ r + 3 ] . int - mem [ q + 1 ] . int ;
                                                                    dy2 := mem [ r + 4 ] . int - mem [ q + 2 ] . int ;
                                                                    If dx2 = 0 Then If dy2 = 0 Then
                                                                                      Begin
                                                                                        If mem [ r ] . hh . b1 = 0 Then
                                                                                          Begin
                                                                                            curx := mem [ r + 1 ] . int ;
                                                                                            cury := mem [ r + 2 ] . int ;
                                                                                          End
                                                                                        Else
                                                                                          Begin
                                                                                            unskew ( mem [ r + 1 ] . int , mem [ r + 2 ] . int , mem [ r ] . hh . b1 ) ;
                                                                                            skew ( curx , cury , mem [ q ] . hh . b1 ) ;
                                                                                          End ;
                                                                                        dx2 := curx - mem [ q + 1 ] . int ;
                                                                                        dy2 := cury - mem [ q + 2 ] . int ;
                                                                                      End ;
                                                                  End ;
                                                dmax := abs ( dx2 ) ;
                                                If abs ( dy2 ) > dmax Then dmax := abs ( dy2 ) ;
                                                While dmax < 268435456 Do
                                                  Begin
                                                    dmax := dmax + dmax ;
                                                    dx2 := dx2 + dx2 ;
                                                    dy2 := dy2 + dy2 ;
                                                  End ;
                                                unskew ( dx1 , dy1 , mem [ p ] . hh . b1 ) ;
                                                del := pythadd ( curx , cury ) ;
                                                dx1 := makefraction ( curx , del ) ;
                                                dy1 := makefraction ( cury , del ) ;
                                                unskew ( dx2 , dy2 , mem [ q ] . hh . b1 ) ;
                                                del := pythadd ( curx , cury ) ;
                                                dx2 := makefraction ( curx , del ) ;
                                                dy2 := makefraction ( cury , del ) ;
                                                del := takefraction ( dx1 , dy2 ) - takefraction ( dx2 , dy1 ) ;
                                                If del > 4684844 Then clockwise := false
                                                Else If del < - 4684844 Then clockwise := true
                                                Else clockwise := revturns ;
                                              End ;
                6 , - 2 : clockwise := true ;
                0 : clockwise := revturns ;
              End ;
              While true Do
                Begin
                  If clockwise Then If o1 = 1 Then o1 := 8
                  Else o1 := o1 - 1
                  Else If o1 = 8 Then o1 := 1
                  Else o1 := o1 + 1 ;
                  If o1 = o2 Then goto 30 ;
                  newboundary ( s , octantcode [ o1 ] ) ;
                  s := mem [ s ] . hh . rh ;
                  mem [ s + 3 ] . int := mem [ s + 5 ] . int ;
                End ;
              30 : If q = r Then
                     Begin
                       q := mem [ q ] . hh . rh ;
                       r := q ;
                       p := s ;
                       mem [ s ] . hh . rh := q ;
                       mem [ q + 3 ] . int := mem [ q + 5 ] . int ;
                       mem [ q ] . hh . b0 := 0 ;
                       freenode ( curspec , 7 ) ;
                       curspec := q ;
                     End ;
              p := mem [ p ] . hh . rh ;
              Repeat
                s := mem [ p ] . hh . rh ;
                o1 := octantnumber [ mem [ p + 5 ] . int ] ;
                o2 := octantnumber [ mem [ s + 3 ] . int ] ;
                If abs ( o1 - o2 ) = 1 Then
                  Begin
                    If o2 < o1 Then o2 := o1 ;
                    If odd ( o2 ) Then mem [ p + 6 ] . int := 0
                    Else mem [ p + 6 ] . int := 1 ;
                  End
                Else
                  Begin
                    If o1 = 8 Then turningnumber := turningnumber + 1
                    Else turningnumber := turningnumber - 1 ;
                    mem [ p + 6 ] . int := 0 ;
                  End ;
                mem [ s + 4 ] . int := mem [ p + 6 ] . int ;
                p := s ;
              Until p = q ;
            End ;
          p := q ;
          q := r ;
        Until p = curspec ; ;
        While mem [ curspec ] . hh . b0 <> 0 Do
          curspec := mem [ curspec ] . hh . rh ;
        If tracing > 0 Then If ( internal [ 36 ] <= 0 ) Or ( chopped <> 0 ) Then printspec ( 560 )
        Else If internal [ 36 ] > 65536 Then printspec ( 561 )
        Else printspec ( 562 ) ;
        makespec := curspec ;
      End ;
      Procedure endround ( x , y : scaled ) ;
      Begin
        y := y + 32768 - ycorr [ octant ] ;
        x := x + y - xcorr [ octant ] ;
        m1 := floorunscaled ( x ) ;
        n1 := floorunscaled ( y ) ;
        If x - 65536 * m1 >= y - 65536 * n1 + zcorr [ octant ] Then d1 := 1
        Else d1 := 0 ;
      End ;
      Procedure fillspec ( h : halfword ) ;

      Var p , q , r , s : halfword ;
      Begin
        If internal [ 10 ] > 0 Then beginedgetracing ;
        p := h ;
        Repeat
          octant := mem [ p + 3 ] . int ;
          q := p ;
          While mem [ q ] . hh . b1 <> 0 Do
            q := mem [ q ] . hh . rh ;
          If q <> p Then
            Begin
              endround ( mem [ p + 1 ] . int , mem [ p + 2 ] . int ) ;
              m0 := m1 ;
              n0 := n1 ;
              d0 := d1 ;
              endround ( mem [ q + 1 ] . int , mem [ q + 2 ] . int ) ;
              If n1 - n0 >= movesize Then overflow ( 540 , movesize ) ;
              move [ 0 ] := d0 ;
              moveptr := 0 ;
              r := p ;
              Repeat
                s := mem [ r ] . hh . rh ;
                makemoves ( mem [ r + 1 ] . int , mem [ r + 5 ] . int , mem [ s + 3 ] . int , mem [ s + 1 ] . int , mem [ r + 2 ] . int + 32768 , mem [ r + 6 ] . int + 32768 , mem [ s + 4 ] . int + 32768 , mem [ s + 2 ] . int + 32768 , xycorr [ octant ] , ycorr [ octant ] ) ;
                r := s ;
              Until r = q ;
              move [ moveptr ] := move [ moveptr ] - d1 ;
              If internal [ 35 ] > 0 Then smoothmoves ( 0 , moveptr ) ;
              movetoedges ( m0 , n0 , m1 , n1 ) ;
            End ;
          p := mem [ q ] . hh . rh ;
        Until p = h ;
        tossknotlist ( h ) ;
        If internal [ 10 ] > 0 Then endedgetracing ;
      End ;
      Procedure dupoffset ( w : halfword ) ;

      Var r : halfword ;
      Begin
        r := getnode ( 3 ) ;
        mem [ r + 1 ] . int := mem [ w + 1 ] . int ;
        mem [ r + 2 ] . int := mem [ w + 2 ] . int ;
        mem [ r ] . hh . rh := mem [ w ] . hh . rh ;
        mem [ mem [ w ] . hh . rh ] . hh . lh := r ;
        mem [ r ] . hh . lh := w ;
        mem [ w ] . hh . rh := r ;
      End ;
      Function makepen ( h : halfword ) : halfword ;

      Label 30 , 31 , 45 , 40 ;

      Var o , oo , k : smallnumber ;
        p : halfword ;
        q , r , s , w , hh : halfword ;
        n : integer ;
        dx , dy : scaled ;
        mc : scaled ;
      Begin
        q := h ;
        r := mem [ q ] . hh . rh ;
        mc := abs ( mem [ h + 1 ] . int ) ;
        If q = r Then
          Begin
            hh := h ;
            mem [ h ] . hh . b1 := 0 ;
            If mc < abs ( mem [ h + 2 ] . int ) Then mc := abs ( mem [ h + 2 ] . int ) ;
          End
        Else
          Begin
            o := 0 ;
            hh := 0 ;
            While true Do
              Begin
                s := mem [ r ] . hh . rh ;
                If mc < abs ( mem [ r + 1 ] . int ) Then mc := abs ( mem [ r + 1 ] . int ) ;
                If mc < abs ( mem [ r + 2 ] . int ) Then mc := abs ( mem [ r + 2 ] . int ) ;
                dx := mem [ r + 1 ] . int - mem [ q + 1 ] . int ;
                dy := mem [ r + 2 ] . int - mem [ q + 2 ] . int ;
                If dx = 0 Then If dy = 0 Then goto 45 ;
                If abvscd ( dx , mem [ s + 2 ] . int - mem [ r + 2 ] . int , dy , mem [ s + 1 ] . int - mem [ r + 1 ] . int ) < 0 Then goto 45 ;
                If dx > 0 Then octant := 1
                Else If dx = 0 Then If dy > 0 Then octant := 1
                Else octant := 2
                Else
                  Begin
                    dx := - dx ;
                    octant := 2 ;
                  End ;
                If dy < 0 Then
                  Begin
                    dy := - dy ;
                    octant := octant + 2 ;
                  End
                Else If dy = 0 Then If octant > 1 Then octant := 4 ;
                If dx < dy Then octant := octant + 4 ;
                mem [ q ] . hh . b1 := octant ;
                oo := octantnumber [ octant ] ;
                If o > oo Then
                  Begin
                    If hh <> 0 Then goto 45 ;
                    hh := q ;
                  End ;
                o := oo ;
                If ( q = h ) And ( hh <> 0 ) Then goto 30 ;
                q := r ;
                r := s ;
              End ;
            30 :
          End ;
        If mc >= 268402688 Then goto 45 ;
        p := getnode ( 10 ) ;
        q := hh ;
        mem [ p + 9 ] . int := mc ;
        mem [ p ] . hh . lh := 0 ;
        If mem [ q ] . hh . rh <> q Then mem [ p ] . hh . rh := 1 ;
        For k := 1 To 8 Do
          Begin
            octant := octantcode [ k ] ;
            n := 0 ;
            h := p + octant ;
            While true Do
              Begin
                r := getnode ( 3 ) ;
                skew ( mem [ q + 1 ] . int , mem [ q + 2 ] . int , octant ) ;
                mem [ r + 1 ] . int := curx ;
                mem [ r + 2 ] . int := cury ;
                If n = 0 Then mem [ h ] . hh . rh := r
                Else If odd ( k ) Then
                       Begin
                         mem [ w ] . hh . rh := r ;
                         mem [ r ] . hh . lh := w ;
                       End
                Else
                  Begin
                    mem [ w ] . hh . lh := r ;
                    mem [ r ] . hh . rh := w ;
                  End ;
                w := r ;
                If mem [ q ] . hh . b1 <> octant Then goto 31 ;
                q := mem [ q ] . hh . rh ;
                n := n + 1 ;
              End ;
            31 : r := mem [ h ] . hh . rh ;
            If odd ( k ) Then
              Begin
                mem [ w ] . hh . rh := r ;
                mem [ r ] . hh . lh := w ;
              End
            Else
              Begin
                mem [ w ] . hh . lh := r ;
                mem [ r ] . hh . rh := w ;
                mem [ h ] . hh . rh := w ;
                r := w ;
              End ;
            If ( mem [ r + 2 ] . int <> mem [ mem [ r ] . hh . rh + 2 ] . int ) Or ( n = 0 ) Then
              Begin
                dupoffset ( r ) ;
                n := n + 1 ;
              End ;
            r := mem [ r ] . hh . lh ;
            If mem [ r + 1 ] . int <> mem [ mem [ r ] . hh . lh + 1 ] . int Then dupoffset ( r )
            Else n := n - 1 ;
            If n >= 255 Then overflow ( 579 , 255 ) ;
            mem [ h ] . hh . lh := n ;
          End ;
        goto 40 ;
        45 : p := 3 ;
        If mc >= 268402688 Then
          Begin
            Begin
              If interaction = 3 Then ;
              printnl ( 261 ) ;
              print ( 573 ) ;
            End ;
            Begin
              helpptr := 2 ;
              helpline [ 1 ] := 574 ;
              helpline [ 0 ] := 575 ;
            End ;
          End
        Else
          Begin
            Begin
              If interaction = 3 Then ;
              printnl ( 261 ) ;
              print ( 576 ) ;
            End ;
            Begin
              helpptr := 3 ;
              helpline [ 2 ] := 577 ;
              helpline [ 1 ] := 578 ;
              helpline [ 0 ] := 575 ;
            End ;
          End ;
        putgeterror ;
        40 : If internal [ 6 ] > 0 Then printpen ( p , 572 , true ) ;
        makepen := p ;
      End ;
      Function trivialknot ( x , y : scaled ) : halfword ;

      Var p : halfword ;
      Begin
        p := getnode ( 7 ) ;
        mem [ p ] . hh . b0 := 1 ;
        mem [ p ] . hh . b1 := 1 ;
        mem [ p + 1 ] . int := x ;
        mem [ p + 3 ] . int := x ;
        mem [ p + 5 ] . int := x ;
        mem [ p + 2 ] . int := y ;
        mem [ p + 4 ] . int := y ;
        mem [ p + 6 ] . int := y ;
        trivialknot := p ;
      End ;
      Function makepath ( penhead : halfword ) : halfword ;

      Var p : halfword ;
        k : 1 .. 8 ;
        h : halfword ;
        m , n : integer ;
        w , ww : halfword ;
      Begin
        p := 29999 ;
        For k := 1 To 8 Do
          Begin
            octant := octantcode [ k ] ;
            h := penhead + octant ;
            n := mem [ h ] . hh . lh ;
            w := mem [ h ] . hh . rh ;
            If Not odd ( k ) Then w := mem [ w ] . hh . lh ;
            For m := 1 To n + 1 Do
              Begin
                If odd ( k ) Then ww := mem [ w ] . hh . rh
                Else ww := mem [ w ] . hh . lh ;
                If ( mem [ ww + 1 ] . int <> mem [ w + 1 ] . int ) Or ( mem [ ww + 2 ] . int <> mem [ w + 2 ] . int ) Then
                  Begin
                    unskew ( mem [ ww + 1 ] . int , mem [ ww + 2 ] . int , octant ) ;
                    mem [ p ] . hh . rh := trivialknot ( curx , cury ) ;
                    p := mem [ p ] . hh . rh ;
                  End ;
                w := ww ;
              End ;
          End ;
        If p = 29999 Then
          Begin
            w := mem [ penhead + 1 ] . hh . rh ;
            p := trivialknot ( mem [ w + 1 ] . int + mem [ w + 2 ] . int , mem [ w + 2 ] . int ) ;
            mem [ 29999 ] . hh . rh := p ;
          End ;
        mem [ p ] . hh . rh := mem [ 29999 ] . hh . rh ;
        makepath := mem [ 29999 ] . hh . rh ;
      End ;
      Procedure findoffset ( x , y : scaled ; p : halfword ) ;

      Label 30 , 10 ;

      Var octant : 1 .. 8 ;
        s : - 1 .. + 1 ;
        n : integer ;
        h , w , ww : halfword ;
      Begin
        If x > 0 Then octant := 1
        Else If x = 0 Then If y <= 0 Then If y = 0 Then
                                            Begin
                                              curx := 0 ;
                                              cury := 0 ;
                                              goto 10 ;
                                            End
        Else octant := 2
        Else octant := 1
        Else
          Begin
            x := - x ;
            If y = 0 Then octant := 4
            Else octant := 2 ;
          End ;
        If y < 0 Then
          Begin
            octant := octant + 2 ;
            y := - y ;
          End ;
        If x >= y Then x := x - y
        Else
          Begin
            octant := octant + 4 ;
            x := y - x ;
            y := y - x ;
          End ;
        If odd ( octantnumber [ octant ] ) Then s := - 1
        Else s := + 1 ;
        h := p + octant ;
        w := mem [ mem [ h ] . hh . rh ] . hh . rh ;
        ww := mem [ w ] . hh . rh ;
        n := mem [ h ] . hh . lh ;
        While n > 1 Do
          Begin
            If abvscd ( x , mem [ ww + 2 ] . int - mem [ w + 2 ] . int , y , mem [ ww + 1 ] . int - mem [ w + 1 ] . int ) <> s Then goto 30 ;
            w := ww ;
            ww := mem [ w ] . hh . rh ;
            n := n - 1 ;
          End ;
        30 : unskew ( mem [ w + 1 ] . int , mem [ w + 2 ] . int , octant ) ;
        10 :
      End ;
      Procedure splitforoffset ( p : halfword ; t : fraction ) ;

      Var q : halfword ;
        r : halfword ;
      Begin
        q := mem [ p ] . hh . rh ;
        splitcubic ( p , t , mem [ q + 1 ] . int , mem [ q + 2 ] . int ) ;
        r := mem [ p ] . hh . rh ;
        If mem [ r + 2 ] . int < mem [ p + 2 ] . int Then mem [ r + 2 ] . int := mem [ p + 2 ] . int
        Else If mem [ r + 2 ] . int > mem [ q + 2 ] . int Then mem [ r + 2 ] . int := mem [ q + 2 ] . int ;
        If mem [ r + 1 ] . int < mem [ p + 1 ] . int Then mem [ r + 1 ] . int := mem [ p + 1 ] . int
        Else If mem [ r + 1 ] . int > mem [ q + 1 ] . int Then mem [ r + 1 ] . int := mem [ q + 1 ] . int ;
      End ;
      Procedure finoffsetprep ( p : halfword ; k : halfword ; w : halfword ; x0 , x1 , x2 , y0 , y1 , y2 : integer ; rising : boolean ; n : integer ) ;

      Label 10 ;

      Var ww : halfword ;
        du , dv : scaled ;
        t0 , t1 , t2 : integer ;
        t : fraction ;
        s : fraction ;
        v : integer ;
      Begin
        While true Do
          Begin
            mem [ p ] . hh . b1 := k ;
            If rising Then If k = n Then goto 10
            Else ww := mem [ w ] . hh . rh
            Else If k = 1 Then goto 10
            Else ww := mem [ w ] . hh . lh ;
            du := mem [ ww + 1 ] . int - mem [ w + 1 ] . int ;
            dv := mem [ ww + 2 ] . int - mem [ w + 2 ] . int ;
            If abs ( du ) >= abs ( dv ) Then
              Begin
                s := makefraction ( dv , du ) ;
                t0 := takefraction ( x0 , s ) - y0 ;
                t1 := takefraction ( x1 , s ) - y1 ;
                t2 := takefraction ( x2 , s ) - y2 ;
              End
            Else
              Begin
                s := makefraction ( du , dv ) ;
                t0 := x0 - takefraction ( y0 , s ) ;
                t1 := x1 - takefraction ( y1 , s ) ;
                t2 := x2 - takefraction ( y2 , s ) ;
              End ;
            t := crossingpoint ( t0 , t1 , t2 ) ;
            If t >= 268435456 Then goto 10 ;
            Begin
              splitforoffset ( p , t ) ;
              mem [ p ] . hh . b1 := k ;
              p := mem [ p ] . hh . rh ;
              v := x0 - takefraction ( x0 - x1 , t ) ;
              x1 := x1 - takefraction ( x1 - x2 , t ) ;
              x0 := v - takefraction ( v - x1 , t ) ;
              v := y0 - takefraction ( y0 - y1 , t ) ;
              y1 := y1 - takefraction ( y1 - y2 , t ) ;
              y0 := v - takefraction ( v - y1 , t ) ;
              t1 := t1 - takefraction ( t1 - t2 , t ) ;
              If t1 > 0 Then t1 := 0 ;
              t := crossingpoint ( 0 , - t1 , - t2 ) ;
              If t < 268435456 Then
                Begin
                  splitforoffset ( p , t ) ;
                  mem [ mem [ p ] . hh . rh ] . hh . b1 := k ;
                  v := x1 - takefraction ( x1 - x2 , t ) ;
                  x1 := x0 - takefraction ( x0 - x1 , t ) ;
                  x2 := x1 - takefraction ( x1 - v , t ) ;
                  v := y1 - takefraction ( y1 - y2 , t ) ;
                  y1 := y0 - takefraction ( y0 - y1 , t ) ;
                  y2 := y1 - takefraction ( y1 - v , t ) ;
                End ;
            End ;
            If rising Then k := k + 1
            Else k := k - 1 ;
            w := ww ;
          End ;
        10 :
      End ;
      Procedure offsetprep ( c , h : halfword ) ;

      Label 30 , 45 ;

      Var n : halfword ;
        p , q , r , lh , ww : halfword ;
        k : halfword ;
        w : halfword ;
        x0 , x1 , x2 , y0 , y1 , y2 : integer ;
        t0 , t1 , t2 : integer ;
        du , dv , dx , dy : integer ;
        maxcoef : integer ;
        x0a , x1a , x2a , y0a , y1a , y2a : integer ;
        t : fraction ;
        s : fraction ;
      Begin
        p := c ;
        n := mem [ h ] . hh . lh ;
        lh := mem [ h ] . hh . rh ;
        While mem [ p ] . hh . b1 <> 0 Do
          Begin
            q := mem [ p ] . hh . rh ;
            If n <= 1 Then mem [ p ] . hh . b1 := 1
            Else
              Begin
                x0 := mem [ p + 5 ] . int - mem [ p + 1 ] . int ;
                x2 := mem [ q + 1 ] . int - mem [ q + 3 ] . int ;
                x1 := mem [ q + 3 ] . int - mem [ p + 5 ] . int ;
                y0 := mem [ p + 6 ] . int - mem [ p + 2 ] . int ;
                y2 := mem [ q + 2 ] . int - mem [ q + 4 ] . int ;
                y1 := mem [ q + 4 ] . int - mem [ p + 6 ] . int ;
                maxcoef := abs ( x0 ) ;
                If abs ( x1 ) > maxcoef Then maxcoef := abs ( x1 ) ;
                If abs ( x2 ) > maxcoef Then maxcoef := abs ( x2 ) ;
                If abs ( y0 ) > maxcoef Then maxcoef := abs ( y0 ) ;
                If abs ( y1 ) > maxcoef Then maxcoef := abs ( y1 ) ;
                If abs ( y2 ) > maxcoef Then maxcoef := abs ( y2 ) ;
                If maxcoef = 0 Then goto 45 ;
                While maxcoef < 134217728 Do
                  Begin
                    maxcoef := maxcoef + maxcoef ;
                    x0 := x0 + x0 ;
                    x1 := x1 + x1 ;
                    x2 := x2 + x2 ;
                    y0 := y0 + y0 ;
                    y1 := y1 + y1 ;
                    y2 := y2 + y2 ;
                  End ;
                dx := x0 ;
                dy := y0 ;
                If dx = 0 Then If dy = 0 Then
                                 Begin
                                   dx := x1 ;
                                   dy := y1 ;
                                   If dx = 0 Then If dy = 0 Then
                                                    Begin
                                                      dx := x2 ;
                                                      dy := y2 ;
                                                    End ;
                                 End ;
                If dx = 0 Then finoffsetprep ( p , n , mem [ mem [ lh ] . hh . lh ] . hh . lh , - x0 , - x1 , - x2 , - y0 , - y1 , - y2 , false , n )
                Else
                  Begin
                    k := 1 ;
                    w := mem [ lh ] . hh . rh ;
                    While true Do
                      Begin
                        If k = n Then goto 30 ;
                        ww := mem [ w ] . hh . rh ;
                        If abvscd ( dy , abs ( mem [ ww + 1 ] . int - mem [ w + 1 ] . int ) , dx , abs ( mem [ ww + 2 ] . int - mem [ w + 2 ] . int ) ) >= 0 Then
                          Begin
                            k := k + 1 ;
                            w := ww ;
                          End
                        Else goto 30 ;
                      End ;
                    30 : ;
                    If k = 1 Then t := 268435457
                    Else
                      Begin
                        ww := mem [ w ] . hh . lh ;
                        du := mem [ ww + 1 ] . int - mem [ w + 1 ] . int ;
                        dv := mem [ ww + 2 ] . int - mem [ w + 2 ] . int ;
                        If abs ( du ) >= abs ( dv ) Then
                          Begin
                            s := makefraction ( dv , du ) ;
                            t0 := takefraction ( x0 , s ) - y0 ;
                            t1 := takefraction ( x1 , s ) - y1 ;
                            t2 := takefraction ( x2 , s ) - y2 ;
                          End
                        Else
                          Begin
                            s := makefraction ( du , dv ) ;
                            t0 := x0 - takefraction ( y0 , s ) ;
                            t1 := x1 - takefraction ( y1 , s ) ;
                            t2 := x2 - takefraction ( y2 , s ) ;
                          End ;
                        t := crossingpoint ( - t0 , - t1 , - t2 ) ;
                      End ;
                    If t >= 268435456 Then finoffsetprep ( p , k , w , x0 , x1 , x2 , y0 , y1 , y2 , true , n )
                    Else
                      Begin
                        splitforoffset ( p , t ) ;
                        r := mem [ p ] . hh . rh ;
                        x1a := x0 - takefraction ( x0 - x1 , t ) ;
                        x1 := x1 - takefraction ( x1 - x2 , t ) ;
                        x2a := x1a - takefraction ( x1a - x1 , t ) ;
                        y1a := y0 - takefraction ( y0 - y1 , t ) ;
                        y1 := y1 - takefraction ( y1 - y2 , t ) ;
                        y2a := y1a - takefraction ( y1a - y1 , t ) ;
                        finoffsetprep ( p , k , w , x0 , x1a , x2a , y0 , y1a , y2a , true , n ) ;
                        x0 := x2a ;
                        y0 := y2a ;
                        t1 := t1 - takefraction ( t1 - t2 , t ) ;
                        If t1 < 0 Then t1 := 0 ;
                        t := crossingpoint ( 0 , t1 , t2 ) ;
                        If t < 268435456 Then
                          Begin
                            splitforoffset ( r , t ) ;
                            x1a := x1 - takefraction ( x1 - x2 , t ) ;
                            x1 := x0 - takefraction ( x0 - x1 , t ) ;
                            x0a := x1 - takefraction ( x1 - x1a , t ) ;
                            y1a := y1 - takefraction ( y1 - y2 , t ) ;
                            y1 := y0 - takefraction ( y0 - y1 , t ) ;
                            y0a := y1 - takefraction ( y1 - y1a , t ) ;
                            finoffsetprep ( mem [ r ] . hh . rh , k , w , x0a , x1a , x2 , y0a , y1a , y2 , true , n ) ;
                            x2 := x0a ;
                            y2 := y0a ;
                          End ;
                        finoffsetprep ( r , k - 1 , ww , - x0 , - x1 , - x2 , - y0 , - y1 , - y2 , false , n ) ;
                      End ;
                  End ;
                45 :
              End ;
            Repeat
              r := mem [ p ] . hh . rh ;
              If mem [ p + 1 ] . int = mem [ p + 5 ] . int Then If mem [ p + 2 ] . int = mem [ p + 6 ] . int Then If mem [ p + 1 ] . int = mem [ r + 3 ] . int Then If mem [ p + 2 ] . int = mem [ r + 4 ] . int Then If mem [ p + 1 ] . int = mem [ r + 1 ] . int Then If mem [ p + 2 ] . int = mem [ r + 2 ] . int Then
                                                                                                                                                                                                                                                                          Begin
                                                                                                                                                                                                                                                                            removecubic ( p ) ;
                                                                                                                                                                                                                                                                            If r = q Then q := p ;
                                                                                                                                                                                                                                                                            r := p ;
                                                                                                                                                                                                                                                                          End ;
              p := r ;
            Until p = q ;
          End ;
      End ;
      Procedure skewlineedges ( p , w , ww : halfword ) ;

      Var x0 , y0 , x1 , y1 : scaled ;
      Begin
        If ( mem [ w + 1 ] . int <> mem [ ww + 1 ] . int ) Or ( mem [ w + 2 ] . int <> mem [ ww + 2 ] . int ) Then
          Begin
            x0 := mem [ p + 1 ] . int + mem [ w + 1 ] . int ;
            y0 := mem [ p + 2 ] . int + mem [ w + 2 ] . int ;
            x1 := mem [ p + 1 ] . int + mem [ ww + 1 ] . int ;
            y1 := mem [ p + 2 ] . int + mem [ ww + 2 ] . int ;
            unskew ( x0 , y0 , octant ) ;
            x0 := curx ;
            y0 := cury ;
            unskew ( x1 , y1 , octant ) ;
            lineedges ( x0 , y0 , curx , cury ) ;
          End ;
      End ;
      Procedure dualmoves ( h , p , q : halfword ) ;

      Label 30 , 31 ;

      Var r , s : halfword ;
        m , n : integer ;
        mm0 , mm1 : integer ;
        k : integer ;
        w , ww : halfword ;
        smoothbot , smoothtop : 0 .. movesize ;
        xx , yy , xp , yp , delx , dely , tx , ty : scaled ;
      Begin
        k := mem [ h ] . hh . lh + 1 ;
        ww := mem [ h ] . hh . rh ;
        w := mem [ ww ] . hh . lh ;
        mm0 := floorunscaled ( mem [ p + 1 ] . int + mem [ w + 1 ] . int - xycorr [ octant ] ) ;
        mm1 := floorunscaled ( mem [ q + 1 ] . int + mem [ ww + 1 ] . int - xycorr [ octant ] ) ;
        For n := 1 To n1 - n0 + 1 Do
          envmove [ n ] := mm1 ;
        envmove [ 0 ] := mm0 ;
        moveptr := 0 ;
        m := mm0 ;
        r := p ;
        While true Do
          Begin
            If r = q Then smoothtop := moveptr ;
            While mem [ r ] . hh . b1 <> k Do
              Begin
                xx := mem [ r + 1 ] . int + mem [ w + 1 ] . int ;
                yy := mem [ r + 2 ] . int + mem [ w + 2 ] . int + 32768 ;
                If mem [ r ] . hh . b1 < k Then
                  Begin
                    k := k - 1 ;
                    w := mem [ w ] . hh . lh ;
                    xp := mem [ r + 1 ] . int + mem [ w + 1 ] . int ;
                    yp := mem [ r + 2 ] . int + mem [ w + 2 ] . int + 32768 ;
                    If yp <> yy Then
                      Begin
                        ty := floorscaled ( yy - ycorr [ octant ] ) ;
                        dely := yp - yy ;
                        yy := yy - ty ;
                        ty := yp - ycorr [ octant ] - ty ;
                        If ty >= 65536 Then
                          Begin
                            delx := xp - xx ;
                            yy := 65536 - yy ;
                            While true Do
                              Begin
                                If m < envmove [ moveptr ] Then envmove [ moveptr ] := m ;
                                tx := takefraction ( delx , makefraction ( yy , dely ) ) ;
                                If abvscd ( tx , dely , delx , yy ) + xycorr [ octant ] > 0 Then tx := tx - 1 ;
                                m := floorunscaled ( xx + tx ) ;
                                ty := ty - 65536 ;
                                moveptr := moveptr + 1 ;
                                If ty < 65536 Then goto 31 ;
                                yy := yy + 65536 ;
                              End ;
                            31 : If m < envmove [ moveptr ] Then envmove [ moveptr ] := m ;
                          End ;
                      End ;
                  End
                Else
                  Begin
                    k := k + 1 ;
                    w := mem [ w ] . hh . rh ;
                    xp := mem [ r + 1 ] . int + mem [ w + 1 ] . int ;
                    yp := mem [ r + 2 ] . int + mem [ w + 2 ] . int + 32768 ;
                  End ;
                m := floorunscaled ( xp - xycorr [ octant ] ) ;
                moveptr := floorunscaled ( yp - ycorr [ octant ] ) - n0 ;
                If m < envmove [ moveptr ] Then envmove [ moveptr ] := m ;
              End ;
            If r = p Then smoothbot := moveptr ;
            If r = q Then goto 30 ;
            move [ moveptr ] := 1 ;
            n := moveptr ;
            s := mem [ r ] . hh . rh ;
            makemoves ( mem [ r + 1 ] . int + mem [ w + 1 ] . int , mem [ r + 5 ] . int + mem [ w + 1 ] . int , mem [ s + 3 ] . int + mem [ w + 1 ] . int , mem [ s + 1 ] . int + mem [ w + 1 ] . int , mem [ r + 2 ] . int + mem [ w + 2 ] . int + 32768 , mem [ r + 6 ] . int + mem [ w + 2 ] . int + 32768 , mem [ s + 4 ] . int + mem [ w + 2 ] . int + 32768 , mem [ s + 2 ] . int + mem [ w + 2 ] . int + 32768 , xycorr [ octant ] , ycorr [ octant ] ) ;
            Repeat
              If m < envmove [ n ] Then envmove [ n ] := m ;
              m := m + move [ n ] - 1 ;
              n := n + 1 ;
            Until n > moveptr ;
            r := s ;
          End ;
        30 : move [ 0 ] := d0 + envmove [ 1 ] - mm0 ;
        For n := 1 To moveptr Do
          move [ n ] := envmove [ n + 1 ] - envmove [ n ] + 1 ;
        move [ moveptr ] := move [ moveptr ] - d1 ;
        If internal [ 35 ] > 0 Then smoothmoves ( smoothbot , smoothtop ) ;
        movetoedges ( m0 , n0 , m1 , n1 ) ;
        If mem [ q + 6 ] . int = 1 Then
          Begin
            w := mem [ h ] . hh . rh ;
            skewlineedges ( q , w , mem [ w ] . hh . lh ) ;
          End ;
      End ;
      Procedure fillenvelope ( spechead : halfword ) ;

      Label 30 , 31 ;

      Var p , q , r , s : halfword ;
        h : halfword ;
        www : halfword ;
        m , n : integer ;
        mm0 , mm1 : integer ;
        k : integer ;
        w , ww : halfword ;
        smoothbot , smoothtop : 0 .. movesize ;
        xx , yy , xp , yp , delx , dely , tx , ty : scaled ;
      Begin
        If internal [ 10 ] > 0 Then beginedgetracing ;
        p := spechead ;
        Repeat
          octant := mem [ p + 3 ] . int ;
          h := curpen + octant ;
          q := p ;
          While mem [ q ] . hh . b1 <> 0 Do
            q := mem [ q ] . hh . rh ;
          w := mem [ h ] . hh . rh ;
          If mem [ p + 4 ] . int = 1 Then w := mem [ w ] . hh . lh ;
          ww := mem [ h ] . hh . rh ;
          www := ww ;
          If odd ( octantnumber [ octant ] ) Then www := mem [ www ] . hh . lh
          Else ww := mem [ ww ] . hh . lh ;
          If w <> ww Then skewlineedges ( p , w , ww ) ;
          endround ( mem [ p + 1 ] . int + mem [ ww + 1 ] . int , mem [ p + 2 ] . int + mem [ ww + 2 ] . int ) ;
          m0 := m1 ;
          n0 := n1 ;
          d0 := d1 ;
          endround ( mem [ q + 1 ] . int + mem [ www + 1 ] . int , mem [ q + 2 ] . int + mem [ www + 2 ] . int ) ;
          If n1 - n0 >= movesize Then overflow ( 540 , movesize ) ;
          offsetprep ( p , h ) ;
          q := p ;
          While mem [ q ] . hh . b1 <> 0 Do
            q := mem [ q ] . hh . rh ;
          If odd ( octantnumber [ octant ] ) Then
            Begin
              k := 0 ;
              w := mem [ h ] . hh . rh ;
              ww := mem [ w ] . hh . lh ;
              mm0 := floorunscaled ( mem [ p + 1 ] . int + mem [ w + 1 ] . int - xycorr [ octant ] ) ;
              mm1 := floorunscaled ( mem [ q + 1 ] . int + mem [ ww + 1 ] . int - xycorr [ octant ] ) ;
              For n := 0 To n1 - n0 Do
                envmove [ n ] := mm0 ;
              envmove [ n1 - n0 ] := mm1 ;
              moveptr := 0 ;
              m := mm0 ;
              r := p ;
              mem [ q ] . hh . b1 := mem [ h ] . hh . lh + 1 ;
              While true Do
                Begin
                  If r = q Then smoothtop := moveptr ;
                  While mem [ r ] . hh . b1 <> k Do
                    Begin
                      xx := mem [ r + 1 ] . int + mem [ w + 1 ] . int ;
                      yy := mem [ r + 2 ] . int + mem [ w + 2 ] . int + 32768 ;
                      If mem [ r ] . hh . b1 > k Then
                        Begin
                          k := k + 1 ;
                          w := mem [ w ] . hh . rh ;
                          xp := mem [ r + 1 ] . int + mem [ w + 1 ] . int ;
                          yp := mem [ r + 2 ] . int + mem [ w + 2 ] . int + 32768 ;
                          If yp <> yy Then
                            Begin
                              ty := floorscaled ( yy - ycorr [ octant ] ) ;
                              dely := yp - yy ;
                              yy := yy - ty ;
                              ty := yp - ycorr [ octant ] - ty ;
                              If ty >= 65536 Then
                                Begin
                                  delx := xp - xx ;
                                  yy := 65536 - yy ;
                                  While true Do
                                    Begin
                                      tx := takefraction ( delx , makefraction ( yy , dely ) ) ;
                                      If abvscd ( tx , dely , delx , yy ) + xycorr [ octant ] > 0 Then tx := tx - 1 ;
                                      m := floorunscaled ( xx + tx ) ;
                                      If m > envmove [ moveptr ] Then envmove [ moveptr ] := m ;
                                      ty := ty - 65536 ;
                                      If ty < 65536 Then goto 31 ;
                                      yy := yy + 65536 ;
                                      moveptr := moveptr + 1 ;
                                    End ;
                                  31 :
                                End ;
                            End ;
                        End
                      Else
                        Begin
                          k := k - 1 ;
                          w := mem [ w ] . hh . lh ;
                          xp := mem [ r + 1 ] . int + mem [ w + 1 ] . int ;
                          yp := mem [ r + 2 ] . int + mem [ w + 2 ] . int + 32768 ;
                        End ;
                      m := floorunscaled ( xp - xycorr [ octant ] ) ;
                      moveptr := floorunscaled ( yp - ycorr [ octant ] ) - n0 ;
                      If m > envmove [ moveptr ] Then envmove [ moveptr ] := m ;
                    End ;
                  If r = p Then smoothbot := moveptr ;
                  If r = q Then goto 30 ;
                  move [ moveptr ] := 1 ;
                  n := moveptr ;
                  s := mem [ r ] . hh . rh ;
                  makemoves ( mem [ r + 1 ] . int + mem [ w + 1 ] . int , mem [ r + 5 ] . int + mem [ w + 1 ] . int , mem [ s + 3 ] . int + mem [ w + 1 ] . int , mem [ s + 1 ] . int + mem [ w + 1 ] . int , mem [ r + 2 ] . int + mem [ w + 2 ] . int + 32768 , mem [ r + 6 ] . int + mem [ w + 2 ] . int + 32768 , mem [ s + 4 ] . int + mem [ w + 2 ] . int + 32768 , mem [ s + 2 ] . int + mem [ w + 2 ] . int + 32768 , xycorr [ octant ] , ycorr [ octant ] ) ;
                  Repeat
                    m := m + move [ n ] - 1 ;
                    If m > envmove [ n ] Then envmove [ n ] := m ;
                    n := n + 1 ;
                  Until n > moveptr ;
                  r := s ;
                End ;
              30 : move [ 0 ] := d0 + envmove [ 0 ] - mm0 ;
              For n := 1 To moveptr Do
                move [ n ] := envmove [ n ] - envmove [ n - 1 ] + 1 ;
              move [ moveptr ] := move [ moveptr ] - d1 ;
              If internal [ 35 ] > 0 Then smoothmoves ( smoothbot , smoothtop ) ;
              movetoedges ( m0 , n0 , m1 , n1 ) ;
              If mem [ q + 6 ] . int = 0 Then
                Begin
                  w := mem [ h ] . hh . rh ;
                  skewlineedges ( q , mem [ w ] . hh . lh , w ) ;
                End ;
            End
          Else dualmoves ( h , p , q ) ;
          mem [ q ] . hh . b1 := 0 ;
          p := mem [ q ] . hh . rh ;
        Until p = spechead ;
        If internal [ 10 ] > 0 Then endedgetracing ;
        tossknotlist ( spechead ) ;
      End ;
      Function makeellipse ( majoraxis , minoraxis : scaled ; theta : angle ) : halfword ;

      Label 30 , 31 , 40 ;

      Var p , q , r , s : halfword ;
        h : halfword ;
        alpha , beta , gamma , delta : integer ;
        c , d : integer ;
        u , v : integer ;
        symmetric : boolean ;
      Begin
        If ( majoraxis = minoraxis ) Or ( theta Mod 94371840 = 0 ) Then
          Begin
            symmetric := true ;
            alpha := 0 ;
            If odd ( theta Div 94371840 ) Then
              Begin
                beta := majoraxis ;
                gamma := minoraxis ;
                nsin := 268435456 ;
                ncos := 0 ;
              End
            Else
              Begin
                beta := minoraxis ;
                gamma := majoraxis ;
                theta := 0 ;
              End ;
          End
        Else
          Begin
            symmetric := false ;
            nsincos ( theta ) ;
            gamma := takefraction ( majoraxis , nsin ) ;
            delta := takefraction ( minoraxis , ncos ) ;
            beta := pythadd ( gamma , delta ) ;
            alpha := takefraction ( takefraction ( majoraxis , makefraction ( gamma , beta ) ) , ncos ) - takefraction ( takefraction ( minoraxis , makefraction ( delta , beta ) ) , nsin ) ;
            alpha := ( alpha + 32768 ) Div 65536 ;
            gamma := pythadd ( takefraction ( majoraxis , ncos ) , takefraction ( minoraxis , nsin ) ) ;
          End ;
        beta := ( beta + 32768 ) Div 65536 ;
        gamma := ( gamma + 32768 ) Div 65536 ;
        p := getnode ( 7 ) ;
        q := getnode ( 7 ) ;
        r := getnode ( 7 ) ;
        If symmetric Then s := 0
        Else s := getnode ( 7 ) ;
        h := p ;
        mem [ p ] . hh . rh := q ;
        mem [ q ] . hh . rh := r ;
        mem [ r ] . hh . rh := s ;
        If beta = 0 Then beta := 1 ;
        If gamma = 0 Then gamma := 1 ;
        If gamma <= abs ( alpha ) Then If alpha > 0 Then alpha := gamma - 1
        Else alpha := 1 - gamma ;
        mem [ p + 1 ] . int := - alpha * 32768 ;
        mem [ p + 2 ] . int := - beta * 32768 ;
        mem [ q + 1 ] . int := gamma * 32768 ;
        mem [ q + 2 ] . int := mem [ p + 2 ] . int ;
        mem [ r + 1 ] . int := mem [ q + 1 ] . int ;
        mem [ p + 5 ] . int := 0 ;
        mem [ q + 3 ] . int := - 32768 ;
        mem [ q + 5 ] . int := 32768 ;
        mem [ r + 3 ] . int := 0 ;
        mem [ r + 5 ] . int := 0 ;
        mem [ p + 6 ] . int := beta ;
        mem [ q + 6 ] . int := gamma ;
        mem [ r + 6 ] . int := beta ;
        mem [ q + 4 ] . int := gamma + alpha ;
        If symmetric Then
          Begin
            mem [ r + 2 ] . int := 0 ;
            mem [ r + 4 ] . int := beta ;
          End
        Else
          Begin
            mem [ r + 2 ] . int := - mem [ p + 2 ] . int ;
            mem [ r + 4 ] . int := beta + beta ;
            mem [ s + 1 ] . int := - mem [ p + 1 ] . int ;
            mem [ s + 2 ] . int := mem [ r + 2 ] . int ;
            mem [ s + 3 ] . int := 32768 ;
            mem [ s + 4 ] . int := gamma - alpha ;
          End ;
        While true Do
          Begin
            u := mem [ p + 5 ] . int + mem [ q + 5 ] . int ;
            v := mem [ q + 3 ] . int + mem [ r + 3 ] . int ;
            c := mem [ p + 6 ] . int + mem [ q + 6 ] . int ;
            delta := pythadd ( u , v ) ;
            If majoraxis = minoraxis Then d := majoraxis
            Else
              Begin
                If theta = 0 Then
                  Begin
                    alpha := u ;
                    beta := v ;
                  End
                Else
                  Begin
                    alpha := takefraction ( u , ncos ) + takefraction ( v , nsin ) ;
                    beta := takefraction ( v , ncos ) - takefraction ( u , nsin ) ;
                  End ;
                alpha := makefraction ( alpha , delta ) ;
                beta := makefraction ( beta , delta ) ;
                d := pythadd ( takefraction ( majoraxis , alpha ) , takefraction ( minoraxis , beta ) ) ;
              End ;
            alpha := abs ( u ) ;
            beta := abs ( v ) ;
            If alpha < beta Then
              Begin
                alpha := abs ( v ) ;
                beta := abs ( u ) ;
              End ;
            If internal [ 38 ] <> 0 Then d := d - takefraction ( internal [ 38 ] , makefraction ( beta + beta , delta ) ) ;
            d := takefraction ( ( d + 4 ) Div 8 , delta ) ;
            alpha := alpha Div 32768 ;
            If d < alpha Then d := alpha ;
            delta := c - d ;
            If delta > 0 Then
              Begin
                If delta > mem [ r + 4 ] . int Then delta := mem [ r + 4 ] . int ;
                If delta >= mem [ q + 4 ] . int Then
                  Begin
                    delta := mem [ q + 4 ] . int ;
                    mem [ p + 6 ] . int := c - delta ;
                    mem [ p + 5 ] . int := u ;
                    mem [ q + 3 ] . int := v ;
                    mem [ q + 1 ] . int := mem [ q + 1 ] . int - delta * mem [ r + 3 ] . int ;
                    mem [ q + 2 ] . int := mem [ q + 2 ] . int + delta * mem [ q + 5 ] . int ;
                    mem [ r + 4 ] . int := mem [ r + 4 ] . int - delta ;
                  End
                Else
                  Begin
                    s := getnode ( 7 ) ;
                    mem [ p ] . hh . rh := s ;
                    mem [ s ] . hh . rh := q ;
                    mem [ s + 1 ] . int := mem [ q + 1 ] . int + delta * mem [ q + 3 ] . int ;
                    mem [ s + 2 ] . int := mem [ q + 2 ] . int - delta * mem [ p + 5 ] . int ;
                    mem [ q + 1 ] . int := mem [ q + 1 ] . int - delta * mem [ r + 3 ] . int ;
                    mem [ q + 2 ] . int := mem [ q + 2 ] . int + delta * mem [ q + 5 ] . int ;
                    mem [ s + 3 ] . int := mem [ q + 3 ] . int ;
                    mem [ s + 5 ] . int := u ;
                    mem [ q + 3 ] . int := v ;
                    mem [ s + 6 ] . int := c - delta ;
                    mem [ s + 4 ] . int := mem [ q + 4 ] . int - delta ;
                    mem [ q + 4 ] . int := delta ;
                    mem [ r + 4 ] . int := mem [ r + 4 ] . int - delta ;
                  End ;
              End
            Else p := q ;
            While true Do
              Begin
                q := mem [ p ] . hh . rh ;
                If q = 0 Then goto 30 ;
                If mem [ q + 4 ] . int = 0 Then
                  Begin
                    mem [ p ] . hh . rh := mem [ q ] . hh . rh ;
                    mem [ p + 6 ] . int := mem [ q + 6 ] . int ;
                    mem [ p + 5 ] . int := mem [ q + 5 ] . int ;
                    freenode ( q , 7 ) ;
                  End
                Else
                  Begin
                    r := mem [ q ] . hh . rh ;
                    If r = 0 Then goto 30 ;
                    If mem [ r + 4 ] . int = 0 Then
                      Begin
                        mem [ p ] . hh . rh := r ;
                        freenode ( q , 7 ) ;
                        p := r ;
                      End
                    Else goto 40 ;
                  End ;
              End ;
            40 : ;
          End ;
        30 : ;
        If symmetric Then
          Begin
            s := 0 ;
            q := h ;
            While true Do
              Begin
                r := getnode ( 7 ) ;
                mem [ r ] . hh . rh := s ;
                s := r ;
                mem [ s + 1 ] . int := mem [ q + 1 ] . int ;
                mem [ s + 2 ] . int := - mem [ q + 2 ] . int ;
                If q = p Then goto 31 ;
                q := mem [ q ] . hh . rh ;
                If mem [ q + 2 ] . int = 0 Then goto 31 ;
              End ;
            31 : If ( mem [ p ] . hh . rh <> 0 ) Then freenode ( mem [ p ] . hh . rh , 7 ) ;
            mem [ p ] . hh . rh := s ;
            beta := - mem [ h + 2 ] . int ;
            While mem [ p + 2 ] . int <> beta Do
              p := mem [ p ] . hh . rh ;
            q := mem [ p ] . hh . rh ;
          End ;
        If q <> 0 Then
          Begin
            If mem [ h + 5 ] . int = 0 Then
              Begin
                p := h ;
                h := mem [ h ] . hh . rh ;
                freenode ( p , 7 ) ;
                mem [ q + 1 ] . int := - mem [ h + 1 ] . int ;
              End ;
            p := q ;
          End
        Else q := p ;
        r := mem [ h ] . hh . rh ;
        Repeat
          s := getnode ( 7 ) ;
          mem [ p ] . hh . rh := s ;
          p := s ;
          mem [ p + 1 ] . int := - mem [ r + 1 ] . int ;
          mem [ p + 2 ] . int := - mem [ r + 2 ] . int ;
          r := mem [ r ] . hh . rh ;
        Until r = q ;
        mem [ p ] . hh . rh := h ;
        makeellipse := h ;
      End ;
      Function finddirectiontime ( x , y : scaled ; h : halfword ) : scaled ;

      Label 10 , 40 , 45 , 30 ;

      Var max : scaled ;
        p , q : halfword ;
        n : scaled ;
        tt : scaled ;
        x1 , x2 , x3 , y1 , y2 , y3 : scaled ;
        theta , phi : angle ;
        t : fraction ;
      Begin
        If abs ( x ) < abs ( y ) Then
          Begin
            x := makefraction ( x , abs ( y ) ) ;
            If y > 0 Then y := 268435456
            Else y := - 268435456 ;
          End
        Else If x = 0 Then
               Begin
                 finddirectiontime := 0 ;
                 goto 10 ;
               End
        Else
          Begin
            y := makefraction ( y , abs ( x ) ) ;
            If x > 0 Then x := 268435456
            Else x := - 268435456 ;
          End ;
        n := 0 ;
        p := h ;
        While true Do
          Begin
            If mem [ p ] . hh . b1 = 0 Then goto 45 ;
            q := mem [ p ] . hh . rh ;
            tt := 0 ;
            x1 := mem [ p + 5 ] . int - mem [ p + 1 ] . int ;
            x2 := mem [ q + 3 ] . int - mem [ p + 5 ] . int ;
            x3 := mem [ q + 1 ] . int - mem [ q + 3 ] . int ;
            y1 := mem [ p + 6 ] . int - mem [ p + 2 ] . int ;
            y2 := mem [ q + 4 ] . int - mem [ p + 6 ] . int ;
            y3 := mem [ q + 2 ] . int - mem [ q + 4 ] . int ;
            max := abs ( x1 ) ;
            If abs ( x2 ) > max Then max := abs ( x2 ) ;
            If abs ( x3 ) > max Then max := abs ( x3 ) ;
            If abs ( y1 ) > max Then max := abs ( y1 ) ;
            If abs ( y2 ) > max Then max := abs ( y2 ) ;
            If abs ( y3 ) > max Then max := abs ( y3 ) ;
            If max = 0 Then goto 40 ;
            While max < 134217728 Do
              Begin
                max := max + max ;
                x1 := x1 + x1 ;
                x2 := x2 + x2 ;
                x3 := x3 + x3 ;
                y1 := y1 + y1 ;
                y2 := y2 + y2 ;
                y3 := y3 + y3 ;
              End ;
            t := x1 ;
            x1 := takefraction ( x1 , x ) + takefraction ( y1 , y ) ;
            y1 := takefraction ( y1 , x ) - takefraction ( t , y ) ;
            t := x2 ;
            x2 := takefraction ( x2 , x ) + takefraction ( y2 , y ) ;
            y2 := takefraction ( y2 , x ) - takefraction ( t , y ) ;
            t := x3 ;
            x3 := takefraction ( x3 , x ) + takefraction ( y3 , y ) ;
            y3 := takefraction ( y3 , x ) - takefraction ( t , y ) ;
            If y1 = 0 Then If x1 >= 0 Then goto 40 ;
            If n > 0 Then
              Begin
                theta := narg ( x1 , y1 ) ;
                If theta >= 0 Then If phi <= 0 Then If phi >= theta - 188743680 Then goto 40 ;
                If theta <= 0 Then If phi >= 0 Then If phi <= theta + 188743680 Then goto 40 ;
                If p = h Then goto 45 ;
              End ;
            If ( x3 <> 0 ) Or ( y3 <> 0 ) Then phi := narg ( x3 , y3 ) ;
            If x1 < 0 Then If x2 < 0 Then If x3 < 0 Then goto 30 ;
            If abvscd ( y1 , y3 , y2 , y2 ) = 0 Then
              Begin
                If abvscd ( y1 , y2 , 0 , 0 ) < 0 Then
                  Begin
                    t := makefraction ( y1 , y1 - y2 ) ;
                    x1 := x1 - takefraction ( x1 - x2 , t ) ;
                    x2 := x2 - takefraction ( x2 - x3 , t ) ;
                    If x1 - takefraction ( x1 - x2 , t ) >= 0 Then
                      Begin
                        tt := ( t + 2048 ) Div 4096 ;
                        goto 40 ;
                      End ;
                  End
                Else If y3 = 0 Then If y1 = 0 Then
                                      Begin
                                        t := crossingpoint ( - x1 , - x2 , - x3 ) ;
                                        If t <= 268435456 Then
                                          Begin
                                            tt := ( t + 2048 ) Div 4096 ;
                                            goto 40 ;
                                          End ;
                                        If abvscd ( x1 , x3 , x2 , x2 ) <= 0 Then
                                          Begin
                                            t := makefraction ( x1 , x1 - x2 ) ;
                                            Begin
                                              tt := ( t + 2048 ) Div 4096 ;
                                              goto 40 ;
                                            End ;
                                          End ;
                                      End
                Else If x3 >= 0 Then
                       Begin
                         tt := 65536 ;
                         goto 40 ;
                       End ;
                goto 30 ;
              End ;
            If y1 <= 0 Then If y1 < 0 Then
                              Begin
                                y1 := - y1 ;
                                y2 := - y2 ;
                                y3 := - y3 ;
                              End
            Else If y2 > 0 Then
                   Begin
                     y2 := - y2 ;
                     y3 := - y3 ;
                   End ;
            t := crossingpoint ( y1 , y2 , y3 ) ;
            If t > 268435456 Then goto 30 ;
            y2 := y2 - takefraction ( y2 - y3 , t ) ;
            x1 := x1 - takefraction ( x1 - x2 , t ) ;
            x2 := x2 - takefraction ( x2 - x3 , t ) ;
            x1 := x1 - takefraction ( x1 - x2 , t ) ;
            If x1 >= 0 Then
              Begin
                tt := ( t + 2048 ) Div 4096 ;
                goto 40 ;
              End ;
            If y2 > 0 Then y2 := 0 ;
            tt := t ;
            t := crossingpoint ( 0 , - y2 , - y3 ) ;
            If t > 268435456 Then goto 30 ;
            x1 := x1 - takefraction ( x1 - x2 , t ) ;
            x2 := x2 - takefraction ( x2 - x3 , t ) ;
            If x1 - takefraction ( x1 - x2 , t ) >= 0 Then
              Begin
                t := tt - takefraction ( tt - 268435456 , t ) ;
                Begin
                  tt := ( t + 2048 ) Div 4096 ;
                  goto 40 ;
                End ;
              End ;
            30 : ;
            p := q ;
            n := n + 65536 ;
          End ;
        45 : finddirectiontime := - 65536 ;
        goto 10 ;
        40 : finddirectiontime := n + tt ;
        10 :
      End ;
      Procedure cubicintersection ( p , pp : halfword ) ;

      Label 22 , 45 , 10 ;

      Var q , qq : halfword ;
      Begin
        timetogo := 5000 ;
        maxt := 2 ;
        q := mem [ p ] . hh . rh ;
        qq := mem [ pp ] . hh . rh ;
        bisectptr := 20 ;
        bisectstack [ bisectptr - 5 ] := mem [ p + 5 ] . int - mem [ p + 1 ] . int ;
        bisectstack [ bisectptr - 4 ] := mem [ q + 3 ] . int - mem [ p + 5 ] . int ;
        bisectstack [ bisectptr - 3 ] := mem [ q + 1 ] . int - mem [ q + 3 ] . int ;
        If bisectstack [ bisectptr - 5 ] < 0 Then If bisectstack [ bisectptr - 3 ] >= 0 Then
                                                    Begin
                                                      If bisectstack [ bisectptr - 4 ] < 0 Then bisectstack [ bisectptr - 2 ] := bisectstack [ bisectptr - 5 ] + bisectstack [ bisectptr - 4 ]
                                                      Else bisectstack [ bisectptr - 2 ] := bisectstack [ bisectptr - 5 ] ;
                                                      bisectstack [ bisectptr - 1 ] := bisectstack [ bisectptr - 5 ] + bisectstack [ bisectptr - 4 ] + bisectstack [ bisectptr - 3 ] ;
                                                      If bisectstack [ bisectptr - 1 ] < 0 Then bisectstack [ bisectptr - 1 ] := 0 ;
                                                    End
        Else
          Begin
            bisectstack [ bisectptr - 2 ] := bisectstack [ bisectptr - 5 ] + bisectstack [ bisectptr - 4 ] + bisectstack [ bisectptr - 3 ] ;
            If bisectstack [ bisectptr - 2 ] > bisectstack [ bisectptr - 5 ] Then bisectstack [ bisectptr - 2 ] := bisectstack [ bisectptr - 5 ] ;
            bisectstack [ bisectptr - 1 ] := bisectstack [ bisectptr - 5 ] + bisectstack [ bisectptr - 4 ] ;
            If bisectstack [ bisectptr - 1 ] < 0 Then bisectstack [ bisectptr - 1 ] := 0 ;
          End
        Else If bisectstack [ bisectptr - 3 ] <= 0 Then
               Begin
                 If bisectstack [ bisectptr - 4 ] > 0 Then bisectstack [ bisectptr - 1 ] := bisectstack [ bisectptr - 5 ] + bisectstack [ bisectptr - 4 ]
                 Else bisectstack [ bisectptr - 1 ] := bisectstack [ bisectptr - 5 ] ;
                 bisectstack [ bisectptr - 2 ] := bisectstack [ bisectptr - 5 ] + bisectstack [ bisectptr - 4 ] + bisectstack [ bisectptr - 3 ] ;
                 If bisectstack [ bisectptr - 2 ] > 0 Then bisectstack [ bisectptr - 2 ] := 0 ;
               End
        Else
          Begin
            bisectstack [ bisectptr - 1 ] := bisectstack [ bisectptr - 5 ] + bisectstack [ bisectptr - 4 ] + bisectstack [ bisectptr - 3 ] ;
            If bisectstack [ bisectptr - 1 ] < bisectstack [ bisectptr - 5 ] Then bisectstack [ bisectptr - 1 ] := bisectstack [ bisectptr - 5 ] ;
            bisectstack [ bisectptr - 2 ] := bisectstack [ bisectptr - 5 ] + bisectstack [ bisectptr - 4 ] ;
            If bisectstack [ bisectptr - 2 ] > 0 Then bisectstack [ bisectptr - 2 ] := 0 ;
          End ;
        bisectstack [ bisectptr - 10 ] := mem [ p + 6 ] . int - mem [ p + 2 ] . int ;
        bisectstack [ bisectptr - 9 ] := mem [ q + 4 ] . int - mem [ p + 6 ] . int ;
        bisectstack [ bisectptr - 8 ] := mem [ q + 2 ] . int - mem [ q + 4 ] . int ;
        If bisectstack [ bisectptr - 10 ] < 0 Then If bisectstack [ bisectptr - 8 ] >= 0 Then
                                                     Begin
                                                       If bisectstack [ bisectptr - 9 ] < 0 Then bisectstack [ bisectptr - 7 ] := bisectstack [ bisectptr - 10 ] + bisectstack [ bisectptr - 9 ]
                                                       Else bisectstack [ bisectptr - 7 ] := bisectstack [ bisectptr - 10 ] ;
                                                       bisectstack [ bisectptr - 6 ] := bisectstack [ bisectptr - 10 ] + bisectstack [ bisectptr - 9 ] + bisectstack [ bisectptr - 8 ] ;
                                                       If bisectstack [ bisectptr - 6 ] < 0 Then bisectstack [ bisectptr - 6 ] := 0 ;
                                                     End
        Else
          Begin
            bisectstack [ bisectptr - 7 ] := bisectstack [ bisectptr - 10 ] + bisectstack [ bisectptr - 9 ] + bisectstack [ bisectptr - 8 ] ;
            If bisectstack [ bisectptr - 7 ] > bisectstack [ bisectptr - 10 ] Then bisectstack [ bisectptr - 7 ] := bisectstack [ bisectptr - 10 ] ;
            bisectstack [ bisectptr - 6 ] := bisectstack [ bisectptr - 10 ] + bisectstack [ bisectptr - 9 ] ;
            If bisectstack [ bisectptr - 6 ] < 0 Then bisectstack [ bisectptr - 6 ] := 0 ;
          End
        Else If bisectstack [ bisectptr - 8 ] <= 0 Then
               Begin
                 If bisectstack [ bisectptr - 9 ] > 0 Then bisectstack [ bisectptr - 6 ] := bisectstack [ bisectptr - 10 ] + bisectstack [ bisectptr - 9 ]
                 Else bisectstack [ bisectptr - 6 ] := bisectstack [ bisectptr - 10 ] ;
                 bisectstack [ bisectptr - 7 ] := bisectstack [ bisectptr - 10 ] + bisectstack [ bisectptr - 9 ] + bisectstack [ bisectptr - 8 ] ;
                 If bisectstack [ bisectptr - 7 ] > 0 Then bisectstack [ bisectptr - 7 ] := 0 ;
               End
        Else
          Begin
            bisectstack [ bisectptr - 6 ] := bisectstack [ bisectptr - 10 ] + bisectstack [ bisectptr - 9 ] + bisectstack [ bisectptr - 8 ] ;
            If bisectstack [ bisectptr - 6 ] < bisectstack [ bisectptr - 10 ] Then bisectstack [ bisectptr - 6 ] := bisectstack [ bisectptr - 10 ] ;
            bisectstack [ bisectptr - 7 ] := bisectstack [ bisectptr - 10 ] + bisectstack [ bisectptr - 9 ] ;
            If bisectstack [ bisectptr - 7 ] > 0 Then bisectstack [ bisectptr - 7 ] := 0 ;
          End ;
        bisectstack [ bisectptr - 15 ] := mem [ pp + 5 ] . int - mem [ pp + 1 ] . int ;
        bisectstack [ bisectptr - 14 ] := mem [ qq + 3 ] . int - mem [ pp + 5 ] . int ;
        bisectstack [ bisectptr - 13 ] := mem [ qq + 1 ] . int - mem [ qq + 3 ] . int ;
        If bisectstack [ bisectptr - 15 ] < 0 Then If bisectstack [ bisectptr - 13 ] >= 0 Then
                                                     Begin
                                                       If bisectstack [ bisectptr - 14 ] < 0 Then bisectstack [ bisectptr - 12 ] := bisectstack [ bisectptr - 15 ] + bisectstack [ bisectptr - 14 ]
                                                       Else bisectstack [ bisectptr - 12 ] := bisectstack [ bisectptr - 15 ] ;
                                                       bisectstack [ bisectptr - 11 ] := bisectstack [ bisectptr - 15 ] + bisectstack [ bisectptr - 14 ] + bisectstack [ bisectptr - 13 ] ;
                                                       If bisectstack [ bisectptr - 11 ] < 0 Then bisectstack [ bisectptr - 11 ] := 0 ;
                                                     End
        Else
          Begin
            bisectstack [ bisectptr - 12 ] := bisectstack [ bisectptr - 15 ] + bisectstack [ bisectptr - 14 ] + bisectstack [ bisectptr - 13 ] ;
            If bisectstack [ bisectptr - 12 ] > bisectstack [ bisectptr - 15 ] Then bisectstack [ bisectptr - 12 ] := bisectstack [ bisectptr - 15 ] ;
            bisectstack [ bisectptr - 11 ] := bisectstack [ bisectptr - 15 ] + bisectstack [ bisectptr - 14 ] ;
            If bisectstack [ bisectptr - 11 ] < 0 Then bisectstack [ bisectptr - 11 ] := 0 ;
          End
        Else If bisectstack [ bisectptr - 13 ] <= 0 Then
               Begin
                 If bisectstack [ bisectptr - 14 ] > 0 Then bisectstack [ bisectptr - 11 ] := bisectstack [ bisectptr - 15 ] + bisectstack [ bisectptr - 14 ]
                 Else bisectstack [ bisectptr - 11 ] := bisectstack [ bisectptr - 15 ] ;
                 bisectstack [ bisectptr - 12 ] := bisectstack [ bisectptr - 15 ] + bisectstack [ bisectptr - 14 ] + bisectstack [ bisectptr - 13 ] ;
                 If bisectstack [ bisectptr - 12 ] > 0 Then bisectstack [ bisectptr - 12 ] := 0 ;
               End
        Else
          Begin
            bisectstack [ bisectptr - 11 ] := bisectstack [ bisectptr - 15 ] + bisectstack [ bisectptr - 14 ] + bisectstack [ bisectptr - 13 ] ;
            If bisectstack [ bisectptr - 11 ] < bisectstack [ bisectptr - 15 ] Then bisectstack [ bisectptr - 11 ] := bisectstack [ bisectptr - 15 ] ;
            bisectstack [ bisectptr - 12 ] := bisectstack [ bisectptr - 15 ] + bisectstack [ bisectptr - 14 ] ;
            If bisectstack [ bisectptr - 12 ] > 0 Then bisectstack [ bisectptr - 12 ] := 0 ;
          End ;
        bisectstack [ bisectptr - 20 ] := mem [ pp + 6 ] . int - mem [ pp + 2 ] . int ;
        bisectstack [ bisectptr - 19 ] := mem [ qq + 4 ] . int - mem [ pp + 6 ] . int ;
        bisectstack [ bisectptr - 18 ] := mem [ qq + 2 ] . int - mem [ qq + 4 ] . int ;
        If bisectstack [ bisectptr - 20 ] < 0 Then If bisectstack [ bisectptr - 18 ] >= 0 Then
                                                     Begin
                                                       If bisectstack [ bisectptr - 19 ] < 0 Then bisectstack [ bisectptr - 17 ] := bisectstack [ bisectptr - 20 ] + bisectstack [ bisectptr - 19 ]
                                                       Else bisectstack [ bisectptr - 17 ] := bisectstack [ bisectptr - 20 ] ;
                                                       bisectstack [ bisectptr - 16 ] := bisectstack [ bisectptr - 20 ] + bisectstack [ bisectptr - 19 ] + bisectstack [ bisectptr - 18 ] ;
                                                       If bisectstack [ bisectptr - 16 ] < 0 Then bisectstack [ bisectptr - 16 ] := 0 ;
                                                     End
        Else
          Begin
            bisectstack [ bisectptr - 17 ] := bisectstack [ bisectptr - 20 ] + bisectstack [ bisectptr - 19 ] + bisectstack [ bisectptr - 18 ] ;
            If bisectstack [ bisectptr - 17 ] > bisectstack [ bisectptr - 20 ] Then bisectstack [ bisectptr - 17 ] := bisectstack [ bisectptr - 20 ] ;
            bisectstack [ bisectptr - 16 ] := bisectstack [ bisectptr - 20 ] + bisectstack [ bisectptr - 19 ] ;
            If bisectstack [ bisectptr - 16 ] < 0 Then bisectstack [ bisectptr - 16 ] := 0 ;
          End
        Else If bisectstack [ bisectptr - 18 ] <= 0 Then
               Begin
                 If bisectstack [ bisectptr - 19 ] > 0 Then bisectstack [ bisectptr - 16 ] := bisectstack [ bisectptr - 20 ] + bisectstack [ bisectptr - 19 ]
                 Else bisectstack [ bisectptr - 16 ] := bisectstack [ bisectptr - 20 ] ;
                 bisectstack [ bisectptr - 17 ] := bisectstack [ bisectptr - 20 ] + bisectstack [ bisectptr - 19 ] + bisectstack [ bisectptr - 18 ] ;
                 If bisectstack [ bisectptr - 17 ] > 0 Then bisectstack [ bisectptr - 17 ] := 0 ;
               End
        Else
          Begin
            bisectstack [ bisectptr - 16 ] := bisectstack [ bisectptr - 20 ] + bisectstack [ bisectptr - 19 ] + bisectstack [ bisectptr - 18 ] ;
            If bisectstack [ bisectptr - 16 ] < bisectstack [ bisectptr - 20 ] Then bisectstack [ bisectptr - 16 ] := bisectstack [ bisectptr - 20 ] ;
            bisectstack [ bisectptr - 17 ] := bisectstack [ bisectptr - 20 ] + bisectstack [ bisectptr - 19 ] ;
            If bisectstack [ bisectptr - 17 ] > 0 Then bisectstack [ bisectptr - 17 ] := 0 ;
          End ;
        delx := mem [ p + 1 ] . int - mem [ pp + 1 ] . int ;
        dely := mem [ p + 2 ] . int - mem [ pp + 2 ] . int ;
        tol := 0 ;
        uv := bisectptr ;
        xy := bisectptr ;
        threel := 0 ;
        curt := 1 ;
        curtt := 1 ;
        While true Do
          Begin
            22 : If delx - tol <= bisectstack [ xy - 11 ] - bisectstack [ uv - 2 ] Then If delx + tol >= bisectstack [ xy - 12 ] - bisectstack [ uv - 1 ] Then If dely - tol <= bisectstack [ xy - 16 ] - bisectstack [ uv - 7 ] Then If dely + tol >= bisectstack [ xy - 17 ] - bisectstack [ uv - 6 ] Then
                                                                                                                                                                                                                                        Begin
                                                                                                                                                                                                                                          If curt >= maxt Then
                                                                                                                                                                                                                                            Begin
                                                                                                                                                                                                                                              If maxt = 131072 Then
                                                                                                                                                                                                                                                Begin
                                                                                                                                                                                                                                                  curt := ( curt + 1 ) Div 2 ;
                                                                                                                                                                                                                                                  curtt := ( curtt + 1 ) Div 2 ;
                                                                                                                                                                                                                                                  goto 10 ;
                                                                                                                                                                                                                                                End ;
                                                                                                                                                                                                                                              maxt := maxt + maxt ;
                                                                                                                                                                                                                                              apprt := curt ;
                                                                                                                                                                                                                                              apprtt := curtt ;
                                                                                                                                                                                                                                            End ;
                                                                                                                                                                                                                                          bisectstack [ bisectptr ] := delx ;
                                                                                                                                                                                                                                          bisectstack [ bisectptr + 1 ] := dely ;
                                                                                                                                                                                                                                          bisectstack [ bisectptr + 2 ] := tol ;
                                                                                                                                                                                                                                          bisectstack [ bisectptr + 3 ] := uv ;
                                                                                                                                                                                                                                          bisectstack [ bisectptr + 4 ] := xy ;
                                                                                                                                                                                                                                          bisectptr := bisectptr + 45 ;
                                                                                                                                                                                                                                          curt := curt + curt ;
                                                                                                                                                                                                                                          curtt := curtt + curtt ;
                                                                                                                                                                                                                                          bisectstack [ bisectptr - 25 ] := bisectstack [ uv - 5 ] ;
                                                                                                                                                                                                                                          bisectstack [ bisectptr - 3 ] := bisectstack [ uv - 3 ] ;
                                                                                                                                                                                                                                          bisectstack [ bisectptr - 24 ] := ( bisectstack [ bisectptr - 25 ] + bisectstack [ uv - 4 ] ) Div 2 ;
                                                                                                                                                                                                                                          bisectstack [ bisectptr - 4 ] := ( bisectstack [ bisectptr - 3 ] + bisectstack [ uv - 4 ] ) Div 2 ;
                                                                                                                                                                                                                                          bisectstack [ bisectptr - 23 ] := ( bisectstack [ bisectptr - 24 ] + bisectstack [ bisectptr - 4 ] ) Div 2 ;
                                                                                                                                                                                                                                          bisectstack [ bisectptr - 5 ] := bisectstack [ bisectptr - 23 ] ;
                                                                                                                                                                                                                                          If bisectstack [ bisectptr - 25 ] < 0 Then If bisectstack [ bisectptr - 23 ] >= 0 Then
                                                                                                                                                                                                                                                                                       Begin
                                                                                                                                                                                                                                                                                         If bisectstack [ bisectptr - 24 ] < 0 Then bisectstack [ bisectptr - 22 ] := bisectstack [ bisectptr - 25 ] + bisectstack [ bisectptr - 24 ]
                                                                                                                                                                                                                                                                                         Else bisectstack [ bisectptr - 22 ] := bisectstack [ bisectptr - 25 ] ;
                                                                                                                                                                                                                                                                                         bisectstack [ bisectptr - 21 ] := bisectstack [ bisectptr - 25 ] + bisectstack [ bisectptr - 24 ] + bisectstack [ bisectptr - 23 ] ;
                                                                                                                                                                                                                                                                                         If bisectstack [ bisectptr - 21 ] < 0 Then bisectstack [ bisectptr - 21 ] := 0 ;
                                                                                                                                                                                                                                                                                       End
                                                                                                                                                                                                                                          Else
                                                                                                                                                                                                                                            Begin
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 22 ] := bisectstack [ bisectptr - 25 ] + bisectstack [ bisectptr - 24 ] + bisectstack [ bisectptr - 23 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 22 ] > bisectstack [ bisectptr - 25 ] Then bisectstack [ bisectptr - 22 ] := bisectstack [ bisectptr - 25 ] ;
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 21 ] := bisectstack [ bisectptr - 25 ] + bisectstack [ bisectptr - 24 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 21 ] < 0 Then bisectstack [ bisectptr - 21 ] := 0 ;
                                                                                                                                                                                                                                            End
                                                                                                                                                                                                                                          Else If bisectstack [ bisectptr - 23 ] <= 0 Then
                                                                                                                                                                                                                                                 Begin
                                                                                                                                                                                                                                                   If bisectstack [ bisectptr - 24 ] > 0 Then bisectstack [ bisectptr - 21 ] := bisectstack [ bisectptr - 25 ] + bisectstack [ bisectptr - 24 ]
                                                                                                                                                                                                                                                   Else bisectstack [ bisectptr - 21 ] := bisectstack [ bisectptr - 25 ] ;
                                                                                                                                                                                                                                                   bisectstack [ bisectptr - 22 ] := bisectstack [ bisectptr - 25 ] + bisectstack [ bisectptr - 24 ] + bisectstack [ bisectptr - 23 ] ;
                                                                                                                                                                                                                                                   If bisectstack [ bisectptr - 22 ] > 0 Then bisectstack [ bisectptr - 22 ] := 0 ;
                                                                                                                                                                                                                                                 End
                                                                                                                                                                                                                                          Else
                                                                                                                                                                                                                                            Begin
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 21 ] := bisectstack [ bisectptr - 25 ] + bisectstack [ bisectptr - 24 ] + bisectstack [ bisectptr - 23 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 21 ] < bisectstack [ bisectptr - 25 ] Then bisectstack [ bisectptr - 21 ] := bisectstack [ bisectptr - 25 ] ;
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 22 ] := bisectstack [ bisectptr - 25 ] + bisectstack [ bisectptr - 24 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 22 ] > 0 Then bisectstack [ bisectptr - 22 ] := 0 ;
                                                                                                                                                                                                                                            End ;
                                                                                                                                                                                                                                          If bisectstack [ bisectptr - 5 ] < 0 Then If bisectstack [ bisectptr - 3 ] >= 0 Then
                                                                                                                                                                                                                                                                                      Begin
                                                                                                                                                                                                                                                                                        If bisectstack [ bisectptr - 4 ] < 0 Then bisectstack [ bisectptr - 2 ] := bisectstack [ bisectptr - 5 ] + bisectstack [ bisectptr - 4 ]
                                                                                                                                                                                                                                                                                        Else bisectstack [ bisectptr - 2 ] := bisectstack [ bisectptr - 5 ] ;
                                                                                                                                                                                                                                                                                        bisectstack [ bisectptr - 1 ] := bisectstack [ bisectptr - 5 ] + bisectstack [ bisectptr - 4 ] + bisectstack [ bisectptr - 3 ] ;
                                                                                                                                                                                                                                                                                        If bisectstack [ bisectptr - 1 ] < 0 Then bisectstack [ bisectptr - 1 ] := 0 ;
                                                                                                                                                                                                                                                                                      End
                                                                                                                                                                                                                                          Else
                                                                                                                                                                                                                                            Begin
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 2 ] := bisectstack [ bisectptr - 5 ] + bisectstack [ bisectptr - 4 ] + bisectstack [ bisectptr - 3 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 2 ] > bisectstack [ bisectptr - 5 ] Then bisectstack [ bisectptr - 2 ] := bisectstack [ bisectptr - 5 ] ;
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 1 ] := bisectstack [ bisectptr - 5 ] + bisectstack [ bisectptr - 4 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 1 ] < 0 Then bisectstack [ bisectptr - 1 ] := 0 ;
                                                                                                                                                                                                                                            End
                                                                                                                                                                                                                                          Else If bisectstack [ bisectptr - 3 ] <= 0 Then
                                                                                                                                                                                                                                                 Begin
                                                                                                                                                                                                                                                   If bisectstack [ bisectptr - 4 ] > 0 Then bisectstack [ bisectptr - 1 ] := bisectstack [ bisectptr - 5 ] + bisectstack [ bisectptr - 4 ]
                                                                                                                                                                                                                                                   Else bisectstack [ bisectptr - 1 ] := bisectstack [ bisectptr - 5 ] ;
                                                                                                                                                                                                                                                   bisectstack [ bisectptr - 2 ] := bisectstack [ bisectptr - 5 ] + bisectstack [ bisectptr - 4 ] + bisectstack [ bisectptr - 3 ] ;
                                                                                                                                                                                                                                                   If bisectstack [ bisectptr - 2 ] > 0 Then bisectstack [ bisectptr - 2 ] := 0 ;
                                                                                                                                                                                                                                                 End
                                                                                                                                                                                                                                          Else
                                                                                                                                                                                                                                            Begin
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 1 ] := bisectstack [ bisectptr - 5 ] + bisectstack [ bisectptr - 4 ] + bisectstack [ bisectptr - 3 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 1 ] < bisectstack [ bisectptr - 5 ] Then bisectstack [ bisectptr - 1 ] := bisectstack [ bisectptr - 5 ] ;
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 2 ] := bisectstack [ bisectptr - 5 ] + bisectstack [ bisectptr - 4 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 2 ] > 0 Then bisectstack [ bisectptr - 2 ] := 0 ;
                                                                                                                                                                                                                                            End ;
                                                                                                                                                                                                                                          bisectstack [ bisectptr - 30 ] := bisectstack [ uv - 10 ] ;
                                                                                                                                                                                                                                          bisectstack [ bisectptr - 8 ] := bisectstack [ uv - 8 ] ;
                                                                                                                                                                                                                                          bisectstack [ bisectptr - 29 ] := ( bisectstack [ bisectptr - 30 ] + bisectstack [ uv - 9 ] ) Div 2 ;
                                                                                                                                                                                                                                          bisectstack [ bisectptr - 9 ] := ( bisectstack [ bisectptr - 8 ] + bisectstack [ uv - 9 ] ) Div 2 ;
                                                                                                                                                                                                                                          bisectstack [ bisectptr - 28 ] := ( bisectstack [ bisectptr - 29 ] + bisectstack [ bisectptr - 9 ] ) Div 2 ;
                                                                                                                                                                                                                                          bisectstack [ bisectptr - 10 ] := bisectstack [ bisectptr - 28 ] ;
                                                                                                                                                                                                                                          If bisectstack [ bisectptr - 30 ] < 0 Then If bisectstack [ bisectptr - 28 ] >= 0 Then
                                                                                                                                                                                                                                                                                       Begin
                                                                                                                                                                                                                                                                                         If bisectstack [ bisectptr - 29 ] < 0 Then bisectstack [ bisectptr - 27 ] := bisectstack [ bisectptr - 30 ] + bisectstack [ bisectptr - 29 ]
                                                                                                                                                                                                                                                                                         Else bisectstack [ bisectptr - 27 ] := bisectstack [ bisectptr - 30 ] ;
                                                                                                                                                                                                                                                                                         bisectstack [ bisectptr - 26 ] := bisectstack [ bisectptr - 30 ] + bisectstack [ bisectptr - 29 ] + bisectstack [ bisectptr - 28 ] ;
                                                                                                                                                                                                                                                                                         If bisectstack [ bisectptr - 26 ] < 0 Then bisectstack [ bisectptr - 26 ] := 0 ;
                                                                                                                                                                                                                                                                                       End
                                                                                                                                                                                                                                          Else
                                                                                                                                                                                                                                            Begin
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 27 ] := bisectstack [ bisectptr - 30 ] + bisectstack [ bisectptr - 29 ] + bisectstack [ bisectptr - 28 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 27 ] > bisectstack [ bisectptr - 30 ] Then bisectstack [ bisectptr - 27 ] := bisectstack [ bisectptr - 30 ] ;
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 26 ] := bisectstack [ bisectptr - 30 ] + bisectstack [ bisectptr - 29 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 26 ] < 0 Then bisectstack [ bisectptr - 26 ] := 0 ;
                                                                                                                                                                                                                                            End
                                                                                                                                                                                                                                          Else If bisectstack [ bisectptr - 28 ] <= 0 Then
                                                                                                                                                                                                                                                 Begin
                                                                                                                                                                                                                                                   If bisectstack [ bisectptr - 29 ] > 0 Then bisectstack [ bisectptr - 26 ] := bisectstack [ bisectptr - 30 ] + bisectstack [ bisectptr - 29 ]
                                                                                                                                                                                                                                                   Else bisectstack [ bisectptr - 26 ] := bisectstack [ bisectptr - 30 ] ;
                                                                                                                                                                                                                                                   bisectstack [ bisectptr - 27 ] := bisectstack [ bisectptr - 30 ] + bisectstack [ bisectptr - 29 ] + bisectstack [ bisectptr - 28 ] ;
                                                                                                                                                                                                                                                   If bisectstack [ bisectptr - 27 ] > 0 Then bisectstack [ bisectptr - 27 ] := 0 ;
                                                                                                                                                                                                                                                 End
                                                                                                                                                                                                                                          Else
                                                                                                                                                                                                                                            Begin
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 26 ] := bisectstack [ bisectptr - 30 ] + bisectstack [ bisectptr - 29 ] + bisectstack [ bisectptr - 28 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 26 ] < bisectstack [ bisectptr - 30 ] Then bisectstack [ bisectptr - 26 ] := bisectstack [ bisectptr - 30 ] ;
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 27 ] := bisectstack [ bisectptr - 30 ] + bisectstack [ bisectptr - 29 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 27 ] > 0 Then bisectstack [ bisectptr - 27 ] := 0 ;
                                                                                                                                                                                                                                            End ;
                                                                                                                                                                                                                                          If bisectstack [ bisectptr - 10 ] < 0 Then If bisectstack [ bisectptr - 8 ] >= 0 Then
                                                                                                                                                                                                                                                                                       Begin
                                                                                                                                                                                                                                                                                         If bisectstack [ bisectptr - 9 ] < 0 Then bisectstack [ bisectptr - 7 ] := bisectstack [ bisectptr - 10 ] + bisectstack [ bisectptr - 9 ]
                                                                                                                                                                                                                                                                                         Else bisectstack [ bisectptr - 7 ] := bisectstack [ bisectptr - 10 ] ;
                                                                                                                                                                                                                                                                                         bisectstack [ bisectptr - 6 ] := bisectstack [ bisectptr - 10 ] + bisectstack [ bisectptr - 9 ] + bisectstack [ bisectptr - 8 ] ;
                                                                                                                                                                                                                                                                                         If bisectstack [ bisectptr - 6 ] < 0 Then bisectstack [ bisectptr - 6 ] := 0 ;
                                                                                                                                                                                                                                                                                       End
                                                                                                                                                                                                                                          Else
                                                                                                                                                                                                                                            Begin
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 7 ] := bisectstack [ bisectptr - 10 ] + bisectstack [ bisectptr - 9 ] + bisectstack [ bisectptr - 8 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 7 ] > bisectstack [ bisectptr - 10 ] Then bisectstack [ bisectptr - 7 ] := bisectstack [ bisectptr - 10 ] ;
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 6 ] := bisectstack [ bisectptr - 10 ] + bisectstack [ bisectptr - 9 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 6 ] < 0 Then bisectstack [ bisectptr - 6 ] := 0 ;
                                                                                                                                                                                                                                            End
                                                                                                                                                                                                                                          Else If bisectstack [ bisectptr - 8 ] <= 0 Then
                                                                                                                                                                                                                                                 Begin
                                                                                                                                                                                                                                                   If bisectstack [ bisectptr - 9 ] > 0 Then bisectstack [ bisectptr - 6 ] := bisectstack [ bisectptr - 10 ] + bisectstack [ bisectptr - 9 ]
                                                                                                                                                                                                                                                   Else bisectstack [ bisectptr - 6 ] := bisectstack [ bisectptr - 10 ] ;
                                                                                                                                                                                                                                                   bisectstack [ bisectptr - 7 ] := bisectstack [ bisectptr - 10 ] + bisectstack [ bisectptr - 9 ] + bisectstack [ bisectptr - 8 ] ;
                                                                                                                                                                                                                                                   If bisectstack [ bisectptr - 7 ] > 0 Then bisectstack [ bisectptr - 7 ] := 0 ;
                                                                                                                                                                                                                                                 End
                                                                                                                                                                                                                                          Else
                                                                                                                                                                                                                                            Begin
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 6 ] := bisectstack [ bisectptr - 10 ] + bisectstack [ bisectptr - 9 ] + bisectstack [ bisectptr - 8 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 6 ] < bisectstack [ bisectptr - 10 ] Then bisectstack [ bisectptr - 6 ] := bisectstack [ bisectptr - 10 ] ;
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 7 ] := bisectstack [ bisectptr - 10 ] + bisectstack [ bisectptr - 9 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 7 ] > 0 Then bisectstack [ bisectptr - 7 ] := 0 ;
                                                                                                                                                                                                                                            End ;
                                                                                                                                                                                                                                          bisectstack [ bisectptr - 35 ] := bisectstack [ xy - 15 ] ;
                                                                                                                                                                                                                                          bisectstack [ bisectptr - 13 ] := bisectstack [ xy - 13 ] ;
                                                                                                                                                                                                                                          bisectstack [ bisectptr - 34 ] := ( bisectstack [ bisectptr - 35 ] + bisectstack [ xy - 14 ] ) Div 2 ;
                                                                                                                                                                                                                                          bisectstack [ bisectptr - 14 ] := ( bisectstack [ bisectptr - 13 ] + bisectstack [ xy - 14 ] ) Div 2 ;
                                                                                                                                                                                                                                          bisectstack [ bisectptr - 33 ] := ( bisectstack [ bisectptr - 34 ] + bisectstack [ bisectptr - 14 ] ) Div 2 ;
                                                                                                                                                                                                                                          bisectstack [ bisectptr - 15 ] := bisectstack [ bisectptr - 33 ] ;
                                                                                                                                                                                                                                          If bisectstack [ bisectptr - 35 ] < 0 Then If bisectstack [ bisectptr - 33 ] >= 0 Then
                                                                                                                                                                                                                                                                                       Begin
                                                                                                                                                                                                                                                                                         If bisectstack [ bisectptr - 34 ] < 0 Then bisectstack [ bisectptr - 32 ] := bisectstack [ bisectptr - 35 ] + bisectstack [ bisectptr - 34 ]
                                                                                                                                                                                                                                                                                         Else bisectstack [ bisectptr - 32 ] := bisectstack [ bisectptr - 35 ] ;
                                                                                                                                                                                                                                                                                         bisectstack [ bisectptr - 31 ] := bisectstack [ bisectptr - 35 ] + bisectstack [ bisectptr - 34 ] + bisectstack [ bisectptr - 33 ] ;
                                                                                                                                                                                                                                                                                         If bisectstack [ bisectptr - 31 ] < 0 Then bisectstack [ bisectptr - 31 ] := 0 ;
                                                                                                                                                                                                                                                                                       End
                                                                                                                                                                                                                                          Else
                                                                                                                                                                                                                                            Begin
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 32 ] := bisectstack [ bisectptr - 35 ] + bisectstack [ bisectptr - 34 ] + bisectstack [ bisectptr - 33 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 32 ] > bisectstack [ bisectptr - 35 ] Then bisectstack [ bisectptr - 32 ] := bisectstack [ bisectptr - 35 ] ;
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 31 ] := bisectstack [ bisectptr - 35 ] + bisectstack [ bisectptr - 34 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 31 ] < 0 Then bisectstack [ bisectptr - 31 ] := 0 ;
                                                                                                                                                                                                                                            End
                                                                                                                                                                                                                                          Else If bisectstack [ bisectptr - 33 ] <= 0 Then
                                                                                                                                                                                                                                                 Begin
                                                                                                                                                                                                                                                   If bisectstack [ bisectptr - 34 ] > 0 Then bisectstack [ bisectptr - 31 ] := bisectstack [ bisectptr - 35 ] + bisectstack [ bisectptr - 34 ]
                                                                                                                                                                                                                                                   Else bisectstack [ bisectptr - 31 ] := bisectstack [ bisectptr - 35 ] ;
                                                                                                                                                                                                                                                   bisectstack [ bisectptr - 32 ] := bisectstack [ bisectptr - 35 ] + bisectstack [ bisectptr - 34 ] + bisectstack [ bisectptr - 33 ] ;
                                                                                                                                                                                                                                                   If bisectstack [ bisectptr - 32 ] > 0 Then bisectstack [ bisectptr - 32 ] := 0 ;
                                                                                                                                                                                                                                                 End
                                                                                                                                                                                                                                          Else
                                                                                                                                                                                                                                            Begin
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 31 ] := bisectstack [ bisectptr - 35 ] + bisectstack [ bisectptr - 34 ] + bisectstack [ bisectptr - 33 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 31 ] < bisectstack [ bisectptr - 35 ] Then bisectstack [ bisectptr - 31 ] := bisectstack [ bisectptr - 35 ] ;
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 32 ] := bisectstack [ bisectptr - 35 ] + bisectstack [ bisectptr - 34 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 32 ] > 0 Then bisectstack [ bisectptr - 32 ] := 0 ;
                                                                                                                                                                                                                                            End ;
                                                                                                                                                                                                                                          If bisectstack [ bisectptr - 15 ] < 0 Then If bisectstack [ bisectptr - 13 ] >= 0 Then
                                                                                                                                                                                                                                                                                       Begin
                                                                                                                                                                                                                                                                                         If bisectstack [ bisectptr - 14 ] < 0 Then bisectstack [ bisectptr - 12 ] := bisectstack [ bisectptr - 15 ] + bisectstack [ bisectptr - 14 ]
                                                                                                                                                                                                                                                                                         Else bisectstack [ bisectptr - 12 ] := bisectstack [ bisectptr - 15 ] ;
                                                                                                                                                                                                                                                                                         bisectstack [ bisectptr - 11 ] := bisectstack [ bisectptr - 15 ] + bisectstack [ bisectptr - 14 ] + bisectstack [ bisectptr - 13 ] ;
                                                                                                                                                                                                                                                                                         If bisectstack [ bisectptr - 11 ] < 0 Then bisectstack [ bisectptr - 11 ] := 0 ;
                                                                                                                                                                                                                                                                                       End
                                                                                                                                                                                                                                          Else
                                                                                                                                                                                                                                            Begin
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 12 ] := bisectstack [ bisectptr - 15 ] + bisectstack [ bisectptr - 14 ] + bisectstack [ bisectptr - 13 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 12 ] > bisectstack [ bisectptr - 15 ] Then bisectstack [ bisectptr - 12 ] := bisectstack [ bisectptr - 15 ] ;
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 11 ] := bisectstack [ bisectptr - 15 ] + bisectstack [ bisectptr - 14 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 11 ] < 0 Then bisectstack [ bisectptr - 11 ] := 0 ;
                                                                                                                                                                                                                                            End
                                                                                                                                                                                                                                          Else If bisectstack [ bisectptr - 13 ] <= 0 Then
                                                                                                                                                                                                                                                 Begin
                                                                                                                                                                                                                                                   If bisectstack [ bisectptr - 14 ] > 0 Then bisectstack [ bisectptr - 11 ] := bisectstack [ bisectptr - 15 ] + bisectstack [ bisectptr - 14 ]
                                                                                                                                                                                                                                                   Else bisectstack [ bisectptr - 11 ] := bisectstack [ bisectptr - 15 ] ;
                                                                                                                                                                                                                                                   bisectstack [ bisectptr - 12 ] := bisectstack [ bisectptr - 15 ] + bisectstack [ bisectptr - 14 ] + bisectstack [ bisectptr - 13 ] ;
                                                                                                                                                                                                                                                   If bisectstack [ bisectptr - 12 ] > 0 Then bisectstack [ bisectptr - 12 ] := 0 ;
                                                                                                                                                                                                                                                 End
                                                                                                                                                                                                                                          Else
                                                                                                                                                                                                                                            Begin
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 11 ] := bisectstack [ bisectptr - 15 ] + bisectstack [ bisectptr - 14 ] + bisectstack [ bisectptr - 13 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 11 ] < bisectstack [ bisectptr - 15 ] Then bisectstack [ bisectptr - 11 ] := bisectstack [ bisectptr - 15 ] ;
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 12 ] := bisectstack [ bisectptr - 15 ] + bisectstack [ bisectptr - 14 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 12 ] > 0 Then bisectstack [ bisectptr - 12 ] := 0 ;
                                                                                                                                                                                                                                            End ;
                                                                                                                                                                                                                                          bisectstack [ bisectptr - 40 ] := bisectstack [ xy - 20 ] ;
                                                                                                                                                                                                                                          bisectstack [ bisectptr - 18 ] := bisectstack [ xy - 18 ] ;
                                                                                                                                                                                                                                          bisectstack [ bisectptr - 39 ] := ( bisectstack [ bisectptr - 40 ] + bisectstack [ xy - 19 ] ) Div 2 ;
                                                                                                                                                                                                                                          bisectstack [ bisectptr - 19 ] := ( bisectstack [ bisectptr - 18 ] + bisectstack [ xy - 19 ] ) Div 2 ;
                                                                                                                                                                                                                                          bisectstack [ bisectptr - 38 ] := ( bisectstack [ bisectptr - 39 ] + bisectstack [ bisectptr - 19 ] ) Div 2 ;
                                                                                                                                                                                                                                          bisectstack [ bisectptr - 20 ] := bisectstack [ bisectptr - 38 ] ;
                                                                                                                                                                                                                                          If bisectstack [ bisectptr - 40 ] < 0 Then If bisectstack [ bisectptr - 38 ] >= 0 Then
                                                                                                                                                                                                                                                                                       Begin
                                                                                                                                                                                                                                                                                         If bisectstack [ bisectptr - 39 ] < 0 Then bisectstack [ bisectptr - 37 ] := bisectstack [ bisectptr - 40 ] + bisectstack [ bisectptr - 39 ]
                                                                                                                                                                                                                                                                                         Else bisectstack [ bisectptr - 37 ] := bisectstack [ bisectptr - 40 ] ;
                                                                                                                                                                                                                                                                                         bisectstack [ bisectptr - 36 ] := bisectstack [ bisectptr - 40 ] + bisectstack [ bisectptr - 39 ] + bisectstack [ bisectptr - 38 ] ;
                                                                                                                                                                                                                                                                                         If bisectstack [ bisectptr - 36 ] < 0 Then bisectstack [ bisectptr - 36 ] := 0 ;
                                                                                                                                                                                                                                                                                       End
                                                                                                                                                                                                                                          Else
                                                                                                                                                                                                                                            Begin
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 37 ] := bisectstack [ bisectptr - 40 ] + bisectstack [ bisectptr - 39 ] + bisectstack [ bisectptr - 38 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 37 ] > bisectstack [ bisectptr - 40 ] Then bisectstack [ bisectptr - 37 ] := bisectstack [ bisectptr - 40 ] ;
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 36 ] := bisectstack [ bisectptr - 40 ] + bisectstack [ bisectptr - 39 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 36 ] < 0 Then bisectstack [ bisectptr - 36 ] := 0 ;
                                                                                                                                                                                                                                            End
                                                                                                                                                                                                                                          Else If bisectstack [ bisectptr - 38 ] <= 0 Then
                                                                                                                                                                                                                                                 Begin
                                                                                                                                                                                                                                                   If bisectstack [ bisectptr - 39 ] > 0 Then bisectstack [ bisectptr - 36 ] := bisectstack [ bisectptr - 40 ] + bisectstack [ bisectptr - 39 ]
                                                                                                                                                                                                                                                   Else bisectstack [ bisectptr - 36 ] := bisectstack [ bisectptr - 40 ] ;
                                                                                                                                                                                                                                                   bisectstack [ bisectptr - 37 ] := bisectstack [ bisectptr - 40 ] + bisectstack [ bisectptr - 39 ] + bisectstack [ bisectptr - 38 ] ;
                                                                                                                                                                                                                                                   If bisectstack [ bisectptr - 37 ] > 0 Then bisectstack [ bisectptr - 37 ] := 0 ;
                                                                                                                                                                                                                                                 End
                                                                                                                                                                                                                                          Else
                                                                                                                                                                                                                                            Begin
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 36 ] := bisectstack [ bisectptr - 40 ] + bisectstack [ bisectptr - 39 ] + bisectstack [ bisectptr - 38 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 36 ] < bisectstack [ bisectptr - 40 ] Then bisectstack [ bisectptr - 36 ] := bisectstack [ bisectptr - 40 ] ;
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 37 ] := bisectstack [ bisectptr - 40 ] + bisectstack [ bisectptr - 39 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 37 ] > 0 Then bisectstack [ bisectptr - 37 ] := 0 ;
                                                                                                                                                                                                                                            End ;
                                                                                                                                                                                                                                          If bisectstack [ bisectptr - 20 ] < 0 Then If bisectstack [ bisectptr - 18 ] >= 0 Then
                                                                                                                                                                                                                                                                                       Begin
                                                                                                                                                                                                                                                                                         If bisectstack [ bisectptr - 19 ] < 0 Then bisectstack [ bisectptr - 17 ] := bisectstack [ bisectptr - 20 ] + bisectstack [ bisectptr - 19 ]
                                                                                                                                                                                                                                                                                         Else bisectstack [ bisectptr - 17 ] := bisectstack [ bisectptr - 20 ] ;
                                                                                                                                                                                                                                                                                         bisectstack [ bisectptr - 16 ] := bisectstack [ bisectptr - 20 ] + bisectstack [ bisectptr - 19 ] + bisectstack [ bisectptr - 18 ] ;
                                                                                                                                                                                                                                                                                         If bisectstack [ bisectptr - 16 ] < 0 Then bisectstack [ bisectptr - 16 ] := 0 ;
                                                                                                                                                                                                                                                                                       End
                                                                                                                                                                                                                                          Else
                                                                                                                                                                                                                                            Begin
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 17 ] := bisectstack [ bisectptr - 20 ] + bisectstack [ bisectptr - 19 ] + bisectstack [ bisectptr - 18 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 17 ] > bisectstack [ bisectptr - 20 ] Then bisectstack [ bisectptr - 17 ] := bisectstack [ bisectptr - 20 ] ;
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 16 ] := bisectstack [ bisectptr - 20 ] + bisectstack [ bisectptr - 19 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 16 ] < 0 Then bisectstack [ bisectptr - 16 ] := 0 ;
                                                                                                                                                                                                                                            End
                                                                                                                                                                                                                                          Else If bisectstack [ bisectptr - 18 ] <= 0 Then
                                                                                                                                                                                                                                                 Begin
                                                                                                                                                                                                                                                   If bisectstack [ bisectptr - 19 ] > 0 Then bisectstack [ bisectptr - 16 ] := bisectstack [ bisectptr - 20 ] + bisectstack [ bisectptr - 19 ]
                                                                                                                                                                                                                                                   Else bisectstack [ bisectptr - 16 ] := bisectstack [ bisectptr - 20 ] ;
                                                                                                                                                                                                                                                   bisectstack [ bisectptr - 17 ] := bisectstack [ bisectptr - 20 ] + bisectstack [ bisectptr - 19 ] + bisectstack [ bisectptr - 18 ] ;
                                                                                                                                                                                                                                                   If bisectstack [ bisectptr - 17 ] > 0 Then bisectstack [ bisectptr - 17 ] := 0 ;
                                                                                                                                                                                                                                                 End
                                                                                                                                                                                                                                          Else
                                                                                                                                                                                                                                            Begin
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 16 ] := bisectstack [ bisectptr - 20 ] + bisectstack [ bisectptr - 19 ] + bisectstack [ bisectptr - 18 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 16 ] < bisectstack [ bisectptr - 20 ] Then bisectstack [ bisectptr - 16 ] := bisectstack [ bisectptr - 20 ] ;
                                                                                                                                                                                                                                              bisectstack [ bisectptr - 17 ] := bisectstack [ bisectptr - 20 ] + bisectstack [ bisectptr - 19 ] ;
                                                                                                                                                                                                                                              If bisectstack [ bisectptr - 17 ] > 0 Then bisectstack [ bisectptr - 17 ] := 0 ;
                                                                                                                                                                                                                                            End ;
                                                                                                                                                                                                                                          uv := bisectptr - 20 ;
                                                                                                                                                                                                                                          xy := bisectptr - 20 ;
                                                                                                                                                                                                                                          delx := delx + delx ;
                                                                                                                                                                                                                                          dely := dely + dely ;
                                                                                                                                                                                                                                          tol := tol - threel + tolstep ;
                                                                                                                                                                                                                                          tol := tol + tol ;
                                                                                                                                                                                                                                          threel := threel + tolstep ;
                                                                                                                                                                                                                                          goto 22 ;
                                                                                                                                                                                                                                        End ;
            If timetogo > 0 Then timetogo := timetogo - 1
            Else
              Begin
                While apprt < 65536 Do
                  Begin
                    apprt := apprt + apprt ;
                    apprtt := apprtt + apprtt ;
                  End ;
                curt := apprt ;
                curtt := apprtt ;
                goto 10 ;
              End ;
            45 : If odd ( curtt ) Then If odd ( curt ) Then
                                         Begin
                                           curt := ( curt ) Div 2 ;
                                           curtt := ( curtt ) Div 2 ;
                                           If curt = 0 Then goto 10 ;
                                           bisectptr := bisectptr - 45 ;
                                           threel := threel - tolstep ;
                                           delx := bisectstack [ bisectptr ] ;
                                           dely := bisectstack [ bisectptr + 1 ] ;
                                           tol := bisectstack [ bisectptr + 2 ] ;
                                           uv := bisectstack [ bisectptr + 3 ] ;
                                           xy := bisectstack [ bisectptr + 4 ] ;
                                           goto 45 ;
                                         End
                 Else
                   Begin
                     curt := curt + 1 ;
                     delx := delx + bisectstack [ uv - 5 ] + bisectstack [ uv - 4 ] + bisectstack [ uv - 3 ] ;
                     dely := dely + bisectstack [ uv - 10 ] + bisectstack [ uv - 9 ] + bisectstack [ uv - 8 ] ;
                     uv := uv + 20 ;
                     curtt := curtt - 1 ;
                     xy := xy - 20 ;
                     delx := delx + bisectstack [ xy - 15 ] + bisectstack [ xy - 14 ] + bisectstack [ xy - 13 ] ;
                     dely := dely + bisectstack [ xy - 20 ] + bisectstack [ xy - 19 ] + bisectstack [ xy - 18 ] ;
                   End
                 Else
                   Begin
                     curtt := curtt + 1 ;
                     tol := tol + threel ;
                     delx := delx - bisectstack [ xy - 15 ] - bisectstack [ xy - 14 ] - bisectstack [ xy - 13 ] ;
                     dely := dely - bisectstack [ xy - 20 ] - bisectstack [ xy - 19 ] - bisectstack [ xy - 18 ] ;
                     xy := xy + 20 ;
                   End ;
          End ;
        10 :
      End ;
      Procedure pathintersection ( h , hh : halfword ) ;

      Label 10 ;

      Var p , pp : halfword ;
        n , nn : integer ;
      Begin
        If mem [ h ] . hh . b1 = 0 Then
          Begin
            mem [ h + 5 ] . int := mem [ h + 1 ] . int ;
            mem [ h + 3 ] . int := mem [ h + 1 ] . int ;
            mem [ h + 6 ] . int := mem [ h + 2 ] . int ;
            mem [ h + 4 ] . int := mem [ h + 2 ] . int ;
            mem [ h ] . hh . b1 := 1 ;
          End ;
        If mem [ hh ] . hh . b1 = 0 Then
          Begin
            mem [ hh + 5 ] . int := mem [ hh + 1 ] . int ;
            mem [ hh + 3 ] . int := mem [ hh + 1 ] . int ;
            mem [ hh + 6 ] . int := mem [ hh + 2 ] . int ;
            mem [ hh + 4 ] . int := mem [ hh + 2 ] . int ;
            mem [ hh ] . hh . b1 := 1 ;
          End ; ;
        tolstep := 0 ;
        Repeat
          n := - 65536 ;
          p := h ;
          Repeat
            If mem [ p ] . hh . b1 <> 0 Then
              Begin
                nn := - 65536 ;
                pp := hh ;
                Repeat
                  If mem [ pp ] . hh . b1 <> 0 Then
                    Begin
                      cubicintersection ( p , pp ) ;
                      If curt > 0 Then
                        Begin
                          curt := curt + n ;
                          curtt := curtt + nn ;
                          goto 10 ;
                        End ;
                    End ;
                  nn := nn + 65536 ;
                  pp := mem [ pp ] . hh . rh ;
                Until pp = hh ;
              End ;
            n := n + 65536 ;
            p := mem [ p ] . hh . rh ;
          Until p = h ;
          tolstep := tolstep + 3 ;
        Until tolstep > 3 ;
        curt := - 65536 ;
        curtt := - 65536 ;
        10 :
      End ;
      Function initscreen : boolean ;
      Begin
        initscreen := false ;
      End ;
      Procedure updatescreen ;
      Begin
        writeln ( logfile , 'Calling UPDATESCREEN' ) ;
      End ;
      Procedure blankrectangle ( leftcol , rightcol : screencol ; toprow , botrow : screenrow ) ;

      Var r : screenrow ;
        c : screencol ;
      Begin
        writeln ( logfile ) ;
        writeln ( logfile , 'Calling BLANKRECTANGLE(' , leftcol : 1 , ',' , rightcol : 1 , ',' , toprow : 1 , ',' , botrow : 1 , ')' ) ;
      End ;
      Procedure paintrow ( r : screenrow ; b : pixelcolor ; Var a : transspec ; n : screencol ) ;

      Var k : screencol ;
        c : screencol ;
      Begin
        write ( logfile , 'Calling PAINTROW(' , r : 1 , ',' , b : 1 , ';' ) ;
        For k := 0 To n Do
          Begin
            write ( logfile , a [ k ] : 1 ) ;
            If k <> n Then write ( logfile , ',' ) ;
          End ;
        writeln ( logfile , ')' ) ;
      End ;
      Procedure openawindow ( k : windownumber ; r0 , c0 , r1 , c1 : scaled ; x , y : scaled ) ;

      Var m , n : integer ;
      Begin
        If r0 < 0 Then r0 := 0
        Else r0 := roundunscaled ( r0 ) ;
        r1 := roundunscaled ( r1 ) ;
        If r1 > screendepth Then r1 := screendepth ;
        If r1 < r0 Then If r0 > screendepth Then r0 := r1
        Else r1 := r0 ;
        If c0 < 0 Then c0 := 0
        Else c0 := roundunscaled ( c0 ) ;
        c1 := roundunscaled ( c1 ) ;
        If c1 > screenwidth Then c1 := screenwidth ;
        If c1 < c0 Then If c0 > screenwidth Then c0 := c1
        Else c1 := c0 ;
        windowopen [ k ] := true ;
        windowtime [ k ] := windowtime [ k ] + 1 ;
        leftcol [ k ] := c0 ;
        rightcol [ k ] := c1 ;
        toprow [ k ] := r0 ;
        botrow [ k ] := r1 ;
        m := roundunscaled ( x ) ;
        n := roundunscaled ( y ) - 1 ;
        mwindow [ k ] := c0 - m ;
        nwindow [ k ] := r0 + n ;
        Begin
          If Not screenstarted Then
            Begin
              screenOK := initscreen ;
              screenstarted := true ;
            End ;
        End ;
        If screenOK Then
          Begin
            blankrectangle ( c0 , c1 , r0 , r1 ) ;
            updatescreen ;
          End ;
      End ;
      Procedure dispedges ( k : windownumber ) ;

      Label 30 , 40 ;

      Var p , q : halfword ;
        alreadythere : boolean ;
        r : integer ;
        n : screencol ;
        w , ww : integer ;
        b : pixelcolor ;
        m , mm : integer ;
        d : integer ;
        madjustment : integer ;
        rightedge : integer ;
        mincol : screencol ;
      Begin
        If screenOK Then If leftcol [ k ] < rightcol [ k ] Then If toprow [ k ] < botrow [ k ] Then
                                                                  Begin
                                                                    alreadythere := false ;
                                                                    If mem [ curedges + 3 ] . hh . rh = k Then If mem [ curedges + 4 ] . int = windowtime [ k ] Then alreadythere := true ;
                                                                    If Not alreadythere Then blankrectangle ( leftcol [ k ] , rightcol [ k ] , toprow [ k ] , botrow [ k ] ) ;
                                                                    madjustment := mwindow [ k ] - mem [ curedges + 3 ] . hh . lh ;
                                                                    rightedge := 8 * ( rightcol [ k ] - madjustment ) ;
                                                                    mincol := leftcol [ k ] ;
                                                                    p := mem [ curedges ] . hh . rh ;
                                                                    r := nwindow [ k ] - ( mem [ curedges + 1 ] . hh . lh - 4096 ) ;
                                                                    While ( p <> curedges ) And ( r >= toprow [ k ] ) Do
                                                                      Begin
                                                                        If r < botrow [ k ] Then
                                                                          Begin
                                                                            If mem [ p + 1 ] . hh . lh > 1 Then sortedges ( p )
                                                                            Else If mem [ p + 1 ] . hh . lh = 1 Then If alreadythere Then goto 30 ;
                                                                            mem [ p + 1 ] . hh . lh := 1 ;
                                                                            n := 0 ;
                                                                            ww := 0 ;
                                                                            m := - 1 ;
                                                                            w := 0 ;
                                                                            q := mem [ p + 1 ] . hh . rh ;
                                                                            rowtransition [ 0 ] := mincol ;
                                                                            While true Do
                                                                              Begin
                                                                                If q = 30000 Then d := rightedge
                                                                                Else d := mem [ q ] . hh . lh - 0 ;
                                                                                mm := ( d Div 8 ) + madjustment ;
                                                                                If mm <> m Then
                                                                                  Begin
                                                                                    If w <= 0 Then
                                                                                      Begin
                                                                                        If ww > 0 Then If m > mincol Then
                                                                                                         Begin
                                                                                                           If n = 0 Then If alreadythere Then
                                                                                                                           Begin
                                                                                                                             b := 0 ;
                                                                                                                             n := n + 1 ;
                                                                                                                           End
                                                                                                           Else b := 1
                                                                                                           Else n := n + 1 ;
                                                                                                           rowtransition [ n ] := m ;
                                                                                                         End ;
                                                                                      End
                                                                                    Else If ww <= 0 Then If m > mincol Then
                                                                                                           Begin
                                                                                                             If n = 0 Then b := 1 ;
                                                                                                             n := n + 1 ;
                                                                                                             rowtransition [ n ] := m ;
                                                                                                           End ;
                                                                                    m := mm ;
                                                                                    w := ww ;
                                                                                  End ;
                                                                                If d >= rightedge Then goto 40 ;
                                                                                ww := ww + ( d Mod 8 ) - 4 ;
                                                                                q := mem [ q ] . hh . rh ;
                                                                              End ;
                                                                            40 : If alreadythere Or ( ww > 0 ) Then
                                                                                   Begin
                                                                                     If n = 0 Then If ww > 0 Then b := 1
                                                                                     Else b := 0 ;
                                                                                     n := n + 1 ;
                                                                                     rowtransition [ n ] := rightcol [ k ] ;
                                                                                   End
                                                                                 Else If n = 0 Then goto 30 ; ;
                                                                            paintrow ( r , b , rowtransition , n ) ;
                                                                            30 :
                                                                          End ;
                                                                        p := mem [ p ] . hh . rh ;
                                                                        r := r - 1 ;
                                                                      End ;
                                                                    updatescreen ;
                                                                    windowtime [ k ] := windowtime [ k ] + 1 ;
                                                                    mem [ curedges + 3 ] . hh . rh := k ;
                                                                    mem [ curedges + 4 ] . int := windowtime [ k ] ;
                                                                  End ;
      End ;
      Function maxcoef ( p : halfword ) : fraction ;

      Var x : fraction ;
      Begin
        x := 0 ;
        While mem [ p ] . hh . lh <> 0 Do
          Begin
            If abs ( mem [ p + 1 ] . int ) > x Then x := abs ( mem [ p + 1 ] . int ) ;
            p := mem [ p ] . hh . rh ;
          End ;
        maxcoef := x ;
      End ;
      Function pplusq ( p : halfword ; q : halfword ; t : smallnumber ) : halfword ;

      Label 30 ;

      Var pp , qq : halfword ;
        r , s : halfword ;
        threshold : integer ;
        v : integer ;
      Begin
        If t = 17 Then threshold := 2685
        Else threshold := 8 ;
        r := 29999 ;
        pp := mem [ p ] . hh . lh ;
        qq := mem [ q ] . hh . lh ;
        While true Do
          If pp = qq Then If pp = 0 Then goto 30
          Else
            Begin
              v := mem [ p + 1 ] . int + mem [ q + 1 ] . int ;
              mem [ p + 1 ] . int := v ;
              s := p ;
              p := mem [ p ] . hh . rh ;
              pp := mem [ p ] . hh . lh ;
              If abs ( v ) < threshold Then freenode ( s , 2 )
              Else
                Begin
                  If abs ( v ) >= 626349397 Then If watchcoefs Then
                                                   Begin
                                                     mem [ qq ] . hh . b0 := 0 ;
                                                     fixneeded := true ;
                                                   End ;
                  mem [ r ] . hh . rh := s ;
                  r := s ;
                End ;
              q := mem [ q ] . hh . rh ;
              qq := mem [ q ] . hh . lh ;
            End
          Else If mem [ pp + 1 ] . int < mem [ qq + 1 ] . int Then
                 Begin
                   s := getnode ( 2 ) ;
                   mem [ s ] . hh . lh := qq ;
                   mem [ s + 1 ] . int := mem [ q + 1 ] . int ;
                   q := mem [ q ] . hh . rh ;
                   qq := mem [ q ] . hh . lh ;
                   mem [ r ] . hh . rh := s ;
                   r := s ;
                 End
          Else
            Begin
              mem [ r ] . hh . rh := p ;
              r := p ;
              p := mem [ p ] . hh . rh ;
              pp := mem [ p ] . hh . lh ;
            End ;
        30 : mem [ p + 1 ] . int := slowadd ( mem [ p + 1 ] . int , mem [ q + 1 ] . int ) ;
        mem [ r ] . hh . rh := p ;
        depfinal := p ;
        pplusq := mem [ 29999 ] . hh . rh ;
      End ;
      Function ptimesv ( p : halfword ; v : integer ; t0 , t1 : smallnumber ; visscaled : boolean ) : halfword ;

      Var r , s : halfword ;
        w : integer ;
        threshold : integer ;
        scalingdown : boolean ;
      Begin
        If t0 <> t1 Then scalingdown := true
        Else scalingdown := Not visscaled ;
        If t1 = 17 Then threshold := 1342
        Else threshold := 4 ;
        r := 29999 ;
        While mem [ p ] . hh . lh <> 0 Do
          Begin
            If scalingdown Then w := takefraction ( v , mem [ p + 1 ] . int )
            Else w := takescaled ( v , mem [ p + 1 ] . int ) ;
            If abs ( w ) <= threshold Then
              Begin
                s := mem [ p ] . hh . rh ;
                freenode ( p , 2 ) ;
                p := s ;
              End
            Else
              Begin
                If abs ( w ) >= 626349397 Then
                  Begin
                    fixneeded := true ;
                    mem [ mem [ p ] . hh . lh ] . hh . b0 := 0 ;
                  End ;
                mem [ r ] . hh . rh := p ;
                r := p ;
                mem [ p + 1 ] . int := w ;
                p := mem [ p ] . hh . rh ;
              End ;
          End ;
        mem [ r ] . hh . rh := p ;
        If visscaled Then mem [ p + 1 ] . int := takescaled ( mem [ p + 1 ] . int , v )
        Else mem [ p + 1 ] . int := takefraction ( mem [ p + 1 ] . int , v ) ;
        ptimesv := mem [ 29999 ] . hh . rh ;
      End ;
      Function pwithxbecomingq ( p , x , q : halfword ; t : smallnumber ) : halfword ;

      Var r , s : halfword ;
        v : integer ;
        sx : integer ;
      Begin
        s := p ;
        r := 29999 ;
        sx := mem [ x + 1 ] . int ;
        While mem [ mem [ s ] . hh . lh + 1 ] . int > sx Do
          Begin
            r := s ;
            s := mem [ s ] . hh . rh ;
          End ;
        If mem [ s ] . hh . lh <> x Then pwithxbecomingq := p
        Else
          Begin
            mem [ 29999 ] . hh . rh := p ;
            mem [ r ] . hh . rh := mem [ s ] . hh . rh ;
            v := mem [ s + 1 ] . int ;
            freenode ( s , 2 ) ;
            pwithxbecomingq := pplusfq ( mem [ 29999 ] . hh . rh , v , q , t , 17 ) ;
          End ;
      End ;
      Procedure newdep ( q , p : halfword ) ;

      Var r : halfword ;
      Begin
        mem [ q + 1 ] . hh . rh := p ;
        mem [ q + 1 ] . hh . lh := 13 ;
        r := mem [ 13 ] . hh . rh ;
        mem [ depfinal ] . hh . rh := r ;
        mem [ r + 1 ] . hh . lh := depfinal ;
        mem [ 13 ] . hh . rh := q ;
      End ;
      Function constdependency ( v : scaled ) : halfword ;
      Begin
        depfinal := getnode ( 2 ) ;
        mem [ depfinal + 1 ] . int := v ;
        mem [ depfinal ] . hh . lh := 0 ;
        constdependency := depfinal ;
      End ;
      Function singledependency ( p : halfword ) : halfword ;

      Var q : halfword ;
        m : integer ;
      Begin
        m := mem [ p + 1 ] . int Mod 64 ;
        If m > 28 Then singledependency := constdependency ( 0 )
        Else
          Begin
            q := getnode ( 2 ) ;
            mem [ q + 1 ] . int := twotothe [ 28 - m ] ;
            mem [ q ] . hh . lh := p ;
            mem [ q ] . hh . rh := constdependency ( 0 ) ;
            singledependency := q ;
          End ;
      End ;
      Function copydeplist ( p : halfword ) : halfword ;

      Label 30 ;

      Var q : halfword ;
      Begin
        q := getnode ( 2 ) ;
        depfinal := q ;
        While true Do
          Begin
            mem [ depfinal ] . hh . lh := mem [ p ] . hh . lh ;
            mem [ depfinal + 1 ] . int := mem [ p + 1 ] . int ;
            If mem [ depfinal ] . hh . lh = 0 Then goto 30 ;
            mem [ depfinal ] . hh . rh := getnode ( 2 ) ;
            depfinal := mem [ depfinal ] . hh . rh ;
            p := mem [ p ] . hh . rh ;
          End ;
        30 : copydeplist := q ;
      End ;
      Procedure lineareq ( p : halfword ; t : smallnumber ) ;

      Var q , r , s : halfword ;
        x : halfword ;
        n : integer ;
        v : integer ;
        prevr : halfword ;
        finalnode : halfword ;
        w : integer ;
      Begin
        q := p ;
        r := mem [ p ] . hh . rh ;
        v := mem [ q + 1 ] . int ;
        While mem [ r ] . hh . lh <> 0 Do
          Begin
            If abs ( mem [ r + 1 ] . int ) > abs ( v ) Then
              Begin
                q := r ;
                v := mem [ r + 1 ] . int ;
              End ;
            r := mem [ r ] . hh . rh ;
          End ;
        x := mem [ q ] . hh . lh ;
        n := mem [ x + 1 ] . int Mod 64 ;
        s := 29999 ;
        mem [ s ] . hh . rh := p ;
        r := p ;
        Repeat
          If r = q Then
            Begin
              mem [ s ] . hh . rh := mem [ r ] . hh . rh ;
              freenode ( r , 2 ) ;
            End
          Else
            Begin
              w := makefraction ( mem [ r + 1 ] . int , v ) ;
              If abs ( w ) <= 1342 Then
                Begin
                  mem [ s ] . hh . rh := mem [ r ] . hh . rh ;
                  freenode ( r , 2 ) ;
                End
              Else
                Begin
                  mem [ r + 1 ] . int := - w ;
                  s := r ;
                End ;
            End ;
          r := mem [ s ] . hh . rh ;
        Until mem [ r ] . hh . lh = 0 ;
        If t = 18 Then mem [ r + 1 ] . int := - makescaled ( mem [ r + 1 ] . int , v )
        Else If v <> - 268435456 Then mem [ r + 1 ] . int := - makefraction ( mem [ r + 1 ] . int , v ) ;
        finalnode := r ;
        p := mem [ 29999 ] . hh . rh ;
        If internal [ 2 ] > 0 Then If interesting ( x ) Then
                                     Begin
                                       begindiagnostic ;
                                       printnl ( 596 ) ;
                                       printvariablename ( x ) ;
                                       w := n ;
                                       While w > 0 Do
                                         Begin
                                           print ( 589 ) ;
                                           w := w - 2 ;
                                         End ;
                                       printchar ( 61 ) ;
                                       printdependency ( p , 17 ) ;
                                       enddiagnostic ( false ) ;
                                     End ;
        prevr := 13 ;
        r := mem [ 13 ] . hh . rh ;
        While r <> 13 Do
          Begin
            s := mem [ r + 1 ] . hh . rh ;
            q := pwithxbecomingq ( s , x , p , mem [ r ] . hh . b0 ) ;
            If mem [ q ] . hh . lh = 0 Then makeknown ( r , q )
            Else
              Begin
                mem [ r + 1 ] . hh . rh := q ;
                Repeat
                  q := mem [ q ] . hh . rh ;
                Until mem [ q ] . hh . lh = 0 ;
                prevr := q ;
              End ;
            r := mem [ prevr ] . hh . rh ;
          End ;
        If n > 0 Then
          Begin
            s := 29999 ;
            mem [ 29999 ] . hh . rh := p ;
            r := p ;
            Repeat
              If n > 30 Then w := 0
              Else w := mem [ r + 1 ] . int Div twotothe [ n ] ;
              If ( abs ( w ) <= 1342 ) And ( mem [ r ] . hh . lh <> 0 ) Then
                Begin
                  mem [ s ] . hh . rh := mem [ r ] . hh . rh ;
                  freenode ( r , 2 ) ;
                End
              Else
                Begin
                  mem [ r + 1 ] . int := w ;
                  s := r ;
                End ;
              r := mem [ s ] . hh . rh ;
            Until mem [ s ] . hh . lh = 0 ;
            p := mem [ 29999 ] . hh . rh ;
          End ;
        If mem [ p ] . hh . lh = 0 Then
          Begin
            mem [ x ] . hh . b0 := 16 ;
            mem [ x + 1 ] . int := mem [ p + 1 ] . int ;
            If abs ( mem [ x + 1 ] . int ) >= 268435456 Then valtoobig ( mem [ x + 1 ] . int ) ;
            freenode ( p , 2 ) ;
            If curexp = x Then If curtype = 19 Then
                                 Begin
                                   curexp := mem [ x + 1 ] . int ;
                                   curtype := 16 ;
                                   freenode ( x , 2 ) ;
                                 End ;
          End
        Else
          Begin
            mem [ x ] . hh . b0 := 17 ;
            depfinal := finalnode ;
            newdep ( x , p ) ;
            If curexp = x Then If curtype = 19 Then curtype := 17 ;
          End ;
        If fixneeded Then fixdependencies ;
      End ;
      Function newringentry ( p : halfword ) : halfword ;

      Var q : halfword ;
      Begin
        q := getnode ( 2 ) ;
        mem [ q ] . hh . b1 := 11 ;
        mem [ q ] . hh . b0 := mem [ p ] . hh . b0 ;
        If mem [ p + 1 ] . int = 0 Then mem [ q + 1 ] . int := p
        Else mem [ q + 1 ] . int := mem [ p + 1 ] . int ;
        mem [ p + 1 ] . int := q ;
        newringentry := q ;
      End ;
      Procedure nonlineareq ( v : integer ; p : halfword ; flushp : boolean ) ;

      Var t : smallnumber ;
        q , r : halfword ;
      Begin
        t := mem [ p ] . hh . b0 - 1 ;
        q := mem [ p + 1 ] . int ;
        If flushp Then mem [ p ] . hh . b0 := 1
        Else p := q ;
        Repeat
          r := mem [ q + 1 ] . int ;
          mem [ q ] . hh . b0 := t ;
          Case t Of 
            2 : mem [ q + 1 ] . int := v ;
            4 :
                Begin
                  mem [ q + 1 ] . int := v ;
                  Begin
                    If strref [ v ] < 127 Then strref [ v ] := strref [ v ] + 1 ;
                  End ;
                End ;
            6 :
                Begin
                  mem [ q + 1 ] . int := v ;
                  mem [ v ] . hh . lh := mem [ v ] . hh . lh + 1 ;
                End ;
            9 : mem [ q + 1 ] . int := copypath ( v ) ;
            11 : mem [ q + 1 ] . int := copyedges ( v ) ;
          End ;
          q := r ;
        Until q = p ;
      End ;
      Procedure ringmerge ( p , q : halfword ) ;

      Label 10 ;

      Var r : halfword ;
      Begin
        r := mem [ p + 1 ] . int ;
        While r <> p Do
          Begin
            If r = q Then
              Begin
                Begin
                  Begin
                    If interaction = 3 Then ;
                    printnl ( 261 ) ;
                    print ( 599 ) ;
                  End ;
                  Begin
                    helpptr := 2 ;
                    helpline [ 1 ] := 600 ;
                    helpline [ 0 ] := 601 ;
                  End ;
                  putgeterror ;
                End ;
                goto 10 ;
              End ;
            r := mem [ r + 1 ] . int ;
          End ;
        r := mem [ p + 1 ] . int ;
        mem [ p + 1 ] . int := mem [ q + 1 ] . int ;
        mem [ q + 1 ] . int := r ;
        10 :
      End ;
      Procedure showcmdmod ( c , m : integer ) ;
      Begin
        begindiagnostic ;
        printnl ( 123 ) ;
        printcmdmod ( c , m ) ;
        printchar ( 125 ) ;
        enddiagnostic ( false ) ;
      End ;
      Procedure showcontext ;

      Label 30 ;

      Var oldsetting : 0 .. 5 ;
        i : 0 .. bufsize ;
        l : integer ;
        m : integer ;
        n : 0 .. errorline ;
        p : integer ;
        q : integer ;
      Begin
        fileptr := inputptr ;
        inputstack [ fileptr ] := curinput ;
        While true Do
          Begin
            curinput := inputstack [ fileptr ] ;
            If ( fileptr = inputptr ) Or ( curinput . indexfield <= 6 ) Or ( curinput . indexfield <> 10 ) Or ( curinput . locfield <> 0 ) Then
              Begin
                tally := 0 ;
                oldsetting := selector ;
                If ( curinput . indexfield <= 6 ) Then
                  Begin
                    If curinput . namefield <= 1 Then If ( curinput . namefield = 0 ) And ( fileptr = 0 ) Then printnl ( 603 )
                    Else printnl ( 604 )
                    Else If curinput . namefield = 2 Then printnl ( 605 )
                    Else
                      Begin
                        printnl ( 606 ) ;
                        printint ( line ) ;
                      End ;
                    printchar ( 32 ) ;
                    Begin
                      l := tally ;
                      tally := 0 ;
                      selector := 4 ;
                      trickcount := 1000000 ;
                    End ;
                    If curinput . limitfield > 0 Then For i := curinput . startfield To curinput . limitfield - 1 Do
                                                        Begin
                                                          If i = curinput . locfield Then
                                                            Begin
                                                              firstcount := tally ;
                                                              trickcount := tally + 1 + errorline - halferrorline ;
                                                              If trickcount < errorline Then trickcount := errorline ;
                                                            End ;
                                                          print ( buffer [ i ] ) ;
                                                        End ;
                  End
                Else
                  Begin
                    Case curinput . indexfield Of 
                      7 : printnl ( 607 ) ;
                      8 :
                          Begin
                            printnl ( 612 ) ;
                            p := paramstack [ curinput . limitfield ] ;
                            If p <> 0 Then If mem [ p ] . hh . rh = 1 Then printexp ( p , 0 )
                            Else showtokenlist ( p , 0 , 20 , tally ) ;
                            print ( 613 ) ;
                          End ;
                      9 : printnl ( 608 ) ;
                      10 : If curinput . locfield = 0 Then printnl ( 609 )
                           Else printnl ( 610 ) ;
                      11 : printnl ( 611 ) ;
                      12 :
                           Begin
                             println ;
                             If curinput . namefield <> 0 Then slowprint ( hash [ curinput . namefield ] . rh )
                             Else
                               Begin
                                 p := paramstack [ curinput . limitfield ] ;
                                 If p = 0 Then showtokenlist ( paramstack [ curinput . limitfield + 1 ] , 0 , 20 , tally )
                                 Else
                                   Begin
                                     q := p ;
                                     While mem [ q ] . hh . rh <> 0 Do
                                       q := mem [ q ] . hh . rh ;
                                     mem [ q ] . hh . rh := paramstack [ curinput . limitfield + 1 ] ;
                                     showtokenlist ( p , 0 , 20 , tally ) ;
                                     mem [ q ] . hh . rh := 0 ;
                                   End ;
                               End ;
                             print ( 501 ) ;
                           End ;
                      others : printnl ( 63 )
                    End ;
                    Begin
                      l := tally ;
                      tally := 0 ;
                      selector := 4 ;
                      trickcount := 1000000 ;
                    End ;
                    If curinput . indexfield <> 12 Then showtokenlist ( curinput . startfield , curinput . locfield , 100000 , 0 )
                    Else showmacro ( curinput . startfield , curinput . locfield , 100000 ) ;
                  End ;
                selector := oldsetting ;
                If trickcount = 1000000 Then
                  Begin
                    firstcount := tally ;
                    trickcount := tally + 1 + errorline - halferrorline ;
                    If trickcount < errorline Then trickcount := errorline ;
                  End ;
                If tally < trickcount Then m := tally - firstcount
                Else m := trickcount - firstcount ;
                If l + firstcount <= halferrorline Then
                  Begin
                    p := 0 ;
                    n := l + firstcount ;
                  End
                Else
                  Begin
                    print ( 276 ) ;
                    p := l + firstcount - halferrorline + 3 ;
                    n := halferrorline ;
                  End ;
                For q := p To firstcount - 1 Do
                  printchar ( trickbuf [ q Mod errorline ] ) ;
                println ;
                For q := 1 To n Do
                  printchar ( 32 ) ;
                If m + n <= errorline Then p := firstcount + m
                Else p := firstcount + ( errorline - n - 3 ) ;
                For q := firstcount To p - 1 Do
                  printchar ( trickbuf [ q Mod errorline ] ) ;
                If m + n > errorline Then print ( 276 ) ;
              End ;
            If ( curinput . indexfield <= 6 ) Then If ( curinput . namefield > 2 ) Or ( fileptr = 0 ) Then goto 30 ;
            fileptr := fileptr - 1 ;
          End ;
        30 : curinput := inputstack [ inputptr ] ;
      End ;
      Procedure begintokenlist ( p : halfword ; t : quarterword ) ;
      Begin
        Begin
          If inputptr > maxinstack Then
            Begin
              maxinstack := inputptr ;
              If inputptr = stacksize Then overflow ( 614 , stacksize ) ;
            End ;
          inputstack [ inputptr ] := curinput ;
          inputptr := inputptr + 1 ;
        End ;
        curinput . startfield := p ;
        curinput . indexfield := t ;
        curinput . limitfield := paramptr ;
        curinput . locfield := p ;
      End ;
      Procedure endtokenlist ;

      Label 30 ;

      Var p : halfword ;
      Begin
        If curinput . indexfield >= 10 Then If curinput . indexfield <= 11 Then
                                              Begin
                                                flushtokenlist ( curinput . startfield ) ;
                                                goto 30 ;
                                              End
        Else deletemacref ( curinput . startfield ) ;
        While paramptr > curinput . limitfield Do
          Begin
            paramptr := paramptr - 1 ;
            p := paramstack [ paramptr ] ;
            If p <> 0 Then If mem [ p ] . hh . rh = 1 Then
                             Begin
                               recyclevalue ( p ) ;
                               freenode ( p , 2 ) ;
                             End
            Else flushtokenlist ( p ) ;
          End ;
        30 :
             Begin
               inputptr := inputptr - 1 ;
               curinput := inputstack [ inputptr ] ;
             End ;
        Begin
          If interrupt <> 0 Then pauseforinstructions ;
        End ;
      End ;
      Procedure encapsulate ( p : halfword ) ;
      Begin
        curexp := getnode ( 2 ) ;
        mem [ curexp ] . hh . b0 := curtype ;
        mem [ curexp ] . hh . b1 := 11 ;
        newdep ( curexp , p ) ;
      End ;
      Procedure install ( r , q : halfword ) ;

      Var p : halfword ;
      Begin
        If mem [ q ] . hh . b0 = 16 Then
          Begin
            mem [ r + 1 ] . int := mem [ q + 1 ] . int ;
            mem [ r ] . hh . b0 := 16 ;
          End
        Else If mem [ q ] . hh . b0 = 19 Then
               Begin
                 p := singledependency ( q ) ;
                 If p = depfinal Then
                   Begin
                     mem [ r ] . hh . b0 := 16 ;
                     mem [ r + 1 ] . int := 0 ;
                     freenode ( p , 2 ) ;
                   End
                 Else
                   Begin
                     mem [ r ] . hh . b0 := 17 ;
                     newdep ( r , p ) ;
                   End ;
               End
        Else
          Begin
            mem [ r ] . hh . b0 := mem [ q ] . hh . b0 ;
            newdep ( r , copydeplist ( mem [ q + 1 ] . hh . rh ) ) ;
          End ;
      End ;
      Procedure makeexpcopy ( p : halfword ) ;

      Label 20 ;

      Var q , r , t : halfword ;
      Begin
        20 : curtype := mem [ p ] . hh . b0 ;
        Case curtype Of 
          1 , 2 , 16 : curexp := mem [ p + 1 ] . int ;
          3 , 5 , 7 , 12 , 10 : curexp := newringentry ( p ) ;
          4 :
              Begin
                curexp := mem [ p + 1 ] . int ;
                Begin
                  If strref [ curexp ] < 127 Then strref [ curexp ] := strref [ curexp ] + 1 ;
                End ;
              End ;
          6 :
              Begin
                curexp := mem [ p + 1 ] . int ;
                mem [ curexp ] . hh . lh := mem [ curexp ] . hh . lh + 1 ;
              End ;
          11 : curexp := copyedges ( mem [ p + 1 ] . int ) ;
          9 , 8 : curexp := copypath ( mem [ p + 1 ] . int ) ;
          13 , 14 :
                    Begin
                      If mem [ p + 1 ] . int = 0 Then initbignode ( p ) ;
                      t := getnode ( 2 ) ;
                      mem [ t ] . hh . b1 := 11 ;
                      mem [ t ] . hh . b0 := curtype ;
                      initbignode ( t ) ;
                      q := mem [ p + 1 ] . int + bignodesize [ curtype ] ;
                      r := mem [ t + 1 ] . int + bignodesize [ curtype ] ;
                      Repeat
                        q := q - 2 ;
                        r := r - 2 ;
                        install ( r , q ) ;
                      Until q = mem [ p + 1 ] . int ;
                      curexp := t ;
                    End ;
          17 , 18 : encapsulate ( copydeplist ( mem [ p + 1 ] . hh . rh ) ) ;
          15 :
               Begin
                 Begin
                   If serialno > 2147483583 Then overflow ( 587 , serialno Div 64 ) ;
                   mem [ p ] . hh . b0 := 19 ;
                   serialno := serialno + 64 ;
                   mem [ p + 1 ] . int := serialno ;
                 End ;
                 goto 20 ;
               End ;
          19 :
               Begin
                 q := singledependency ( p ) ;
                 If q = depfinal Then
                   Begin
                     curtype := 16 ;
                     curexp := 0 ;
                     freenode ( q , 2 ) ;
                   End
                 Else
                   Begin
                     curtype := 17 ;
                     encapsulate ( q ) ;
                   End ;
               End ;
          others : confusion ( 800 )
        End ;
      End ;
      Function curtok : halfword ;

      Var p : halfword ;
        savetype : smallnumber ;
        saveexp : integer ;
      Begin
        If cursym = 0 Then If curcmd = 38 Then
                             Begin
                               savetype := curtype ;
                               saveexp := curexp ;
                               makeexpcopy ( curmod ) ;
                               p := stashcurexp ;
                               mem [ p ] . hh . rh := 0 ;
                               curtype := savetype ;
                               curexp := saveexp ;
                             End
        Else
          Begin
            p := getnode ( 2 ) ;
            mem [ p + 1 ] . int := curmod ;
            mem [ p ] . hh . b1 := 12 ;
            If curcmd = 42 Then mem [ p ] . hh . b0 := 16
            Else mem [ p ] . hh . b0 := 4 ;
          End
        Else
          Begin
            Begin
              p := avail ;
              If p = 0 Then p := getavail
              Else
                Begin
                  avail := mem [ p ] . hh . rh ;
                  mem [ p ] . hh . rh := 0 ;
                End ;
            End ;
            mem [ p ] . hh . lh := cursym ;
          End ;
        curtok := p ;
      End ;
      Procedure backinput ;

      Var p : halfword ;
      Begin
        p := curtok ;
        While ( curinput . indexfield > 6 ) And ( curinput . locfield = 0 ) Do
          endtokenlist ;
        begintokenlist ( p , 10 ) ;
      End ;
      Procedure backerror ;
      Begin
        OKtointerrupt := false ;
        backinput ;
        OKtointerrupt := true ;
        error ;
      End ;
      Procedure inserror ;
      Begin
        OKtointerrupt := false ;
        backinput ;
        curinput . indexfield := 11 ;
        OKtointerrupt := true ;
        error ;
      End ;
      Procedure beginfilereading ;
      Begin
        If inopen = 6 Then overflow ( 615 , 6 ) ;
        If first = bufsize Then overflow ( 256 , bufsize ) ;
        inopen := inopen + 1 ;
        Begin
          If inputptr > maxinstack Then
            Begin
              maxinstack := inputptr ;
              If inputptr = stacksize Then overflow ( 614 , stacksize ) ;
            End ;
          inputstack [ inputptr ] := curinput ;
          inputptr := inputptr + 1 ;
        End ;
        curinput . indexfield := inopen ;
        linestack [ curinput . indexfield ] := line ;
        curinput . startfield := first ;
        curinput . namefield := 0 ;
      End ;
      Procedure endfilereading ;
      Begin
        first := curinput . startfield ;
        line := linestack [ curinput . indexfield ] ;
        If curinput . indexfield <> inopen Then confusion ( 616 ) ;
        If curinput . namefield > 2 Then aclose ( inputfile [ curinput . indexfield ] ) ;
        Begin
          inputptr := inputptr - 1 ;
          curinput := inputstack [ inputptr ] ;
        End ;
        inopen := inopen - 1 ;
      End ;
      Procedure clearforerrorprompt ;
      Begin
        While ( curinput . indexfield <= 6 ) And ( curinput . namefield = 0 ) And ( inputptr > 0 ) And ( curinput . locfield = curinput . limitfield ) Do
          endfilereading ;
        println ;
        breakin ( termin , true ) ;
      End ;
      Function checkoutervalidity : boolean ;

      Var p : halfword ;
      Begin
        If scannerstatus = 0 Then checkoutervalidity := true
        Else
          Begin
            deletionsallowed := false ;
            If cursym <> 0 Then
              Begin
                p := getavail ;
                mem [ p ] . hh . lh := cursym ;
                begintokenlist ( p , 10 ) ;
              End ;
            If scannerstatus > 1 Then
              Begin
                runaway ;
                If cursym = 0 Then
                  Begin
                    If interaction = 3 Then ;
                    printnl ( 261 ) ;
                    print ( 622 ) ;
                  End
                Else
                  Begin
                    Begin
                      If interaction = 3 Then ;
                      printnl ( 261 ) ;
                      print ( 623 ) ;
                    End ;
                  End ;
                print ( 624 ) ;
                Begin
                  helpptr := 4 ;
                  helpline [ 3 ] := 625 ;
                  helpline [ 2 ] := 626 ;
                  helpline [ 1 ] := 627 ;
                  helpline [ 0 ] := 628 ;
                End ;
                Case scannerstatus Of 
                  2 :
                      Begin
                        print ( 629 ) ;
                        helpline [ 3 ] := 630 ;
                        cursym := 2363 ;
                      End ;
                  3 :
                      Begin
                        print ( 631 ) ;
                        helpline [ 3 ] := 632 ;
                        If warninginfo = 0 Then cursym := 2367
                        Else
                          Begin
                            cursym := 2359 ;
                            eqtb [ 2359 ] . rh := warninginfo ;
                          End ;
                      End ;
                  4 , 5 :
                          Begin
                            print ( 633 ) ;
                            If scannerstatus = 5 Then slowprint ( hash [ warninginfo ] . rh )
                            Else printvariablename ( warninginfo ) ;
                            cursym := 2365 ;
                          End ;
                  6 :
                      Begin
                        print ( 634 ) ;
                        slowprint ( hash [ warninginfo ] . rh ) ;
                        print ( 635 ) ;
                        helpline [ 3 ] := 636 ;
                        cursym := 2364 ;
                      End ;
                End ;
                inserror ;
              End
            Else
              Begin
                Begin
                  If interaction = 3 Then ;
                  printnl ( 261 ) ;
                  print ( 617 ) ;
                End ;
                printint ( warninginfo ) ;
                Begin
                  helpptr := 3 ;
                  helpline [ 2 ] := 618 ;
                  helpline [ 1 ] := 619 ;
                  helpline [ 0 ] := 620 ;
                End ;
                If cursym = 0 Then helpline [ 2 ] := 621 ;
                cursym := 2366 ;
                inserror ;
              End ;
            deletionsallowed := true ;
            checkoutervalidity := false ;
          End ;
      End ;
      Procedure firmuptheline ;
      forward ;
      Procedure getnext ;

      Label 20 , 10 , 40 , 25 , 85 , 86 , 87 , 30 ;

      Var k : 0 .. bufsize ;
        c : ASCIIcode ;
        Class : ASCIIcode ;
          n , f : integer ;
          Begin
            20 : cursym := 0 ;
            If ( curinput . indexfield <= 6 ) Then
              Begin
                25 : c := buffer [ curinput . locfield ] ;
                curinput . locfield := curinput . locfield + 1 ;
                Class := charclass [ c ] ;
                  Case Class Of 
                    0 : goto 85 ;
                    1 :
                        Begin
                          Class := charclass [ buffer [ curinput . locfield ] ] ;
                            If Class > 1 Then goto 25
                            Else If Class < 1 Then
                                   Begin
                                     n := 0 ;
                                     goto 86 ;
                                   End ;
                          End ;
                          2 : goto 25 ;
                          3 :
                              Begin
                                If curinput . namefield > 2 Then
                                  Begin
                                    line := line + 1 ;
                                    first := curinput . startfield ;
                                    If Not forceeof Then
                                      Begin
                                        If inputln ( inputfile [ curinput . indexfield ] , true ) Then firmuptheline
                                        Else forceeof := true ;
                                      End ;
                                    If forceeof Then
                                      Begin
                                        printchar ( 41 ) ;
                                        openparens := openparens - 1 ;
                                        break ( termout ) ;
                                        forceeof := false ;
                                        endfilereading ;
                                        If checkoutervalidity Then goto 20
                                        Else goto 20 ;
                                      End ;
                                    buffer [ curinput . limitfield ] := 37 ;
                                    first := curinput . limitfield + 1 ;
                                    curinput . locfield := curinput . startfield ;
                                  End
                                Else
                                  Begin
                                    If inputptr > 0 Then
                                      Begin
                                        endfilereading ;
                                        goto 20 ;
                                      End ;
                                    If selector < 2 Then openlogfile ;
                                    If interaction > 1 Then
                                      Begin
                                        If curinput . limitfield = curinput . startfield Then printnl ( 651 ) ;
                                        println ;
                                        first := curinput . startfield ;
                                        Begin ;
                                          print ( 42 ) ;
                                          terminput ;
                                        End ;
                                        curinput . limitfield := last ;
                                        buffer [ curinput . limitfield ] := 37 ;
                                        first := curinput . limitfield + 1 ;
                                        curinput . locfield := curinput . startfield ;
                                      End
                                    Else fatalerror ( 652 ) ;
                                  End ;
                                Begin
                                  If interrupt <> 0 Then pauseforinstructions ;
                                End ;
                                goto 25 ;
                              End ;
                          4 :
                              Begin
                                If buffer [ curinput . locfield ] = 34 Then curmod := 285
                                Else
                                  Begin
                                    k := curinput . locfield ;
                                    buffer [ curinput . limitfield + 1 ] := 34 ;
                                    Repeat
                                      curinput . locfield := curinput . locfield + 1 ;
                                    Until buffer [ curinput . locfield ] = 34 ;
                                    If curinput . locfield > curinput . limitfield Then
                                      Begin
                                        curinput . locfield := curinput . limitfield ;
                                        Begin
                                          If interaction = 3 Then ;
                                          printnl ( 261 ) ;
                                          print ( 644 ) ;
                                        End ;
                                        Begin
                                          helpptr := 3 ;
                                          helpline [ 2 ] := 645 ;
                                          helpline [ 1 ] := 646 ;
                                          helpline [ 0 ] := 647 ;
                                        End ;
                                        deletionsallowed := false ;
                                        error ;
                                        deletionsallowed := true ;
                                        goto 20 ;
                                      End ;
                                    If ( curinput . locfield = k + 1 ) And ( ( strstart [ buffer [ k ] + 1 ] - strstart [ buffer [ k ] ] ) = 1 ) Then curmod := buffer [ k ]
                                    Else
                                      Begin
                                        Begin
                                          If poolptr + curinput . locfield - k > maxpoolptr Then
                                            Begin
                                              If poolptr + curinput . locfield - k > poolsize Then overflow ( 257 , poolsize - initpoolptr ) ;
                                              maxpoolptr := poolptr + curinput . locfield - k ;
                                            End ;
                                        End ;
                                        Repeat
                                          Begin
                                            strpool [ poolptr ] := buffer [ k ] ;
                                            poolptr := poolptr + 1 ;
                                          End ;
                                          k := k + 1 ;
                                        Until k = curinput . locfield ;
                                        curmod := makestring ;
                                      End ;
                                  End ;
                                curinput . locfield := curinput . locfield + 1 ;
                                curcmd := 39 ;
                                goto 10 ;
                              End ;
                          5 , 6 , 7 , 8 :
                                          Begin
                                            k := curinput . locfield - 1 ;
                                            goto 40 ;
                                          End ;
                          20 :
                               Begin
                                 Begin
                                   If interaction = 3 Then ;
                                   printnl ( 261 ) ;
                                   print ( 641 ) ;
                                 End ;
                                 Begin
                                   helpptr := 2 ;
                                   helpline [ 1 ] := 642 ;
                                   helpline [ 0 ] := 643 ;
                                 End ;
                                 deletionsallowed := false ;
                                 error ;
                                 deletionsallowed := true ;
                                 goto 20 ;
                               End ;
                          others :
                        End ;
                    k := curinput . locfield - 1 ;
                    While charclass [ buffer [ curinput . locfield ] ] = Class Do
                      curinput . locfield := curinput . locfield + 1 ;
                    goto 40 ;
                    85 : n := c - 48 ;
                    While charclass [ buffer [ curinput . locfield ] ] = 0 Do
                      Begin
                        If n < 4096 Then n := 10 * n + buffer [ curinput . locfield ] - 48 ;
                        curinput . locfield := curinput . locfield + 1 ;
                      End ;
                    If buffer [ curinput . locfield ] = 46 Then If charclass [ buffer [ curinput . locfield + 1 ] ] = 0 Then goto 30 ;
                    f := 0 ;
                    goto 87 ;
                    30 : curinput . locfield := curinput . locfield + 1 ;
                    86 : k := 0 ;
                    Repeat
                      If k < 17 Then
                        Begin
                          dig [ k ] := buffer [ curinput . locfield ] - 48 ;
                          k := k + 1 ;
                        End ;
                      curinput . locfield := curinput . locfield + 1 ;
                    Until charclass [ buffer [ curinput . locfield ] ] <> 0 ;
                    f := rounddecimals ( k ) ;
                    If f = 65536 Then
                      Begin
                        n := n + 1 ;
                        f := 0 ;
                      End ;
                    87 : If n < 4096 Then curmod := n * 65536 + f
                         Else
                           Begin
                             Begin
                               If interaction = 3 Then ;
                               printnl ( 261 ) ;
                               print ( 648 ) ;
                             End ;
                             Begin
                               helpptr := 2 ;
                               helpline [ 1 ] := 649 ;
                               helpline [ 0 ] := 650 ;
                             End ;
                             deletionsallowed := false ;
                             error ;
                             deletionsallowed := true ;
                             curmod := 268435455 ;
                           End ;
                    curcmd := 42 ;
                    goto 10 ;
                    40 : cursym := idlookup ( k , curinput . locfield - k ) ;
                  End
                  Else If curinput . locfield >= himemmin Then
                         Begin
                           cursym := mem [ curinput . locfield ] . hh . lh ;
                           curinput . locfield := mem [ curinput . locfield ] . hh . rh ;
                           If cursym >= 2370 Then If cursym >= 2520 Then
                                                    Begin
                                                      If cursym >= 2670 Then cursym := cursym - 150 ;
                                                      begintokenlist ( paramstack [ curinput . limitfield + cursym - ( 2520 ) ] , 9 ) ;
                                                      goto 20 ;
                                                    End
                           Else
                             Begin
                               curcmd := 38 ;
                               curmod := paramstack [ curinput . limitfield + cursym - ( 2370 ) ] ;
                               cursym := 0 ;
                               goto 10 ;
                             End ;
                         End
                  Else If curinput . locfield > 0 Then
                         Begin
                           If mem [ curinput . locfield ] . hh . b1 = 12 Then
                             Begin
                               curmod := mem [ curinput . locfield + 1 ] . int ;
                               If mem [ curinput . locfield ] . hh . b0 = 16 Then curcmd := 42
                               Else
                                 Begin
                                   curcmd := 39 ;
                                   Begin
                                     If strref [ curmod ] < 127 Then strref [ curmod ] := strref [ curmod ] + 1 ;
                                   End ;
                                 End ;
                             End
                           Else
                             Begin
                               curmod := curinput . locfield ;
                               curcmd := 38 ;
                             End ;
                           curinput . locfield := mem [ curinput . locfield ] . hh . rh ;
                           goto 10 ;
                         End
                  Else
                    Begin
                      endtokenlist ;
                      goto 20 ;
                    End ;
                  curcmd := eqtb [ cursym ] . lh ;
                  curmod := eqtb [ cursym ] . rh ;
                  If curcmd >= 86 Then If checkoutervalidity Then curcmd := curcmd - 86
                  Else goto 20 ;
                  10 :
                End ;
                Procedure firmuptheline ;

                Var k : 0 .. bufsize ;
                Begin
                  curinput . limitfield := last ;
                  If internal [ 31 ] > 0 Then If interaction > 1 Then
                                                Begin ;
                                                  println ;
                                                  If curinput . startfield < curinput . limitfield Then For k := curinput . startfield To curinput . limitfield - 1 Do
                                                                                                          print ( buffer [ k ] ) ;
                                                  first := curinput . limitfield ;
                                                  Begin ;
                                                    print ( 653 ) ;
                                                    terminput ;
                                                  End ;
                                                  If last > first Then
                                                    Begin
                                                      For k := first To last - 1 Do
                                                        buffer [ k + curinput . startfield - first ] := buffer [ k ] ;
                                                      curinput . limitfield := curinput . startfield + last - first ;
                                                    End ;
                                                End ;
                End ;
                Function scantoks ( terminator : commandcode ; substlist , tailend : halfword ; suffixcount : smallnumber ) : halfword ;

                Label 30 , 40 ;

                Var p : halfword ;
                  q : halfword ;
                  balance : integer ;
                Begin
                  p := 29998 ;
                  balance := 1 ;
                  mem [ 29998 ] . hh . rh := 0 ;
                  While true Do
                    Begin
                      getnext ;
                      If cursym > 0 Then
                        Begin
                          Begin
                            q := substlist ;
                            While q <> 0 Do
                              Begin
                                If mem [ q ] . hh . lh = cursym Then
                                  Begin
                                    cursym := mem [ q + 1 ] . int ;
                                    curcmd := 7 ;
                                    goto 40 ;
                                  End ;
                                q := mem [ q ] . hh . rh ;
                              End ;
                            40 :
                          End ;
                          If curcmd = terminator Then If curmod > 0 Then balance := balance + 1
                          Else
                            Begin
                              balance := balance - 1 ;
                              If balance = 0 Then goto 30 ;
                            End
                          Else If curcmd = 61 Then
                                 Begin
                                   If curmod = 0 Then getnext
                                   Else If curmod <= suffixcount Then cursym := 2519 + curmod ;
                                 End ;
                        End ;
                      mem [ p ] . hh . rh := curtok ;
                      p := mem [ p ] . hh . rh ;
                    End ;
                  30 : mem [ p ] . hh . rh := tailend ;
                  flushnodelist ( substlist ) ;
                  scantoks := mem [ 29998 ] . hh . rh ;
                End ;
                Procedure getsymbol ;

                Label 20 ;
                Begin
                  20 : getnext ;
                  If ( cursym = 0 ) Or ( cursym > 2357 ) Then
                    Begin
                      Begin
                        If interaction = 3 Then ;
                        printnl ( 261 ) ;
                        print ( 665 ) ;
                      End ;
                      Begin
                        helpptr := 3 ;
                        helpline [ 2 ] := 666 ;
                        helpline [ 1 ] := 667 ;
                        helpline [ 0 ] := 668 ;
                      End ;
                      If cursym > 0 Then helpline [ 2 ] := 669
                      Else If curcmd = 39 Then
                             Begin
                               If strref [ curmod ] < 127 Then If strref [ curmod ] > 1 Then strref [ curmod ] := strref [ curmod ] - 1
                               Else flushstring ( curmod ) ;
                             End ;
                      cursym := 2357 ;
                      inserror ;
                      goto 20 ;
                    End ;
                End ;
                Procedure getclearsymbol ;
                Begin
                  getsymbol ;
                  clearsymbol ( cursym , false ) ;
                End ;
                Procedure checkequals ;
                Begin
                  If curcmd <> 51 Then If curcmd <> 77 Then
                                         Begin
                                           missingerr ( 61 ) ;
                                           Begin
                                             helpptr := 5 ;
                                             helpline [ 4 ] := 670 ;
                                             helpline [ 3 ] := 671 ;
                                             helpline [ 2 ] := 672 ;
                                             helpline [ 1 ] := 673 ;
                                             helpline [ 0 ] := 674 ;
                                           End ;
                                           backerror ;
                                         End ;
                End ;
                Procedure makeopdef ;

                Var m : commandcode ;
                  p , q , r : halfword ;
                Begin
                  m := curmod ;
                  getsymbol ;
                  q := getnode ( 2 ) ;
                  mem [ q ] . hh . lh := cursym ;
                  mem [ q + 1 ] . int := 2370 ;
                  getclearsymbol ;
                  warninginfo := cursym ;
                  getsymbol ;
                  p := getnode ( 2 ) ;
                  mem [ p ] . hh . lh := cursym ;
                  mem [ p + 1 ] . int := 2371 ;
                  mem [ p ] . hh . rh := q ;
                  getnext ;
                  checkequals ;
                  scannerstatus := 5 ;
                  q := getavail ;
                  mem [ q ] . hh . lh := 0 ;
                  r := getavail ;
                  mem [ q ] . hh . rh := r ;
                  mem [ r ] . hh . lh := 0 ;
                  mem [ r ] . hh . rh := scantoks ( 16 , p , 0 , 0 ) ;
                  scannerstatus := 0 ;
                  eqtb [ warninginfo ] . lh := m ;
                  eqtb [ warninginfo ] . rh := q ;
                  getxnext ;
                End ;
                Procedure checkdelimiter ( ldelim , rdelim : halfword ) ;

                Label 10 ;
                Begin
                  If curcmd = 62 Then If curmod = ldelim Then goto 10 ;
                  If cursym <> rdelim Then
                    Begin
                      missingerr ( hash [ rdelim ] . rh ) ;
                      Begin
                        helpptr := 2 ;
                        helpline [ 1 ] := 922 ;
                        helpline [ 0 ] := 923 ;
                      End ;
                      backerror ;
                    End
                  Else
                    Begin
                      Begin
                        If interaction = 3 Then ;
                        printnl ( 261 ) ;
                        print ( 924 ) ;
                      End ;
                      slowprint ( hash [ rdelim ] . rh ) ;
                      print ( 925 ) ;
                      Begin
                        helpptr := 3 ;
                        helpline [ 2 ] := 926 ;
                        helpline [ 1 ] := 927 ;
                        helpline [ 0 ] := 928 ;
                      End ;
                      error ;
                    End ;
                  10 :
                End ;
                Function scandeclaredvariable : halfword ;

                Label 30 ;

                Var x : halfword ;
                  h , t : halfword ;
                  l : halfword ;
                Begin
                  getsymbol ;
                  x := cursym ;
                  If curcmd <> 41 Then clearsymbol ( x , false ) ;
                  h := getavail ;
                  mem [ h ] . hh . lh := x ;
                  t := h ;
                  While true Do
                    Begin
                      getxnext ;
                      If cursym = 0 Then goto 30 ;
                      If curcmd <> 41 Then If curcmd <> 40 Then If curcmd = 63 Then
                                                                  Begin
                                                                    l := cursym ;
                                                                    getxnext ;
                                                                    If curcmd <> 64 Then
                                                                      Begin
                                                                        backinput ;
                                                                        cursym := l ;
                                                                        curcmd := 63 ;
                                                                        goto 30 ;
                                                                      End
                                                                    Else cursym := 0 ;
                                                                  End
                      Else goto 30 ;
                      mem [ t ] . hh . rh := getavail ;
                      t := mem [ t ] . hh . rh ;
                      mem [ t ] . hh . lh := cursym ;
                    End ;
                  30 : If eqtb [ x ] . lh Mod 86 <> 41 Then clearsymbol ( x , false ) ;
                  If eqtb [ x ] . rh = 0 Then newroot ( x ) ;
                  scandeclaredvariable := h ;
                End ;
                Procedure scandef ;

                Var m : 1 .. 2 ;
                  n : 0 .. 3 ;
                  k : 0 .. 150 ;
                  c : 0 .. 7 ;
                  r : halfword ;
                  q : halfword ;
                  p : halfword ;
                  base : halfword ;
                  ldelim , rdelim : halfword ;
                Begin
                  m := curmod ;
                  c := 0 ;
                  mem [ 29998 ] . hh . rh := 0 ;
                  q := getavail ;
                  mem [ q ] . hh . lh := 0 ;
                  r := 0 ;
                  If m = 1 Then
                    Begin
                      getclearsymbol ;
                      warninginfo := cursym ;
                      getnext ;
                      scannerstatus := 5 ;
                      n := 0 ;
                      eqtb [ warninginfo ] . lh := 10 ;
                      eqtb [ warninginfo ] . rh := q ;
                    End
                  Else
                    Begin
                      p := scandeclaredvariable ;
                      flushvariable ( eqtb [ mem [ p ] . hh . lh ] . rh , mem [ p ] . hh . rh , true ) ;
                      warninginfo := findvariable ( p ) ;
                      flushlist ( p ) ;
                      If warninginfo = 0 Then
                        Begin
                          Begin
                            If interaction = 3 Then ;
                            printnl ( 261 ) ;
                            print ( 681 ) ;
                          End ;
                          Begin
                            helpptr := 2 ;
                            helpline [ 1 ] := 682 ;
                            helpline [ 0 ] := 683 ;
                          End ;
                          error ;
                          warninginfo := 21 ;
                        End ;
                      scannerstatus := 4 ;
                      n := 2 ;
                      If curcmd = 61 Then If curmod = 3 Then
                                            Begin
                                              n := 3 ;
                                              getnext ;
                                            End ;
                      mem [ warninginfo ] . hh . b0 := 20 + n ;
                      mem [ warninginfo + 1 ] . int := q ;
                    End ;
                  k := n ;
                  If curcmd = 31 Then Repeat
                                        ldelim := cursym ;
                                        rdelim := curmod ;
                                        getnext ;
                                        If ( curcmd = 56 ) And ( curmod >= 2370 ) Then base := curmod
                                        Else
                                          Begin
                                            Begin
                                              If interaction = 3 Then ;
                                              printnl ( 261 ) ;
                                              print ( 684 ) ;
                                            End ;
                                            Begin
                                              helpptr := 1 ;
                                              helpline [ 0 ] := 685 ;
                                            End ;
                                            backerror ;
                                            base := 2370 ;
                                          End ;
                                        Repeat
                                          mem [ q ] . hh . rh := getavail ;
                                          q := mem [ q ] . hh . rh ;
                                          mem [ q ] . hh . lh := base + k ;
                                          getsymbol ;
                                          p := getnode ( 2 ) ;
                                          mem [ p + 1 ] . int := base + k ;
                                          mem [ p ] . hh . lh := cursym ;
                                          If k = 150 Then overflow ( 686 , 150 ) ;
                                          k := k + 1 ;
                                          mem [ p ] . hh . rh := r ;
                                          r := p ;
                                          getnext ;
                                        Until curcmd <> 82 ;
                                        checkdelimiter ( ldelim , rdelim ) ;
                                        getnext ;
                    Until curcmd <> 31 ;
                  If curcmd = 56 Then
                    Begin
                      p := getnode ( 2 ) ;
                      If curmod < 2370 Then
                        Begin
                          c := curmod ;
                          mem [ p + 1 ] . int := 2370 + k ;
                        End
                      Else
                        Begin
                          mem [ p + 1 ] . int := curmod + k ;
                          If curmod = 2370 Then c := 4
                          Else If curmod = 2520 Then c := 6
                          Else c := 7 ;
                        End ;
                      If k = 150 Then overflow ( 686 , 150 ) ;
                      k := k + 1 ;
                      getsymbol ;
                      mem [ p ] . hh . lh := cursym ;
                      mem [ p ] . hh . rh := r ;
                      r := p ;
                      getnext ;
                      If c = 4 Then If curcmd = 69 Then
                                      Begin
                                        c := 5 ;
                                        p := getnode ( 2 ) ;
                                        If k = 150 Then overflow ( 686 , 150 ) ;
                                        mem [ p + 1 ] . int := 2370 + k ;
                                        getsymbol ;
                                        mem [ p ] . hh . lh := cursym ;
                                        mem [ p ] . hh . rh := r ;
                                        r := p ;
                                        getnext ;
                                      End ;
                    End ;
                  checkequals ;
                  p := getavail ;
                  mem [ p ] . hh . lh := c ;
                  mem [ q ] . hh . rh := p ;
                  If m = 1 Then mem [ p ] . hh . rh := scantoks ( 16 , r , 0 , n )
                  Else
                    Begin
                      q := getavail ;
                      mem [ q ] . hh . lh := bgloc ;
                      mem [ p ] . hh . rh := q ;
                      p := getavail ;
                      mem [ p ] . hh . lh := egloc ;
                      mem [ q ] . hh . rh := scantoks ( 16 , r , p , n ) ;
                    End ;
                  If warninginfo = 21 Then flushtokenlist ( mem [ 22 ] . int ) ;
                  scannerstatus := 0 ;
                  getxnext ;
                End ;
                Procedure scanprimary ;
                forward ;
                Procedure scansecondary ;
                forward ;
                Procedure scantertiary ;
                forward ;
                Procedure scanexpression ;
                forward ;
                Procedure scansuffix ;
                forward ;
                Procedure printmacroname ( a , n : halfword ) ;

                Var p , q : halfword ;
                Begin
                  If n <> 0 Then slowprint ( hash [ n ] . rh )
                  Else
                    Begin
                      p := mem [ a ] . hh . lh ;
                      If p = 0 Then slowprint ( hash [ mem [ mem [ mem [ a ] . hh . rh ] . hh . lh ] . hh . lh ] . rh )
                      Else
                        Begin
                          q := p ;
                          While mem [ q ] . hh . rh <> 0 Do
                            q := mem [ q ] . hh . rh ;
                          mem [ q ] . hh . rh := mem [ mem [ a ] . hh . rh ] . hh . lh ;
                          showtokenlist ( p , 0 , 1000 , 0 ) ;
                          mem [ q ] . hh . rh := 0 ;
                        End ;
                    End ;
                End ;
                Procedure printarg ( q : halfword ; n : integer ; b : halfword ) ;
                Begin
                  If mem [ q ] . hh . rh = 1 Then printnl ( 498 )
                  Else If ( b < 2670 ) And ( b <> 7 ) Then printnl ( 499 )
                  Else printnl ( 500 ) ;
                  printint ( n ) ;
                  print ( 702 ) ;
                  If mem [ q ] . hh . rh = 1 Then printexp ( q , 1 )
                  Else showtokenlist ( q , 0 , 1000 , 0 ) ;
                End ;
                Procedure scantextarg ( ldelim , rdelim : halfword ) ;

                Label 30 ;

                Var balance : integer ;
                  p : halfword ;
                Begin
                  warninginfo := ldelim ;
                  scannerstatus := 3 ;
                  p := 29998 ;
                  balance := 1 ;
                  mem [ 29998 ] . hh . rh := 0 ;
                  While true Do
                    Begin
                      getnext ;
                      If ldelim = 0 Then
                        Begin
                          If curcmd > 82 Then
                            Begin
                              If balance = 1 Then goto 30
                              Else If curcmd = 84 Then balance := balance - 1 ;
                            End
                          Else If curcmd = 32 Then balance := balance + 1 ;
                        End
                      Else
                        Begin
                          If curcmd = 62 Then
                            Begin
                              If curmod = ldelim Then
                                Begin
                                  balance := balance - 1 ;
                                  If balance = 0 Then goto 30 ;
                                End ;
                            End
                          Else If curcmd = 31 Then If curmod = rdelim Then balance := balance + 1 ;
                        End ;
                      mem [ p ] . hh . rh := curtok ;
                      p := mem [ p ] . hh . rh ;
                    End ;
                  30 : curexp := mem [ 29998 ] . hh . rh ;
                  curtype := 20 ;
                  scannerstatus := 0 ;
                End ;
                Procedure macrocall ( defref , arglist , macroname : halfword ) ;

                Label 40 ;

                Var r : halfword ;
                  p , q : halfword ;
                  n : integer ;
                  ldelim , rdelim : halfword ;
                  tail : halfword ;
                Begin
                  r := mem [ defref ] . hh . rh ;
                  mem [ defref ] . hh . lh := mem [ defref ] . hh . lh + 1 ;
                  If arglist = 0 Then n := 0
                  Else
                    Begin
                      n := 1 ;
                      tail := arglist ;
                      While mem [ tail ] . hh . rh <> 0 Do
                        Begin
                          n := n + 1 ;
                          tail := mem [ tail ] . hh . rh ;
                        End ;
                    End ;
                  If internal [ 9 ] > 0 Then
                    Begin
                      begindiagnostic ;
                      println ;
                      printmacroname ( arglist , macroname ) ;
                      If n = 3 Then print ( 664 ) ;
                      showmacro ( defref , 0 , 100000 ) ;
                      If arglist <> 0 Then
                        Begin
                          n := 0 ;
                          p := arglist ;
                          Repeat
                            q := mem [ p ] . hh . lh ;
                            printarg ( q , n , 0 ) ;
                            n := n + 1 ;
                            p := mem [ p ] . hh . rh ;
                          Until p = 0 ;
                        End ;
                      enddiagnostic ( false ) ;
                    End ;
                  curcmd := 83 ;
                  While mem [ r ] . hh . lh >= 2370 Do
                    Begin
                      If curcmd <> 82 Then
                        Begin
                          getxnext ;
                          If curcmd <> 31 Then
                            Begin
                              Begin
                                If interaction = 3 Then ;
                                printnl ( 261 ) ;
                                print ( 708 ) ;
                              End ;
                              printmacroname ( arglist , macroname ) ;
                              Begin
                                helpptr := 3 ;
                                helpline [ 2 ] := 709 ;
                                helpline [ 1 ] := 710 ;
                                helpline [ 0 ] := 711 ;
                              End ;
                              If mem [ r ] . hh . lh >= 2520 Then
                                Begin
                                  curexp := 0 ;
                                  curtype := 20 ;
                                End
                              Else
                                Begin
                                  curexp := 0 ;
                                  curtype := 16 ;
                                End ;
                              backerror ;
                              curcmd := 62 ;
                              goto 40 ;
                            End ;
                          ldelim := cursym ;
                          rdelim := curmod ;
                        End ;
                      If mem [ r ] . hh . lh >= 2670 Then scantextarg ( ldelim , rdelim )
                      Else
                        Begin
                          getxnext ;
                          If mem [ r ] . hh . lh >= 2520 Then scansuffix
                          Else scanexpression ;
                        End ;
                      If curcmd <> 82 Then If ( curcmd <> 62 ) Or ( curmod <> ldelim ) Then If mem [ mem [ r ] . hh . rh ] . hh . lh >= 2370 Then
                                                                                              Begin
                                                                                                missingerr ( 44 ) ;
                                                                                                Begin
                                                                                                  helpptr := 3 ;
                                                                                                  helpline [ 2 ] := 712 ;
                                                                                                  helpline [ 1 ] := 713 ;
                                                                                                  helpline [ 0 ] := 707 ;
                                                                                                End ;
                                                                                                backerror ;
                                                                                                curcmd := 82 ;
                                                                                              End
                      Else
                        Begin
                          missingerr ( hash [ rdelim ] . rh ) ;
                          Begin
                            helpptr := 2 ;
                            helpline [ 1 ] := 714 ;
                            helpline [ 0 ] := 707 ;
                          End ;
                          backerror ;
                        End ;
                      40 :
                           Begin
                             p := getavail ;
                             If curtype = 20 Then mem [ p ] . hh . lh := curexp
                             Else mem [ p ] . hh . lh := stashcurexp ;
                             If internal [ 9 ] > 0 Then
                               Begin
                                 begindiagnostic ;
                                 printarg ( mem [ p ] . hh . lh , n , mem [ r ] . hh . lh ) ;
                                 enddiagnostic ( false ) ;
                               End ;
                             If arglist = 0 Then arglist := p
                             Else mem [ tail ] . hh . rh := p ;
                             tail := p ;
                             n := n + 1 ;
                           End ;
                      r := mem [ r ] . hh . rh ;
                    End ;
                  If curcmd = 82 Then
                    Begin
                      Begin
                        If interaction = 3 Then ;
                        printnl ( 261 ) ;
                        print ( 703 ) ;
                      End ;
                      printmacroname ( arglist , macroname ) ;
                      printchar ( 59 ) ;
                      printnl ( 704 ) ;
                      slowprint ( hash [ rdelim ] . rh ) ;
                      print ( 300 ) ;
                      Begin
                        helpptr := 3 ;
                        helpline [ 2 ] := 705 ;
                        helpline [ 1 ] := 706 ;
                        helpline [ 0 ] := 707 ;
                      End ;
                      error ;
                    End ;
                  If mem [ r ] . hh . lh <> 0 Then
                    Begin
                      If mem [ r ] . hh . lh < 7 Then
                        Begin
                          getxnext ;
                          If mem [ r ] . hh . lh <> 6 Then If ( curcmd = 51 ) Or ( curcmd = 77 ) Then getxnext ;
                        End ;
                      Case mem [ r ] . hh . lh Of 
                        1 : scanprimary ;
                        2 : scansecondary ;
                        3 : scantertiary ;
                        4 : scanexpression ;
                        5 :
                            Begin
                              scanexpression ;
                              p := getavail ;
                              mem [ p ] . hh . lh := stashcurexp ;
                              If internal [ 9 ] > 0 Then
                                Begin
                                  begindiagnostic ;
                                  printarg ( mem [ p ] . hh . lh , n , 0 ) ;
                                  enddiagnostic ( false ) ;
                                End ;
                              If arglist = 0 Then arglist := p
                              Else mem [ tail ] . hh . rh := p ;
                              tail := p ;
                              n := n + 1 ;
                              If curcmd <> 69 Then
                                Begin
                                  missingerr ( 479 ) ;
                                  print ( 715 ) ;
                                  printmacroname ( arglist , macroname ) ;
                                  Begin
                                    helpptr := 1 ;
                                    helpline [ 0 ] := 716 ;
                                  End ;
                                  backerror ;
                                End ;
                              getxnext ;
                              scanprimary ;
                            End ;
                        6 :
                            Begin
                              If curcmd <> 31 Then ldelim := 0
                              Else
                                Begin
                                  ldelim := cursym ;
                                  rdelim := curmod ;
                                  getxnext ;
                                End ;
                              scansuffix ;
                              If ldelim <> 0 Then
                                Begin
                                  If ( curcmd <> 62 ) Or ( curmod <> ldelim ) Then
                                    Begin
                                      missingerr ( hash [ rdelim ] . rh ) ;
                                      Begin
                                        helpptr := 2 ;
                                        helpline [ 1 ] := 714 ;
                                        helpline [ 0 ] := 707 ;
                                      End ;
                                      backerror ;
                                    End ;
                                  getxnext ;
                                End ;
                            End ;
                        7 : scantextarg ( 0 , 0 ) ;
                      End ;
                      backinput ;
                      Begin
                        p := getavail ;
                        If curtype = 20 Then mem [ p ] . hh . lh := curexp
                        Else mem [ p ] . hh . lh := stashcurexp ;
                        If internal [ 9 ] > 0 Then
                          Begin
                            begindiagnostic ;
                            printarg ( mem [ p ] . hh . lh , n , mem [ r ] . hh . lh ) ;
                            enddiagnostic ( false ) ;
                          End ;
                        If arglist = 0 Then arglist := p
                        Else mem [ tail ] . hh . rh := p ;
                        tail := p ;
                        n := n + 1 ;
                      End ;
                    End ;
                  r := mem [ r ] . hh . rh ;
                  While ( curinput . indexfield > 6 ) And ( curinput . locfield = 0 ) Do
                    endtokenlist ;
                  If paramptr + n > maxparamstack Then
                    Begin
                      maxparamstack := paramptr + n ;
                      If maxparamstack > 150 Then overflow ( 686 , 150 ) ;
                    End ;
                  begintokenlist ( defref , 12 ) ;
                  curinput . namefield := macroname ;
                  curinput . locfield := r ;
                  If n > 0 Then
                    Begin
                      p := arglist ;
                      Repeat
                        paramstack [ paramptr ] := mem [ p ] . hh . lh ;
                        paramptr := paramptr + 1 ;
                        p := mem [ p ] . hh . rh ;
                      Until p = 0 ;
                      flushlist ( arglist ) ;
                    End ;
                End ;
                Procedure getboolean ;
                forward ;
                Procedure passtext ;
                forward ;
                Procedure conditional ;
                forward ;
                Procedure startinput ;
                forward ;
                Procedure beginiteration ;
                forward ;
                Procedure resumeiteration ;
                forward ;
                Procedure stopiteration ;
                forward ;
                Procedure expand ;

                Var p : halfword ;
                  k : integer ;
                  j : poolpointer ;
                Begin
                  If internal [ 7 ] > 65536 Then If curcmd <> 10 Then showcmdmod ( curcmd , curmod ) ;
                  Case curcmd Of 
                    1 : conditional ;
                    2 : If curmod > iflimit Then If iflimit = 1 Then
                                                   Begin
                                                     missingerr ( 58 ) ;
                                                     backinput ;
                                                     cursym := 2362 ;
                                                     inserror ;
                                                   End
                        Else
                          Begin
                            Begin
                              If interaction = 3 Then ;
                              printnl ( 261 ) ;
                              print ( 723 ) ;
                            End ;
                            printcmdmod ( 2 , curmod ) ;
                            Begin
                              helpptr := 1 ;
                              helpline [ 0 ] := 724 ;
                            End ;
                            error ;
                          End
                        Else
                          Begin
                            While curmod <> 2 Do
                              passtext ;
                            Begin
                              p := condptr ;
                              ifline := mem [ p + 1 ] . int ;
                              curif := mem [ p ] . hh . b1 ;
                              iflimit := mem [ p ] . hh . b0 ;
                              condptr := mem [ p ] . hh . rh ;
                              freenode ( p , 2 ) ;
                            End ;
                          End ;
                    3 : If curmod > 0 Then forceeof := true
                        Else startinput ;
                    4 : If curmod = 0 Then
                          Begin
                            Begin
                              If interaction = 3 Then ;
                              printnl ( 261 ) ;
                              print ( 687 ) ;
                            End ;
                            Begin
                              helpptr := 2 ;
                              helpline [ 1 ] := 688 ;
                              helpline [ 0 ] := 689 ;
                            End ;
                            error ;
                          End
                        Else beginiteration ;
                    5 :
                        Begin
                          While ( curinput . indexfield > 6 ) And ( curinput . locfield = 0 ) Do
                            endtokenlist ;
                          If loopptr = 0 Then
                            Begin
                              Begin
                                If interaction = 3 Then ;
                                printnl ( 261 ) ;
                                print ( 691 ) ;
                              End ;
                              Begin
                                helpptr := 2 ;
                                helpline [ 1 ] := 692 ;
                                helpline [ 0 ] := 693 ;
                              End ;
                              error ;
                            End
                          Else resumeiteration ;
                        End ;
                    6 :
                        Begin
                          getboolean ;
                          If internal [ 7 ] > 65536 Then showcmdmod ( 33 , curexp ) ;
                          If curexp = 30 Then If loopptr = 0 Then
                                                Begin
                                                  Begin
                                                    If interaction = 3 Then ;
                                                    printnl ( 261 ) ;
                                                    print ( 694 ) ;
                                                  End ;
                                                  Begin
                                                    helpptr := 1 ;
                                                    helpline [ 0 ] := 695 ;
                                                  End ;
                                                  If curcmd = 83 Then error
                                                  Else backerror ;
                                                End
                          Else
                            Begin
                              p := 0 ;
                              Repeat
                                If ( curinput . indexfield <= 6 ) Then endfilereading
                                Else
                                  Begin
                                    If curinput . indexfield <= 8 Then p := curinput . startfield ;
                                    endtokenlist ;
                                  End ;
                              Until p <> 0 ;
                              If p <> mem [ loopptr ] . hh . lh Then fatalerror ( 698 ) ;
                              stopiteration ;
                            End
                          Else If curcmd <> 83 Then
                                 Begin
                                   missingerr ( 59 ) ;
                                   Begin
                                     helpptr := 2 ;
                                     helpline [ 1 ] := 696 ;
                                     helpline [ 0 ] := 697 ;
                                   End ;
                                   backerror ;
                                 End ;
                        End ;
                    7 : ;
                    9 :
                        Begin
                          getnext ;
                          p := curtok ;
                          getnext ;
                          If curcmd < 11 Then expand
                          Else backinput ;
                          begintokenlist ( p , 10 ) ;
                        End ;
                    8 :
                        Begin
                          getxnext ;
                          scanprimary ;
                          If curtype <> 4 Then
                            Begin
                              disperr ( 0 , 699 ) ;
                              Begin
                                helpptr := 2 ;
                                helpline [ 1 ] := 700 ;
                                helpline [ 0 ] := 701 ;
                              End ;
                              putgetflusherror ( 0 ) ;
                            End
                          Else
                            Begin
                              backinput ;
                              If ( strstart [ curexp + 1 ] - strstart [ curexp ] ) > 0 Then
                                Begin
                                  beginfilereading ;
                                  curinput . namefield := 2 ;
                                  k := first + ( strstart [ curexp + 1 ] - strstart [ curexp ] ) ;
                                  If k >= maxbufstack Then
                                    Begin
                                      If k >= bufsize Then
                                        Begin
                                          maxbufstack := bufsize ;
                                          overflow ( 256 , bufsize ) ;
                                        End ;
                                      maxbufstack := k + 1 ;
                                    End ;
                                  j := strstart [ curexp ] ;
                                  curinput . limitfield := k ;
                                  While first < curinput . limitfield Do
                                    Begin
                                      buffer [ first ] := strpool [ j ] ;
                                      j := j + 1 ;
                                      first := first + 1 ;
                                    End ;
                                  buffer [ curinput . limitfield ] := 37 ;
                                  first := curinput . limitfield + 1 ;
                                  curinput . locfield := curinput . startfield ;
                                  flushcurexp ( 0 ) ;
                                End ;
                            End ;
                        End ;
                    10 : macrocall ( curmod , 0 , cursym ) ;
                  End ;
                End ;
                Procedure getxnext ;

                Var saveexp : halfword ;
                Begin
                  getnext ;
                  If curcmd < 11 Then
                    Begin
                      saveexp := stashcurexp ;
                      Repeat
                        If curcmd = 10 Then macrocall ( curmod , 0 , cursym )
                        Else expand ;
                        getnext ;
                      Until curcmd >= 11 ;
                      unstashcurexp ( saveexp ) ;
                    End ;
                End ;
                Procedure stackargument ( p : halfword ) ;
                Begin
                  If paramptr = maxparamstack Then
                    Begin
                      maxparamstack := maxparamstack + 1 ;
                      If maxparamstack > 150 Then overflow ( 686 , 150 ) ;
                    End ;
                  paramstack [ paramptr ] := p ;
                  paramptr := paramptr + 1 ;
                End ;
                Procedure passtext ;

                Label 30 ;

                Var l : integer ;
                Begin
                  scannerstatus := 1 ;
                  l := 0 ;
                  warninginfo := line ;
                  While true Do
                    Begin
                      getnext ;
                      If curcmd <= 2 Then If curcmd < 2 Then l := l + 1
                      Else
                        Begin
                          If l = 0 Then goto 30 ;
                          If curmod = 2 Then l := l - 1 ;
                        End
                      Else If curcmd = 39 Then
                             Begin
                               If strref [ curmod ] < 127 Then If strref [ curmod ] > 1 Then strref [ curmod ] := strref [ curmod ] - 1
                               Else flushstring ( curmod ) ;
                             End ;
                    End ;
                  30 : scannerstatus := 0 ;
                End ;
                Procedure changeiflimit ( l : smallnumber ; p : halfword ) ;

                Label 10 ;

                Var q : halfword ;
                Begin
                  If p = condptr Then iflimit := l
                  Else
                    Begin
                      q := condptr ;
                      While true Do
                        Begin
                          If q = 0 Then confusion ( 717 ) ;
                          If mem [ q ] . hh . rh = p Then
                            Begin
                              mem [ q ] . hh . b0 := l ;
                              goto 10 ;
                            End ;
                          q := mem [ q ] . hh . rh ;
                        End ;
                    End ;
                  10 :
                End ;
                Procedure checkcolon ;
                Begin
                  If curcmd <> 81 Then
                    Begin
                      missingerr ( 58 ) ;
                      Begin
                        helpptr := 2 ;
                        helpline [ 1 ] := 720 ;
                        helpline [ 0 ] := 697 ;
                      End ;
                      backerror ;
                    End ;
                End ;
                Procedure conditional ;

                Label 10 , 30 , 21 , 40 ;

                Var savecondptr : halfword ;
                  newiflimit : 2 .. 4 ;
                  p : halfword ;
                Begin
                  Begin
                    p := getnode ( 2 ) ;
                    mem [ p ] . hh . rh := condptr ;
                    mem [ p ] . hh . b0 := iflimit ;
                    mem [ p ] . hh . b1 := curif ;
                    mem [ p + 1 ] . int := ifline ;
                    condptr := p ;
                    iflimit := 1 ;
                    ifline := line ;
                    curif := 1 ;
                  End ;
                  savecondptr := condptr ;
                  21 : getboolean ;
                  newiflimit := 4 ;
                  If internal [ 7 ] > 65536 Then
                    Begin
                      begindiagnostic ;
                      If curexp = 30 Then print ( 721 )
                      Else print ( 722 ) ;
                      enddiagnostic ( false ) ;
                    End ;
                  40 : checkcolon ;
                  If curexp = 30 Then
                    Begin
                      changeiflimit ( newiflimit , savecondptr ) ;
                      goto 10 ;
                    End ;
                  While true Do
                    Begin
                      passtext ;
                      If condptr = savecondptr Then goto 30
                      Else If curmod = 2 Then
                             Begin
                               p := condptr ;
                               ifline := mem [ p + 1 ] . int ;
                               curif := mem [ p ] . hh . b1 ;
                               iflimit := mem [ p ] . hh . b0 ;
                               condptr := mem [ p ] . hh . rh ;
                               freenode ( p , 2 ) ;
                             End ;
                    End ;
                  30 : curif := curmod ;
                  ifline := line ;
                  If curmod = 2 Then
                    Begin
                      p := condptr ;
                      ifline := mem [ p + 1 ] . int ;
                      curif := mem [ p ] . hh . b1 ;
                      iflimit := mem [ p ] . hh . b0 ;
                      condptr := mem [ p ] . hh . rh ;
                      freenode ( p , 2 ) ;
                    End
                  Else If curmod = 4 Then goto 21
                  Else
                    Begin
                      curexp := 30 ;
                      newiflimit := 2 ;
                      getxnext ;
                      goto 40 ;
                    End ;
                  10 :
                End ;
                Procedure badfor ( s : strnumber ) ;
                Begin
                  disperr ( 0 , 725 ) ;
                  print ( s ) ;
                  print ( 307 ) ;
                  Begin
                    helpptr := 4 ;
                    helpline [ 3 ] := 726 ;
                    helpline [ 2 ] := 727 ;
                    helpline [ 1 ] := 728 ;
                    helpline [ 0 ] := 309 ;
                  End ;
                  putgetflusherror ( 0 ) ;
                End ;
                Procedure beginiteration ;

                Label 22 , 30 , 40 ;

                Var m : halfword ;
                  n : halfword ;
                  p , q , s , pp : halfword ;
                Begin
                  m := curmod ;
                  n := cursym ;
                  s := getnode ( 2 ) ;
                  If m = 1 Then
                    Begin
                      mem [ s + 1 ] . hh . lh := 1 ;
                      p := 0 ;
                      getxnext ;
                      goto 40 ;
                    End ;
                  getsymbol ;
                  p := getnode ( 2 ) ;
                  mem [ p ] . hh . lh := cursym ;
                  mem [ p + 1 ] . int := m ;
                  getxnext ;
                  If ( curcmd <> 51 ) And ( curcmd <> 77 ) Then
                    Begin
                      missingerr ( 61 ) ;
                      Begin
                        helpptr := 3 ;
                        helpline [ 2 ] := 729 ;
                        helpline [ 1 ] := 672 ;
                        helpline [ 0 ] := 730 ;
                      End ;
                      backerror ;
                    End ;
                  mem [ s + 1 ] . hh . lh := 0 ;
                  q := s + 1 ;
                  mem [ q ] . hh . rh := 0 ;
                  Repeat
                    getxnext ;
                    If m <> 2370 Then scansuffix
                    Else
                      Begin
                        If curcmd >= 81 Then If curcmd <= 82 Then goto 22 ;
                        scanexpression ;
                        If curcmd = 74 Then If q = s + 1 Then
                                              Begin
                                                If curtype <> 16 Then badfor ( 736 ) ;
                                                pp := getnode ( 4 ) ;
                                                mem [ pp + 1 ] . int := curexp ;
                                                getxnext ;
                                                scanexpression ;
                                                If curtype <> 16 Then badfor ( 737 ) ;
                                                mem [ pp + 2 ] . int := curexp ;
                                                If curcmd <> 75 Then
                                                  Begin
                                                    missingerr ( 490 ) ;
                                                    Begin
                                                      helpptr := 2 ;
                                                      helpline [ 1 ] := 738 ;
                                                      helpline [ 0 ] := 739 ;
                                                    End ;
                                                    backerror ;
                                                  End ;
                                                getxnext ;
                                                scanexpression ;
                                                If curtype <> 16 Then badfor ( 740 ) ;
                                                mem [ pp + 3 ] . int := curexp ;
                                                mem [ s + 1 ] . hh . lh := pp ;
                                                goto 30 ;
                                              End ;
                        curexp := stashcurexp ;
                      End ;
                    mem [ q ] . hh . rh := getavail ;
                    q := mem [ q ] . hh . rh ;
                    mem [ q ] . hh . lh := curexp ;
                    curtype := 1 ;
                    22 :
                  Until curcmd <> 82 ;
                  30 : ;
                  40 : If curcmd <> 81 Then
                         Begin
                           missingerr ( 58 ) ;
                           Begin
                             helpptr := 3 ;
                             helpline [ 2 ] := 731 ;
                             helpline [ 1 ] := 732 ;
                             helpline [ 0 ] := 733 ;
                           End ;
                           backerror ;
                         End ;
                  q := getavail ;
                  mem [ q ] . hh . lh := 2358 ;
                  scannerstatus := 6 ;
                  warninginfo := n ;
                  mem [ s ] . hh . lh := scantoks ( 4 , p , q , 0 ) ;
                  scannerstatus := 0 ;
                  mem [ s ] . hh . rh := loopptr ;
                  loopptr := s ;
                  resumeiteration ;
                End ;
                Procedure resumeiteration ;

                Label 45 , 10 ;

                Var p , q : halfword ;
                Begin
                  p := mem [ loopptr + 1 ] . hh . lh ;
                  If p > 1 Then
                    Begin
                      curexp := mem [ p + 1 ] . int ;
                      If ( ( mem [ p + 2 ] . int > 0 ) And ( curexp > mem [ p + 3 ] . int ) ) Or ( ( mem [ p + 2 ] . int < 0 ) And ( curexp < mem [ p + 3 ] . int ) ) Then goto 45 ;
                      curtype := 16 ;
                      q := stashcurexp ;
                      mem [ p + 1 ] . int := curexp + mem [ p + 2 ] . int ;
                    End
                  Else If p < 1 Then
                         Begin
                           p := mem [ loopptr + 1 ] . hh . rh ;
                           If p = 0 Then goto 45 ;
                           mem [ loopptr + 1 ] . hh . rh := mem [ p ] . hh . rh ;
                           q := mem [ p ] . hh . lh ;
                           Begin
                             mem [ p ] . hh . rh := avail ;
                             avail := p ;
                           End ;
                         End
                  Else
                    Begin
                      begintokenlist ( mem [ loopptr ] . hh . lh , 7 ) ;
                      goto 10 ;
                    End ;
                  begintokenlist ( mem [ loopptr ] . hh . lh , 8 ) ;
                  stackargument ( q ) ;
                  If internal [ 7 ] > 65536 Then
                    Begin
                      begindiagnostic ;
                      printnl ( 735 ) ;
                      If ( q <> 0 ) And ( mem [ q ] . hh . rh = 1 ) Then printexp ( q , 1 )
                      Else showtokenlist ( q , 0 , 50 , 0 ) ;
                      printchar ( 125 ) ;
                      enddiagnostic ( false ) ;
                    End ;
                  goto 10 ;
                  45 : stopiteration ;
                  10 :
                End ;
                Procedure stopiteration ;

                Var p , q : halfword ;
                Begin
                  p := mem [ loopptr + 1 ] . hh . lh ;
                  If p > 1 Then freenode ( p , 4 )
                  Else If p < 1 Then
                         Begin
                           q := mem [ loopptr + 1 ] . hh . rh ;
                           While q <> 0 Do
                             Begin
                               p := mem [ q ] . hh . lh ;
                               If p <> 0 Then If mem [ p ] . hh . rh = 1 Then
                                                Begin
                                                  recyclevalue ( p ) ;
                                                  freenode ( p , 2 ) ;
                                                End
                               Else flushtokenlist ( p ) ;
                               p := q ;
                               q := mem [ q ] . hh . rh ;
                               Begin
                                 mem [ p ] . hh . rh := avail ;
                                 avail := p ;
                               End ;
                             End ;
                         End ;
                  p := loopptr ;
                  loopptr := mem [ p ] . hh . rh ;
                  flushtokenlist ( mem [ p ] . hh . lh ) ;
                  freenode ( p , 2 ) ;
                End ;
                Procedure beginname ;
                Begin
                  areadelimiter := 0 ;
                  extdelimiter := 0 ;
                End ;
                Function morename ( c : ASCIIcode ) : boolean ;
                Begin
                  If c = 32 Then morename := false
                  Else
                    Begin
                      If ( c = 62 ) Or ( c = 58 ) Then
                        Begin
                          areadelimiter := poolptr ;
                          extdelimiter := 0 ;
                        End
                      Else If ( c = 46 ) And ( extdelimiter = 0 ) Then extdelimiter := poolptr ;
                      Begin
                        If poolptr + 1 > maxpoolptr Then
                          Begin
                            If poolptr + 1 > poolsize Then overflow ( 257 , poolsize - initpoolptr ) ;
                            maxpoolptr := poolptr + 1 ;
                          End ;
                      End ;
                      Begin
                        strpool [ poolptr ] := c ;
                        poolptr := poolptr + 1 ;
                      End ;
                      morename := true ;
                    End ;
                End ;
                Procedure endname ;
                Begin
                  If strptr + 3 > maxstrptr Then
                    Begin
                      If strptr + 3 > maxstrings Then overflow ( 258 , maxstrings - initstrptr ) ;
                      maxstrptr := strptr + 3 ;
                    End ;
                  If areadelimiter = 0 Then curarea := 285
                  Else
                    Begin
                      curarea := strptr ;
                      strptr := strptr + 1 ;
                      strstart [ strptr ] := areadelimiter + 1 ;
                    End ;
                  If extdelimiter = 0 Then
                    Begin
                      curext := 285 ;
                      curname := makestring ;
                    End
                  Else
                    Begin
                      curname := strptr ;
                      strptr := strptr + 1 ;
                      strstart [ strptr ] := extdelimiter ;
                      curext := makestring ;
                    End ;
                End ;
                Procedure packfilename ( n , a , e : strnumber ) ;

                Var k : integer ;
                  c : ASCIIcode ;
                  j : poolpointer ;
                Begin
                  k := 0 ;
                  For j := strstart [ a ] To strstart [ a + 1 ] - 1 Do
                    Begin
                      c := strpool [ j ] ;
                      k := k + 1 ;
                      If k <= filenamesize Then nameoffile [ k ] := xchr [ c ] ;
                    End ;
                  For j := strstart [ n ] To strstart [ n + 1 ] - 1 Do
                    Begin
                      c := strpool [ j ] ;
                      k := k + 1 ;
                      If k <= filenamesize Then nameoffile [ k ] := xchr [ c ] ;
                    End ;
                  For j := strstart [ e ] To strstart [ e + 1 ] - 1 Do
                    Begin
                      c := strpool [ j ] ;
                      k := k + 1 ;
                      If k <= filenamesize Then nameoffile [ k ] := xchr [ c ] ;
                    End ;
                  If k <= filenamesize Then namelength := k
                  Else namelength := filenamesize ;
                  For k := namelength + 1 To filenamesize Do
                    nameoffile [ k ] := ' ' ;
                End ;
                Procedure packbufferedname ( n : smallnumber ; a , b : integer ) ;

                Var k : integer ;
                  c : ASCIIcode ;
                  j : integer ;
                Begin
                  If n + b - a + 6 > filenamesize Then b := a + filenamesize - n - 6 ;
                  k := 0 ;
                  For j := 1 To n Do
                    Begin
                      c := xord [ MFbasedefault [ j ] ] ;
                      k := k + 1 ;
                      If k <= filenamesize Then nameoffile [ k ] := xchr [ c ] ;
                    End ;
                  For j := a To b Do
                    Begin
                      c := buffer [ j ] ;
                      k := k + 1 ;
                      If k <= filenamesize Then nameoffile [ k ] := xchr [ c ] ;
                    End ;
                  For j := 14 To 18 Do
                    Begin
                      c := xord [ MFbasedefault [ j ] ] ;
                      k := k + 1 ;
                      If k <= filenamesize Then nameoffile [ k ] := xchr [ c ] ;
                    End ;
                  If k <= filenamesize Then namelength := k
                  Else namelength := filenamesize ;
                  For k := namelength + 1 To filenamesize Do
                    nameoffile [ k ] := ' ' ;
                End ;
                Function makenamestring : strnumber ;

                Var k : 1 .. filenamesize ;
                Begin
                  If ( poolptr + namelength > poolsize ) Or ( strptr = maxstrings ) Then makenamestring := 63
                  Else
                    Begin
                      For k := 1 To namelength Do
                        Begin
                          strpool [ poolptr ] := xord [ nameoffile [ k ] ] ;
                          poolptr := poolptr + 1 ;
                        End ;
                      makenamestring := makestring ;
                    End ;
                End ;
                Function amakenamestring ( Var f : alphafile ) : strnumber ;
                Begin
                  amakenamestring := makenamestring ;
                End ;
                Function bmakenamestring ( Var f : bytefile ) : strnumber ;
                Begin
                  bmakenamestring := makenamestring ;
                End ;
                Function wmakenamestring ( Var f : wordfile ) : strnumber ;
                Begin
                  wmakenamestring := makenamestring ;
                End ;
                Procedure scanfilename ;

                Label 30 ;
                Begin
                  beginname ;
                  While buffer [ curinput . locfield ] = 32 Do
                    curinput . locfield := curinput . locfield + 1 ;
                  While true Do
                    Begin
                      If ( buffer [ curinput . locfield ] = 59 ) Or ( buffer [ curinput . locfield ] = 37 ) Then goto 30 ;
                      If Not morename ( buffer [ curinput . locfield ] ) Then goto 30 ;
                      curinput . locfield := curinput . locfield + 1 ;
                    End ;
                  30 : endname ;
                End ;
                Procedure packjobname ( s : strnumber ) ;
                Begin
                  curarea := 285 ;
                  curext := s ;
                  curname := jobname ;
                  packfilename ( curname , curarea , curext ) ;
                End ;
                Procedure promptfilename ( s , e : strnumber ) ;

                Label 30 ;

                Var k : 0 .. bufsize ;
                Begin
                  If interaction = 2 Then ;
                  If s = 743 Then
                    Begin
                      If interaction = 3 Then ;
                      printnl ( 261 ) ;
                      print ( 744 ) ;
                    End
                  Else
                    Begin
                      If interaction = 3 Then ;
                      printnl ( 261 ) ;
                      print ( 745 ) ;
                    End ;
                  printfilename ( curname , curarea , curext ) ;
                  print ( 746 ) ;
                  If e = 747 Then showcontext ;
                  printnl ( 748 ) ;
                  print ( s ) ;
                  If interaction < 2 Then fatalerror ( 749 ) ;
                  breakin ( termin , true ) ;
                  Begin ;
                    print ( 750 ) ;
                    terminput ;
                  End ;
                  Begin
                    beginname ;
                    k := first ;
                    While ( buffer [ k ] = 32 ) And ( k < last ) Do
                      k := k + 1 ;
                    While true Do
                      Begin
                        If k = last Then goto 30 ;
                        If Not morename ( buffer [ k ] ) Then goto 30 ;
                        k := k + 1 ;
                      End ;
                    30 : endname ;
                  End ;
                  If curext = 285 Then curext := e ;
                  packfilename ( curname , curarea , curext ) ;
                End ;
                Procedure openlogfile ;

                Var oldsetting : 0 .. 5 ;
                  k : 0 .. bufsize ;
                  l : 0 .. bufsize ;
                  m : integer ;
                  months : packed array [ 1 .. 36 ] Of char ;
                Begin
                  oldsetting := selector ;
                  If jobname = 0 Then jobname := 751 ;
                  packjobname ( 752 ) ;
                  While Not aopenout ( logfile ) Do
                    Begin
                      selector := 1 ;
                      promptfilename ( 754 , 752 ) ;
                    End ;
                  logname := amakenamestring ( logfile ) ;
                  selector := 2 ;
                  logopened := true ;
                  Begin
                    write ( logfile , 'This is METAFONT, Version 2.7182818' ) ;
                    slowprint ( baseident ) ;
                    print ( 755 ) ;
                    printint ( roundunscaled ( internal [ 16 ] ) ) ;
                    printchar ( 32 ) ;
                    months := 'JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC' ;
                    m := roundunscaled ( internal [ 15 ] ) ;
                    For k := 3 * m - 2 To 3 * m Do
                      write ( logfile , months [ k ] ) ;
                    printchar ( 32 ) ;
                    printint ( roundunscaled ( internal [ 14 ] ) ) ;
                    printchar ( 32 ) ;
                    m := roundunscaled ( internal [ 17 ] ) ;
                    printdd ( m Div 60 ) ;
                    printchar ( 58 ) ;
                    printdd ( m Mod 60 ) ;
                  End ;
                  inputstack [ inputptr ] := curinput ;
                  printnl ( 753 ) ;
                  l := inputstack [ 0 ] . limitfield - 1 ;
                  For k := 1 To l Do
                    print ( buffer [ k ] ) ;
                  println ;
                  selector := oldsetting + 2 ;
                End ;
                Procedure startinput ;

                Label 30 ;
                Begin
                  While ( curinput . indexfield > 6 ) And ( curinput . locfield = 0 ) Do
                    endtokenlist ;
                  If ( curinput . indexfield > 6 ) Then
                    Begin
                      Begin
                        If interaction = 3 Then ;
                        printnl ( 261 ) ;
                        print ( 757 ) ;
                      End ;
                      Begin
                        helpptr := 3 ;
                        helpline [ 2 ] := 758 ;
                        helpline [ 1 ] := 759 ;
                        helpline [ 0 ] := 760 ;
                      End ;
                      error ;
                    End ;
                  If ( curinput . indexfield <= 6 ) Then scanfilename
                  Else
                    Begin
                      curname := 285 ;
                      curext := 285 ;
                      curarea := 285 ;
                    End ;
                  If curext = 285 Then curext := 747 ;
                  packfilename ( curname , curarea , curext ) ;
                  While true Do
                    Begin
                      beginfilereading ;
                      If aopenin ( inputfile [ curinput . indexfield ] ) Then goto 30 ;
                      If curarea = 285 Then
                        Begin
                          packfilename ( curname , 741 , curext ) ;
                          If aopenin ( inputfile [ curinput . indexfield ] ) Then goto 30 ;
                        End ;
                      endfilereading ;
                      promptfilename ( 743 , 747 ) ;
                    End ;
                  30 : curinput . namefield := amakenamestring ( inputfile [ curinput . indexfield ] ) ;
                  strref [ curname ] := 127 ;
                  If jobname = 0 Then
                    Begin
                      jobname := curname ;
                      openlogfile ;
                    End ;
                  If termoffset + ( strstart [ curinput . namefield + 1 ] - strstart [ curinput . namefield ] ) > maxprintline - 2 Then println
                  Else If ( termoffset > 0 ) Or ( fileoffset > 0 ) Then printchar ( 32 ) ;
                  printchar ( 40 ) ;
                  openparens := openparens + 1 ;
                  slowprint ( curinput . namefield ) ;
                  break ( termout ) ;
                  If curinput . namefield = strptr - 1 Then
                    Begin
                      flushstring ( curinput . namefield ) ;
                      curinput . namefield := curname ;
                    End ;
                  Begin
                    line := 1 ;
                    If inputln ( inputfile [ curinput . indexfield ] , false ) Then ;
                    firmuptheline ;
                    buffer [ curinput . limitfield ] := 37 ;
                    first := curinput . limitfield + 1 ;
                    curinput . locfield := curinput . startfield ;
                  End ;
                End ;
                Procedure badexp ( s : strnumber ) ;

                Var saveflag : 0 .. 85 ;
                Begin
                  Begin
                    If interaction = 3 Then ;
                    printnl ( 261 ) ;
                    print ( s ) ;
                  End ;
                  print ( 770 ) ;
                  printcmdmod ( curcmd , curmod ) ;
                  printchar ( 39 ) ;
                  Begin
                    helpptr := 4 ;
                    helpline [ 3 ] := 771 ;
                    helpline [ 2 ] := 772 ;
                    helpline [ 1 ] := 773 ;
                    helpline [ 0 ] := 774 ;
                  End ;
                  backinput ;
                  cursym := 0 ;
                  curcmd := 42 ;
                  curmod := 0 ;
                  inserror ;
                  saveflag := varflag ;
                  varflag := 0 ;
                  getxnext ;
                  varflag := saveflag ;
                End ;
                Procedure stashin ( p : halfword ) ;

                Var q : halfword ;
                Begin
                  mem [ p ] . hh . b0 := curtype ;
                  If curtype = 16 Then mem [ p + 1 ] . int := curexp
                  Else
                    Begin
                      If curtype = 19 Then
                        Begin
                          q := singledependency ( curexp ) ;
                          If q = depfinal Then
                            Begin
                              mem [ p ] . hh . b0 := 16 ;
                              mem [ p + 1 ] . int := 0 ;
                              freenode ( q , 2 ) ;
                            End
                          Else
                            Begin
                              mem [ p ] . hh . b0 := 17 ;
                              newdep ( p , q ) ;
                            End ;
                          recyclevalue ( curexp ) ;
                        End
                      Else
                        Begin
                          mem [ p + 1 ] := mem [ curexp + 1 ] ;
                          mem [ mem [ p + 1 ] . hh . lh ] . hh . rh := p ;
                        End ;
                      freenode ( curexp , 2 ) ;
                    End ;
                  curtype := 1 ;
                End ;
                Procedure backexpr ;

                Var p : halfword ;
                Begin
                  p := stashcurexp ;
                  mem [ p ] . hh . rh := 0 ;
                  begintokenlist ( p , 10 ) ;
                End ;
                Procedure badsubscript ;
                Begin
                  disperr ( 0 , 786 ) ;
                  Begin
                    helpptr := 3 ;
                    helpline [ 2 ] := 787 ;
                    helpline [ 1 ] := 788 ;
                    helpline [ 0 ] := 789 ;
                  End ;
                  flusherror ( 0 ) ;
                End ;
                Procedure obliterated ( q : halfword ) ;
                Begin
                  Begin
                    If interaction = 3 Then ;
                    printnl ( 261 ) ;
                    print ( 790 ) ;
                  End ;
                  showtokenlist ( q , 0 , 1000 , 0 ) ;
                  print ( 791 ) ;
                  Begin
                    helpptr := 5 ;
                    helpline [ 4 ] := 792 ;
                    helpline [ 3 ] := 793 ;
                    helpline [ 2 ] := 794 ;
                    helpline [ 1 ] := 795 ;
                    helpline [ 0 ] := 796 ;
                  End ;
                End ;
                Procedure binarymac ( p , c , n : halfword ) ;

                Var q , r : halfword ;
                Begin
                  q := getavail ;
                  r := getavail ;
                  mem [ q ] . hh . rh := r ;
                  mem [ q ] . hh . lh := p ;
                  mem [ r ] . hh . lh := stashcurexp ;
                  macrocall ( c , q , n ) ;
                End ;
                Procedure materializepen ;

                Label 50 ;

                Var aminusb , aplusb , majoraxis , minoraxis : scaled ;
                  theta : angle ;
                  p : halfword ;
                  q : halfword ;
                Begin
                  q := curexp ;
                  If mem [ q ] . hh . b0 = 0 Then
                    Begin
                      Begin
                        If interaction = 3 Then ;
                        printnl ( 261 ) ;
                        print ( 806 ) ;
                      End ;
                      Begin
                        helpptr := 2 ;
                        helpline [ 1 ] := 807 ;
                        helpline [ 0 ] := 575 ;
                      End ;
                      putgeterror ;
                      curexp := 3 ;
                      goto 50 ;
                    End
                  Else If mem [ q ] . hh . b0 = 4 Then
                         Begin
                           tx := mem [ q + 1 ] . int ;
                           ty := mem [ q + 2 ] . int ;
                           txx := mem [ q + 3 ] . int - tx ;
                           tyx := mem [ q + 4 ] . int - ty ;
                           txy := mem [ q + 5 ] . int - tx ;
                           tyy := mem [ q + 6 ] . int - ty ;
                           aminusb := pythadd ( txx - tyy , tyx + txy ) ;
                           aplusb := pythadd ( txx + tyy , tyx - txy ) ;
                           majoraxis := ( aminusb + aplusb ) Div 2 ;
                           minoraxis := ( abs ( aplusb - aminusb ) ) Div 2 ;
                           If majoraxis = minoraxis Then theta := 0
                           Else theta := ( narg ( txx - tyy , tyx + txy ) + narg ( txx + tyy , tyx - txy ) ) Div 2 ;
                           freenode ( q , 7 ) ;
                           q := makeellipse ( majoraxis , minoraxis , theta ) ;
                           If ( tx <> 0 ) Or ( ty <> 0 ) Then
                             Begin
                               p := q ;
                               Repeat
                                 mem [ p + 1 ] . int := mem [ p + 1 ] . int + tx ;
                                 mem [ p + 2 ] . int := mem [ p + 2 ] . int + ty ;
                                 p := mem [ p ] . hh . rh ;
                               Until p = q ;
                             End ;
                         End ;
                  curexp := makepen ( q ) ;
                  50 : tossknotlist ( q ) ;
                  curtype := 6 ;
                End ;
                Procedure knownpair ;

                Var p : halfword ;
                Begin
                  If curtype <> 14 Then
                    Begin
                      disperr ( 0 , 809 ) ;
                      Begin
                        helpptr := 5 ;
                        helpline [ 4 ] := 810 ;
                        helpline [ 3 ] := 811 ;
                        helpline [ 2 ] := 812 ;
                        helpline [ 1 ] := 813 ;
                        helpline [ 0 ] := 814 ;
                      End ;
                      putgetflusherror ( 0 ) ;
                      curx := 0 ;
                      cury := 0 ;
                    End
                  Else
                    Begin
                      p := mem [ curexp + 1 ] . int ;
                      If mem [ p ] . hh . b0 = 16 Then curx := mem [ p + 1 ] . int
                      Else
                        Begin
                          disperr ( p , 815 ) ;
                          Begin
                            helpptr := 5 ;
                            helpline [ 4 ] := 816 ;
                            helpline [ 3 ] := 811 ;
                            helpline [ 2 ] := 812 ;
                            helpline [ 1 ] := 813 ;
                            helpline [ 0 ] := 814 ;
                          End ;
                          putgeterror ;
                          recyclevalue ( p ) ;
                          curx := 0 ;
                        End ;
                      If mem [ p + 2 ] . hh . b0 = 16 Then cury := mem [ p + 3 ] . int
                      Else
                        Begin
                          disperr ( p + 2 , 817 ) ;
                          Begin
                            helpptr := 5 ;
                            helpline [ 4 ] := 818 ;
                            helpline [ 3 ] := 811 ;
                            helpline [ 2 ] := 812 ;
                            helpline [ 1 ] := 813 ;
                            helpline [ 0 ] := 814 ;
                          End ;
                          putgeterror ;
                          recyclevalue ( p + 2 ) ;
                          cury := 0 ;
                        End ;
                      flushcurexp ( 0 ) ;
                    End ;
                End ;
                Function newknot : halfword ;

                Var q : halfword ;
                Begin
                  q := getnode ( 7 ) ;
                  mem [ q ] . hh . b0 := 0 ;
                  mem [ q ] . hh . b1 := 0 ;
                  mem [ q ] . hh . rh := q ;
                  knownpair ;
                  mem [ q + 1 ] . int := curx ;
                  mem [ q + 2 ] . int := cury ;
                  newknot := q ;
                End ;
                Function scandirection : smallnumber ;

                Var t : 2 .. 4 ;
                  x : scaled ;
                Begin
                  getxnext ;
                  If curcmd = 60 Then
                    Begin
                      getxnext ;
                      scanexpression ;
                      If ( curtype <> 16 ) Or ( curexp < 0 ) Then
                        Begin
                          disperr ( 0 , 821 ) ;
                          Begin
                            helpptr := 1 ;
                            helpline [ 0 ] := 822 ;
                          End ;
                          putgetflusherror ( 65536 ) ;
                        End ;
                      t := 3 ;
                    End
                  Else
                    Begin
                      scanexpression ;
                      If curtype > 14 Then
                        Begin
                          If curtype <> 16 Then
                            Begin
                              disperr ( 0 , 815 ) ;
                              Begin
                                helpptr := 5 ;
                                helpline [ 4 ] := 816 ;
                                helpline [ 3 ] := 811 ;
                                helpline [ 2 ] := 812 ;
                                helpline [ 1 ] := 813 ;
                                helpline [ 0 ] := 814 ;
                              End ;
                              putgetflusherror ( 0 ) ;
                            End ;
                          x := curexp ;
                          If curcmd <> 82 Then
                            Begin
                              missingerr ( 44 ) ;
                              Begin
                                helpptr := 2 ;
                                helpline [ 1 ] := 823 ;
                                helpline [ 0 ] := 824 ;
                              End ;
                              backerror ;
                            End ;
                          getxnext ;
                          scanexpression ;
                          If curtype <> 16 Then
                            Begin
                              disperr ( 0 , 817 ) ;
                              Begin
                                helpptr := 5 ;
                                helpline [ 4 ] := 818 ;
                                helpline [ 3 ] := 811 ;
                                helpline [ 2 ] := 812 ;
                                helpline [ 1 ] := 813 ;
                                helpline [ 0 ] := 814 ;
                              End ;
                              putgetflusherror ( 0 ) ;
                            End ;
                          cury := curexp ;
                          curx := x ;
                        End
                      Else knownpair ;
                      If ( curx = 0 ) And ( cury = 0 ) Then t := 4
                      Else
                        Begin
                          t := 2 ;
                          curexp := narg ( curx , cury ) ;
                        End ;
                    End ;
                  If curcmd <> 65 Then
                    Begin
                      missingerr ( 125 ) ;
                      Begin
                        helpptr := 3 ;
                        helpline [ 2 ] := 819 ;
                        helpline [ 1 ] := 820 ;
                        helpline [ 0 ] := 697 ;
                      End ;
                      backerror ;
                    End ;
                  getxnext ;
                  scandirection := t ;
                End ;
                Procedure donullary ( c : quarterword ) ;

                Var k : integer ;
                Begin
                  Begin
                    If aritherror Then cleararith ;
                  End ;
                  If internal [ 7 ] > 131072 Then showcmdmod ( 33 , c ) ;
                  Case c Of 
                    30 , 31 :
                              Begin
                                curtype := 2 ;
                                curexp := c ;
                              End ;
                    32 :
                         Begin
                           curtype := 11 ;
                           curexp := getnode ( 6 ) ;
                           initedges ( curexp ) ;
                         End ;
                    33 :
                         Begin
                           curtype := 6 ;
                           curexp := 3 ;
                         End ;
                    37 :
                         Begin
                           curtype := 16 ;
                           curexp := normrand ;
                         End ;
                    36 :
                         Begin
                           curtype := 8 ;
                           curexp := getnode ( 7 ) ;
                           mem [ curexp ] . hh . b0 := 4 ;
                           mem [ curexp ] . hh . b1 := 4 ;
                           mem [ curexp ] . hh . rh := curexp ;
                           mem [ curexp + 1 ] . int := 0 ;
                           mem [ curexp + 2 ] . int := 0 ;
                           mem [ curexp + 3 ] . int := 65536 ;
                           mem [ curexp + 4 ] . int := 0 ;
                           mem [ curexp + 5 ] . int := 0 ;
                           mem [ curexp + 6 ] . int := 65536 ;
                         End ;
                    34 :
                         Begin
                           If jobname = 0 Then openlogfile ;
                           curtype := 4 ;
                           curexp := jobname ;
                         End ;
                    35 :
                         Begin
                           If interaction <= 1 Then fatalerror ( 835 ) ;
                           beginfilereading ;
                           curinput . namefield := 1 ;
                           Begin ;
                             print ( 285 ) ;
                             terminput ;
                           End ;
                           Begin
                             If poolptr + last - curinput . startfield > maxpoolptr Then
                               Begin
                                 If poolptr + last - curinput . startfield > poolsize Then overflow ( 257 , poolsize - initpoolptr ) ;
                                 maxpoolptr := poolptr + last - curinput . startfield ;
                               End ;
                           End ;
                           For k := curinput . startfield To last - 1 Do
                             Begin
                               strpool [ poolptr ] := buffer [ k ] ;
                               poolptr := poolptr + 1 ;
                             End ;
                           endfilereading ;
                           curtype := 4 ;
                           curexp := makestring ;
                         End ;
                  End ;
                  Begin
                    If aritherror Then cleararith ;
                  End ;
                End ;
                Function nicepair ( p : integer ; t : quarterword ) : boolean ;

                Label 10 ;
                Begin
                  If t = 14 Then
                    Begin
                      p := mem [ p + 1 ] . int ;
                      If mem [ p ] . hh . b0 = 16 Then If mem [ p + 2 ] . hh . b0 = 16 Then
                                                         Begin
                                                           nicepair := true ;
                                                           goto 10 ;
                                                         End ;
                    End ;
                  nicepair := false ;
                  10 :
                End ;
                Procedure printknownorunknowntype ( t : smallnumber ; v : integer ) ;
                Begin
                  printchar ( 40 ) ;
                  If t < 17 Then If t <> 14 Then printtype ( t )
                  Else If nicepair ( v , 14 ) Then print ( 337 )
                  Else print ( 836 )
                  Else print ( 837 ) ;
                  printchar ( 41 ) ;
                End ;
                Procedure badunary ( c : quarterword ) ;
                Begin
                  disperr ( 0 , 838 ) ;
                  printop ( c ) ;
                  printknownorunknowntype ( curtype , curexp ) ;
                  Begin
                    helpptr := 3 ;
                    helpline [ 2 ] := 839 ;
                    helpline [ 1 ] := 840 ;
                    helpline [ 0 ] := 841 ;
                  End ;
                  putgeterror ;
                End ;
                Procedure negatedeplist ( p : halfword ) ;

                Label 10 ;
                Begin
                  While true Do
                    Begin
                      mem [ p + 1 ] . int := - mem [ p + 1 ] . int ;
                      If mem [ p ] . hh . lh = 0 Then goto 10 ;
                      p := mem [ p ] . hh . rh ;
                    End ;
                  10 :
                End ;
                Procedure pairtopath ;
                Begin
                  curexp := newknot ;
                  curtype := 9 ;
                End ;
                Procedure takepart ( c : quarterword ) ;

                Var p : halfword ;
                Begin
                  p := mem [ curexp + 1 ] . int ;
                  mem [ 18 ] . int := p ;
                  mem [ 17 ] . hh . b0 := curtype ;
                  mem [ p ] . hh . rh := 17 ;
                  freenode ( curexp , 2 ) ;
                  makeexpcopy ( p + 2 * ( c - 53 ) ) ;
                  recyclevalue ( 17 ) ;
                End ;
                Procedure strtonum ( c : quarterword ) ;

                Var n : integer ;
                  m : ASCIIcode ;
                  k : poolpointer ;
                  b : 8 .. 16 ;
                  badchar : boolean ;
                Begin
                  If c = 49 Then If ( strstart [ curexp + 1 ] - strstart [ curexp ] ) = 0 Then n := - 1
                  Else n := strpool [ strstart [ curexp ] ]
                  Else
                    Begin
                      If c = 47 Then b := 8
                      Else b := 16 ;
                      n := 0 ;
                      badchar := false ;
                      For k := strstart [ curexp ] To strstart [ curexp + 1 ] - 1 Do
                        Begin
                          m := strpool [ k ] ;
                          If ( m >= 48 ) And ( m <= 57 ) Then m := m - 48
                          Else If ( m >= 65 ) And ( m <= 70 ) Then m := m - 55
                          Else If ( m >= 97 ) And ( m <= 102 ) Then m := m - 87
                          Else
                            Begin
                              badchar := true ;
                              m := 0 ;
                            End ;
                          If m >= b Then
                            Begin
                              badchar := true ;
                              m := 0 ;
                            End ;
                          If n < 32768 Div b Then n := n * b + m
                          Else n := 32767 ;
                        End ;
                      If badchar Then
                        Begin
                          disperr ( 0 , 843 ) ;
                          If c = 47 Then
                            Begin
                              helpptr := 1 ;
                              helpline [ 0 ] := 844 ;
                            End
                          Else
                            Begin
                              helpptr := 1 ;
                              helpline [ 0 ] := 845 ;
                            End ;
                          putgeterror ;
                        End ;
                      If n > 4095 Then
                        Begin
                          Begin
                            If interaction = 3 Then ;
                            printnl ( 261 ) ;
                            print ( 846 ) ;
                          End ;
                          printint ( n ) ;
                          printchar ( 41 ) ;
                          Begin
                            helpptr := 1 ;
                            helpline [ 0 ] := 847 ;
                          End ;
                          putgeterror ;
                        End ;
                    End ;
                  flushcurexp ( n * 65536 ) ;
                End ;
                Function pathlength : scaled ;

                Var n : scaled ;
                  p : halfword ;
                Begin
                  p := curexp ;
                  If mem [ p ] . hh . b0 = 0 Then n := - 65536
                  Else n := 0 ;
                  Repeat
                    p := mem [ p ] . hh . rh ;
                    n := n + 65536 ;
                  Until p = curexp ;
                  pathlength := n ;
                End ;
                Procedure testknown ( c : quarterword ) ;

                Label 30 ;

                Var b : 30 .. 31 ;
                  p , q : halfword ;
                Begin
                  b := 31 ;
                  Case curtype Of 
                    1 , 2 , 4 , 6 , 8 , 9 , 11 , 16 : b := 30 ;
                    13 , 14 :
                              Begin
                                p := mem [ curexp + 1 ] . int ;
                                q := p + bignodesize [ curtype ] ;
                                Repeat
                                  q := q - 2 ;
                                  If mem [ q ] . hh . b0 <> 16 Then goto 30 ;
                                Until q = p ;
                                b := 30 ;
                                30 :
                              End ;
                    others :
                  End ;
                  If c = 39 Then flushcurexp ( b )
                  Else flushcurexp ( 61 - b ) ;
                  curtype := 2 ;
                End ;
                Procedure dounary ( c : quarterword ) ;

                Var p , q : halfword ;
                  x : integer ;
                Begin
                  Begin
                    If aritherror Then cleararith ;
                  End ;
                  If internal [ 7 ] > 131072 Then
                    Begin
                      begindiagnostic ;
                      printnl ( 123 ) ;
                      printop ( c ) ;
                      printchar ( 40 ) ;
                      printexp ( 0 , 0 ) ;
                      print ( 842 ) ;
                      enddiagnostic ( false ) ;
                    End ;
                  Case c Of 
                    69 : If curtype < 14 Then If curtype <> 11 Then badunary ( 69 ) ;
                    70 : Case curtype Of 
                           14 , 19 :
                                     Begin
                                       q := curexp ;
                                       makeexpcopy ( q ) ;
                                       If curtype = 17 Then negatedeplist ( mem [ curexp + 1 ] . hh . rh )
                                       Else If curtype = 14 Then
                                              Begin
                                                p := mem [ curexp + 1 ] . int ;
                                                If mem [ p ] . hh . b0 = 16 Then mem [ p + 1 ] . int := - mem [ p + 1 ] . int
                                                Else negatedeplist ( mem [ p + 1 ] . hh . rh ) ;
                                                If mem [ p + 2 ] . hh . b0 = 16 Then mem [ p + 3 ] . int := - mem [ p + 3 ] . int
                                                Else negatedeplist ( mem [ p + 3 ] . hh . rh ) ;
                                              End ;
                                       recyclevalue ( q ) ;
                                       freenode ( q , 2 ) ;
                                     End ;
                           17 , 18 : negatedeplist ( mem [ curexp + 1 ] . hh . rh ) ;
                           16 : curexp := - curexp ;
                           11 : negateedges ( curexp ) ;
                           others : badunary ( 70 )
                         End ;
                    41 : If curtype <> 2 Then badunary ( 41 )
                         Else curexp := 61 - curexp ;
                    59 , 60 , 61 , 62 , 63 , 64 , 65 , 38 , 66 : If curtype <> 16 Then badunary ( c )
                                                                 Else Case c Of 
                                                                        59 : curexp := squarert ( curexp ) ;
                                                                        60 : curexp := mexp ( curexp ) ;
                                                                        61 : curexp := mlog ( curexp ) ;
                                                                        62 , 63 :
                                                                                  Begin
                                                                                    nsincos ( ( curexp Mod 23592960 ) * 16 ) ;
                                                                                    If c = 62 Then curexp := roundfraction ( nsin )
                                                                                    Else curexp := roundfraction ( ncos ) ;
                                                                                  End ;
                                                                        64 : curexp := floorscaled ( curexp ) ;
                                                                        65 : curexp := unifrand ( curexp ) ;
                                                                        38 :
                                                                             Begin
                                                                               If odd ( roundunscaled ( curexp ) ) Then curexp := 30
                                                                               Else curexp := 31 ;
                                                                               curtype := 2 ;
                                                                             End ;
                                                                        66 :
                                                                             Begin
                                                                               curexp := roundunscaled ( curexp ) Mod 256 ;
                                                                               If curexp < 0 Then curexp := curexp + 256 ;
                                                                               If charexists [ curexp ] Then curexp := 30
                                                                               Else curexp := 31 ;
                                                                               curtype := 2 ;
                                                                             End ;
                                                                   End ;
                    67 : If nicepair ( curexp , curtype ) Then
                           Begin
                             p := mem [ curexp + 1 ] . int ;
                             x := narg ( mem [ p + 1 ] . int , mem [ p + 3 ] . int ) ;
                             If x >= 0 Then flushcurexp ( ( x + 8 ) div 16 )
                             Else flushcurexp ( - ( ( - x + 8 ) div 16 ) ) ;
                           End
                         Else badunary ( 67 ) ;
                    53 , 54 : If ( curtype <= 14 ) And ( curtype >= 13 ) Then takepart ( c )
                              Else badunary ( c ) ;
                    55 , 56 , 57 , 58 : If curtype = 13 Then takepart ( c )
                                        Else badunary ( c ) ;
                    50 : If curtype <> 16 Then badunary ( 50 )
                         Else
                           Begin
                             curexp := roundunscaled ( curexp ) Mod 256 ;
                             curtype := 4 ;
                             If curexp < 0 Then curexp := curexp + 256 ;
                             If ( strstart [ curexp + 1 ] - strstart [ curexp ] ) <> 1 Then
                               Begin
                                 Begin
                                   If poolptr + 1 > maxpoolptr Then
                                     Begin
                                       If poolptr + 1 > poolsize Then overflow ( 257 , poolsize - initpoolptr ) ;
                                       maxpoolptr := poolptr + 1 ;
                                     End ;
                                 End ;
                                 Begin
                                   strpool [ poolptr ] := curexp ;
                                   poolptr := poolptr + 1 ;
                                 End ;
                                 curexp := makestring ;
                               End ;
                           End ;
                    42 : If curtype <> 16 Then badunary ( 42 )
                         Else
                           Begin
                             oldsetting := selector ;
                             selector := 5 ;
                             printscaled ( curexp ) ;
                             curexp := makestring ;
                             selector := oldsetting ;
                             curtype := 4 ;
                           End ;
                    47 , 48 , 49 : If curtype <> 4 Then badunary ( c )
                                   Else strtonum ( c ) ;
                    51 : If curtype = 4 Then flushcurexp ( ( strstart [ curexp + 1 ] - strstart [ curexp ] ) * 65536 )
                         Else If curtype = 9 Then flushcurexp ( pathlength )
                         Else If curtype = 16 Then curexp := abs ( curexp )
                         Else If nicepair ( curexp , curtype ) Then flushcurexp ( pythadd ( mem [ mem [ curexp + 1 ] . int + 1 ] . int , mem [ mem [ curexp + 1 ] . int + 3 ] . int ) )
                         Else badunary ( c ) ;
                    52 : If curtype = 14 Then flushcurexp ( 0 )
                         Else If curtype <> 9 Then badunary ( 52 )
                         Else If mem [ curexp ] . hh . b0 = 0 Then flushcurexp ( 0 )
                         Else
                           Begin
                             curpen := 3 ;
                             curpathtype := 1 ;
                             curexp := makespec ( curexp , - 1879080960 , 0 ) ;
                             flushcurexp ( turningnumber * 65536 ) ;
                           End ;
                    2 :
                        Begin
                          If ( curtype >= 2 ) And ( curtype <= 3 ) Then flushcurexp ( 30 )
                          Else flushcurexp ( 31 ) ;
                          curtype := 2 ;
                        End ;
                    4 :
                        Begin
                          If ( curtype >= 4 ) And ( curtype <= 5 ) Then flushcurexp ( 30 )
                          Else flushcurexp ( 31 ) ;
                          curtype := 2 ;
                        End ;
                    6 :
                        Begin
                          If ( curtype >= 6 ) And ( curtype <= 8 ) Then flushcurexp ( 30 )
                          Else flushcurexp ( 31 ) ;
                          curtype := 2 ;
                        End ;
                    9 :
                        Begin
                          If ( curtype >= 9 ) And ( curtype <= 10 ) Then flushcurexp ( 30 )
                          Else flushcurexp ( 31 ) ;
                          curtype := 2 ;
                        End ;
                    11 :
                         Begin
                           If ( curtype >= 11 ) And ( curtype <= 12 ) Then flushcurexp ( 30 )
                           Else flushcurexp ( 31 ) ;
                           curtype := 2 ;
                         End ;
                    13 , 14 :
                              Begin
                                If curtype = c Then flushcurexp ( 30 )
                                Else flushcurexp ( 31 ) ;
                                curtype := 2 ;
                              End ;
                    15 :
                         Begin
                           If ( curtype >= 16 ) And ( curtype <= 19 ) Then flushcurexp ( 30 )
                           Else flushcurexp ( 31 ) ;
                           curtype := 2 ;
                         End ;
                    39 , 40 : testknown ( c ) ;
                    68 :
                         Begin
                           If curtype <> 9 Then flushcurexp ( 31 )
                           Else If mem [ curexp ] . hh . b0 <> 0 Then flushcurexp ( 30 )
                           Else flushcurexp ( 31 ) ;
                           curtype := 2 ;
                         End ;
                    45 :
                         Begin
                           If curtype = 14 Then pairtopath ;
                           If curtype = 9 Then curtype := 8
                           Else badunary ( 45 ) ;
                         End ;
                    44 :
                         Begin
                           If curtype = 8 Then materializepen ;
                           If curtype <> 6 Then badunary ( 44 )
                           Else
                             Begin
                               flushcurexp ( makepath ( curexp ) ) ;
                               curtype := 9 ;
                             End ;
                         End ;
                    46 : If curtype <> 11 Then badunary ( 46 )
                         Else flushcurexp ( totalweight ( curexp ) ) ;
                    43 : If curtype = 9 Then
                           Begin
                             p := htapypoc ( curexp ) ;
                             If mem [ p ] . hh . b1 = 0 Then p := mem [ p ] . hh . rh ;
                             tossknotlist ( curexp ) ;
                             curexp := p ;
                           End
                         Else If curtype = 14 Then pairtopath
                         Else badunary ( 43 ) ;
                  End ;
                  Begin
                    If aritherror Then cleararith ;
                  End ;
                End ;
                Procedure badbinary ( p : halfword ; c : quarterword ) ;
                Begin
                  disperr ( p , 285 ) ;
                  disperr ( 0 , 838 ) ;
                  If c >= 94 Then printop ( c ) ;
                  printknownorunknowntype ( mem [ p ] . hh . b0 , p ) ;
                  If c >= 94 Then print ( 479 )
                  Else printop ( c ) ;
                  printknownorunknowntype ( curtype , curexp ) ;
                  Begin
                    helpptr := 3 ;
                    helpline [ 2 ] := 839 ;
                    helpline [ 1 ] := 848 ;
                    helpline [ 0 ] := 849 ;
                  End ;
                  putgeterror ;
                End ;
                Function tarnished ( p : halfword ) : halfword ;

                Label 10 ;

                Var q : halfword ;
                  r : halfword ;
                Begin
                  q := mem [ p + 1 ] . int ;
                  r := q + bignodesize [ mem [ p ] . hh . b0 ] ;
                  Repeat
                    r := r - 2 ;
                    If mem [ r ] . hh . b0 = 19 Then
                      Begin
                        tarnished := 1 ;
                        goto 10 ;
                      End ;
                  Until r = q ;
                  tarnished := 0 ;
                  10 :
                End ;
                Procedure depfinish ( v , q : halfword ; t : smallnumber ) ;

                Var p : halfword ;
                  vv : scaled ;
                Begin
                  If q = 0 Then p := curexp
                  Else p := q ;
                  mem [ p + 1 ] . hh . rh := v ;
                  mem [ p ] . hh . b0 := t ;
                  If mem [ v ] . hh . lh = 0 Then
                    Begin
                      vv := mem [ v + 1 ] . int ;
                      If q = 0 Then flushcurexp ( vv )
                      Else
                        Begin
                          recyclevalue ( p ) ;
                          mem [ q ] . hh . b0 := 16 ;
                          mem [ q + 1 ] . int := vv ;
                        End ;
                    End
                  Else If q = 0 Then curtype := t ;
                  If fixneeded Then fixdependencies ;
                End ;
                Procedure addorsubtract ( p , q : halfword ; c : quarterword ) ;

                Label 30 , 10 ;

                Var s , t : smallnumber ;
                  r : halfword ;
                  v : integer ;
                Begin
                  If q = 0 Then
                    Begin
                      t := curtype ;
                      If t < 17 Then v := curexp
                      Else v := mem [ curexp + 1 ] . hh . rh ;
                    End
                  Else
                    Begin
                      t := mem [ q ] . hh . b0 ;
                      If t < 17 Then v := mem [ q + 1 ] . int
                      Else v := mem [ q + 1 ] . hh . rh ;
                    End ;
                  If t = 16 Then
                    Begin
                      If c = 70 Then v := - v ;
                      If mem [ p ] . hh . b0 = 16 Then
                        Begin
                          v := slowadd ( mem [ p + 1 ] . int , v ) ;
                          If q = 0 Then curexp := v
                          Else mem [ q + 1 ] . int := v ;
                          goto 10 ;
                        End ;
                      r := mem [ p + 1 ] . hh . rh ;
                      While mem [ r ] . hh . lh <> 0 Do
                        r := mem [ r ] . hh . rh ;
                      mem [ r + 1 ] . int := slowadd ( mem [ r + 1 ] . int , v ) ;
                      If q = 0 Then
                        Begin
                          q := getnode ( 2 ) ;
                          curexp := q ;
                          curtype := mem [ p ] . hh . b0 ;
                          mem [ q ] . hh . b1 := 11 ;
                        End ;
                      mem [ q + 1 ] . hh . rh := mem [ p + 1 ] . hh . rh ;
                      mem [ q ] . hh . b0 := mem [ p ] . hh . b0 ;
                      mem [ q + 1 ] . hh . lh := mem [ p + 1 ] . hh . lh ;
                      mem [ mem [ p + 1 ] . hh . lh ] . hh . rh := q ;
                      mem [ p ] . hh . b0 := 16 ; ;
                    End
                  Else
                    Begin
                      If c = 70 Then negatedeplist ( v ) ;
                      If mem [ p ] . hh . b0 = 16 Then
                        Begin
                          While mem [ v ] . hh . lh <> 0 Do
                            v := mem [ v ] . hh . rh ;
                          mem [ v + 1 ] . int := slowadd ( mem [ p + 1 ] . int , mem [ v + 1 ] . int ) ;
                        End
                      Else
                        Begin
                          s := mem [ p ] . hh . b0 ;
                          r := mem [ p + 1 ] . hh . rh ;
                          If t = 17 Then
                            Begin
                              If s = 17 Then If maxcoef ( r ) + maxcoef ( v ) < 626349397 Then
                                               Begin
                                                 v := pplusq ( v , r , 17 ) ;
                                                 goto 30 ;
                                               End ;
                              t := 18 ;
                              v := poverv ( v , 65536 , 17 , 18 ) ;
                            End ;
                          If s = 18 Then v := pplusq ( v , r , 18 )
                          Else v := pplusfq ( v , 65536 , r , 18 , 17 ) ;
                          30 : If q <> 0 Then depfinish ( v , q , t )
                               Else
                                 Begin
                                   curtype := t ;
                                   depfinish ( v , 0 , t ) ;
                                 End ;
                        End ;
                    End ;
                  10 :
                End ;
                Procedure depmult ( p : halfword ; v : integer ; visscaled : boolean ) ;

                Label 10 ;

                Var q : halfword ;
                  s , t : smallnumber ;
                Begin
                  If p = 0 Then q := curexp
                  Else If mem [ p ] . hh . b0 <> 16 Then q := p
                  Else
                    Begin
                      If visscaled Then mem [ p + 1 ] . int := takescaled ( mem [ p + 1 ] . int , v )
                      Else mem [ p + 1 ] . int := takefraction ( mem [ p + 1 ] . int , v ) ;
                      goto 10 ;
                    End ;
                  t := mem [ q ] . hh . b0 ;
                  q := mem [ q + 1 ] . hh . rh ;
                  s := t ;
                  If t = 17 Then If visscaled Then If abvscd ( maxcoef ( q ) , abs ( v ) , 626349396 , 65536 ) >= 0 Then t := 18 ;
                  q := ptimesv ( q , v , s , t , visscaled ) ;
                  depfinish ( q , p , t ) ;
                  10 :
                End ;
                Procedure hardtimes ( p : halfword ) ;

                Var q : halfword ;
                  r : halfword ;
                  u , v : scaled ;
                Begin
                  If mem [ p ] . hh . b0 = 14 Then
                    Begin
                      q := stashcurexp ;
                      unstashcurexp ( p ) ;
                      p := q ;
                    End ;
                  r := mem [ curexp + 1 ] . int ;
                  u := mem [ r + 1 ] . int ;
                  v := mem [ r + 3 ] . int ;
                  mem [ r + 2 ] . hh . b0 := mem [ p ] . hh . b0 ;
                  newdep ( r + 2 , copydeplist ( mem [ p + 1 ] . hh . rh ) ) ;
                  mem [ r ] . hh . b0 := mem [ p ] . hh . b0 ;
                  mem [ r + 1 ] := mem [ p + 1 ] ;
                  mem [ mem [ p + 1 ] . hh . lh ] . hh . rh := r ;
                  freenode ( p , 2 ) ;
                  depmult ( r , u , true ) ;
                  depmult ( r + 2 , v , true ) ;
                End ;
                Procedure depdiv ( p : halfword ; v : scaled ) ;

                Label 10 ;

                Var q : halfword ;
                  s , t : smallnumber ;
                Begin
                  If p = 0 Then q := curexp
                  Else If mem [ p ] . hh . b0 <> 16 Then q := p
                  Else
                    Begin
                      mem [ p + 1 ] . int := makescaled ( mem [ p + 1 ] . int , v ) ;
                      goto 10 ;
                    End ;
                  t := mem [ q ] . hh . b0 ;
                  q := mem [ q + 1 ] . hh . rh ;
                  s := t ;
                  If t = 17 Then If abvscd ( maxcoef ( q ) , 65536 , 626349396 , abs ( v ) ) >= 0 Then t := 18 ;
                  q := poverv ( q , v , s , t ) ;
                  depfinish ( q , p , t ) ;
                  10 :
                End ;
                Procedure setuptrans ( c : quarterword ) ;

                Label 30 , 10 ;

                Var p , q , r : halfword ;
                Begin
                  If ( c <> 88 ) Or ( curtype <> 13 ) Then
                    Begin
                      p := stashcurexp ;
                      curexp := idtransform ;
                      curtype := 13 ;
                      q := mem [ curexp + 1 ] . int ;
                      Case c Of 
                        84 : If mem [ p ] . hh . b0 = 16 Then
                               Begin
                                 nsincos ( ( mem [ p + 1 ] . int Mod 23592960 ) * 16 ) ;
                                 mem [ q + 5 ] . int := roundfraction ( ncos ) ;
                                 mem [ q + 9 ] . int := roundfraction ( nsin ) ;
                                 mem [ q + 7 ] . int := - mem [ q + 9 ] . int ;
                                 mem [ q + 11 ] . int := mem [ q + 5 ] . int ;
                                 goto 30 ;
                               End ;
                        85 : If mem [ p ] . hh . b0 > 14 Then
                               Begin
                                 install ( q + 6 , p ) ;
                                 goto 30 ;
                               End ;
                        86 : If mem [ p ] . hh . b0 > 14 Then
                               Begin
                                 install ( q + 4 , p ) ;
                                 install ( q + 10 , p ) ;
                                 goto 30 ;
                               End ;
                        87 : If mem [ p ] . hh . b0 = 14 Then
                               Begin
                                 r := mem [ p + 1 ] . int ;
                                 install ( q , r ) ;
                                 install ( q + 2 , r + 2 ) ;
                                 goto 30 ;
                               End ;
                        89 : If mem [ p ] . hh . b0 > 14 Then
                               Begin
                                 install ( q + 4 , p ) ;
                                 goto 30 ;
                               End ;
                        90 : If mem [ p ] . hh . b0 > 14 Then
                               Begin
                                 install ( q + 10 , p ) ;
                                 goto 30 ;
                               End ;
                        91 : If mem [ p ] . hh . b0 = 14 Then
                               Begin
                                 r := mem [ p + 1 ] . int ;
                                 install ( q + 4 , r ) ;
                                 install ( q + 10 , r ) ;
                                 install ( q + 8 , r + 2 ) ;
                                 If mem [ r + 2 ] . hh . b0 = 16 Then mem [ r + 3 ] . int := - mem [ r + 3 ] . int
                                 Else negatedeplist ( mem [ r + 3 ] . hh . rh ) ;
                                 install ( q + 6 , r + 2 ) ;
                                 goto 30 ;
                               End ;
                        88 : ;
                      End ;
                      disperr ( p , 858 ) ;
                      Begin
                        helpptr := 3 ;
                        helpline [ 2 ] := 859 ;
                        helpline [ 1 ] := 860 ;
                        helpline [ 0 ] := 538 ;
                      End ;
                      putgeterror ;
                      30 : recyclevalue ( p ) ;
                      freenode ( p , 2 ) ;
                    End ;
                  q := mem [ curexp + 1 ] . int ;
                  r := q + 12 ;
                  Repeat
                    r := r - 2 ;
                    If mem [ r ] . hh . b0 <> 16 Then goto 10 ;
                  Until r = q ;
                  txx := mem [ q + 5 ] . int ;
                  txy := mem [ q + 7 ] . int ;
                  tyx := mem [ q + 9 ] . int ;
                  tyy := mem [ q + 11 ] . int ;
                  tx := mem [ q + 1 ] . int ;
                  ty := mem [ q + 3 ] . int ;
                  flushcurexp ( 0 ) ;
                  10 :
                End ;
                Procedure setupknowntrans ( c : quarterword ) ;
                Begin
                  setuptrans ( c ) ;
                  If curtype <> 16 Then
                    Begin
                      disperr ( 0 , 861 ) ;
                      Begin
                        helpptr := 3 ;
                        helpline [ 2 ] := 862 ;
                        helpline [ 1 ] := 863 ;
                        helpline [ 0 ] := 538 ;
                      End ;
                      putgetflusherror ( 0 ) ;
                      txx := 65536 ;
                      txy := 0 ;
                      tyx := 0 ;
                      tyy := 65536 ;
                      tx := 0 ;
                      ty := 0 ;
                    End ;
                End ;
                Procedure trans ( p , q : halfword ) ;

                Var v : scaled ;
                Begin
                  v := takescaled ( mem [ p ] . int , txx ) + takescaled ( mem [ q ] . int , txy ) + tx ;
                  mem [ q ] . int := takescaled ( mem [ p ] . int , tyx ) + takescaled ( mem [ q ] . int , tyy ) + ty ;
                  mem [ p ] . int := v ;
                End ;
                Procedure pathtrans ( p : halfword ; c : quarterword ) ;

                Label 10 ;

                Var q : halfword ;
                Begin
                  setupknowntrans ( c ) ;
                  unstashcurexp ( p ) ;
                  If curtype = 6 Then
                    Begin
                      If mem [ curexp + 9 ] . int = 0 Then If tx = 0 Then If ty = 0 Then goto 10 ;
                      flushcurexp ( makepath ( curexp ) ) ;
                      curtype := 8 ;
                    End ;
                  q := curexp ;
                  Repeat
                    If mem [ q ] . hh . b0 <> 0 Then trans ( q + 3 , q + 4 ) ;
                    trans ( q + 1 , q + 2 ) ;
                    If mem [ q ] . hh . b1 <> 0 Then trans ( q + 5 , q + 6 ) ;
                    q := mem [ q ] . hh . rh ;
                  Until q = curexp ;
                  10 :
                End ;
                Procedure edgestrans ( p : halfword ; c : quarterword ) ;

                Label 10 ;
                Begin
                  setupknowntrans ( c ) ;
                  unstashcurexp ( p ) ;
                  curedges := curexp ;
                  If mem [ curedges ] . hh . rh = curedges Then goto 10 ;
                  If txx = 0 Then If tyy = 0 Then If txy Mod 65536 = 0 Then If tyx Mod 65536 = 0 Then
                                                                              Begin
                                                                                xyswapedges ;
                                                                                txx := txy ;
                                                                                tyy := tyx ;
                                                                                txy := 0 ;
                                                                                tyx := 0 ;
                                                                                If mem [ curedges ] . hh . rh = curedges Then goto 10 ;
                                                                              End ;
                  If txy = 0 Then If tyx = 0 Then If txx Mod 65536 = 0 Then If tyy Mod 65536 = 0 Then
                                                                              Begin
                                                                                If ( txx = 0 ) Or ( tyy = 0 ) Then
                                                                                  Begin
                                                                                    tossedges ( curedges ) ;
                                                                                    curexp := getnode ( 6 ) ;
                                                                                    initedges ( curexp ) ;
                                                                                  End
                                                                                Else
                                                                                  Begin
                                                                                    If txx < 0 Then
                                                                                      Begin
                                                                                        xreflectedges ;
                                                                                        txx := - txx ;
                                                                                      End ;
                                                                                    If tyy < 0 Then
                                                                                      Begin
                                                                                        yreflectedges ;
                                                                                        tyy := - tyy ;
                                                                                      End ;
                                                                                    If txx <> 65536 Then xscaleedges ( txx Div 65536 ) ;
                                                                                    If tyy <> 65536 Then yscaleedges ( tyy Div 65536 ) ;
                                                                                    tx := roundunscaled ( tx ) ;
                                                                                    ty := roundunscaled ( ty ) ;
                                                                                    If ( mem [ curedges + 2 ] . hh . lh + tx <= 0 ) Or ( mem [ curedges + 2 ] . hh . rh + tx >= 8192 ) Or ( mem [ curedges + 1 ] . hh . lh + ty <= 0 ) Or ( mem [ curedges + 1 ] . hh . rh + ty >= 8191 ) Or ( abs ( tx ) >= 4096 ) Or ( abs ( ty ) >= 4096 ) Then
                                                                                      Begin
                                                                                        Begin
                                                                                          If interaction = 3 Then ;
                                                                                          printnl ( 261 ) ;
                                                                                          print ( 867 ) ;
                                                                                        End ;
                                                                                        Begin
                                                                                          helpptr := 3 ;
                                                                                          helpline [ 2 ] := 868 ;
                                                                                          helpline [ 1 ] := 537 ;
                                                                                          helpline [ 0 ] := 538 ;
                                                                                        End ;
                                                                                        putgeterror ;
                                                                                      End
                                                                                    Else
                                                                                      Begin
                                                                                        If tx <> 0 Then
                                                                                          Begin
                                                                                            If Not ( abs ( mem [ curedges + 3 ] . hh . lh - tx - 4096 ) < 4096 ) Then fixoffset ;
                                                                                            mem [ curedges + 2 ] . hh . lh := mem [ curedges + 2 ] . hh . lh + tx ;
                                                                                            mem [ curedges + 2 ] . hh . rh := mem [ curedges + 2 ] . hh . rh + tx ;
                                                                                            mem [ curedges + 3 ] . hh . lh := mem [ curedges + 3 ] . hh . lh - tx ;
                                                                                            mem [ curedges + 4 ] . int := 0 ;
                                                                                          End ;
                                                                                        If ty <> 0 Then
                                                                                          Begin
                                                                                            mem [ curedges + 1 ] . hh . lh := mem [ curedges + 1 ] . hh . lh + ty ;
                                                                                            mem [ curedges + 1 ] . hh . rh := mem [ curedges + 1 ] . hh . rh + ty ;
                                                                                            mem [ curedges + 5 ] . hh . lh := mem [ curedges + 5 ] . hh . lh + ty ;
                                                                                            mem [ curedges + 4 ] . int := 0 ;
                                                                                          End ;
                                                                                      End ;
                                                                                  End ;
                                                                                goto 10 ;
                                                                              End ;
                  Begin
                    If interaction = 3 Then ;
                    printnl ( 261 ) ;
                    print ( 864 ) ;
                  End ;
                  Begin
                    helpptr := 3 ;
                    helpline [ 2 ] := 865 ;
                    helpline [ 1 ] := 866 ;
                    helpline [ 0 ] := 538 ;
                  End ;
                  putgeterror ;
                  10 :
                End ;
                Procedure bilin1 ( p : halfword ; t : scaled ; q : halfword ; u , delta : scaled ) ;

                Var r : halfword ;
                Begin
                  If t <> 65536 Then depmult ( p , t , true ) ;
                  If u <> 0 Then If mem [ q ] . hh . b0 = 16 Then delta := delta + takescaled ( mem [ q + 1 ] . int , u )
                  Else
                    Begin
                      If mem [ p ] . hh . b0 <> 18 Then
                        Begin
                          If mem [ p ] . hh . b0 = 16 Then newdep ( p , constdependency ( mem [ p + 1 ] . int ) )
                          Else mem [ p + 1 ] . hh . rh := ptimesv ( mem [ p + 1 ] . hh . rh , 65536 , 17 , 18 , true ) ;
                          mem [ p ] . hh . b0 := 18 ;
                        End ;
                      mem [ p + 1 ] . hh . rh := pplusfq ( mem [ p + 1 ] . hh . rh , u , mem [ q + 1 ] . hh . rh , 18 , mem [ q ] . hh . b0 ) ;
                    End ;
                  If mem [ p ] . hh . b0 = 16 Then mem [ p + 1 ] . int := mem [ p + 1 ] . int + delta
                  Else
                    Begin
                      r := mem [ p + 1 ] . hh . rh ;
                      While mem [ r ] . hh . lh <> 0 Do
                        r := mem [ r ] . hh . rh ;
                      delta := mem [ r + 1 ] . int + delta ;
                      If r <> mem [ p + 1 ] . hh . rh Then mem [ r + 1 ] . int := delta
                      Else
                        Begin
                          recyclevalue ( p ) ;
                          mem [ p ] . hh . b0 := 16 ;
                          mem [ p + 1 ] . int := delta ;
                        End ;
                    End ;
                  If fixneeded Then fixdependencies ;
                End ;
                Procedure addmultdep ( p : halfword ; v : scaled ; r : halfword ) ;
                Begin
                  If mem [ r ] . hh . b0 = 16 Then mem [ depfinal + 1 ] . int := mem [ depfinal + 1 ] . int + takescaled ( mem [ r + 1 ] . int , v )
                  Else
                    Begin
                      mem [ p + 1 ] . hh . rh := pplusfq ( mem [ p + 1 ] . hh . rh , v , mem [ r + 1 ] . hh . rh , 18 , mem [ r ] . hh . b0 ) ;
                      If fixneeded Then fixdependencies ;
                    End ;
                End ;
                Procedure bilin2 ( p , t : halfword ; v : scaled ; u , q : halfword ) ;

                Var vv : scaled ;
                Begin
                  vv := mem [ p + 1 ] . int ;
                  mem [ p ] . hh . b0 := 18 ;
                  newdep ( p , constdependency ( 0 ) ) ;
                  If vv <> 0 Then addmultdep ( p , vv , t ) ;
                  If v <> 0 Then addmultdep ( p , v , u ) ;
                  If q <> 0 Then addmultdep ( p , 65536 , q ) ;
                  If mem [ p + 1 ] . hh . rh = depfinal Then
                    Begin
                      vv := mem [ depfinal + 1 ] . int ;
                      recyclevalue ( p ) ;
                      mem [ p ] . hh . b0 := 16 ;
                      mem [ p + 1 ] . int := vv ;
                    End ;
                End ;
                Procedure bilin3 ( p : halfword ; t , v , u , delta : scaled ) ;
                Begin
                  If t <> 65536 Then delta := delta + takescaled ( mem [ p + 1 ] . int , t )
                  Else delta := delta + mem [ p + 1 ] . int ;
                  If u <> 0 Then mem [ p + 1 ] . int := delta + takescaled ( v , u )
                  Else mem [ p + 1 ] . int := delta ;
                End ;
                Procedure bigtrans ( p : halfword ; c : quarterword ) ;

                Label 10 ;

                Var q , r , pp , qq : halfword ;
                  s : smallnumber ;
                Begin
                  s := bignodesize [ mem [ p ] . hh . b0 ] ;
                  q := mem [ p + 1 ] . int ;
                  r := q + s ;
                  Repeat
                    r := r - 2 ;
                    If mem [ r ] . hh . b0 <> 16 Then
                      Begin
                        setupknowntrans ( c ) ;
                        makeexpcopy ( p ) ;
                        r := mem [ curexp + 1 ] . int ;
                        If curtype = 13 Then
                          Begin
                            bilin1 ( r + 10 , tyy , q + 6 , tyx , 0 ) ;
                            bilin1 ( r + 8 , tyy , q + 4 , tyx , 0 ) ;
                            bilin1 ( r + 6 , txx , q + 10 , txy , 0 ) ;
                            bilin1 ( r + 4 , txx , q + 8 , txy , 0 ) ;
                          End ;
                        bilin1 ( r + 2 , tyy , q , tyx , ty ) ;
                        bilin1 ( r , txx , q + 2 , txy , tx ) ;
                        goto 10 ;
                      End ;
                  Until r = q ;
                  setuptrans ( c ) ;
                  If curtype = 16 Then
                    Begin
                      makeexpcopy ( p ) ;
                      r := mem [ curexp + 1 ] . int ;
                      If curtype = 13 Then
                        Begin
                          bilin3 ( r + 10 , tyy , mem [ q + 7 ] . int , tyx , 0 ) ;
                          bilin3 ( r + 8 , tyy , mem [ q + 5 ] . int , tyx , 0 ) ;
                          bilin3 ( r + 6 , txx , mem [ q + 11 ] . int , txy , 0 ) ;
                          bilin3 ( r + 4 , txx , mem [ q + 9 ] . int , txy , 0 ) ;
                        End ;
                      bilin3 ( r + 2 , tyy , mem [ q + 1 ] . int , tyx , ty ) ;
                      bilin3 ( r , txx , mem [ q + 3 ] . int , txy , tx ) ;
                    End
                  Else
                    Begin
                      pp := stashcurexp ;
                      qq := mem [ pp + 1 ] . int ;
                      makeexpcopy ( p ) ;
                      r := mem [ curexp + 1 ] . int ;
                      If curtype = 13 Then
                        Begin
                          bilin2 ( r + 10 , qq + 10 , mem [ q + 7 ] . int , qq + 8 , 0 ) ;
                          bilin2 ( r + 8 , qq + 10 , mem [ q + 5 ] . int , qq + 8 , 0 ) ;
                          bilin2 ( r + 6 , qq + 4 , mem [ q + 11 ] . int , qq + 6 , 0 ) ;
                          bilin2 ( r + 4 , qq + 4 , mem [ q + 9 ] . int , qq + 6 , 0 ) ;
                        End ;
                      bilin2 ( r + 2 , qq + 10 , mem [ q + 1 ] . int , qq + 8 , qq + 2 ) ;
                      bilin2 ( r , qq + 4 , mem [ q + 3 ] . int , qq + 6 , qq ) ;
                      recyclevalue ( pp ) ;
                      freenode ( pp , 2 ) ;
                    End ; ;
                  10 :
                End ;
                Procedure cat ( p : halfword ) ;

                Var a , b : strnumber ;
                  k : poolpointer ;
                Begin
                  a := mem [ p + 1 ] . int ;
                  b := curexp ;
                  Begin
                    If poolptr + ( strstart [ a + 1 ] - strstart [ a ] ) + ( strstart [ b + 1 ] - strstart [ b ] ) > maxpoolptr Then
                      Begin
                        If poolptr + ( strstart [ a + 1 ] - strstart [ a ] ) + ( strstart [ b + 1 ] - strstart [ b ] ) > poolsize Then overflow ( 257 , poolsize - initpoolptr ) ;
                        maxpoolptr := poolptr + ( strstart [ a + 1 ] - strstart [ a ] ) + ( strstart [ b + 1 ] - strstart [ b ] ) ;
                      End ;
                  End ;
                  For k := strstart [ a ] To strstart [ a + 1 ] - 1 Do
                    Begin
                      strpool [ poolptr ] := strpool [ k ] ;
                      poolptr := poolptr + 1 ;
                    End ;
                  For k := strstart [ b ] To strstart [ b + 1 ] - 1 Do
                    Begin
                      strpool [ poolptr ] := strpool [ k ] ;
                      poolptr := poolptr + 1 ;
                    End ;
                  curexp := makestring ;
                  Begin
                    If strref [ b ] < 127 Then If strref [ b ] > 1 Then strref [ b ] := strref [ b ] - 1
                    Else flushstring ( b ) ;
                  End ;
                End ;
                Procedure chopstring ( p : halfword ) ;

                Var a , b : integer ;
                  l : integer ;
                  k : integer ;
                  s : strnumber ;
                  reversed : boolean ;
                Begin
                  a := roundunscaled ( mem [ p + 1 ] . int ) ;
                  b := roundunscaled ( mem [ p + 3 ] . int ) ;
                  If a <= b Then reversed := false
                  Else
                    Begin
                      reversed := true ;
                      k := a ;
                      a := b ;
                      b := k ;
                    End ;
                  s := curexp ;
                  l := ( strstart [ s + 1 ] - strstart [ s ] ) ;
                  If a < 0 Then
                    Begin
                      a := 0 ;
                      If b < 0 Then b := 0 ;
                    End ;
                  If b > l Then
                    Begin
                      b := l ;
                      If a > l Then a := l ;
                    End ;
                  Begin
                    If poolptr + b - a > maxpoolptr Then
                      Begin
                        If poolptr + b - a > poolsize Then overflow ( 257 , poolsize - initpoolptr ) ;
                        maxpoolptr := poolptr + b - a ;
                      End ;
                  End ;
                  If reversed Then For k := strstart [ s ] + b - 1 Downto strstart [ s ] + a Do
                                     Begin
                                       strpool [ poolptr ] := strpool [ k ] ;
                                       poolptr := poolptr + 1 ;
                                     End
                                     Else For k := strstart [ s ] + a To strstart [ s ] + b - 1 Do
                                            Begin
                                              strpool [ poolptr ] := strpool [ k ] ;
                                              poolptr := poolptr + 1 ;
                                            End ;
                  curexp := makestring ;
                  Begin
                    If strref [ s ] < 127 Then If strref [ s ] > 1 Then strref [ s ] := strref [ s ] - 1
                    Else flushstring ( s ) ;
                  End ;
                End ;
                Procedure choppath ( p : halfword ) ;

                Var q : halfword ;
                  pp , qq , rr , ss : halfword ;
                  a , b , k , l : scaled ;
                  reversed : boolean ;
                Begin
                  l := pathlength ;
                  a := mem [ p + 1 ] . int ;
                  b := mem [ p + 3 ] . int ;
                  If a <= b Then reversed := false
                  Else
                    Begin
                      reversed := true ;
                      k := a ;
                      a := b ;
                      b := k ;
                    End ;
                  If a < 0 Then If mem [ curexp ] . hh . b0 = 0 Then
                                  Begin
                                    a := 0 ;
                                    If b < 0 Then b := 0 ;
                                  End
                  Else Repeat
                         a := a + l ;
                         b := b + l ;
                    Until a >= 0 ;
                  If b > l Then If mem [ curexp ] . hh . b0 = 0 Then
                                  Begin
                                    b := l ;
                                    If a > l Then a := l ;
                                  End
                  Else While a >= l Do
                         Begin
                           a := a - l ;
                           b := b - l ;
                         End ;
                  q := curexp ;
                  While a >= 65536 Do
                    Begin
                      q := mem [ q ] . hh . rh ;
                      a := a - 65536 ;
                      b := b - 65536 ;
                    End ;
                  If b = a Then
                    Begin
                      If a > 0 Then
                        Begin
                          qq := mem [ q ] . hh . rh ;
                          splitcubic ( q , a * 4096 , mem [ qq + 1 ] . int , mem [ qq + 2 ] . int ) ;
                          q := mem [ q ] . hh . rh ;
                        End ;
                      pp := copyknot ( q ) ;
                      qq := pp ;
                    End
                  Else
                    Begin
                      pp := copyknot ( q ) ;
                      qq := pp ;
                      Repeat
                        q := mem [ q ] . hh . rh ;
                        rr := qq ;
                        qq := copyknot ( q ) ;
                        mem [ rr ] . hh . rh := qq ;
                        b := b - 65536 ;
                      Until b <= 0 ;
                      If a > 0 Then
                        Begin
                          ss := pp ;
                          pp := mem [ pp ] . hh . rh ;
                          splitcubic ( ss , a * 4096 , mem [ pp + 1 ] . int , mem [ pp + 2 ] . int ) ;
                          pp := mem [ ss ] . hh . rh ;
                          freenode ( ss , 7 ) ;
                          If rr = ss Then
                            Begin
                              b := makescaled ( b , 65536 - a ) ;
                              rr := pp ;
                            End ;
                        End ;
                      If b < 0 Then
                        Begin
                          splitcubic ( rr , ( b + 65536 ) * 4096 , mem [ qq + 1 ] . int , mem [ qq + 2 ] . int ) ;
                          freenode ( qq , 7 ) ;
                          qq := mem [ rr ] . hh . rh ;
                        End ;
                    End ;
                  mem [ pp ] . hh . b0 := 0 ;
                  mem [ qq ] . hh . b1 := 0 ;
                  mem [ qq ] . hh . rh := pp ;
                  tossknotlist ( curexp ) ;
                  If reversed Then
                    Begin
                      curexp := mem [ htapypoc ( pp ) ] . hh . rh ;
                      tossknotlist ( pp ) ;
                    End
                  Else curexp := pp ;
                End ;
                Procedure pairvalue ( x , y : scaled ) ;

                Var p : halfword ;
                Begin
                  p := getnode ( 2 ) ;
                  flushcurexp ( p ) ;
                  curtype := 14 ;
                  mem [ p ] . hh . b0 := 14 ;
                  mem [ p ] . hh . b1 := 11 ;
                  initbignode ( p ) ;
                  p := mem [ p + 1 ] . int ;
                  mem [ p ] . hh . b0 := 16 ;
                  mem [ p + 1 ] . int := x ;
                  mem [ p + 2 ] . hh . b0 := 16 ;
                  mem [ p + 3 ] . int := y ;
                End ;
                Procedure setupoffset ( p : halfword ) ;
                Begin
                  findoffset ( mem [ p + 1 ] . int , mem [ p + 3 ] . int , curexp ) ;
                  pairvalue ( curx , cury ) ;
                End ;
                Procedure setupdirectiontime ( p : halfword ) ;
                Begin
                  flushcurexp ( finddirectiontime ( mem [ p + 1 ] . int , mem [ p + 3 ] . int , curexp ) ) ;
                End ;
                Procedure findpoint ( v : scaled ; c : quarterword ) ;

                Var p : halfword ;
                  n : scaled ;
                  q : halfword ;
                Begin
                  p := curexp ;
                  If mem [ p ] . hh . b0 = 0 Then n := - 65536
                  Else n := 0 ;
                  Repeat
                    p := mem [ p ] . hh . rh ;
                    n := n + 65536 ;
                  Until p = curexp ;
                  If n = 0 Then v := 0
                  Else If v < 0 Then If mem [ p ] . hh . b0 = 0 Then v := 0
                  Else v := n - 1 - ( ( - v - 1 ) Mod n )
                  Else If v > n Then If mem [ p ] . hh . b0 = 0 Then v := n
                  Else v := v Mod n ;
                  p := curexp ;
                  While v >= 65536 Do
                    Begin
                      p := mem [ p ] . hh . rh ;
                      v := v - 65536 ;
                    End ;
                  If v <> 0 Then
                    Begin
                      q := mem [ p ] . hh . rh ;
                      splitcubic ( p , v * 4096 , mem [ q + 1 ] . int , mem [ q + 2 ] . int ) ;
                      p := mem [ p ] . hh . rh ;
                    End ;
                  Case c Of 
                    97 : pairvalue ( mem [ p + 1 ] . int , mem [ p + 2 ] . int ) ;
                    98 : If mem [ p ] . hh . b0 = 0 Then pairvalue ( mem [ p + 1 ] . int , mem [ p + 2 ] . int )
                         Else pairvalue ( mem [ p + 3 ] . int , mem [ p + 4 ] . int ) ;
                    99 : If mem [ p ] . hh . b1 = 0 Then pairvalue ( mem [ p + 1 ] . int , mem [ p + 2 ] . int )
                         Else pairvalue ( mem [ p + 5 ] . int , mem [ p + 6 ] . int ) ;
                  End ;
                End ;
                Procedure dobinary ( p : halfword ; c : quarterword ) ;

                Label 30 , 31 , 10 ;

                Var q , r , rr : halfword ;
                  oldp , oldexp : halfword ;
                  v : integer ;
                Begin
                  Begin
                    If aritherror Then cleararith ;
                  End ;
                  If internal [ 7 ] > 131072 Then
                    Begin
                      begindiagnostic ;
                      printnl ( 850 ) ;
                      printexp ( p , 0 ) ;
                      printchar ( 41 ) ;
                      printop ( c ) ;
                      printchar ( 40 ) ;
                      printexp ( 0 , 0 ) ;
                      print ( 842 ) ;
                      enddiagnostic ( false ) ;
                    End ;
                  Case mem [ p ] . hh . b0 Of 
                    13 , 14 : oldp := tarnished ( p ) ;
                    19 : oldp := 1 ;
                    others : oldp := 0
                  End ;
                  If oldp <> 0 Then
                    Begin
                      q := stashcurexp ;
                      oldp := p ;
                      makeexpcopy ( oldp ) ;
                      p := stashcurexp ;
                      unstashcurexp ( q ) ;
                    End ; ;
                  Case curtype Of 
                    13 , 14 : oldexp := tarnished ( curexp ) ;
                    19 : oldexp := 1 ;
                    others : oldexp := 0
                  End ;
                  If oldexp <> 0 Then
                    Begin
                      oldexp := curexp ;
                      makeexpcopy ( oldexp ) ;
                    End ;
                  Case c Of 
                    69 , 70 : If ( curtype < 14 ) Or ( mem [ p ] . hh . b0 < 14 ) Then If ( curtype = 11 ) And ( mem [ p ] . hh . b0 = 11 ) Then
                                                                                         Begin
                                                                                           If c = 70 Then negateedges ( curexp ) ;
                                                                                           curedges := curexp ;
                                                                                           mergeedges ( mem [ p + 1 ] . int ) ;
                                                                                         End
                              Else badbinary ( p , c )
                              Else If curtype = 14 Then If mem [ p ] . hh . b0 <> 14 Then badbinary ( p , c )
                              Else
                                Begin
                                  q := mem [ p + 1 ] . int ;
                                  r := mem [ curexp + 1 ] . int ;
                                  addorsubtract ( q , r , c ) ;
                                  addorsubtract ( q + 2 , r + 2 , c ) ;
                                End
                              Else If mem [ p ] . hh . b0 = 14 Then badbinary ( p , c )
                              Else addorsubtract ( p , 0 , c ) ;
                    77 , 78 , 79 , 80 , 81 , 82 :
                                                  Begin
                                                    If ( curtype > 14 ) And ( mem [ p ] . hh . b0 > 14 ) Then addorsubtract ( p , 0 , 70 )
                                                    Else If curtype <> mem [ p ] . hh . b0 Then
                                                           Begin
                                                             badbinary ( p , c ) ;
                                                             goto 30 ;
                                                           End
                                                    Else If curtype = 4 Then flushcurexp ( strvsstr ( mem [ p + 1 ] . int , curexp ) )
                                                    Else If ( curtype = 5 ) Or ( curtype = 3 ) Then
                                                           Begin
                                                             q := mem [ curexp + 1 ] . int ;
                                                             While ( q <> curexp ) And ( q <> p ) Do
                                                               q := mem [ q + 1 ] . int ;
                                                             If q = p Then flushcurexp ( 0 ) ;
                                                           End
                                                    Else If ( curtype = 14 ) Or ( curtype = 13 ) Then
                                                           Begin
                                                             q := mem [ p + 1 ] . int ;
                                                             r := mem [ curexp + 1 ] . int ;
                                                             rr := r + bignodesize [ curtype ] - 2 ;
                                                             While true Do
                                                               Begin
                                                                 addorsubtract ( q , r , 70 ) ;
                                                                 If mem [ r ] . hh . b0 <> 16 Then goto 31 ;
                                                                 If mem [ r + 1 ] . int <> 0 Then goto 31 ;
                                                                 If r = rr Then goto 31 ;
                                                                 q := q + 2 ;
                                                                 r := r + 2 ;
                                                               End ;
                                                             31 : takepart ( 53 + ( r - mem [ curexp + 1 ] . int ) div 2 ) ;
                                                           End
                                                    Else If curtype = 2 Then flushcurexp ( curexp - mem [ p + 1 ] . int )
                                                    Else
                                                      Begin
                                                        badbinary ( p , c ) ;
                                                        goto 30 ;
                                                      End ;
                                                    If curtype <> 16 Then
                                                      Begin
                                                        If curtype < 16 Then
                                                          Begin
                                                            disperr ( p , 285 ) ;
                                                            Begin
                                                              helpptr := 1 ;
                                                              helpline [ 0 ] := 851 ;
                                                            End
                                                          End
                                                        Else
                                                          Begin
                                                            helpptr := 2 ;
                                                            helpline [ 1 ] := 852 ;
                                                            helpline [ 0 ] := 853 ;
                                                          End ;
                                                        disperr ( 0 , 854 ) ;
                                                        putgetflusherror ( 31 ) ;
                                                      End
                                                    Else Case c Of 
                                                           77 : If curexp < 0 Then curexp := 30
                                                                Else curexp := 31 ;
                                                           78 : If curexp <= 0 Then curexp := 30
                                                                Else curexp := 31 ;
                                                           79 : If curexp > 0 Then curexp := 30
                                                                Else curexp := 31 ;
                                                           80 : If curexp >= 0 Then curexp := 30
                                                                Else curexp := 31 ;
                                                           81 : If curexp = 0 Then curexp := 30
                                                                Else curexp := 31 ;
                                                           82 : If curexp <> 0 Then curexp := 30
                                                                Else curexp := 31 ;
                                                      End ;
                                                    curtype := 2 ;
                                                    30 :
                                                  End ;
                    76 , 75 : If ( mem [ p ] . hh . b0 <> 2 ) Or ( curtype <> 2 ) Then badbinary ( p , c )
                              Else If mem [ p + 1 ] . int = c - 45 Then curexp := mem [ p + 1 ] . int ;
                    71 : If ( curtype < 14 ) Or ( mem [ p ] . hh . b0 < 14 ) Then badbinary ( p , 71 )
                         Else If ( curtype = 16 ) Or ( mem [ p ] . hh . b0 = 16 ) Then
                                Begin
                                  If mem [ p ] . hh . b0 = 16 Then
                                    Begin
                                      v := mem [ p + 1 ] . int ;
                                      freenode ( p , 2 ) ;
                                    End
                                  Else
                                    Begin
                                      v := curexp ;
                                      unstashcurexp ( p ) ;
                                    End ;
                                  If curtype = 16 Then curexp := takescaled ( curexp , v )
                                  Else If curtype = 14 Then
                                         Begin
                                           p := mem [ curexp + 1 ] . int ;
                                           depmult ( p , v , true ) ;
                                           depmult ( p + 2 , v , true ) ;
                                         End
                                  Else depmult ( 0 , v , true ) ;
                                  goto 10 ;
                                End
                         Else If ( nicepair ( p , mem [ p ] . hh . b0 ) And ( curtype > 14 ) ) Or ( nicepair ( curexp , curtype ) And ( mem [ p ] . hh . b0 > 14 ) ) Then
                                Begin
                                  hardtimes ( p ) ;
                                  goto 10 ;
                                End
                         Else badbinary ( p , 71 ) ;
                    72 : If ( curtype <> 16 ) Or ( mem [ p ] . hh . b0 < 14 ) Then badbinary ( p , 72 )
                         Else
                           Begin
                             v := curexp ;
                             unstashcurexp ( p ) ;
                             If v = 0 Then
                               Begin
                                 disperr ( 0 , 784 ) ;
                                 Begin
                                   helpptr := 2 ;
                                   helpline [ 1 ] := 856 ;
                                   helpline [ 0 ] := 857 ;
                                 End ;
                                 putgeterror ;
                               End
                             Else
                               Begin
                                 If curtype = 16 Then curexp := makescaled ( curexp , v )
                                 Else If curtype = 14 Then
                                        Begin
                                          p := mem [ curexp + 1 ] . int ;
                                          depdiv ( p , v ) ;
                                          depdiv ( p + 2 , v ) ;
                                        End
                                 Else depdiv ( 0 , v ) ;
                               End ;
                             goto 10 ;
                           End ;
                    73 , 74 : If ( curtype = 16 ) And ( mem [ p ] . hh . b0 = 16 ) Then If c = 73 Then curexp := pythadd ( mem [ p + 1 ] . int , curexp )
                              Else curexp := pythsub ( mem [ p + 1 ] . int , curexp )
                              Else badbinary ( p , c ) ;
                    84 , 85 , 86 , 87 , 88 , 89 , 90 , 91 : If ( mem [ p ] . hh . b0 = 9 ) Or ( mem [ p ] . hh . b0 = 8 ) Or ( mem [ p ] . hh . b0 = 6 ) Then
                                                              Begin
                                                                pathtrans ( p , c ) ;
                                                                goto 10 ;
                                                              End
                                                            Else If ( mem [ p ] . hh . b0 = 14 ) Or ( mem [ p ] . hh . b0 = 13 ) Then bigtrans ( p , c )
                                                            Else If mem [ p ] . hh . b0 = 11 Then
                                                                   Begin
                                                                     edgestrans ( p , c ) ;
                                                                     goto 10 ;
                                                                   End
                                                            Else badbinary ( p , c ) ;
                    83 : If ( curtype = 4 ) And ( mem [ p ] . hh . b0 = 4 ) Then cat ( p )
                         Else badbinary ( p , 83 ) ;
                    94 : If nicepair ( p , mem [ p ] . hh . b0 ) And ( curtype = 4 ) Then chopstring ( mem [ p + 1 ] . int )
                         Else badbinary ( p , 94 ) ;
                    95 :
                         Begin
                           If curtype = 14 Then pairtopath ;
                           If nicepair ( p , mem [ p ] . hh . b0 ) And ( curtype = 9 ) Then choppath ( mem [ p + 1 ] . int )
                           Else badbinary ( p , 95 ) ;
                         End ;
                    97 , 98 , 99 :
                                   Begin
                                     If curtype = 14 Then pairtopath ;
                                     If ( curtype = 9 ) And ( mem [ p ] . hh . b0 = 16 ) Then findpoint ( mem [ p + 1 ] . int , c )
                                     Else badbinary ( p , c ) ;
                                   End ;
                    100 :
                          Begin
                            If curtype = 8 Then materializepen ;
                            If ( curtype = 6 ) And nicepair ( p , mem [ p ] . hh . b0 ) Then setupoffset ( mem [ p + 1 ] . int )
                            Else badbinary ( p , 100 ) ;
                          End ;
                    96 :
                         Begin
                           If curtype = 14 Then pairtopath ;
                           If ( curtype = 9 ) And nicepair ( p , mem [ p ] . hh . b0 ) Then setupdirectiontime ( mem [ p + 1 ] . int )
                           Else badbinary ( p , 96 ) ;
                         End ;
                    92 :
                         Begin
                           If mem [ p ] . hh . b0 = 14 Then
                             Begin
                               q := stashcurexp ;
                               unstashcurexp ( p ) ;
                               pairtopath ;
                               p := stashcurexp ;
                               unstashcurexp ( q ) ;
                             End ;
                           If curtype = 14 Then pairtopath ;
                           If ( curtype = 9 ) And ( mem [ p ] . hh . b0 = 9 ) Then
                             Begin
                               pathintersection ( mem [ p + 1 ] . int , curexp ) ;
                               pairvalue ( curt , curtt ) ;
                             End
                           Else badbinary ( p , 92 ) ;
                         End ;
                  End ;
                  recyclevalue ( p ) ;
                  freenode ( p , 2 ) ;
                  10 :
                       Begin
                         If aritherror Then cleararith ;
                       End ;
                  If oldp <> 0 Then
                    Begin
                      recyclevalue ( oldp ) ;
                      freenode ( oldp , 2 ) ;
                    End ;
                  If oldexp <> 0 Then
                    Begin
                      recyclevalue ( oldexp ) ;
                      freenode ( oldexp , 2 ) ;
                    End ;
                End ;
                Procedure fracmult ( n , d : scaled ) ;

                Var p : halfword ;
                  oldexp : halfword ;
                  v : fraction ;
                Begin
                  If internal [ 7 ] > 131072 Then
                    Begin
                      begindiagnostic ;
                      printnl ( 850 ) ;
                      printscaled ( n ) ;
                      printchar ( 47 ) ;
                      printscaled ( d ) ;
                      print ( 855 ) ;
                      printexp ( 0 , 0 ) ;
                      print ( 842 ) ;
                      enddiagnostic ( false ) ;
                    End ;
                  Case curtype Of 
                    13 , 14 : oldexp := tarnished ( curexp ) ;
                    19 : oldexp := 1 ;
                    others : oldexp := 0
                  End ;
                  If oldexp <> 0 Then
                    Begin
                      oldexp := curexp ;
                      makeexpcopy ( oldexp ) ;
                    End ;
                  v := makefraction ( n , d ) ;
                  If curtype = 16 Then curexp := takefraction ( curexp , v )
                  Else If curtype = 14 Then
                         Begin
                           p := mem [ curexp + 1 ] . int ;
                           depmult ( p , v , false ) ;
                           depmult ( p + 2 , v , false ) ;
                         End
                  Else depmult ( 0 , v , false ) ;
                  If oldexp <> 0 Then
                    Begin
                      recyclevalue ( oldexp ) ;
                      freenode ( oldexp , 2 ) ;
                    End
                End ;
                Procedure writegf ( a , b : gfindex ) ;

                Var k : gfindex ;
                Begin
                  For k := a To b Do
                    write ( gffile , gfbuf [ k ] ) ;
                End ;
                Procedure gfswap ;
                Begin
                  If gflimit = gfbufsize Then
                    Begin
                      writegf ( 0 , halfbuf - 1 ) ;
                      gflimit := halfbuf ;
                      gfoffset := gfoffset + gfbufsize ;
                      gfptr := 0 ;
                    End
                  Else
                    Begin
                      writegf ( halfbuf , gfbufsize - 1 ) ;
                      gflimit := gfbufsize ;
                    End ;
                End ;
                Procedure gffour ( x : integer ) ;
                Begin
                  If x >= 0 Then
                    Begin
                      gfbuf [ gfptr ] := x Div 16777216 ;
                      gfptr := gfptr + 1 ;
                      If gfptr = gflimit Then gfswap ;
                    End
                  Else
                    Begin
                      x := x + 1073741824 ;
                      x := x + 1073741824 ;
                      Begin
                        gfbuf [ gfptr ] := ( x Div 16777216 ) + 128 ;
                        gfptr := gfptr + 1 ;
                        If gfptr = gflimit Then gfswap ;
                      End ;
                    End ;
                  x := x Mod 16777216 ;
                  Begin
                    gfbuf [ gfptr ] := x Div 65536 ;
                    gfptr := gfptr + 1 ;
                    If gfptr = gflimit Then gfswap ;
                  End ;
                  x := x Mod 65536 ;
                  Begin
                    gfbuf [ gfptr ] := x Div 256 ;
                    gfptr := gfptr + 1 ;
                    If gfptr = gflimit Then gfswap ;
                  End ;
                  Begin
                    gfbuf [ gfptr ] := x Mod 256 ;
                    gfptr := gfptr + 1 ;
                    If gfptr = gflimit Then gfswap ;
                  End ;
                End ;
                Procedure gftwo ( x : integer ) ;
                Begin
                  Begin
                    gfbuf [ gfptr ] := x Div 256 ;
                    gfptr := gfptr + 1 ;
                    If gfptr = gflimit Then gfswap ;
                  End ;
                  Begin
                    gfbuf [ gfptr ] := x Mod 256 ;
                    gfptr := gfptr + 1 ;
                    If gfptr = gflimit Then gfswap ;
                  End ;
                End ;
                Procedure gfthree ( x : integer ) ;
                Begin
                  Begin
                    gfbuf [ gfptr ] := x Div 65536 ;
                    gfptr := gfptr + 1 ;
                    If gfptr = gflimit Then gfswap ;
                  End ;
                  Begin
                    gfbuf [ gfptr ] := ( x Mod 65536 ) Div 256 ;
                    gfptr := gfptr + 1 ;
                    If gfptr = gflimit Then gfswap ;
                  End ;
                  Begin
                    gfbuf [ gfptr ] := x Mod 256 ;
                    gfptr := gfptr + 1 ;
                    If gfptr = gflimit Then gfswap ;
                  End ;
                End ;
                Procedure gfpaint ( d : integer ) ;
                Begin
                  If d < 64 Then
                    Begin
                      gfbuf [ gfptr ] := 0 + d ;
                      gfptr := gfptr + 1 ;
                      If gfptr = gflimit Then gfswap ;
                    End
                  Else If d < 256 Then
                         Begin
                           Begin
                             gfbuf [ gfptr ] := 64 ;
                             gfptr := gfptr + 1 ;
                             If gfptr = gflimit Then gfswap ;
                           End ;
                           Begin
                             gfbuf [ gfptr ] := d ;
                             gfptr := gfptr + 1 ;
                             If gfptr = gflimit Then gfswap ;
                           End ;
                         End
                  Else
                    Begin
                      Begin
                        gfbuf [ gfptr ] := 65 ;
                        gfptr := gfptr + 1 ;
                        If gfptr = gflimit Then gfswap ;
                      End ;
                      gftwo ( d ) ;
                    End ;
                End ;
                Procedure gfstring ( s , t : strnumber ) ;

                Var k : poolpointer ;
                  l : integer ;
                Begin
                  If s <> 0 Then
                    Begin
                      l := ( strstart [ s + 1 ] - strstart [ s ] ) ;
                      If t <> 0 Then l := l + ( strstart [ t + 1 ] - strstart [ t ] ) ;
                      If l <= 255 Then
                        Begin
                          Begin
                            gfbuf [ gfptr ] := 239 ;
                            gfptr := gfptr + 1 ;
                            If gfptr = gflimit Then gfswap ;
                          End ;
                          Begin
                            gfbuf [ gfptr ] := l ;
                            gfptr := gfptr + 1 ;
                            If gfptr = gflimit Then gfswap ;
                          End ;
                        End
                      Else
                        Begin
                          Begin
                            gfbuf [ gfptr ] := 241 ;
                            gfptr := gfptr + 1 ;
                            If gfptr = gflimit Then gfswap ;
                          End ;
                          gfthree ( l ) ;
                        End ;
                      For k := strstart [ s ] To strstart [ s + 1 ] - 1 Do
                        Begin
                          gfbuf [ gfptr ] := strpool [ k ] ;
                          gfptr := gfptr + 1 ;
                          If gfptr = gflimit Then gfswap ;
                        End ;
                    End ;
                  If t <> 0 Then For k := strstart [ t ] To strstart [ t + 1 ] - 1 Do
                                   Begin
                                     gfbuf [ gfptr ] := strpool [ k ] ;
                                     gfptr := gfptr + 1 ;
                                     If gfptr = gflimit Then gfswap ;
                                   End ;
                End ;
                Procedure gfboc ( minm , maxm , minn , maxn : integer ) ;

                Label 10 ;
                Begin
                  If minm < gfminm Then gfminm := minm ;
                  If maxn > gfmaxn Then gfmaxn := maxn ;
                  If bocp = - 1 Then If bocc >= 0 Then If bocc < 256 Then If maxm - minm >= 0 Then If maxm - minm < 256 Then If maxm >= 0 Then If maxm < 256 Then If maxn - minn >= 0 Then If maxn - minn < 256 Then If maxn >= 0 Then If maxn < 256 Then
                                                                                                                                                                                                                                         Begin
                                                                                                                                                                                                                                           Begin
                                                                                                                                                                                                                                             gfbuf [ gfptr ] := 68 ;
                                                                                                                                                                                                                                             gfptr := gfptr + 1 ;
                                                                                                                                                                                                                                             If gfptr = gflimit Then gfswap ;
                                                                                                                                                                                                                                           End ;
                                                                                                                                                                                                                                           Begin
                                                                                                                                                                                                                                             gfbuf [ gfptr ] := bocc ;
                                                                                                                                                                                                                                             gfptr := gfptr + 1 ;
                                                                                                                                                                                                                                             If gfptr = gflimit Then gfswap ;
                                                                                                                                                                                                                                           End ;
                                                                                                                                                                                                                                           Begin
                                                                                                                                                                                                                                             gfbuf [ gfptr ] := maxm - minm ;
                                                                                                                                                                                                                                             gfptr := gfptr + 1 ;
                                                                                                                                                                                                                                             If gfptr = gflimit Then gfswap ;
                                                                                                                                                                                                                                           End ;
                                                                                                                                                                                                                                           Begin
                                                                                                                                                                                                                                             gfbuf [ gfptr ] := maxm ;
                                                                                                                                                                                                                                             gfptr := gfptr + 1 ;
                                                                                                                                                                                                                                             If gfptr = gflimit Then gfswap ;
                                                                                                                                                                                                                                           End ;
                                                                                                                                                                                                                                           Begin
                                                                                                                                                                                                                                             gfbuf [ gfptr ] := maxn - minn ;
                                                                                                                                                                                                                                             gfptr := gfptr + 1 ;
                                                                                                                                                                                                                                             If gfptr = gflimit Then gfswap ;
                                                                                                                                                                                                                                           End ;
                                                                                                                                                                                                                                           Begin
                                                                                                                                                                                                                                             gfbuf [ gfptr ] := maxn ;
                                                                                                                                                                                                                                             gfptr := gfptr + 1 ;
                                                                                                                                                                                                                                             If gfptr = gflimit Then gfswap ;
                                                                                                                                                                                                                                           End ;
                                                                                                                                                                                                                                           goto 10 ;
                                                                                                                                                                                                                                         End ;
                  Begin
                    gfbuf [ gfptr ] := 67 ;
                    gfptr := gfptr + 1 ;
                    If gfptr = gflimit Then gfswap ;
                  End ;
                  gffour ( bocc ) ;
                  gffour ( bocp ) ;
                  gffour ( minm ) ;
                  gffour ( maxm ) ;
                  gffour ( minn ) ;
                  gffour ( maxn ) ;
                  10 :
                End ;
                Procedure initgf ;

                Var k : eightbits ;
                  t : integer ;
                Begin
                  gfminm := 4096 ;
                  gfmaxm := - 4096 ;
                  gfminn := 4096 ;
                  gfmaxn := - 4096 ;
                  For k := 0 To 255 Do
                    charptr [ k ] := - 1 ;
                  If internal [ 27 ] <= 0 Then gfext := 1054
                  Else
                    Begin
                      oldsetting := selector ;
                      selector := 5 ;
                      printchar ( 46 ) ;
                      printint ( makescaled ( internal [ 27 ] , 59429463 ) ) ;
                      print ( 1055 ) ;
                      gfext := makestring ;
                      selector := oldsetting ;
                    End ;
                  Begin
                    If jobname = 0 Then openlogfile ;
                    packjobname ( gfext ) ;
                    While Not bopenout ( gffile ) Do
                      promptfilename ( 756 , gfext ) ;
                    outputfilename := bmakenamestring ( gffile ) ;
                  End ;
                  Begin
                    gfbuf [ gfptr ] := 247 ;
                    gfptr := gfptr + 1 ;
                    If gfptr = gflimit Then gfswap ;
                  End ;
                  Begin
                    gfbuf [ gfptr ] := 131 ;
                    gfptr := gfptr + 1 ;
                    If gfptr = gflimit Then gfswap ;
                  End ;
                  oldsetting := selector ;
                  selector := 5 ;
                  print ( 1053 ) ;
                  printint ( roundunscaled ( internal [ 14 ] ) ) ;
                  printchar ( 46 ) ;
                  printdd ( roundunscaled ( internal [ 15 ] ) ) ;
                  printchar ( 46 ) ;
                  printdd ( roundunscaled ( internal [ 16 ] ) ) ;
                  printchar ( 58 ) ;
                  t := roundunscaled ( internal [ 17 ] ) ;
                  printdd ( t Div 60 ) ;
                  printdd ( t Mod 60 ) ;
                  selector := oldsetting ;
                  Begin
                    gfbuf [ gfptr ] := ( poolptr - strstart [ strptr ] ) ;
                    gfptr := gfptr + 1 ;
                    If gfptr = gflimit Then gfswap ;
                  End ;
                  gfstring ( 0 , makestring ) ;
                  strptr := strptr - 1 ;
                  poolptr := strstart [ strptr ] ;
                  gfprevptr := gfoffset + gfptr ;
                End ;
                Procedure shipout ( c : eightbits ) ;

                Label 30 ;

                Var f : integer ;
                  prevm , m , mm : integer ;
                  prevn , n : integer ;
                  p , q : halfword ;
                  prevw , w , ww : integer ;
                  d : integer ;
                  delta : integer ;
                  curminm : integer ;
                  xoff , yoff : integer ;
                Begin
                  If outputfilename = 0 Then initgf ;
                  f := roundunscaled ( internal [ 19 ] ) ;
                  xoff := roundunscaled ( internal [ 29 ] ) ;
                  yoff := roundunscaled ( internal [ 30 ] ) ;
                  If termoffset > maxprintline - 9 Then println
                  Else If ( termoffset > 0 ) Or ( fileoffset > 0 ) Then printchar ( 32 ) ;
                  printchar ( 91 ) ;
                  printint ( c ) ;
                  If f <> 0 Then
                    Begin
                      printchar ( 46 ) ;
                      printint ( f ) ;
                    End ;
                  break ( termout ) ;
                  bocc := 256 * f + c ;
                  bocp := charptr [ c ] ;
                  charptr [ c ] := gfprevptr ;
                  If internal [ 34 ] > 0 Then
                    Begin
                      If xoff <> 0 Then
                        Begin
                          gfstring ( 438 , 0 ) ;
                          Begin
                            gfbuf [ gfptr ] := 243 ;
                            gfptr := gfptr + 1 ;
                            If gfptr = gflimit Then gfswap ;
                          End ;
                          gffour ( xoff * 65536 ) ;
                        End ;
                      If yoff <> 0 Then
                        Begin
                          gfstring ( 439 , 0 ) ;
                          Begin
                            gfbuf [ gfptr ] := 243 ;
                            gfptr := gfptr + 1 ;
                            If gfptr = gflimit Then gfswap ;
                          End ;
                          gffour ( yoff * 65536 ) ;
                        End ;
                    End ;
                  prevn := 4096 ;
                  p := mem [ curedges ] . hh . lh ;
                  n := mem [ curedges + 1 ] . hh . rh - 4096 ;
                  While p <> curedges Do
                    Begin
                      If mem [ p + 1 ] . hh . lh > 1 Then sortedges ( p ) ;
                      q := mem [ p + 1 ] . hh . rh ;
                      w := 0 ;
                      prevm := - 268435456 ;
                      ww := 0 ;
                      prevw := 0 ;
                      m := prevm ;
                      Repeat
                        If q = 30000 Then mm := 268435456
                        Else
                          Begin
                            d := mem [ q ] . hh . lh - 0 ;
                            mm := d Div 8 ;
                            ww := ww + ( d Mod 8 ) - 4 ;
                          End ;
                        If mm <> m Then
                          Begin
                            If prevw <= 0 Then
                              Begin
                                If w > 0 Then
                                  Begin
                                    If prevm = - 268435456 Then
                                      Begin
                                        If prevn = 4096 Then
                                          Begin
                                            gfboc ( mem [ curedges + 2 ] . hh . lh + xoff - 4096 , mem [ curedges + 2 ] . hh . rh + xoff - 4096 , mem [ curedges + 1 ] . hh . lh + yoff - 4096 , n + yoff ) ;
                                            curminm := mem [ curedges + 2 ] . hh . lh - 4096 + mem [ curedges + 3 ] . hh . lh ;
                                          End
                                        Else If prevn > n + 1 Then
                                               Begin
                                                 delta := prevn - n - 1 ;
                                                 If delta < 256 Then
                                                   Begin
                                                     Begin
                                                       gfbuf [ gfptr ] := 71 ;
                                                       gfptr := gfptr + 1 ;
                                                       If gfptr = gflimit Then gfswap ;
                                                     End ;
                                                     Begin
                                                       gfbuf [ gfptr ] := delta ;
                                                       gfptr := gfptr + 1 ;
                                                       If gfptr = gflimit Then gfswap ;
                                                     End ;
                                                   End
                                                 Else
                                                   Begin
                                                     Begin
                                                       gfbuf [ gfptr ] := 72 ;
                                                       gfptr := gfptr + 1 ;
                                                       If gfptr = gflimit Then gfswap ;
                                                     End ;
                                                     gftwo ( delta ) ;
                                                   End ;
                                               End
                                        Else
                                          Begin
                                            delta := m - curminm ;
                                            If delta > 164 Then
                                              Begin
                                                gfbuf [ gfptr ] := 70 ;
                                                gfptr := gfptr + 1 ;
                                                If gfptr = gflimit Then gfswap ;
                                              End
                                            Else
                                              Begin
                                                Begin
                                                  gfbuf [ gfptr ] := 74 + delta ;
                                                  gfptr := gfptr + 1 ;
                                                  If gfptr = gflimit Then gfswap ;
                                                End ;
                                                goto 30 ;
                                              End ;
                                          End ;
                                        gfpaint ( m - curminm ) ;
                                        30 : prevn := n ;
                                      End
                                    Else gfpaint ( m - prevm ) ;
                                    prevm := m ;
                                    prevw := w ;
                                  End ;
                              End
                            Else If w <= 0 Then
                                   Begin
                                     gfpaint ( m - prevm ) ;
                                     prevm := m ;
                                     prevw := w ;
                                   End ;
                            m := mm ;
                          End ;
                        w := ww ;
                        q := mem [ q ] . hh . rh ;
                      Until mm = 268435456 ;
                      If w <> 0 Then printnl ( 1057 ) ;
                      If prevm - mem [ curedges + 3 ] . hh . lh + xoff > gfmaxm Then gfmaxm := prevm - mem [ curedges + 3 ] . hh . lh + xoff ;
                      p := mem [ p ] . hh . lh ;
                      n := n - 1 ;
                    End ;
                  If prevn = 4096 Then
                    Begin
                      gfboc ( 0 , 0 , 0 , 0 ) ;
                      If gfmaxm < 0 Then gfmaxm := 0 ;
                      If gfminn > 0 Then gfminn := 0 ;
                    End
                  Else If prevn + yoff < gfminn Then gfminn := prevn + yoff ;
                  Begin
                    gfbuf [ gfptr ] := 69 ;
                    gfptr := gfptr + 1 ;
                    If gfptr = gflimit Then gfswap ;
                  End ;
                  gfprevptr := gfoffset + gfptr ;
                  totalchars := totalchars + 1 ;
                  printchar ( 93 ) ;
                  break ( termout ) ;
                  If internal [ 11 ] > 0 Then printedges ( 1056 , true , xoff , yoff ) ;
                End ;
                Procedure tryeq ( l , r : halfword ) ;

                Label 30 , 31 ;

                Var p : halfword ;
                  t : 16 .. 19 ;
                  q : halfword ;
                  pp : halfword ;
                  tt : 17 .. 19 ;
                  copied : boolean ;
                Begin
                  t := mem [ l ] . hh . b0 ;
                  If t = 16 Then
                    Begin
                      t := 17 ;
                      p := constdependency ( - mem [ l + 1 ] . int ) ;
                      q := p ;
                    End
                  Else If t = 19 Then
                         Begin
                           t := 17 ;
                           p := singledependency ( l ) ;
                           mem [ p + 1 ] . int := - mem [ p + 1 ] . int ;
                           q := depfinal ;
                         End
                  Else
                    Begin
                      p := mem [ l + 1 ] . hh . rh ;
                      q := p ;
                      While true Do
                        Begin
                          mem [ q + 1 ] . int := - mem [ q + 1 ] . int ;
                          If mem [ q ] . hh . lh = 0 Then goto 30 ;
                          q := mem [ q ] . hh . rh ;
                        End ;
                      30 : mem [ mem [ l + 1 ] . hh . lh ] . hh . rh := mem [ q ] . hh . rh ;
                      mem [ mem [ q ] . hh . rh + 1 ] . hh . lh := mem [ l + 1 ] . hh . lh ;
                      mem [ l ] . hh . b0 := 16 ;
                    End ;
                  If r = 0 Then If curtype = 16 Then
                                  Begin
                                    mem [ q + 1 ] . int := mem [ q + 1 ] . int + curexp ;
                                    goto 31 ;
                                  End
                  Else
                    Begin
                      tt := curtype ;
                      If tt = 19 Then pp := singledependency ( curexp )
                      Else pp := mem [ curexp + 1 ] . hh . rh ;
                    End
                  Else If mem [ r ] . hh . b0 = 16 Then
                         Begin
                           mem [ q + 1 ] . int := mem [ q + 1 ] . int + mem [ r + 1 ] . int ;
                           goto 31 ;
                         End
                  Else
                    Begin
                      tt := mem [ r ] . hh . b0 ;
                      If tt = 19 Then pp := singledependency ( r )
                      Else pp := mem [ r + 1 ] . hh . rh ;
                    End ;
                  If tt <> 19 Then copied := false
                  Else
                    Begin
                      copied := true ;
                      tt := 17 ;
                    End ;
                  watchcoefs := false ;
                  If t = tt Then p := pplusq ( p , pp , t )
                  Else If t = 18 Then p := pplusfq ( p , 65536 , pp , 18 , 17 )
                  Else
                    Begin
                      q := p ;
                      While mem [ q ] . hh . lh <> 0 Do
                        Begin
                          mem [ q + 1 ] . int := roundfraction ( mem [ q + 1 ] . int ) ;
                          q := mem [ q ] . hh . rh ;
                        End ;
                      t := 18 ;
                      p := pplusq ( p , pp , t ) ;
                    End ;
                  watchcoefs := true ; ;
                  If copied Then flushnodelist ( pp ) ;
                  31 : ;
                  If mem [ p ] . hh . lh = 0 Then
                    Begin
                      If abs ( mem [ p + 1 ] . int ) > 64 Then
                        Begin
                          Begin
                            If interaction = 3 Then ;
                            printnl ( 261 ) ;
                            print ( 897 ) ;
                          End ;
                          print ( 899 ) ;
                          printscaled ( mem [ p + 1 ] . int ) ;
                          printchar ( 41 ) ;
                          Begin
                            helpptr := 2 ;
                            helpline [ 1 ] := 898 ;
                            helpline [ 0 ] := 896 ;
                          End ;
                          putgeterror ;
                        End
                      Else If r = 0 Then
                             Begin
                               Begin
                                 If interaction = 3 Then ;
                                 printnl ( 261 ) ;
                                 print ( 599 ) ;
                               End ;
                               Begin
                                 helpptr := 2 ;
                                 helpline [ 1 ] := 600 ;
                                 helpline [ 0 ] := 601 ;
                               End ;
                               putgeterror ;
                             End ;
                      freenode ( p , 2 ) ;
                    End
                  Else
                    Begin
                      lineareq ( p , t ) ;
                      If r = 0 Then If curtype <> 16 Then If mem [ curexp ] . hh . b0 = 16 Then
                                                            Begin
                                                              pp := curexp ;
                                                              curexp := mem [ curexp + 1 ] . int ;
                                                              curtype := 16 ;
                                                              freenode ( pp , 2 ) ;
                                                            End ;
                    End ;
                End ;
                Procedure makeeq ( lhs : halfword ) ;

                Label 20 , 30 , 45 ;

                Var t : smallnumber ;
                  v : integer ;
                  p , q : halfword ;
                Begin
                  20 : t := mem [ lhs ] . hh . b0 ;
                  If t <= 14 Then v := mem [ lhs + 1 ] . int ;
                  Case t Of 
                    2 , 4 , 6 , 9 , 11 : If curtype = t + 1 Then
                                           Begin
                                             nonlineareq ( v , curexp , false ) ;
                                             unstashcurexp ( curexp ) ;
                                             goto 30 ;
                                           End
                                         Else If curtype = t Then
                                                Begin
                                                  If curtype <= 4 Then
                                                    Begin
                                                      If curtype = 4 Then
                                                        Begin
                                                          If strvsstr ( v , curexp ) <> 0 Then goto 45 ;
                                                        End
                                                      Else If v <> curexp Then goto 45 ;
                                                      Begin
                                                        Begin
                                                          If interaction = 3 Then ;
                                                          printnl ( 261 ) ;
                                                          print ( 599 ) ;
                                                        End ;
                                                        Begin
                                                          helpptr := 2 ;
                                                          helpline [ 1 ] := 600 ;
                                                          helpline [ 0 ] := 601 ;
                                                        End ;
                                                        putgeterror ;
                                                      End ;
                                                      goto 30 ;
                                                    End ;
                                                  Begin
                                                    If interaction = 3 Then ;
                                                    printnl ( 261 ) ;
                                                    print ( 894 ) ;
                                                  End ;
                                                  Begin
                                                    helpptr := 2 ;
                                                    helpline [ 1 ] := 895 ;
                                                    helpline [ 0 ] := 896 ;
                                                  End ;
                                                  putgeterror ;
                                                  goto 30 ;
                                                  45 :
                                                       Begin
                                                         If interaction = 3 Then ;
                                                         printnl ( 261 ) ;
                                                         print ( 897 ) ;
                                                       End ;
                                                  Begin
                                                    helpptr := 2 ;
                                                    helpline [ 1 ] := 898 ;
                                                    helpline [ 0 ] := 896 ;
                                                  End ;
                                                  putgeterror ;
                                                  goto 30 ;
                                                End ;
                    3 , 5 , 7 , 12 , 10 : If curtype = t - 1 Then
                                            Begin
                                              nonlineareq ( curexp , lhs , true ) ;
                                              goto 30 ;
                                            End
                                          Else If curtype = t Then
                                                 Begin
                                                   ringmerge ( lhs , curexp ) ;
                                                   goto 30 ;
                                                 End
                                          Else If curtype = 14 Then If t = 10 Then
                                                                      Begin
                                                                        pairtopath ;
                                                                        goto 20 ;
                                                                      End ;
                    13 , 14 : If curtype = t Then
                                Begin
                                  p := v + bignodesize [ t ] ;
                                  q := mem [ curexp + 1 ] . int + bignodesize [ t ] ;
                                  Repeat
                                    p := p - 2 ;
                                    q := q - 2 ;
                                    tryeq ( p , q ) ;
                                  Until p = v ;
                                  goto 30 ;
                                End ;
                    16 , 17 , 18 , 19 : If curtype >= 16 Then
                                          Begin
                                            tryeq ( lhs , 0 ) ;
                                            goto 30 ;
                                          End ;
                    1 : ;
                  End ;
                  disperr ( lhs , 285 ) ;
                  disperr ( 0 , 891 ) ;
                  If mem [ lhs ] . hh . b0 <= 14 Then printtype ( mem [ lhs ] . hh . b0 )
                  Else print ( 341 ) ;
                  printchar ( 61 ) ;
                  If curtype <= 14 Then printtype ( curtype )
                  Else print ( 341 ) ;
                  printchar ( 41 ) ;
                  Begin
                    helpptr := 2 ;
                    helpline [ 1 ] := 892 ;
                    helpline [ 0 ] := 893 ;
                  End ;
                  putgeterror ;
                  30 :
                       Begin
                         If aritherror Then cleararith ;
                       End ;
                  recyclevalue ( lhs ) ;
                  freenode ( lhs , 2 ) ;
                End ;
                Procedure doassignment ;
                forward ;
                Procedure doequation ;

                Var lhs : halfword ;
                  p : halfword ;
                Begin
                  lhs := stashcurexp ;
                  getxnext ;
                  varflag := 77 ;
                  scanexpression ;
                  If curcmd = 51 Then doequation
                  Else If curcmd = 77 Then doassignment ;
                  If internal [ 7 ] > 131072 Then
                    Begin
                      begindiagnostic ;
                      printnl ( 850 ) ;
                      printexp ( lhs , 0 ) ;
                      print ( 886 ) ;
                      printexp ( 0 , 0 ) ;
                      print ( 842 ) ;
                      enddiagnostic ( false ) ;
                    End ;
                  If curtype = 10 Then If mem [ lhs ] . hh . b0 = 14 Then
                                         Begin
                                           p := stashcurexp ;
                                           unstashcurexp ( lhs ) ;
                                           lhs := p ;
                                         End ;
                  makeeq ( lhs ) ;
                End ;
                Procedure doassignment ;

                Var lhs : halfword ;
                  p : halfword ;
                  q : halfword ;
                Begin
                  If curtype <> 20 Then
                    Begin
                      disperr ( 0 , 883 ) ;
                      Begin
                        helpptr := 2 ;
                        helpline [ 1 ] := 884 ;
                        helpline [ 0 ] := 885 ;
                      End ;
                      error ;
                      doequation ;
                    End
                  Else
                    Begin
                      lhs := curexp ;
                      curtype := 1 ;
                      getxnext ;
                      varflag := 77 ;
                      scanexpression ;
                      If curcmd = 51 Then doequation
                      Else If curcmd = 77 Then doassignment ;
                      If internal [ 7 ] > 131072 Then
                        Begin
                          begindiagnostic ;
                          printnl ( 123 ) ;
                          If mem [ lhs ] . hh . lh > 2369 Then slowprint ( intname [ mem [ lhs ] . hh . lh - ( 2369 ) ] )
                          Else showtokenlist ( lhs , 0 , 1000 , 0 ) ;
                          print ( 461 ) ;
                          printexp ( 0 , 0 ) ;
                          printchar ( 125 ) ;
                          enddiagnostic ( false ) ;
                        End ;
                      If mem [ lhs ] . hh . lh > 2369 Then If curtype = 16 Then internal [ mem [ lhs ] . hh . lh - ( 2369 ) ] := curexp
                      Else
                        Begin
                          disperr ( 0 , 887 ) ;
                          slowprint ( intname [ mem [ lhs ] . hh . lh - ( 2369 ) ] ) ;
                          print ( 888 ) ;
                          Begin
                            helpptr := 2 ;
                            helpline [ 1 ] := 889 ;
                            helpline [ 0 ] := 890 ;
                          End ;
                          putgeterror ;
                        End
                      Else
                        Begin
                          p := findvariable ( lhs ) ;
                          If p <> 0 Then
                            Begin
                              q := stashcurexp ;
                              curtype := undtype ( p ) ;
                              recyclevalue ( p ) ;
                              mem [ p ] . hh . b0 := curtype ;
                              mem [ p + 1 ] . int := 0 ;
                              makeexpcopy ( p ) ;
                              p := stashcurexp ;
                              unstashcurexp ( q ) ;
                              makeeq ( p ) ;
                            End
                          Else
                            Begin
                              obliterated ( lhs ) ;
                              putgeterror ;
                            End ;
                        End ;
                      flushnodelist ( lhs ) ;
                    End ;
                End ;
                Procedure dotypedeclaration ;

                Var t : smallnumber ;
                  p : halfword ;
                  q : halfword ;
                Begin
                  If curmod >= 13 Then t := curmod
                  Else t := curmod + 1 ;
                  Repeat
                    p := scandeclaredvariable ;
                    flushvariable ( eqtb [ mem [ p ] . hh . lh ] . rh , mem [ p ] . hh . rh , false ) ;
                    q := findvariable ( p ) ;
                    If q <> 0 Then
                      Begin
                        mem [ q ] . hh . b0 := t ;
                        mem [ q + 1 ] . int := 0 ;
                      End
                    Else
                      Begin
                        Begin
                          If interaction = 3 Then ;
                          printnl ( 261 ) ;
                          print ( 900 ) ;
                        End ;
                        Begin
                          helpptr := 2 ;
                          helpline [ 1 ] := 901 ;
                          helpline [ 0 ] := 902 ;
                        End ;
                        putgeterror ;
                      End ;
                    flushlist ( p ) ;
                    If curcmd < 82 Then
                      Begin
                        Begin
                          If interaction = 3 Then ;
                          printnl ( 261 ) ;
                          print ( 903 ) ;
                        End ;
                        Begin
                          helpptr := 5 ;
                          helpline [ 4 ] := 904 ;
                          helpline [ 3 ] := 905 ;
                          helpline [ 2 ] := 906 ;
                          helpline [ 1 ] := 907 ;
                          helpline [ 0 ] := 908 ;
                        End ;
                        If curcmd = 42 Then helpline [ 2 ] := 909 ;
                        putgeterror ;
                        scannerstatus := 2 ;
                        Repeat
                          getnext ;
                          If curcmd = 39 Then
                            Begin
                              If strref [ curmod ] < 127 Then If strref [ curmod ] > 1 Then strref [ curmod ] := strref [ curmod ] - 1
                              Else flushstring ( curmod ) ;
                            End ;
                        Until curcmd >= 82 ;
                        scannerstatus := 0 ;
                      End ;
                  Until curcmd > 82 ;
                End ;
                Procedure dorandomseed ;
                Begin
                  getxnext ;
                  If curcmd <> 77 Then
                    Begin
                      missingerr ( 461 ) ;
                      Begin
                        helpptr := 1 ;
                        helpline [ 0 ] := 914 ;
                      End ;
                      backerror ;
                    End ;
                  getxnext ;
                  scanexpression ;
                  If curtype <> 16 Then
                    Begin
                      disperr ( 0 , 915 ) ;
                      Begin
                        helpptr := 2 ;
                        helpline [ 1 ] := 916 ;
                        helpline [ 0 ] := 917 ;
                      End ;
                      putgetflusherror ( 0 ) ;
                    End
                  Else
                    Begin
                      initrandoms ( curexp ) ;
                      If selector >= 2 Then
                        Begin
                          oldsetting := selector ;
                          selector := 2 ;
                          printnl ( 918 ) ;
                          printscaled ( curexp ) ;
                          printchar ( 125 ) ;
                          printnl ( 285 ) ;
                          selector := oldsetting ;
                        End ;
                    End ;
                End ;
                Procedure doprotection ;

                Var m : 0 .. 1 ;
                  t : halfword ;
                Begin
                  m := curmod ;
                  Repeat
                    getsymbol ;
                    t := eqtb [ cursym ] . lh ;
                    If m = 0 Then
                      Begin
                        If t >= 86 Then eqtb [ cursym ] . lh := t - 86 ;
                      End
                    Else If t < 86 Then eqtb [ cursym ] . lh := t + 86 ;
                    getxnext ;
                  Until curcmd <> 82 ;
                End ;
                Procedure defdelims ;

                Var ldelim , rdelim : halfword ;
                Begin
                  getclearsymbol ;
                  ldelim := cursym ;
                  getclearsymbol ;
                  rdelim := cursym ;
                  eqtb [ ldelim ] . lh := 31 ;
                  eqtb [ ldelim ] . rh := rdelim ;
                  eqtb [ rdelim ] . lh := 62 ;
                  eqtb [ rdelim ] . rh := ldelim ;
                  getxnext ;
                End ;
                Procedure dostatement ;
                forward ;
                Procedure dointerim ;
                Begin
                  getxnext ;
                  If curcmd <> 40 Then
                    Begin
                      Begin
                        If interaction = 3 Then ;
                        printnl ( 261 ) ;
                        print ( 924 ) ;
                      End ;
                      If cursym = 0 Then print ( 929 )
                      Else slowprint ( hash [ cursym ] . rh ) ;
                      print ( 930 ) ;
                      Begin
                        helpptr := 1 ;
                        helpline [ 0 ] := 931 ;
                      End ;
                      backerror ;
                    End
                  Else
                    Begin
                      saveinternal ( curmod ) ;
                      backinput ;
                    End ;
                  dostatement ;
                End ;
                Procedure dolet ;

                Var l : halfword ;
                Begin
                  getsymbol ;
                  l := cursym ;
                  getxnext ;
                  If curcmd <> 51 Then If curcmd <> 77 Then
                                         Begin
                                           missingerr ( 61 ) ;
                                           Begin
                                             helpptr := 3 ;
                                             helpline [ 2 ] := 932 ;
                                             helpline [ 1 ] := 672 ;
                                             helpline [ 0 ] := 933 ;
                                           End ;
                                           backerror ;
                                         End ;
                  getsymbol ;
                  Case curcmd Of 
                    10 , 53 , 44 , 49 : mem [ curmod ] . hh . lh := mem [ curmod ] . hh . lh + 1 ;
                    others :
                  End ;
                  clearsymbol ( l , false ) ;
                  eqtb [ l ] . lh := curcmd ;
                  If curcmd = 41 Then eqtb [ l ] . rh := 0
                  Else eqtb [ l ] . rh := curmod ;
                  getxnext ;
                End ;
                Procedure donewinternal ;
                Begin
                  Repeat
                    If intptr = maxinternal Then overflow ( 934 , maxinternal ) ;
                    getclearsymbol ;
                    intptr := intptr + 1 ;
                    eqtb [ cursym ] . lh := 40 ;
                    eqtb [ cursym ] . rh := intptr ;
                    intname [ intptr ] := hash [ cursym ] . rh ;
                    internal [ intptr ] := 0 ;
                    getxnext ;
                  Until curcmd <> 82 ;
                End ;
                Procedure doshow ;
                Begin
                  Repeat
                    getxnext ;
                    scanexpression ;
                    printnl ( 765 ) ;
                    printexp ( 0 , 2 ) ;
                    flushcurexp ( 0 ) ;
                  Until curcmd <> 82 ;
                End ;
                Procedure disptoken ;
                Begin
                  printnl ( 940 ) ;
                  If cursym = 0 Then
                    Begin
                      If curcmd = 42 Then printscaled ( curmod )
                      Else If curcmd = 38 Then
                             Begin
                               gpointer := curmod ;
                               printcapsule ;
                             End
                      Else
                        Begin
                          printchar ( 34 ) ;
                          slowprint ( curmod ) ;
                          printchar ( 34 ) ;
                          Begin
                            If strref [ curmod ] < 127 Then If strref [ curmod ] > 1 Then strref [ curmod ] := strref [ curmod ] - 1
                            Else flushstring ( curmod ) ;
                          End ;
                        End ;
                    End
                  Else
                    Begin
                      slowprint ( hash [ cursym ] . rh ) ;
                      printchar ( 61 ) ;
                      If eqtb [ cursym ] . lh >= 86 Then print ( 941 ) ;
                      printcmdmod ( curcmd , curmod ) ;
                      If curcmd = 10 Then
                        Begin
                          println ;
                          showmacro ( curmod , 0 , 100000 ) ;
                        End ;
                    End ;
                End ;
                Procedure doshowtoken ;
                Begin
                  Repeat
                    getnext ;
                    disptoken ;
                    getxnext ;
                  Until curcmd <> 82 ;
                End ;
                Procedure doshowstats ;
                Begin
                  printnl ( 950 ) ;
                  print ( 358 ) ;
                  print ( 558 ) ;
                  printint ( himemmin - lomemmax - 1 ) ;
                  print ( 951 ) ;
                  println ;
                  printnl ( 952 ) ;
                  printint ( strptr - initstrptr ) ;
                  printchar ( 38 ) ;
                  printint ( poolptr - initpoolptr ) ;
                  print ( 558 ) ;
                  printint ( maxstrings - maxstrptr ) ;
                  printchar ( 38 ) ;
                  printint ( poolsize - maxpoolptr ) ;
                  print ( 951 ) ;
                  println ;
                  getxnext ;
                End ;
                Procedure dispvar ( p : halfword ) ;

                Var q : halfword ;
                  n : 0 .. maxprintline ;
                Begin
                  If mem [ p ] . hh . b0 = 21 Then
                    Begin
                      q := mem [ p + 1 ] . hh . lh ;
                      Repeat
                        dispvar ( q ) ;
                        q := mem [ q ] . hh . rh ;
                      Until q = 17 ;
                      q := mem [ p + 1 ] . hh . rh ;
                      While mem [ q ] . hh . b1 = 3 Do
                        Begin
                          dispvar ( q ) ;
                          q := mem [ q ] . hh . rh ;
                        End ;
                    End
                  Else If mem [ p ] . hh . b0 >= 22 Then
                         Begin
                           printnl ( 285 ) ;
                           printvariablename ( p ) ;
                           If mem [ p ] . hh . b0 > 22 Then print ( 664 ) ;
                           print ( 953 ) ;
                           If fileoffset >= maxprintline - 20 Then n := 5
                           Else n := maxprintline - fileoffset - 15 ;
                           showmacro ( mem [ p + 1 ] . int , 0 , n ) ;
                         End
                  Else If mem [ p ] . hh . b0 <> 0 Then
                         Begin
                           printnl ( 285 ) ;
                           printvariablename ( p ) ;
                           printchar ( 61 ) ;
                           printexp ( p , 0 ) ;
                         End ;
                End ;
                Procedure doshowvar ;

                Label 30 ;
                Begin
                  Repeat
                    getnext ;
                    If cursym > 0 Then If cursym <= 2369 Then If curcmd = 41 Then If curmod <> 0 Then
                                                                                    Begin
                                                                                      dispvar ( curmod ) ;
                                                                                      goto 30 ;
                                                                                    End ;
                    disptoken ;
                    30 : getxnext ;
                  Until curcmd <> 82 ;
                End ;
                Procedure doshowdependencies ;

                Var p : halfword ;
                Begin
                  p := mem [ 13 ] . hh . rh ;
                  While p <> 13 Do
                    Begin
                      If interesting ( p ) Then
                        Begin
                          printnl ( 285 ) ;
                          printvariablename ( p ) ;
                          If mem [ p ] . hh . b0 = 17 Then printchar ( 61 )
                          Else print ( 768 ) ;
                          printdependency ( mem [ p + 1 ] . hh . rh , mem [ p ] . hh . b0 ) ;
                        End ;
                      p := mem [ p + 1 ] . hh . rh ;
                      While mem [ p ] . hh . lh <> 0 Do
                        p := mem [ p ] . hh . rh ;
                      p := mem [ p ] . hh . rh ;
                    End ;
                  getxnext ;
                End ;
                Procedure doshowwhatever ;
                Begin
                  If interaction = 3 Then ;
                  Case curmod Of 
                    0 : doshowtoken ;
                    1 : doshowstats ;
                    2 : doshow ;
                    3 : doshowvar ;
                    4 : doshowdependencies ;
                  End ;
                  If internal [ 32 ] > 0 Then
                    Begin
                      Begin
                        If interaction = 3 Then ;
                        printnl ( 261 ) ;
                        print ( 954 ) ;
                      End ;
                      If interaction < 3 Then
                        Begin
                          helpptr := 0 ;
                          errorcount := errorcount - 1 ;
                        End
                      Else
                        Begin
                          helpptr := 1 ;
                          helpline [ 0 ] := 955 ;
                        End ;
                      If curcmd = 83 Then error
                      Else putgeterror ;
                    End ;
                End ;
                Function scanwith : boolean ;

                Var t : smallnumber ;
                  result : boolean ;
                Begin
                  t := curmod ;
                  curtype := 1 ;
                  getxnext ;
                  scanexpression ;
                  result := false ;
                  If curtype <> t Then
                    Begin
                      disperr ( 0 , 963 ) ;
                      Begin
                        helpptr := 2 ;
                        helpline [ 1 ] := 964 ;
                        helpline [ 0 ] := 965 ;
                      End ;
                      If t = 6 Then helpline [ 1 ] := 966 ;
                      putgetflusherror ( 0 ) ;
                    End
                  Else If curtype = 6 Then result := true
                  Else
                    Begin
                      curexp := roundunscaled ( curexp ) ;
                      If ( abs ( curexp ) < 4 ) And ( curexp <> 0 ) Then result := true
                      Else
                        Begin
                          Begin
                            If interaction = 3 Then ;
                            printnl ( 261 ) ;
                            print ( 967 ) ;
                          End ;
                          Begin
                            helpptr := 1 ;
                            helpline [ 0 ] := 965 ;
                          End ;
                          putgetflusherror ( 0 ) ;
                        End ;
                    End ;
                  scanwith := result ;
                End ;
                Procedure findedgesvar ( t : halfword ) ;

                Var p : halfword ;
                Begin
                  p := findvariable ( t ) ;
                  curedges := 0 ;
                  If p = 0 Then
                    Begin
                      obliterated ( t ) ;
                      putgeterror ;
                    End
                  Else If mem [ p ] . hh . b0 <> 11 Then
                         Begin
                           Begin
                             If interaction = 3 Then ;
                             printnl ( 261 ) ;
                             print ( 790 ) ;
                           End ;
                           showtokenlist ( t , 0 , 1000 , 0 ) ;
                           print ( 968 ) ;
                           printtype ( mem [ p ] . hh . b0 ) ;
                           printchar ( 41 ) ;
                           Begin
                             helpptr := 2 ;
                             helpline [ 1 ] := 969 ;
                             helpline [ 0 ] := 970 ;
                           End ;
                           putgeterror ;
                         End
                  Else curedges := mem [ p + 1 ] . int ;
                  flushnodelist ( t ) ;
                End ;
                Procedure doaddto ;

                Label 30 , 45 ;

                Var lhs , rhs : halfword ;
                  w : integer ;
                  p : halfword ;
                  q : halfword ;
                  addtotype : 0 .. 2 ;
                Begin
                  getxnext ;
                  varflag := 68 ;
                  scanprimary ;
                  If curtype <> 20 Then
                    Begin
                      disperr ( 0 , 971 ) ;
                      Begin
                        helpptr := 4 ;
                        helpline [ 3 ] := 972 ;
                        helpline [ 2 ] := 973 ;
                        helpline [ 1 ] := 974 ;
                        helpline [ 0 ] := 970 ;
                      End ;
                      putgetflusherror ( 0 ) ;
                    End
                  Else
                    Begin
                      lhs := curexp ;
                      addtotype := curmod ;
                      curtype := 1 ;
                      getxnext ;
                      scanexpression ;
                      If addtotype = 2 Then
                        Begin
                          findedgesvar ( lhs ) ;
                          If curedges = 0 Then flushcurexp ( 0 )
                          Else If curtype <> 11 Then
                                 Begin
                                   disperr ( 0 , 975 ) ;
                                   Begin
                                     helpptr := 2 ;
                                     helpline [ 1 ] := 976 ;
                                     helpline [ 0 ] := 970 ;
                                   End ;
                                   putgetflusherror ( 0 ) ;
                                 End
                          Else
                            Begin
                              mergeedges ( curexp ) ;
                              flushcurexp ( 0 ) ;
                            End ;
                        End
                      Else
                        Begin
                          If curtype = 14 Then pairtopath ;
                          If curtype <> 9 Then
                            Begin
                              disperr ( 0 , 975 ) ;
                              Begin
                                helpptr := 2 ;
                                helpline [ 1 ] := 977 ;
                                helpline [ 0 ] := 970 ;
                              End ;
                              putgetflusherror ( 0 ) ;
                              flushtokenlist ( lhs ) ;
                            End
                          Else
                            Begin
                              rhs := curexp ;
                              w := 1 ;
                              curpen := 3 ;
                              While curcmd = 66 Do
                                If scanwith Then If curtype = 16 Then w := curexp
                                Else
                                  Begin
                                    If mem [ curpen ] . hh . lh = 0 Then tosspen ( curpen )
                                    Else mem [ curpen ] . hh . lh := mem [ curpen ] . hh . lh - 1 ;
                                    curpen := curexp ;
                                  End ;
                              findedgesvar ( lhs ) ;
                              If curedges = 0 Then tossknotlist ( rhs )
                              Else
                                Begin
                                  lhs := 0 ;
                                  curpathtype := addtotype ;
                                  If mem [ rhs ] . hh . b0 = 0 Then If curpathtype = 0 Then If mem [ rhs ] . hh . rh = rhs Then
                                                                                              Begin
                                                                                                mem [ rhs + 5 ] . int := mem [ rhs + 1 ] . int ;
                                                                                                mem [ rhs + 6 ] . int := mem [ rhs + 2 ] . int ;
                                                                                                mem [ rhs + 3 ] . int := mem [ rhs + 1 ] . int ;
                                                                                                mem [ rhs + 4 ] . int := mem [ rhs + 2 ] . int ;
                                                                                                mem [ rhs ] . hh . b0 := 1 ;
                                                                                                mem [ rhs ] . hh . b1 := 1 ;
                                                                                              End
                                  Else
                                    Begin
                                      p := htapypoc ( rhs ) ;
                                      q := mem [ p ] . hh . rh ;
                                      mem [ pathtail + 5 ] . int := mem [ q + 5 ] . int ;
                                      mem [ pathtail + 6 ] . int := mem [ q + 6 ] . int ;
                                      mem [ pathtail ] . hh . b1 := mem [ q ] . hh . b1 ;
                                      mem [ pathtail ] . hh . rh := mem [ q ] . hh . rh ;
                                      freenode ( q , 7 ) ;
                                      mem [ p + 5 ] . int := mem [ rhs + 5 ] . int ;
                                      mem [ p + 6 ] . int := mem [ rhs + 6 ] . int ;
                                      mem [ p ] . hh . b1 := mem [ rhs ] . hh . b1 ;
                                      mem [ p ] . hh . rh := mem [ rhs ] . hh . rh ;
                                      freenode ( rhs , 7 ) ;
                                      rhs := p ;
                                    End
                                  Else
                                    Begin
                                      Begin
                                        If interaction = 3 Then ;
                                        printnl ( 261 ) ;
                                        print ( 978 ) ;
                                      End ;
                                      Begin
                                        helpptr := 2 ;
                                        helpline [ 1 ] := 979 ;
                                        helpline [ 0 ] := 970 ;
                                      End ;
                                      putgeterror ;
                                      tossknotlist ( rhs ) ;
                                      goto 45 ;
                                    End
                                  Else If curpathtype = 0 Then lhs := htapypoc ( rhs ) ;
                                  curwt := w ;
                                  rhs := makespec ( rhs , mem [ curpen + 9 ] . int , internal [ 5 ] ) ;
                                  If turningnumber <= 0 Then If curpathtype <> 0 Then If internal [ 39 ] > 0 Then If ( turningnumber < 0 ) And ( mem [ curpen ] . hh . rh = 0 ) Then curwt := - curwt
                                  Else
                                    Begin
                                      If turningnumber = 0 Then If ( internal [ 39 ] <= 65536 ) And ( mem [ curpen ] . hh . rh = 0 ) Then goto 30
                                      Else printstrange ( 980 )
                                      Else printstrange ( 981 ) ;
                                      Begin
                                        helpptr := 3 ;
                                        helpline [ 2 ] := 982 ;
                                        helpline [ 1 ] := 983 ;
                                        helpline [ 0 ] := 984 ;
                                      End ;
                                      putgeterror ;
                                    End ;
                                  30 : ;
                                  If mem [ curpen + 9 ] . int = 0 Then fillspec ( rhs )
                                  Else fillenvelope ( rhs ) ;
                                  If lhs <> 0 Then
                                    Begin
                                      revturns := true ;
                                      lhs := makespec ( lhs , mem [ curpen + 9 ] . int , internal [ 5 ] ) ;
                                      revturns := false ;
                                      If mem [ curpen + 9 ] . int = 0 Then fillspec ( lhs )
                                      Else fillenvelope ( lhs ) ;
                                    End ;
                                  45 :
                                End ;
                              If mem [ curpen ] . hh . lh = 0 Then tosspen ( curpen )
                              Else mem [ curpen ] . hh . lh := mem [ curpen ] . hh . lh - 1 ;
                            End ;
                        End ;
                    End ;
                End ;
                Function tfmcheck ( m : smallnumber ) : scaled ;
                Begin
                  If abs ( internal [ m ] ) >= 134217728 Then
                    Begin
                      Begin
                        If interaction = 3 Then ;
                        printnl ( 261 ) ;
                        print ( 1001 ) ;
                      End ;
                      print ( intname [ m ] ) ;
                      print ( 1002 ) ;
                      Begin
                        helpptr := 1 ;
                        helpline [ 0 ] := 1003 ;
                      End ;
                      putgeterror ;
                      If internal [ m ] > 0 Then tfmcheck := 134217727
                      Else tfmcheck := - 134217727 ;
                    End
                  Else tfmcheck := internal [ m ] ;
                End ;
                Procedure doshipout ;

                Label 10 ;

                Var c : integer ;
                Begin
                  getxnext ;
                  varflag := 83 ;
                  scanexpression ;
                  If curtype <> 20 Then If curtype = 11 Then curedges := curexp
                  Else
                    Begin
                      Begin
                        disperr ( 0 , 971 ) ;
                        Begin
                          helpptr := 4 ;
                          helpline [ 3 ] := 972 ;
                          helpline [ 2 ] := 973 ;
                          helpline [ 1 ] := 974 ;
                          helpline [ 0 ] := 970 ;
                        End ;
                        putgetflusherror ( 0 ) ;
                      End ;
                      goto 10 ;
                    End
                  Else
                    Begin
                      findedgesvar ( curexp ) ;
                      curtype := 1 ;
                    End ;
                  If curedges <> 0 Then
                    Begin
                      c := roundunscaled ( internal [ 18 ] ) Mod 256 ;
                      If c < 0 Then c := c + 256 ;
                      If c < bc Then bc := c ;
                      If c > ec Then ec := c ;
                      charexists [ c ] := true ;
                      gfdx [ c ] := internal [ 24 ] ;
                      gfdy [ c ] := internal [ 25 ] ;
                      tfmwidth [ c ] := tfmcheck ( 20 ) ;
                      tfmheight [ c ] := tfmcheck ( 21 ) ;
                      tfmdepth [ c ] := tfmcheck ( 22 ) ;
                      tfmitalcorr [ c ] := tfmcheck ( 23 ) ;
                      If internal [ 34 ] >= 0 Then shipout ( c ) ;
                    End ;
                  flushcurexp ( 0 ) ;
                  10 :
                End ;
                Procedure dodisplay ;

                Label 45 , 50 , 10 ;

                Var e : halfword ;
                Begin
                  getxnext ;
                  varflag := 73 ;
                  scanprimary ;
                  If curtype <> 20 Then
                    Begin
                      disperr ( 0 , 971 ) ;
                      Begin
                        helpptr := 4 ;
                        helpline [ 3 ] := 972 ;
                        helpline [ 2 ] := 973 ;
                        helpline [ 1 ] := 974 ;
                        helpline [ 0 ] := 970 ;
                      End ;
                      putgetflusherror ( 0 ) ;
                    End
                  Else
                    Begin
                      e := curexp ;
                      curtype := 1 ;
                      getxnext ;
                      scanexpression ;
                      If curtype <> 16 Then goto 50 ;
                      curexp := roundunscaled ( curexp ) ;
                      If curexp < 0 Then goto 45 ;
                      If curexp > 15 Then goto 45 ;
                      If Not windowopen [ curexp ] Then goto 45 ;
                      findedgesvar ( e ) ;
                      If curedges <> 0 Then dispedges ( curexp ) ;
                      goto 10 ;
                      45 : curexp := curexp * 65536 ;
                      50 : disperr ( 0 , 985 ) ;
                      Begin
                        helpptr := 1 ;
                        helpline [ 0 ] := 986 ;
                      End ;
                      putgetflusherror ( 0 ) ;
                      flushtokenlist ( e ) ;
                    End ;
                  10 :
                End ;
                Function getpair ( c : commandcode ) : boolean ;

                Var p : halfword ;
                  b : boolean ;
                Begin
                  If curcmd <> c Then getpair := false
                  Else
                    Begin
                      getxnext ;
                      scanexpression ;
                      If nicepair ( curexp , curtype ) Then
                        Begin
                          p := mem [ curexp + 1 ] . int ;
                          curx := mem [ p + 1 ] . int ;
                          cury := mem [ p + 3 ] . int ;
                          b := true ;
                        End
                      Else b := false ;
                      flushcurexp ( 0 ) ;
                      getpair := b ;
                    End ;
                End ;
                Procedure doopenwindow ;

                Label 45 , 10 ;

                Var k : integer ;
                  r0 , c0 , r1 , c1 : scaled ;
                Begin
                  getxnext ;
                  scanexpression ;
                  If curtype <> 16 Then goto 45 ;
                  k := roundunscaled ( curexp ) ;
                  If k < 0 Then goto 45 ;
                  If k > 15 Then goto 45 ;
                  If Not getpair ( 70 ) Then goto 45 ;
                  r0 := curx ;
                  c0 := cury ;
                  If Not getpair ( 71 ) Then goto 45 ;
                  r1 := curx ;
                  c1 := cury ;
                  If Not getpair ( 72 ) Then goto 45 ;
                  openawindow ( k , r0 , c0 , r1 , c1 , curx , cury ) ;
                  goto 10 ;
                  45 :
                       Begin
                         If interaction = 3 Then ;
                         printnl ( 261 ) ;
                         print ( 987 ) ;
                       End ;
                  Begin
                    helpptr := 2 ;
                    helpline [ 1 ] := 988 ;
                    helpline [ 0 ] := 989 ;
                  End ;
                  putgeterror ;
                  10 :
                End ;
                Procedure docull ;

                Label 45 , 10 ;

                Var e : halfword ;
                  keeping : 0 .. 1 ;
                  w , win , wout : integer ;
                Begin
                  w := 1 ;
                  getxnext ;
                  varflag := 67 ;
                  scanprimary ;
                  If curtype <> 20 Then
                    Begin
                      disperr ( 0 , 971 ) ;
                      Begin
                        helpptr := 4 ;
                        helpline [ 3 ] := 972 ;
                        helpline [ 2 ] := 973 ;
                        helpline [ 1 ] := 974 ;
                        helpline [ 0 ] := 970 ;
                      End ;
                      putgetflusherror ( 0 ) ;
                    End
                  Else
                    Begin
                      e := curexp ;
                      curtype := 1 ;
                      keeping := curmod ;
                      If Not getpair ( 67 ) Then goto 45 ;
                      While ( curcmd = 66 ) And ( curmod = 16 ) Do
                        If scanwith Then w := curexp ;
                      If curx > cury Then goto 45 ;
                      If keeping = 0 Then
                        Begin
                          If ( curx > 0 ) Or ( cury < 0 ) Then goto 45 ;
                          wout := w ;
                          win := 0 ;
                        End
                      Else
                        Begin
                          If ( curx <= 0 ) And ( cury >= 0 ) Then goto 45 ;
                          wout := 0 ;
                          win := w ;
                        End ;
                      findedgesvar ( e ) ;
                      If curedges <> 0 Then culledges ( floorunscaled ( curx + 65535 ) , floorunscaled ( cury ) , wout , win ) ;
                      goto 10 ;
                      45 :
                           Begin
                             If interaction = 3 Then ;
                             printnl ( 261 ) ;
                             print ( 990 ) ;
                           End ;
                      Begin
                        helpptr := 1 ;
                        helpline [ 0 ] := 991 ;
                      End ;
                      putgeterror ;
                      flushtokenlist ( e ) ;
                    End ;
                  10 :
                End ;
                Procedure domessage ;

                Var m : 0 .. 2 ;
                Begin
                  m := curmod ;
                  getxnext ;
                  scanexpression ;
                  If curtype <> 4 Then
                    Begin
                      disperr ( 0 , 699 ) ;
                      Begin
                        helpptr := 1 ;
                        helpline [ 0 ] := 995 ;
                      End ;
                      putgeterror ;
                    End
                  Else Case m Of 
                         0 :
                             Begin
                               printnl ( 285 ) ;
                               slowprint ( curexp ) ;
                             End ;
                         1 :
                             Begin
                               Begin
                                 If interaction = 3 Then ;
                                 printnl ( 261 ) ;
                                 print ( 285 ) ;
                               End ;
                               slowprint ( curexp ) ;
                               If errhelp <> 0 Then useerrhelp := true
                               Else If longhelpseen Then
                                      Begin
                                        helpptr := 1 ;
                                        helpline [ 0 ] := 996 ;
                                      End
                               Else
                                 Begin
                                   If interaction < 3 Then longhelpseen := true ;
                                   Begin
                                     helpptr := 4 ;
                                     helpline [ 3 ] := 997 ;
                                     helpline [ 2 ] := 998 ;
                                     helpline [ 1 ] := 999 ;
                                     helpline [ 0 ] := 1000 ;
                                   End ;
                                 End ;
                               putgeterror ;
                               useerrhelp := false ;
                             End ;
                         2 :
                             Begin
                               If errhelp <> 0 Then
                                 Begin
                                   If strref [ errhelp ] < 127 Then If strref [ errhelp ] > 1 Then strref [ errhelp ] := strref [ errhelp ] - 1
                                   Else flushstring ( errhelp ) ;
                                 End ;
                               If ( strstart [ curexp + 1 ] - strstart [ curexp ] ) = 0 Then errhelp := 0
                               Else
                                 Begin
                                   errhelp := curexp ;
                                   Begin
                                     If strref [ errhelp ] < 127 Then strref [ errhelp ] := strref [ errhelp ] + 1 ;
                                   End ;
                                 End ;
                             End ;
                    End ;
                  flushcurexp ( 0 ) ;
                End ;
                Function getcode : eightbits ;

                Label 40 ;

                Var c : integer ;
                Begin
                  getxnext ;
                  scanexpression ;
                  If curtype = 16 Then
                    Begin
                      c := roundunscaled ( curexp ) ;
                      If c >= 0 Then If c < 256 Then goto 40 ;
                    End
                  Else If curtype = 4 Then If ( strstart [ curexp + 1 ] - strstart [ curexp ] ) = 1 Then
                                             Begin
                                               c := strpool [ strstart [ curexp ] ] ;
                                               goto 40 ;
                                             End ;
                  disperr ( 0 , 1009 ) ;
                  Begin
                    helpptr := 2 ;
                    helpline [ 1 ] := 1010 ;
                    helpline [ 0 ] := 1011 ;
                  End ;
                  putgetflusherror ( 0 ) ;
                  c := 0 ;
                  40 : getcode := c ;
                End ;
                Procedure settag ( c : halfword ; t : smallnumber ; r : halfword ) ;
                Begin
                  If chartag [ c ] = 0 Then
                    Begin
                      chartag [ c ] := t ;
                      charremainder [ c ] := r ;
                      If t = 1 Then
                        Begin
                          labelptr := labelptr + 1 ;
                          labelloc [ labelptr ] := r ;
                          labelchar [ labelptr ] := c ;
                        End ;
                    End
                  Else
                    Begin
                      Begin
                        If interaction = 3 Then ;
                        printnl ( 261 ) ;
                        print ( 1012 ) ;
                      End ;
                      If ( c > 32 ) And ( c < 127 ) Then print ( c )
                      Else If c = 256 Then print ( 1013 )
                      Else
                        Begin
                          print ( 1014 ) ;
                          printint ( c ) ;
                        End ;
                      print ( 1015 ) ;
                      Case chartag [ c ] Of 
                        1 : print ( 1016 ) ;
                        2 : print ( 1017 ) ;
                        3 : print ( 1006 ) ;
                      End ;
                      Begin
                        helpptr := 2 ;
                        helpline [ 1 ] := 1018 ;
                        helpline [ 0 ] := 970 ;
                      End ;
                      putgeterror ;
                    End ;
                End ;
                Procedure dotfmcommand ;

                Label 22 , 30 ;

                Var c , cc : 0 .. 256 ;
                  k : 0 .. maxkerns ;
                  j : integer ;
                Begin
                  Case curmod Of 
                    0 :
                        Begin
                          c := getcode ;
                          While curcmd = 81 Do
                            Begin
                              cc := getcode ;
                              settag ( c , 2 , cc ) ;
                              c := cc ;
                            End ;
                        End ;
                    1 :
                        Begin
                          lkstarted := false ;
                          22 : getxnext ;
                          If ( curcmd = 78 ) And lkstarted Then
                            Begin
                              c := getcode ;
                              If nl - skiptable [ c ] > 128 Then
                                Begin
                                  Begin
                                    Begin
                                      If interaction = 3 Then ;
                                      printnl ( 261 ) ;
                                      print ( 1035 ) ;
                                    End ;
                                    Begin
                                      helpptr := 1 ;
                                      helpline [ 0 ] := 1036 ;
                                    End ;
                                    error ;
                                    ll := skiptable [ c ] ;
                                    Repeat
                                      lll := ligkern [ ll ] . b0 - 0 ;
                                      ligkern [ ll ] . b0 := 128 ;
                                      ll := ll - lll ;
                                    Until lll = 0 ;
                                  End ;
                                  skiptable [ c ] := ligtablesize ;
                                End ;
                              If skiptable [ c ] = ligtablesize Then ligkern [ nl - 1 ] . b0 := 0
                              Else ligkern [ nl - 1 ] . b0 := nl - skiptable [ c ] - 1 ;
                              skiptable [ c ] := nl - 1 ;
                              goto 30 ;
                            End ;
                          If curcmd = 79 Then
                            Begin
                              c := 256 ;
                              curcmd := 81 ;
                            End
                          Else
                            Begin
                              backinput ;
                              c := getcode ;
                            End ;
                          If ( curcmd = 81 ) Or ( curcmd = 80 ) Then
                            Begin
                              If curcmd = 81 Then If c = 256 Then bchlabel := nl
                              Else settag ( c , 1 , nl )
                              Else If skiptable [ c ] < ligtablesize Then
                                     Begin
                                       ll := skiptable [ c ] ;
                                       skiptable [ c ] := ligtablesize ;
                                       Repeat
                                         lll := ligkern [ ll ] . b0 - 0 ;
                                         If nl - ll > 128 Then
                                           Begin
                                             Begin
                                               Begin
                                                 If interaction = 3 Then ;
                                                 printnl ( 261 ) ;
                                                 print ( 1035 ) ;
                                               End ;
                                               Begin
                                                 helpptr := 1 ;
                                                 helpline [ 0 ] := 1036 ;
                                               End ;
                                               error ;
                                               ll := ll ;
                                               Repeat
                                                 lll := ligkern [ ll ] . b0 - 0 ;
                                                 ligkern [ ll ] . b0 := 128 ;
                                                 ll := ll - lll ;
                                               Until lll = 0 ;
                                             End ;
                                             goto 22 ;
                                           End ;
                                         ligkern [ ll ] . b0 := nl - ll - 1 ;
                                         ll := ll - lll ;
                                       Until lll = 0 ;
                                     End ;
                              goto 22 ;
                            End ;
                          If curcmd = 76 Then
                            Begin
                              ligkern [ nl ] . b1 := c + 0 ;
                              ligkern [ nl ] . b0 := 0 ;
                              If curmod < 128 Then
                                Begin
                                  ligkern [ nl ] . b2 := curmod + 0 ;
                                  ligkern [ nl ] . b3 := getcode + 0 ;
                                End
                              Else
                                Begin
                                  getxnext ;
                                  scanexpression ;
                                  If curtype <> 16 Then
                                    Begin
                                      disperr ( 0 , 1037 ) ;
                                      Begin
                                        helpptr := 2 ;
                                        helpline [ 1 ] := 1038 ;
                                        helpline [ 0 ] := 309 ;
                                      End ;
                                      putgetflusherror ( 0 ) ;
                                    End ;
                                  kern [ nk ] := curexp ;
                                  k := 0 ;
                                  While kern [ k ] <> curexp Do
                                    k := k + 1 ;
                                  If k = nk Then
                                    Begin
                                      If nk = maxkerns Then overflow ( 1034 , maxkerns ) ;
                                      nk := nk + 1 ;
                                    End ;
                                  ligkern [ nl ] . b2 := 128 + ( k Div 256 ) ;
                                  ligkern [ nl ] . b3 := ( k Mod 256 ) + 0 ;
                                End ;
                              lkstarted := true ;
                            End
                          Else
                            Begin
                              Begin
                                If interaction = 3 Then ;
                                printnl ( 261 ) ;
                                print ( 1023 ) ;
                              End ;
                              Begin
                                helpptr := 1 ;
                                helpline [ 0 ] := 1024 ;
                              End ;
                              backerror ;
                              ligkern [ nl ] . b1 := 0 ;
                              ligkern [ nl ] . b2 := 0 ;
                              ligkern [ nl ] . b3 := 0 ;
                              ligkern [ nl ] . b0 := 129 ;
                            End ;
                          If nl = ligtablesize Then overflow ( 1025 , ligtablesize ) ;
                          nl := nl + 1 ;
                          If curcmd = 82 Then goto 22 ;
                          If ligkern [ nl - 1 ] . b0 < 128 Then ligkern [ nl - 1 ] . b0 := 128 ;
                          30 :
                        End ;
                    2 :
                        Begin
                          If ne = 256 Then overflow ( 1006 , 256 ) ;
                          c := getcode ;
                          settag ( c , 3 , ne ) ;
                          If curcmd <> 81 Then
                            Begin
                              missingerr ( 58 ) ;
                              Begin
                                helpptr := 1 ;
                                helpline [ 0 ] := 1039 ;
                              End ;
                              backerror ;
                            End ;
                          exten [ ne ] . b0 := getcode + 0 ;
                          If curcmd <> 82 Then
                            Begin
                              missingerr ( 44 ) ;
                              Begin
                                helpptr := 1 ;
                                helpline [ 0 ] := 1039 ;
                              End ;
                              backerror ;
                            End ;
                          exten [ ne ] . b1 := getcode + 0 ;
                          If curcmd <> 82 Then
                            Begin
                              missingerr ( 44 ) ;
                              Begin
                                helpptr := 1 ;
                                helpline [ 0 ] := 1039 ;
                              End ;
                              backerror ;
                            End ;
                          exten [ ne ] . b2 := getcode + 0 ;
                          If curcmd <> 82 Then
                            Begin
                              missingerr ( 44 ) ;
                              Begin
                                helpptr := 1 ;
                                helpline [ 0 ] := 1039 ;
                              End ;
                              backerror ;
                            End ;
                          exten [ ne ] . b3 := getcode + 0 ;
                          ne := ne + 1 ;
                        End ;
                    3 , 4 :
                            Begin
                              c := curmod ;
                              getxnext ;
                              scanexpression ;
                              If ( curtype <> 16 ) Or ( curexp < 32768 ) Then
                                Begin
                                  disperr ( 0 , 1019 ) ;
                                  Begin
                                    helpptr := 2 ;
                                    helpline [ 1 ] := 1020 ;
                                    helpline [ 0 ] := 1021 ;
                                  End ;
                                  putgeterror ;
                                End
                              Else
                                Begin
                                  j := roundunscaled ( curexp ) ;
                                  If curcmd <> 81 Then
                                    Begin
                                      missingerr ( 58 ) ;
                                      Begin
                                        helpptr := 1 ;
                                        helpline [ 0 ] := 1022 ;
                                      End ;
                                      backerror ;
                                    End ;
                                  If c = 3 Then Repeat
                                                  If j > headersize Then overflow ( 1007 , headersize ) ;
                                                  headerbyte [ j ] := getcode ;
                                                  j := j + 1 ;
                                    Until curcmd <> 82
                                  Else Repeat
                                         If j > maxfontdimen Then overflow ( 1008 , maxfontdimen ) ;
                                         While j > np Do
                                           Begin
                                             np := np + 1 ;
                                             param [ np ] := 0 ;
                                           End ;
                                         getxnext ;
                                         scanexpression ;
                                         If curtype <> 16 Then
                                           Begin
                                             disperr ( 0 , 1040 ) ;
                                             Begin
                                               helpptr := 1 ;
                                               helpline [ 0 ] := 309 ;
                                             End ;
                                             putgetflusherror ( 0 ) ;
                                           End ;
                                         param [ j ] := curexp ;
                                         j := j + 1 ;
                                    Until curcmd <> 82 ;
                                End ;
                            End ;
                  End ;
                End ;
                Procedure dospecial ;

                Var m : smallnumber ;
                Begin
                  m := curmod ;
                  getxnext ;
                  scanexpression ;
                  If internal [ 34 ] >= 0 Then If curtype <> m Then
                                                 Begin
                                                   disperr ( 0 , 1060 ) ;
                                                   Begin
                                                     helpptr := 1 ;
                                                     helpline [ 0 ] := 1061 ;
                                                   End ;
                                                   putgeterror ;
                                                 End
                  Else
                    Begin
                      If outputfilename = 0 Then initgf ;
                      If m = 4 Then gfstring ( curexp , 0 )
                      Else
                        Begin
                          Begin
                            gfbuf [ gfptr ] := 243 ;
                            gfptr := gfptr + 1 ;
                            If gfptr = gflimit Then gfswap ;
                          End ;
                          gffour ( curexp ) ;
                        End ;
                    End ;
                  flushcurexp ( 0 ) ;
                End ;
                Procedure storebasefile ;

                Var k : integer ;
                  p , q : halfword ;
                  x : integer ;
                  w : fourquarters ;
                Begin
                  selector := 5 ;
                  print ( 1071 ) ;
                  print ( jobname ) ;
                  printchar ( 32 ) ;
                  printint ( roundunscaled ( internal [ 14 ] ) ) ;
                  printchar ( 46 ) ;
                  printint ( roundunscaled ( internal [ 15 ] ) ) ;
                  printchar ( 46 ) ;
                  printint ( roundunscaled ( internal [ 16 ] ) ) ;
                  printchar ( 41 ) ;
                  If interaction = 0 Then selector := 2
                  Else selector := 3 ;
                  Begin
                    If poolptr + 1 > maxpoolptr Then
                      Begin
                        If poolptr + 1 > poolsize Then overflow ( 257 , poolsize - initpoolptr ) ;
                        maxpoolptr := poolptr + 1 ;
                      End ;
                  End ;
                  baseident := makestring ;
                  strref [ baseident ] := 127 ;
                  packjobname ( 742 ) ;
                  While Not wopenout ( basefile ) Do
                    promptfilename ( 1072 , 742 ) ;
                  printnl ( 1073 ) ;
                  slowprint ( wmakenamestring ( basefile ) ) ;
                  flushstring ( strptr - 1 ) ;
                  printnl ( 285 ) ;
                  slowprint ( baseident ) ;
                  Begin
                    basefile ^ . int := 166307429 ;
                    put ( basefile ) ;
                  End ;
                  Begin
                    basefile ^ . int := 0 ;
                    put ( basefile ) ;
                  End ;
                  Begin
                    basefile ^ . int := 30000 ;
                    put ( basefile ) ;
                  End ;
                  Begin
                    basefile ^ . int := 2100 ;
                    put ( basefile ) ;
                  End ;
                  Begin
                    basefile ^ . int := 1777 ;
                    put ( basefile ) ;
                  End ;
                  Begin
                    basefile ^ . int := 6 ;
                    put ( basefile ) ;
                  End ;
                  Begin
                    basefile ^ . int := poolptr ;
                    put ( basefile ) ;
                  End ;
                  Begin
                    basefile ^ . int := strptr ;
                    put ( basefile ) ;
                  End ;
                  For k := 0 To strptr Do
                    Begin
                      basefile ^ . int := strstart [ k ] ;
                      put ( basefile ) ;
                    End ;
                  k := 0 ;
                  While k + 4 < poolptr Do
                    Begin
                      w . b0 := strpool [ k ] + 0 ;
                      w . b1 := strpool [ k + 1 ] + 0 ;
                      w . b2 := strpool [ k + 2 ] + 0 ;
                      w . b3 := strpool [ k + 3 ] + 0 ;
                      Begin
                        basefile ^ . qqqq := w ;
                        put ( basefile ) ;
                      End ;
                      k := k + 4 ;
                    End ;
                  k := poolptr - 4 ;
                  w . b0 := strpool [ k ] + 0 ;
                  w . b1 := strpool [ k + 1 ] + 0 ;
                  w . b2 := strpool [ k + 2 ] + 0 ;
                  w . b3 := strpool [ k + 3 ] + 0 ;
                  Begin
                    basefile ^ . qqqq := w ;
                    put ( basefile ) ;
                  End ;
                  println ;
                  printint ( strptr ) ;
                  print ( 1068 ) ;
                  printint ( poolptr ) ;
                  sortavail ;
                  varused := 0 ;
                  Begin
                    basefile ^ . int := lomemmax ;
                    put ( basefile ) ;
                  End ;
                  Begin
                    basefile ^ . int := rover ;
                    put ( basefile ) ;
                  End ;
                  p := 0 ;
                  q := rover ;
                  x := 0 ;
                  Repeat
                    For k := p To q + 1 Do
                      Begin
                        basefile ^ := mem [ k ] ;
                        put ( basefile ) ;
                      End ;
                    x := x + q + 2 - p ;
                    varused := varused + q - p ;
                    p := q + mem [ q ] . hh . lh ;
                    q := mem [ q + 1 ] . hh . rh ;
                  Until q = rover ;
                  varused := varused + lomemmax - p ;
                  dynused := memend + 1 - himemmin ;
                  For k := p To lomemmax Do
                    Begin
                      basefile ^ := mem [ k ] ;
                      put ( basefile ) ;
                    End ;
                  x := x + lomemmax + 1 - p ;
                  Begin
                    basefile ^ . int := himemmin ;
                    put ( basefile ) ;
                  End ;
                  Begin
                    basefile ^ . int := avail ;
                    put ( basefile ) ;
                  End ;
                  For k := himemmin To memend Do
                    Begin
                      basefile ^ := mem [ k ] ;
                      put ( basefile ) ;
                    End ;
                  x := x + memend + 1 - himemmin ;
                  p := avail ;
                  While p <> 0 Do
                    Begin
                      dynused := dynused - 1 ;
                      p := mem [ p ] . hh . rh ;
                    End ;
                  Begin
                    basefile ^ . int := varused ;
                    put ( basefile ) ;
                  End ;
                  Begin
                    basefile ^ . int := dynused ;
                    put ( basefile ) ;
                  End ;
                  println ;
                  printint ( x ) ;
                  print ( 1069 ) ;
                  printint ( varused ) ;
                  printchar ( 38 ) ;
                  printint ( dynused ) ;
                  Begin
                    basefile ^ . int := hashused ;
                    put ( basefile ) ;
                  End ;
                  stcount := 2356 - hashused ;
                  For p := 1 To hashused Do
                    If hash [ p ] . rh <> 0 Then
                      Begin
                        Begin
                          basefile ^ . int := p ;
                          put ( basefile ) ;
                        End ;
                        Begin
                          basefile ^ . hh := hash [ p ] ;
                          put ( basefile ) ;
                        End ;
                        Begin
                          basefile ^ . hh := eqtb [ p ] ;
                          put ( basefile ) ;
                        End ;
                        stcount := stcount + 1 ;
                      End ;
                  For p := hashused + 1 To 2369 Do
                    Begin
                      Begin
                        basefile ^ . hh := hash [ p ] ;
                        put ( basefile ) ;
                      End ;
                      Begin
                        basefile ^ . hh := eqtb [ p ] ;
                        put ( basefile ) ;
                      End ;
                    End ;
                  Begin
                    basefile ^ . int := stcount ;
                    put ( basefile ) ;
                  End ;
                  println ;
                  printint ( stcount ) ;
                  print ( 1070 ) ;
                  Begin
                    basefile ^ . int := intptr ;
                    put ( basefile ) ;
                  End ;
                  For k := 1 To intptr Do
                    Begin
                      Begin
                        basefile ^ . int := internal [ k ] ;
                        put ( basefile ) ;
                      End ;
                      Begin
                        basefile ^ . int := intname [ k ] ;
                        put ( basefile ) ;
                      End ;
                    End ;
                  Begin
                    basefile ^ . int := startsym ;
                    put ( basefile ) ;
                  End ;
                  Begin
                    basefile ^ . int := interaction ;
                    put ( basefile ) ;
                  End ;
                  Begin
                    basefile ^ . int := baseident ;
                    put ( basefile ) ;
                  End ;
                  Begin
                    basefile ^ . int := bgloc ;
                    put ( basefile ) ;
                  End ;
                  Begin
                    basefile ^ . int := egloc ;
                    put ( basefile ) ;
                  End ;
                  Begin
                    basefile ^ . int := serialno ;
                    put ( basefile ) ;
                  End ;
                  Begin
                    basefile ^ . int := 69069 ;
                    put ( basefile ) ;
                  End ;
                  internal [ 12 ] := 0 ;
                  wclose ( basefile ) ;
                End ;
                Procedure dostatement ;
                Begin
                  curtype := 1 ;
                  getxnext ;
                  If curcmd > 43 Then
                    Begin
                      If curcmd < 83 Then
                        Begin
                          Begin
                            If interaction = 3 Then ;
                            printnl ( 261 ) ;
                            print ( 869 ) ;
                          End ;
                          printcmdmod ( curcmd , curmod ) ;
                          printchar ( 39 ) ;
                          Begin
                            helpptr := 5 ;
                            helpline [ 4 ] := 870 ;
                            helpline [ 3 ] := 871 ;
                            helpline [ 2 ] := 872 ;
                            helpline [ 1 ] := 873 ;
                            helpline [ 0 ] := 874 ;
                          End ;
                          backerror ;
                          getxnext ;
                        End ;
                    End
                  Else If curcmd > 30 Then
                         Begin
                           varflag := 77 ;
                           scanexpression ;
                           If curcmd < 84 Then
                             Begin
                               If curcmd = 51 Then doequation
                               Else If curcmd = 77 Then doassignment
                               Else If curtype = 4 Then
                                      Begin
                                        If internal [ 1 ] > 0 Then
                                          Begin
                                            printnl ( 285 ) ;
                                            slowprint ( curexp ) ;
                                            break ( termout ) ;
                                          End ;
                                        If internal [ 34 ] > 0 Then
                                          Begin
                                            If outputfilename = 0 Then initgf ;
                                            gfstring ( 1062 , curexp ) ;
                                          End ;
                                      End
                               Else If curtype <> 1 Then
                                      Begin
                                        disperr ( 0 , 879 ) ;
                                        Begin
                                          helpptr := 3 ;
                                          helpline [ 2 ] := 880 ;
                                          helpline [ 1 ] := 881 ;
                                          helpline [ 0 ] := 882 ;
                                        End ;
                                        putgeterror ;
                                      End ;
                               flushcurexp ( 0 ) ;
                               curtype := 1 ;
                             End ;
                         End
                  Else
                    Begin
                      If internal [ 7 ] > 0 Then showcmdmod ( curcmd , curmod ) ;
                      Case curcmd Of 
                        30 : dotypedeclaration ;
                        16 : If curmod > 2 Then makeopdef
                             Else If curmod > 0 Then scandef ;
                        24 : dorandomseed ;
                        23 :
                             Begin
                               println ;
                               interaction := curmod ;
                               If interaction = 0 Then selector := 0
                               Else selector := 1 ;
                               If logopened Then selector := selector + 2 ;
                               getxnext ;
                             End ;
                        21 : doprotection ;
                        27 : defdelims ;
                        12 : Repeat
                               getsymbol ;
                               savevariable ( cursym ) ;
                               getxnext ;
                             Until curcmd <> 82 ;
                        13 : dointerim ;
                        14 : dolet ;
                        15 : donewinternal ;
                        22 : doshowwhatever ;
                        18 : doaddto ;
                        17 : doshipout ;
                        11 : dodisplay ;
                        28 : doopenwindow ;
                        19 : docull ;
                        26 :
                             Begin
                               getsymbol ;
                               startsym := cursym ;
                               getxnext ;
                             End ;
                        25 : domessage ;
                        20 : dotfmcommand ;
                        29 : dospecial ;
                      End ;
                      curtype := 1 ;
                    End ;
                  If curcmd < 83 Then
                    Begin
                      Begin
                        If interaction = 3 Then ;
                        printnl ( 261 ) ;
                        print ( 875 ) ;
                      End ;
                      Begin
                        helpptr := 6 ;
                        helpline [ 5 ] := 876 ;
                        helpline [ 4 ] := 877 ;
                        helpline [ 3 ] := 878 ;
                        helpline [ 2 ] := 872 ;
                        helpline [ 1 ] := 873 ;
                        helpline [ 0 ] := 874 ;
                      End ;
                      backerror ;
                      scannerstatus := 2 ;
                      Repeat
                        getnext ;
                        If curcmd = 39 Then
                          Begin
                            If strref [ curmod ] < 127 Then If strref [ curmod ] > 1 Then strref [ curmod ] := strref [ curmod ] - 1
                            Else flushstring ( curmod ) ;
                          End ;
                      Until curcmd > 82 ;
                      scannerstatus := 0 ;
                    End ;
                  errorcount := 0 ;
                End ;
                Procedure maincontrol ;
                Begin
                  Repeat
                    dostatement ;
                    If curcmd = 84 Then
                      Begin
                        Begin
                          If interaction = 3 Then ;
                          printnl ( 261 ) ;
                          print ( 910 ) ;
                        End ;
                        Begin
                          helpptr := 2 ;
                          helpline [ 1 ] := 911 ;
                          helpline [ 0 ] := 689 ;
                        End ;
                        flusherror ( 0 ) ;
                      End ;
                  Until curcmd = 85 ;
                End ;
                Function sortin ( v : scaled ) : halfword ;

                Label 40 ;

                Var p , q , r : halfword ;
                Begin
                  p := 29999 ;
                  While true Do
                    Begin
                      q := mem [ p ] . hh . rh ;
                      If v <= mem [ q + 1 ] . int Then goto 40 ;
                      p := q ;
                    End ;
                  40 : If v < mem [ q + 1 ] . int Then
                         Begin
                           r := getnode ( 2 ) ;
                           mem [ r + 1 ] . int := v ;
                           mem [ r ] . hh . rh := q ;
                           mem [ p ] . hh . rh := r ;
                         End ;
                  sortin := mem [ p ] . hh . rh ;
                End ;
                Function mincover ( d : scaled ) : integer ;

                Var p : halfword ;
                  l : scaled ;
                  m : integer ;
                Begin
                  m := 0 ;
                  p := mem [ 29999 ] . hh . rh ;
                  perturbation := 2147483647 ;
                  While p <> 19 Do
                    Begin
                      m := m + 1 ;
                      l := mem [ p + 1 ] . int ;
                      Repeat
                        p := mem [ p ] . hh . rh ;
                      Until mem [ p + 1 ] . int > l + d ;
                      If mem [ p + 1 ] . int - l < perturbation Then perturbation := mem [ p + 1 ] . int - l ;
                    End ;
                  mincover := m ;
                End ;
                Function threshold ( m : integer ) : scaled ;

                Var d : scaled ;
                Begin
                  excess := mincover ( 0 ) - m ;
                  If excess <= 0 Then threshold := 0
                  Else
                    Begin
                      Repeat
                        d := perturbation ;
                      Until mincover ( d + d ) <= m ;
                      While mincover ( d ) > m Do
                        d := perturbation ;
                      threshold := d ;
                    End ;
                End ;
                Function skimp ( m : integer ) : integer ;

                Var d : scaled ;
                  p , q , r : halfword ;
                  l : scaled ;
                  v : scaled ;
                Begin
                  d := threshold ( m ) ;
                  perturbation := 0 ;
                  q := 29999 ;
                  m := 0 ;
                  p := mem [ 29999 ] . hh . rh ;
                  While p <> 19 Do
                    Begin
                      m := m + 1 ;
                      l := mem [ p + 1 ] . int ;
                      mem [ p ] . hh . lh := m ;
                      If mem [ mem [ p ] . hh . rh + 1 ] . int <= l + d Then
                        Begin
                          Repeat
                            p := mem [ p ] . hh . rh ;
                            mem [ p ] . hh . lh := m ;
                            excess := excess - 1 ;
                            If excess = 0 Then d := 0 ;
                          Until mem [ mem [ p ] . hh . rh + 1 ] . int > l + d ;
                          v := l + ( mem [ p + 1 ] . int - l ) Div 2 ;
                          If mem [ p + 1 ] . int - v > perturbation Then perturbation := mem [ p + 1 ] . int - v ;
                          r := q ;
                          Repeat
                            r := mem [ r ] . hh . rh ;
                            mem [ r + 1 ] . int := v ;
                          Until r = p ;
                          mem [ q ] . hh . rh := p ;
                        End ;
                      q := p ;
                      p := mem [ p ] . hh . rh ;
                    End ;
                  skimp := m ;
                End ;
                Procedure tfmwarning ( m : smallnumber ) ;
                Begin
                  printnl ( 1041 ) ;
                  print ( intname [ m ] ) ;
                  print ( 1042 ) ;
                  printscaled ( perturbation ) ;
                  print ( 1043 ) ;
                End ;
                Procedure fixdesignsize ;

                Var d : scaled ;
                Begin
                  d := internal [ 26 ] ;
                  If ( d < 65536 ) Or ( d >= 134217728 ) Then
                    Begin
                      If d <> 0 Then printnl ( 1044 ) ;
                      d := 8388608 ;
                      internal [ 26 ] := d ;
                    End ;
                  If headerbyte [ 5 ] < 0 Then If headerbyte [ 6 ] < 0 Then If headerbyte [ 7 ] < 0 Then If headerbyte [ 8 ] < 0 Then
                                                                                                           Begin
                                                                                                             headerbyte [ 5 ] := d Div 1048576 ;
                                                                                                             headerbyte [ 6 ] := ( d Div 4096 ) Mod 256 ;
                                                                                                             headerbyte [ 7 ] := ( d Div 16 ) Mod 256 ;
                                                                                                             headerbyte [ 8 ] := ( d Mod 16 ) * 16 ;
                                                                                                           End ;
                  maxtfmdimen := 16 * internal [ 26 ] - 1 - internal [ 26 ] Div 2097152 ;
                  If maxtfmdimen >= 134217728 Then maxtfmdimen := 134217727 ;
                End ;
                Function dimenout ( x : scaled ) : integer ;
                Begin
                  If abs ( x ) > maxtfmdimen Then
                    Begin
                      tfmchanged := tfmchanged + 1 ;
                      If x > 0 Then x := maxtfmdimen
                      Else x := - maxtfmdimen ;
                    End ;
                  x := makescaled ( x * 16 , internal [ 26 ] ) ;
                  dimenout := x ;
                End ;
                Procedure fixchecksum ;

                Label 10 ;

                Var k : eightbits ;
                  b1 , b2 , b3 , b4 : eightbits ;
                  x : integer ;
                Begin
                  If headerbyte [ 1 ] < 0 Then If headerbyte [ 2 ] < 0 Then If headerbyte [ 3 ] < 0 Then If headerbyte [ 4 ] < 0 Then
                                                                                                           Begin
                                                                                                             b1 := bc ;
                                                                                                             b2 := ec ;
                                                                                                             b3 := bc ;
                                                                                                             b4 := ec ;
                                                                                                             tfmchanged := 0 ;
                                                                                                             For k := bc To ec Do
                                                                                                               If charexists [ k ] Then
                                                                                                                 Begin
                                                                                                                   x := dimenout ( mem [ tfmwidth [ k ] + 1 ] . int ) + ( k + 4 ) * 4194304 ;
                                                                                                                   b1 := ( b1 + b1 + x ) Mod 255 ;
                                                                                                                   b2 := ( b2 + b2 + x ) Mod 253 ;
                                                                                                                   b3 := ( b3 + b3 + x ) Mod 251 ;
                                                                                                                   b4 := ( b4 + b4 + x ) Mod 247 ;
                                                                                                                 End ;
                                                                                                             headerbyte [ 1 ] := b1 ;
                                                                                                             headerbyte [ 2 ] := b2 ;
                                                                                                             headerbyte [ 3 ] := b3 ;
                                                                                                             headerbyte [ 4 ] := b4 ;
                                                                                                             goto 10 ;
                                                                                                           End ;
                  For k := 1 To 4 Do
                    If headerbyte [ k ] < 0 Then headerbyte [ k ] := 0 ;
                  10 :
                End ;
                Procedure tfmtwo ( x : integer ) ;
                Begin
                  write ( tfmfile , x Div 256 ) ;
                  write ( tfmfile , x Mod 256 ) ;
                End ;
                Procedure tfmfour ( x : integer ) ;
                Begin
                  If x >= 0 Then write ( tfmfile , x Div 16777216 )
                  Else
                    Begin
                      x := x + 1073741824 ;
                      x := x + 1073741824 ;
                      write ( tfmfile , ( x Div 16777216 ) + 128 ) ;
                    End ;
                  x := x Mod 16777216 ;
                  write ( tfmfile , x Div 65536 ) ;
                  x := x Mod 65536 ;
                  write ( tfmfile , x Div 256 ) ;
                  write ( tfmfile , x Mod 256 ) ;
                End ;
                Procedure tfmqqqq ( x : fourquarters ) ;
                Begin
                  write ( tfmfile , x . b0 - 0 ) ;
                  write ( tfmfile , x . b1 - 0 ) ;
                  write ( tfmfile , x . b2 - 0 ) ;
                  write ( tfmfile , x . b3 - 0 ) ;
                End ;
                Function openbasefile : boolean ;

                Label 40 , 10 ;

                Var j : 0 .. bufsize ;
                Begin
                  j := curinput . locfield ;
                  If buffer [ curinput . locfield ] = 38 Then
                    Begin
                      curinput . locfield := curinput . locfield + 1 ;
                      j := curinput . locfield ;
                      buffer [ last ] := 32 ;
                      While buffer [ j ] <> 32 Do
                        j := j + 1 ;
                      packbufferedname ( 0 , curinput . locfield , j - 1 ) ;
                      If wopenin ( basefile ) Then goto 40 ;
                      packbufferedname ( 8 , curinput . locfield , j - 1 ) ;
                      If wopenin ( basefile ) Then goto 40 ; ;
                      writeln ( termout , 'Sorry, I can''t find that base;' , ' will try PLAIN.' ) ;
                      break ( termout ) ;
                    End ;
                  packbufferedname ( 13 , 1 , 0 ) ;
                  If Not wopenin ( basefile ) Then
                    Begin ;
                      writeln ( termout , 'I can''t find the PLAIN base file!' ) ;
                      openbasefile := false ;
                      goto 10 ;
                    End ;
                  40 : curinput . locfield := j ;
                  openbasefile := true ;
                  10 :
                End ;
                Function loadbasefile : boolean ;

                Label 6666 , 10 ;

                Var k : integer ;
                  p , q : halfword ;
                  x : integer ;
                  w : fourquarters ;
                Begin
                  x := basefile ^ . int ;
                  If x <> 166307429 Then goto 6666 ;
                  Begin
                    get ( basefile ) ;
                    x := basefile ^ . int ;
                  End ;
                  If x <> 0 Then goto 6666 ;
                  Begin
                    get ( basefile ) ;
                    x := basefile ^ . int ;
                  End ;
                  If x <> 30000 Then goto 6666 ;
                  Begin
                    get ( basefile ) ;
                    x := basefile ^ . int ;
                  End ;
                  If x <> 2100 Then goto 6666 ;
                  Begin
                    get ( basefile ) ;
                    x := basefile ^ . int ;
                  End ;
                  If x <> 1777 Then goto 6666 ;
                  Begin
                    get ( basefile ) ;
                    x := basefile ^ . int ;
                  End ;
                  If x <> 6 Then goto 6666 ;
                  Begin
                    Begin
                      get ( basefile ) ;
                      x := basefile ^ . int ;
                    End ;
                    If x < 0 Then goto 6666 ;
                    If x > poolsize Then
                      Begin ;
                        writeln ( termout , '---! Must increase the ' , 'string pool size' ) ;
                        goto 6666 ;
                      End
                    Else poolptr := x ;
                  End ;
                  Begin
                    Begin
                      get ( basefile ) ;
                      x := basefile ^ . int ;
                    End ;
                    If x < 0 Then goto 6666 ;
                    If x > maxstrings Then
                      Begin ;
                        writeln ( termout , '---! Must increase the ' , 'max strings' ) ;
                        goto 6666 ;
                      End
                    Else strptr := x ;
                  End ;
                  For k := 0 To strptr Do
                    Begin
                      Begin
                        Begin
                          get ( basefile ) ;
                          x := basefile ^ . int ;
                        End ;
                        If ( x < 0 ) Or ( x > poolptr ) Then goto 6666
                        Else strstart [ k ] := x ;
                      End ;
                      strref [ k ] := 127 ;
                    End ;
                  k := 0 ;
                  While k + 4 < poolptr Do
                    Begin
                      Begin
                        get ( basefile ) ;
                        w := basefile ^ . qqqq ;
                      End ;
                      strpool [ k ] := w . b0 - 0 ;
                      strpool [ k + 1 ] := w . b1 - 0 ;
                      strpool [ k + 2 ] := w . b2 - 0 ;
                      strpool [ k + 3 ] := w . b3 - 0 ;
                      k := k + 4 ;
                    End ;
                  k := poolptr - 4 ;
                  Begin
                    get ( basefile ) ;
                    w := basefile ^ . qqqq ;
                  End ;
                  strpool [ k ] := w . b0 - 0 ;
                  strpool [ k + 1 ] := w . b1 - 0 ;
                  strpool [ k + 2 ] := w . b2 - 0 ;
                  strpool [ k + 3 ] := w . b3 - 0 ;
                  initstrptr := strptr ;
                  initpoolptr := poolptr ;
                  maxstrptr := strptr ;
                  maxpoolptr := poolptr ;
                  Begin
                    Begin
                      get ( basefile ) ;
                      x := basefile ^ . int ;
                    End ;
                    If ( x < 1022 ) Or ( x > 29997 ) Then goto 6666
                    Else lomemmax := x ;
                  End ;
                  Begin
                    Begin
                      get ( basefile ) ;
                      x := basefile ^ . int ;
                    End ;
                    If ( x < 23 ) Or ( x > lomemmax ) Then goto 6666
                    Else rover := x ;
                  End ;
                  p := 0 ;
                  q := rover ;
                  Repeat
                    For k := p To q + 1 Do
                      Begin
                        get ( basefile ) ;
                        mem [ k ] := basefile ^ ;
                      End ;
                    p := q + mem [ q ] . hh . lh ;
                    If ( p > lomemmax ) Or ( ( q >= mem [ q + 1 ] . hh . rh ) And ( mem [ q + 1 ] . hh . rh <> rover ) ) Then goto 6666 ;
                    q := mem [ q + 1 ] . hh . rh ;
                  Until q = rover ;
                  For k := p To lomemmax Do
                    Begin
                      get ( basefile ) ;
                      mem [ k ] := basefile ^ ;
                    End ;
                  Begin
                    Begin
                      get ( basefile ) ;
                      x := basefile ^ . int ;
                    End ;
                    If ( x < lomemmax + 1 ) Or ( x > 29998 ) Then goto 6666
                    Else himemmin := x ;
                  End ;
                  Begin
                    Begin
                      get ( basefile ) ;
                      x := basefile ^ . int ;
                    End ;
                    If ( x < 0 ) Or ( x > 30000 ) Then goto 6666
                    Else avail := x ;
                  End ;
                  memend := 30000 ;
                  For k := himemmin To memend Do
                    Begin
                      get ( basefile ) ;
                      mem [ k ] := basefile ^ ;
                    End ;
                  Begin
                    get ( basefile ) ;
                    varused := basefile ^ . int ;
                  End ;
                  Begin
                    get ( basefile ) ;
                    dynused := basefile ^ . int ;
                  End ;
                  Begin
                    Begin
                      get ( basefile ) ;
                      x := basefile ^ . int ;
                    End ;
                    If ( x < 1 ) Or ( x > 2357 ) Then goto 6666
                    Else hashused := x ;
                  End ;
                  p := 0 ;
                  Repeat
                    Begin
                      Begin
                        get ( basefile ) ;
                        x := basefile ^ . int ;
                      End ;
                      If ( x < p + 1 ) Or ( x > hashused ) Then goto 6666
                      Else p := x ;
                    End ;
                    Begin
                      get ( basefile ) ;
                      hash [ p ] := basefile ^ . hh ;
                    End ;
                    Begin
                      get ( basefile ) ;
                      eqtb [ p ] := basefile ^ . hh ;
                    End ;
                  Until p = hashused ;
                  For p := hashused + 1 To 2369 Do
                    Begin
                      Begin
                        get ( basefile ) ;
                        hash [ p ] := basefile ^ . hh ;
                      End ;
                      Begin
                        get ( basefile ) ;
                        eqtb [ p ] := basefile ^ . hh ;
                      End ;
                    End ;
                  Begin
                    get ( basefile ) ;
                    stcount := basefile ^ . int ;
                  End ;
                  Begin
                    Begin
                      get ( basefile ) ;
                      x := basefile ^ . int ;
                    End ;
                    If ( x < 41 ) Or ( x > maxinternal ) Then goto 6666
                    Else intptr := x ;
                  End ;
                  For k := 1 To intptr Do
                    Begin
                      Begin
                        get ( basefile ) ;
                        internal [ k ] := basefile ^ . int ;
                      End ;
                      Begin
                        Begin
                          get ( basefile ) ;
                          x := basefile ^ . int ;
                        End ;
                        If ( x < 0 ) Or ( x > strptr ) Then goto 6666
                        Else intname [ k ] := x ;
                      End ;
                    End ;
                  Begin
                    Begin
                      get ( basefile ) ;
                      x := basefile ^ . int ;
                    End ;
                    If ( x < 0 ) Or ( x > 2357 ) Then goto 6666
                    Else startsym := x ;
                  End ;
                  Begin
                    Begin
                      get ( basefile ) ;
                      x := basefile ^ . int ;
                    End ;
                    If ( x < 0 ) Or ( x > 3 ) Then goto 6666
                    Else interaction := x ;
                  End ;
                  Begin
                    Begin
                      get ( basefile ) ;
                      x := basefile ^ . int ;
                    End ;
                    If ( x < 0 ) Or ( x > strptr ) Then goto 6666
                    Else baseident := x ;
                  End ;
                  Begin
                    Begin
                      get ( basefile ) ;
                      x := basefile ^ . int ;
                    End ;
                    If ( x < 1 ) Or ( x > 2369 ) Then goto 6666
                    Else bgloc := x ;
                  End ;
                  Begin
                    Begin
                      get ( basefile ) ;
                      x := basefile ^ . int ;
                    End ;
                    If ( x < 1 ) Or ( x > 2369 ) Then goto 6666
                    Else egloc := x ;
                  End ;
                  Begin
                    get ( basefile ) ;
                    serialno := basefile ^ . int ;
                  End ;
                  Begin
                    get ( basefile ) ;
                    x := basefile ^ . int ;
                  End ;
                  If ( x <> 69069 ) Or eof ( basefile ) Then goto 6666 ;
                  loadbasefile := true ;
                  goto 10 ;
                  6666 : ;
                  writeln ( termout , '(Fatal base file error; I''m stymied)' ) ;
                  loadbasefile := false ;
                  10 :
                End ;
                Procedure scanprimary ;

                Label 20 , 30 , 31 , 32 ;

                Var p , q , r : halfword ;
                  c : quarterword ;
                  myvarflag : 0 .. 85 ;
                  ldelim , rdelim : halfword ;
                  groupline : integer ;
                  num , denom : scaled ;
                  prehead , posthead , tail : halfword ;
                  tt : smallnumber ;
                  t : halfword ;
                  macroref : halfword ;
                Begin
                  myvarflag := varflag ;
                  varflag := 0 ;
                  20 :
                       Begin
                         If aritherror Then cleararith ;
                       End ;
                  If interrupt <> 0 Then If OKtointerrupt Then
                                           Begin
                                             backinput ;
                                             Begin
                                               If interrupt <> 0 Then pauseforinstructions ;
                                             End ;
                                             getxnext ;
                                           End ;
                  Case curcmd Of 
                    31 :
                         Begin
                           ldelim := cursym ;
                           rdelim := curmod ;
                           getxnext ;
                           scanexpression ;
                           If ( curcmd = 82 ) And ( curtype >= 16 ) Then
                             Begin
                               p := getnode ( 2 ) ;
                               mem [ p ] . hh . b0 := 14 ;
                               mem [ p ] . hh . b1 := 11 ;
                               initbignode ( p ) ;
                               q := mem [ p + 1 ] . int ;
                               stashin ( q ) ;
                               getxnext ;
                               scanexpression ;
                               If curtype < 16 Then
                                 Begin
                                   disperr ( 0 , 775 ) ;
                                   Begin
                                     helpptr := 4 ;
                                     helpline [ 3 ] := 776 ;
                                     helpline [ 2 ] := 777 ;
                                     helpline [ 1 ] := 778 ;
                                     helpline [ 0 ] := 779 ;
                                   End ;
                                   putgetflusherror ( 0 ) ;
                                 End ;
                               stashin ( q + 2 ) ;
                               checkdelimiter ( ldelim , rdelim ) ;
                               curtype := 14 ;
                               curexp := p ;
                             End
                           Else checkdelimiter ( ldelim , rdelim ) ;
                         End ;
                    32 :
                         Begin
                           groupline := line ;
                           If internal [ 7 ] > 0 Then showcmdmod ( curcmd , curmod ) ;
                           Begin
                             p := getavail ;
                             mem [ p ] . hh . lh := 0 ;
                             mem [ p ] . hh . rh := saveptr ;
                             saveptr := p ;
                           End ;
                           Repeat
                             dostatement ;
                           Until curcmd <> 83 ;
                           If curcmd <> 84 Then
                             Begin
                               Begin
                                 If interaction = 3 Then ;
                                 printnl ( 261 ) ;
                                 print ( 780 ) ;
                               End ;
                               printint ( groupline ) ;
                               print ( 781 ) ;
                               Begin
                                 helpptr := 2 ;
                                 helpline [ 1 ] := 782 ;
                                 helpline [ 0 ] := 783 ;
                               End ;
                               backerror ;
                               curcmd := 84 ;
                             End ;
                           unsave ;
                           If internal [ 7 ] > 0 Then showcmdmod ( curcmd , curmod ) ;
                         End ;
                    39 :
                         Begin
                           curtype := 4 ;
                           curexp := curmod ;
                         End ;
                    42 :
                         Begin
                           curexp := curmod ;
                           curtype := 16 ;
                           getxnext ;
                           If curcmd <> 54 Then
                             Begin
                               num := 0 ;
                               denom := 0 ;
                             End
                           Else
                             Begin
                               getxnext ;
                               If curcmd <> 42 Then
                                 Begin
                                   backinput ;
                                   curcmd := 54 ;
                                   curmod := 72 ;
                                   cursym := 2361 ;
                                   goto 30 ;
                                 End ;
                               num := curexp ;
                               denom := curmod ;
                               If denom = 0 Then
                                 Begin
                                   Begin
                                     If interaction = 3 Then ;
                                     printnl ( 261 ) ;
                                     print ( 784 ) ;
                                   End ;
                                   Begin
                                     helpptr := 1 ;
                                     helpline [ 0 ] := 785 ;
                                   End ;
                                   error ;
                                 End
                               Else curexp := makescaled ( num , denom ) ;
                               Begin
                                 If aritherror Then cleararith ;
                               End ;
                               getxnext ;
                             End ;
                           If curcmd >= 30 Then If curcmd < 42 Then
                                                  Begin
                                                    p := stashcurexp ;
                                                    scanprimary ;
                                                    If ( abs ( num ) >= abs ( denom ) ) Or ( curtype < 14 ) Then dobinary ( p , 71 )
                                                    Else
                                                      Begin
                                                        fracmult ( num , denom ) ;
                                                        freenode ( p , 2 ) ;
                                                      End ;
                                                  End ;
                           goto 30 ;
                         End ;
                    33 : donullary ( curmod ) ;
                    34 , 30 , 36 , 43 :
                                        Begin
                                          c := curmod ;
                                          getxnext ;
                                          scanprimary ;
                                          dounary ( c ) ;
                                          goto 30 ;
                                        End ;
                    37 :
                         Begin
                           c := curmod ;
                           getxnext ;
                           scanexpression ;
                           If curcmd <> 69 Then
                             Begin
                               missingerr ( 479 ) ;
                               print ( 715 ) ;
                               printcmdmod ( 37 , c ) ;
                               Begin
                                 helpptr := 1 ;
                                 helpline [ 0 ] := 716 ;
                               End ;
                               backerror ;
                             End ;
                           p := stashcurexp ;
                           getxnext ;
                           scanprimary ;
                           dobinary ( p , c ) ;
                           goto 30 ;
                         End ;
                    35 :
                         Begin
                           getxnext ;
                           scansuffix ;
                           oldsetting := selector ;
                           selector := 5 ;
                           showtokenlist ( curexp , 0 , 100000 , 0 ) ;
                           flushtokenlist ( curexp ) ;
                           curexp := makestring ;
                           selector := oldsetting ;
                           curtype := 4 ;
                           goto 30 ;
                         End ;
                    40 :
                         Begin
                           q := curmod ;
                           If myvarflag = 77 Then
                             Begin
                               getxnext ;
                               If curcmd = 77 Then
                                 Begin
                                   curexp := getavail ;
                                   mem [ curexp ] . hh . lh := q + 2369 ;
                                   curtype := 20 ;
                                   goto 30 ;
                                 End ;
                               backinput ;
                             End ;
                           curtype := 16 ;
                           curexp := internal [ q ] ;
                         End ;
                    38 : makeexpcopy ( curmod ) ;
                    41 :
                         Begin
                           Begin
                             prehead := avail ;
                             If prehead = 0 Then prehead := getavail
                             Else
                               Begin
                                 avail := mem [ prehead ] . hh . rh ;
                                 mem [ prehead ] . hh . rh := 0 ;
                               End ;
                           End ;
                           tail := prehead ;
                           posthead := 0 ;
                           tt := 1 ;
                           While true Do
                             Begin
                               t := curtok ;
                               mem [ tail ] . hh . rh := t ;
                               If tt <> 0 Then
                                 Begin
                                   Begin
                                     p := mem [ prehead ] . hh . rh ;
                                     q := mem [ p ] . hh . lh ;
                                     tt := 0 ;
                                     If eqtb [ q ] . lh Mod 86 = 41 Then
                                       Begin
                                         q := eqtb [ q ] . rh ;
                                         If q = 0 Then goto 32 ;
                                         While true Do
                                           Begin
                                             p := mem [ p ] . hh . rh ;
                                             If p = 0 Then
                                               Begin
                                                 tt := mem [ q ] . hh . b0 ;
                                                 goto 32 ;
                                               End ;
                                             If mem [ q ] . hh . b0 <> 21 Then goto 32 ;
                                             q := mem [ mem [ q + 1 ] . hh . lh ] . hh . rh ;
                                             If p >= himemmin Then
                                               Begin
                                                 Repeat
                                                   q := mem [ q ] . hh . rh ;
                                                 Until mem [ q + 2 ] . hh . lh >= mem [ p ] . hh . lh ;
                                                 If mem [ q + 2 ] . hh . lh > mem [ p ] . hh . lh Then goto 32 ;
                                               End ;
                                           End ;
                                       End ;
                                     32 :
                                   End ;
                                   If tt >= 22 Then
                                     Begin
                                       mem [ tail ] . hh . rh := 0 ;
                                       If tt > 22 Then
                                         Begin
                                           posthead := getavail ;
                                           tail := posthead ;
                                           mem [ tail ] . hh . rh := t ;
                                           tt := 0 ;
                                           macroref := mem [ q + 1 ] . int ;
                                           mem [ macroref ] . hh . lh := mem [ macroref ] . hh . lh + 1 ;
                                         End
                                       Else
                                         Begin
                                           p := getavail ;
                                           mem [ prehead ] . hh . lh := mem [ prehead ] . hh . rh ;
                                           mem [ prehead ] . hh . rh := p ;
                                           mem [ p ] . hh . lh := t ;
                                           macrocall ( mem [ q + 1 ] . int , prehead , 0 ) ;
                                           getxnext ;
                                           goto 20 ;
                                         End ;
                                     End ;
                                 End ;
                               getxnext ;
                               tail := t ;
                               If curcmd = 63 Then
                                 Begin
                                   getxnext ;
                                   scanexpression ;
                                   If curcmd <> 64 Then
                                     Begin
                                       backinput ;
                                       backexpr ;
                                       curcmd := 63 ;
                                       curmod := 0 ;
                                       cursym := 2360 ;
                                     End
                                   Else
                                     Begin
                                       If curtype <> 16 Then badsubscript ;
                                       curcmd := 42 ;
                                       curmod := curexp ;
                                       cursym := 0 ;
                                     End ;
                                 End ;
                               If curcmd > 42 Then goto 31 ;
                               If curcmd < 40 Then goto 31 ;
                             End ;
                           31 : If posthead <> 0 Then
                                  Begin
                                    backinput ;
                                    p := getavail ;
                                    q := mem [ posthead ] . hh . rh ;
                                    mem [ prehead ] . hh . lh := mem [ prehead ] . hh . rh ;
                                    mem [ prehead ] . hh . rh := posthead ;
                                    mem [ posthead ] . hh . lh := q ;
                                    mem [ posthead ] . hh . rh := p ;
                                    mem [ p ] . hh . lh := mem [ q ] . hh . rh ;
                                    mem [ q ] . hh . rh := 0 ;
                                    macrocall ( macroref , prehead , 0 ) ;
                                    mem [ macroref ] . hh . lh := mem [ macroref ] . hh . lh - 1 ;
                                    getxnext ;
                                    goto 20 ;
                                  End ;
                           q := mem [ prehead ] . hh . rh ;
                           Begin
                             mem [ prehead ] . hh . rh := avail ;
                             avail := prehead ;
                           End ;
                           If curcmd = myvarflag Then
                             Begin
                               curtype := 20 ;
                               curexp := q ;
                               goto 30 ;
                             End ;
                           p := findvariable ( q ) ;
                           If p <> 0 Then makeexpcopy ( p )
                           Else
                             Begin
                               obliterated ( q ) ;
                               helpline [ 2 ] := 797 ;
                               helpline [ 1 ] := 798 ;
                               helpline [ 0 ] := 799 ;
                               putgetflusherror ( 0 ) ;
                             End ;
                           flushnodelist ( q ) ;
                           goto 30 ;
                         End ;
                    others :
                             Begin
                               badexp ( 769 ) ;
                               goto 20 ;
                             End
                  End ;
                  getxnext ;
                  30 : If curcmd = 63 Then If curtype >= 16 Then
                                             Begin
                                               p := stashcurexp ;
                                               getxnext ;
                                               scanexpression ;
                                               If curcmd <> 82 Then
                                                 Begin
                                                   Begin
                                                     backinput ;
                                                     backexpr ;
                                                     curcmd := 63 ;
                                                     curmod := 0 ;
                                                     cursym := 2360 ;
                                                   End ;
                                                   unstashcurexp ( p ) ;
                                                 End
                                               Else
                                                 Begin
                                                   q := stashcurexp ;
                                                   getxnext ;
                                                   scanexpression ;
                                                   If curcmd <> 64 Then
                                                     Begin
                                                       missingerr ( 93 ) ;
                                                       Begin
                                                         helpptr := 3 ;
                                                         helpline [ 2 ] := 801 ;
                                                         helpline [ 1 ] := 802 ;
                                                         helpline [ 0 ] := 697 ;
                                                       End ;
                                                       backerror ;
                                                     End ;
                                                   r := stashcurexp ;
                                                   makeexpcopy ( q ) ;
                                                   dobinary ( r , 70 ) ;
                                                   dobinary ( p , 71 ) ;
                                                   dobinary ( q , 69 ) ;
                                                   getxnext ;
                                                 End ;
                                             End ;
                End ;
                Procedure scansuffix ;

                Label 30 ;

                Var h , t : halfword ;
                  p : halfword ;
                Begin
                  h := getavail ;
                  t := h ;
                  While true Do
                    Begin
                      If curcmd = 63 Then
                        Begin
                          getxnext ;
                          scanexpression ;
                          If curtype <> 16 Then badsubscript ;
                          If curcmd <> 64 Then
                            Begin
                              missingerr ( 93 ) ;
                              Begin
                                helpptr := 3 ;
                                helpline [ 2 ] := 803 ;
                                helpline [ 1 ] := 802 ;
                                helpline [ 0 ] := 697 ;
                              End ;
                              backerror ;
                            End ;
                          curcmd := 42 ;
                          curmod := curexp ;
                        End ;
                      If curcmd = 42 Then p := newnumtok ( curmod )
                      Else If ( curcmd = 41 ) Or ( curcmd = 40 ) Then
                             Begin
                               p := getavail ;
                               mem [ p ] . hh . lh := cursym ;
                             End
                      Else goto 30 ;
                      mem [ t ] . hh . rh := p ;
                      t := p ;
                      getxnext ;
                    End ;
                  30 : curexp := mem [ h ] . hh . rh ;
                  Begin
                    mem [ h ] . hh . rh := avail ;
                    avail := h ;
                  End ;
                  curtype := 20 ;
                End ;
                Procedure scansecondary ;

                Label 20 , 22 ;

                Var p : halfword ;
                  c , d : halfword ;
                  macname : halfword ;
                Begin
                  20 : If ( curcmd < 30 ) Or ( curcmd > 43 ) Then badexp ( 804 ) ;
                  scanprimary ;
                  22 : If curcmd <= 55 Then If curcmd >= 52 Then
                                              Begin
                                                p := stashcurexp ;
                                                c := curmod ;
                                                d := curcmd ;
                                                If d = 53 Then
                                                  Begin
                                                    macname := cursym ;
                                                    mem [ c ] . hh . lh := mem [ c ] . hh . lh + 1 ;
                                                  End ;
                                                getxnext ;
                                                scanprimary ;
                                                If d <> 53 Then dobinary ( p , c )
                                                Else
                                                  Begin
                                                    backinput ;
                                                    binarymac ( p , c , macname ) ;
                                                    mem [ c ] . hh . lh := mem [ c ] . hh . lh - 1 ;
                                                    getxnext ;
                                                    goto 20 ;
                                                  End ;
                                                goto 22 ;
                                              End ;
                End ;
                Procedure scantertiary ;

                Label 20 , 22 ;

                Var p : halfword ;
                  c , d : halfword ;
                  macname : halfword ;
                Begin
                  20 : If ( curcmd < 30 ) Or ( curcmd > 43 ) Then badexp ( 805 ) ;
                  scansecondary ;
                  If curtype = 8 Then materializepen ;
                  22 : If curcmd <= 45 Then If curcmd >= 43 Then
                                              Begin
                                                p := stashcurexp ;
                                                c := curmod ;
                                                d := curcmd ;
                                                If d = 44 Then
                                                  Begin
                                                    macname := cursym ;
                                                    mem [ c ] . hh . lh := mem [ c ] . hh . lh + 1 ;
                                                  End ;
                                                getxnext ;
                                                scansecondary ;
                                                If d <> 44 Then dobinary ( p , c )
                                                Else
                                                  Begin
                                                    backinput ;
                                                    binarymac ( p , c , macname ) ;
                                                    mem [ c ] . hh . lh := mem [ c ] . hh . lh - 1 ;
                                                    getxnext ;
                                                    goto 20 ;
                                                  End ;
                                                goto 22 ;
                                              End ;
                End ;
                Procedure scanexpression ;

                Label 20 , 30 , 22 , 25 , 26 , 10 ;

                Var p , q , r , pp , qq : halfword ;
                  c , d : halfword ;
                  myvarflag : 0 .. 85 ;
                  macname : halfword ;
                  cyclehit : boolean ;
                  x , y : scaled ;
                  t : 0 .. 4 ;
                Begin
                  myvarflag := varflag ;
                  20 : If ( curcmd < 30 ) Or ( curcmd > 43 ) Then badexp ( 808 ) ;
                  scantertiary ;
                  22 : If curcmd <= 51 Then If curcmd >= 46 Then If ( curcmd <> 51 ) Or ( myvarflag <> 77 ) Then
                                                                   Begin
                                                                     p := stashcurexp ;
                                                                     c := curmod ;
                                                                     d := curcmd ;
                                                                     If d = 49 Then
                                                                       Begin
                                                                         macname := cursym ;
                                                                         mem [ c ] . hh . lh := mem [ c ] . hh . lh + 1 ;
                                                                       End ;
                                                                     If ( d < 48 ) Or ( ( d = 48 ) And ( ( mem [ p ] . hh . b0 = 14 ) Or ( mem [ p ] . hh . b0 = 9 ) ) ) Then
                                                                       Begin
                                                                         cyclehit := false ;
                                                                         Begin
                                                                           unstashcurexp ( p ) ;
                                                                           If curtype = 14 Then p := newknot
                                                                           Else If curtype = 9 Then p := curexp
                                                                           Else goto 10 ;
                                                                           q := p ;
                                                                           While mem [ q ] . hh . rh <> p Do
                                                                             q := mem [ q ] . hh . rh ;
                                                                           If mem [ p ] . hh . b0 <> 0 Then
                                                                             Begin
                                                                               r := copyknot ( p ) ;
                                                                               mem [ q ] . hh . rh := r ;
                                                                               q := r ;
                                                                             End ;
                                                                           mem [ p ] . hh . b0 := 4 ;
                                                                           mem [ q ] . hh . b1 := 4 ;
                                                                         End ;
                                                                         25 : If curcmd = 46 Then
                                                                                Begin
                                                                                  t := scandirection ;
                                                                                  If t <> 4 Then
                                                                                    Begin
                                                                                      mem [ q ] . hh . b1 := t ;
                                                                                      mem [ q + 5 ] . int := curexp ;
                                                                                      If mem [ q ] . hh . b0 = 4 Then
                                                                                        Begin
                                                                                          mem [ q ] . hh . b0 := t ;
                                                                                          mem [ q + 3 ] . int := curexp ;
                                                                                        End ;
                                                                                    End ;
                                                                                End ;
                                                                         d := curcmd ;
                                                                         If d = 47 Then
                                                                           Begin
                                                                             getxnext ;
                                                                             If curcmd = 58 Then
                                                                               Begin
                                                                                 getxnext ;
                                                                                 y := curcmd ;
                                                                                 If curcmd = 59 Then getxnext ;
                                                                                 scanprimary ;
                                                                                 If ( curtype <> 16 ) Or ( curexp < 49152 ) Then
                                                                                   Begin
                                                                                     disperr ( 0 , 826 ) ;
                                                                                     Begin
                                                                                       helpptr := 1 ;
                                                                                       helpline [ 0 ] := 827 ;
                                                                                     End ;
                                                                                     putgetflusherror ( 65536 ) ;
                                                                                   End ;
                                                                                 If y = 59 Then curexp := - curexp ;
                                                                                 mem [ q + 6 ] . int := curexp ;
                                                                                 If curcmd = 52 Then
                                                                                   Begin
                                                                                     getxnext ;
                                                                                     y := curcmd ;
                                                                                     If curcmd = 59 Then getxnext ;
                                                                                     scanprimary ;
                                                                                     If ( curtype <> 16 ) Or ( curexp < 49152 ) Then
                                                                                       Begin
                                                                                         disperr ( 0 , 826 ) ;
                                                                                         Begin
                                                                                           helpptr := 1 ;
                                                                                           helpline [ 0 ] := 827 ;
                                                                                         End ;
                                                                                         putgetflusherror ( 65536 ) ;
                                                                                       End ;
                                                                                     If y = 59 Then curexp := - curexp ;
                                                                                   End ;
                                                                                 y := curexp ;
                                                                               End
                                                                             Else If curcmd = 57 Then
                                                                                    Begin
                                                                                      mem [ q ] . hh . b1 := 1 ;
                                                                                      t := 1 ;
                                                                                      getxnext ;
                                                                                      scanprimary ;
                                                                                      knownpair ;
                                                                                      mem [ q + 5 ] . int := curx ;
                                                                                      mem [ q + 6 ] . int := cury ;
                                                                                      If curcmd <> 52 Then
                                                                                        Begin
                                                                                          x := mem [ q + 5 ] . int ;
                                                                                          y := mem [ q + 6 ] . int ;
                                                                                        End
                                                                                      Else
                                                                                        Begin
                                                                                          getxnext ;
                                                                                          scanprimary ;
                                                                                          knownpair ;
                                                                                          x := curx ;
                                                                                          y := cury ;
                                                                                        End ;
                                                                                    End
                                                                             Else
                                                                               Begin
                                                                                 mem [ q + 6 ] . int := 65536 ;
                                                                                 y := 65536 ;
                                                                                 backinput ;
                                                                                 goto 30 ;
                                                                               End ;
                                                                             If curcmd <> 47 Then
                                                                               Begin
                                                                                 missingerr ( 409 ) ;
                                                                                 Begin
                                                                                   helpptr := 1 ;
                                                                                   helpline [ 0 ] := 825 ;
                                                                                 End ;
                                                                                 backerror ;
                                                                               End ;
                                                                             30 :
                                                                           End
                                                                         Else If d <> 48 Then goto 26 ;
                                                                         getxnext ;
                                                                         If curcmd = 46 Then
                                                                           Begin
                                                                             t := scandirection ;
                                                                             If mem [ q ] . hh . b1 <> 1 Then x := curexp
                                                                             Else t := 1 ;
                                                                           End
                                                                         Else If mem [ q ] . hh . b1 <> 1 Then
                                                                                Begin
                                                                                  t := 4 ;
                                                                                  x := 0 ;
                                                                                End ;
                                                                         If curcmd = 36 Then
                                                                           Begin
                                                                             cyclehit := true ;
                                                                             getxnext ;
                                                                             pp := p ;
                                                                             qq := p ;
                                                                             If d = 48 Then If p = q Then
                                                                                              Begin
                                                                                                d := 47 ;
                                                                                                mem [ q + 6 ] . int := 65536 ;
                                                                                                y := 65536 ;
                                                                                              End ;
                                                                           End
                                                                         Else
                                                                           Begin
                                                                             scantertiary ;
                                                                             Begin
                                                                               If curtype <> 9 Then pp := newknot
                                                                               Else pp := curexp ;
                                                                               qq := pp ;
                                                                               While mem [ qq ] . hh . rh <> pp Do
                                                                                 qq := mem [ qq ] . hh . rh ;
                                                                               If mem [ pp ] . hh . b0 <> 0 Then
                                                                                 Begin
                                                                                   r := copyknot ( pp ) ;
                                                                                   mem [ qq ] . hh . rh := r ;
                                                                                   qq := r ;
                                                                                 End ;
                                                                               mem [ pp ] . hh . b0 := 4 ;
                                                                               mem [ qq ] . hh . b1 := 4 ;
                                                                             End ;
                                                                           End ;
                                                                         Begin
                                                                           If d = 48 Then If ( mem [ q + 1 ] . int <> mem [ pp + 1 ] . int ) Or ( mem [ q + 2 ] . int <> mem [ pp + 2 ] . int ) Then
                                                                                            Begin
                                                                                              Begin
                                                                                                If interaction = 3 Then ;
                                                                                                printnl ( 261 ) ;
                                                                                                print ( 828 ) ;
                                                                                              End ;
                                                                                              Begin
                                                                                                helpptr := 3 ;
                                                                                                helpline [ 2 ] := 829 ;
                                                                                                helpline [ 1 ] := 830 ;
                                                                                                helpline [ 0 ] := 831 ;
                                                                                              End ;
                                                                                              putgeterror ;
                                                                                              d := 47 ;
                                                                                              mem [ q + 6 ] . int := 65536 ;
                                                                                              y := 65536 ;
                                                                                            End ;
                                                                           If mem [ pp ] . hh . b1 = 4 Then If ( t = 3 ) Or ( t = 2 ) Then
                                                                                                              Begin
                                                                                                                mem [ pp ] . hh . b1 := t ;
                                                                                                                mem [ pp + 5 ] . int := x ;
                                                                                                              End ;
                                                                           If d = 48 Then
                                                                             Begin
                                                                               If mem [ q ] . hh . b0 = 4 Then If mem [ q ] . hh . b1 = 4 Then
                                                                                                                 Begin
                                                                                                                   mem [ q ] . hh . b0 := 3 ;
                                                                                                                   mem [ q + 3 ] . int := 65536 ;
                                                                                                                 End ;
                                                                               If mem [ pp ] . hh . b1 = 4 Then If t = 4 Then
                                                                                                                  Begin
                                                                                                                    mem [ pp ] . hh . b1 := 3 ;
                                                                                                                    mem [ pp + 5 ] . int := 65536 ;
                                                                                                                  End ;
                                                                               mem [ q ] . hh . b1 := mem [ pp ] . hh . b1 ;
                                                                               mem [ q ] . hh . rh := mem [ pp ] . hh . rh ;
                                                                               mem [ q + 5 ] . int := mem [ pp + 5 ] . int ;
                                                                               mem [ q + 6 ] . int := mem [ pp + 6 ] . int ;
                                                                               freenode ( pp , 7 ) ;
                                                                               If qq = pp Then qq := q ;
                                                                             End
                                                                           Else
                                                                             Begin
                                                                               If mem [ q ] . hh . b1 = 4 Then If ( mem [ q ] . hh . b0 = 3 ) Or ( mem [ q ] . hh . b0 = 2 ) Then
                                                                                                                 Begin
                                                                                                                   mem [ q ] . hh . b1 := mem [ q ] . hh . b0 ;
                                                                                                                   mem [ q + 5 ] . int := mem [ q + 3 ] . int ;
                                                                                                                 End ;
                                                                               mem [ q ] . hh . rh := pp ;
                                                                               mem [ pp + 4 ] . int := y ;
                                                                               If t <> 4 Then
                                                                                 Begin
                                                                                   mem [ pp + 3 ] . int := x ;
                                                                                   mem [ pp ] . hh . b0 := t ;
                                                                                 End ;
                                                                             End ;
                                                                           q := qq ;
                                                                         End ;
                                                                         If curcmd >= 46 Then If curcmd <= 48 Then If Not cyclehit Then goto 25 ;
                                                                         26 : If cyclehit Then
                                                                                Begin
                                                                                  If d = 48 Then p := q ;
                                                                                End
                                                                              Else
                                                                                Begin
                                                                                  mem [ p ] . hh . b0 := 0 ;
                                                                                  If mem [ p ] . hh . b1 = 4 Then
                                                                                    Begin
                                                                                      mem [ p ] . hh . b1 := 3 ;
                                                                                      mem [ p + 5 ] . int := 65536 ;
                                                                                    End ;
                                                                                  mem [ q ] . hh . b1 := 0 ;
                                                                                  If mem [ q ] . hh . b0 = 4 Then
                                                                                    Begin
                                                                                      mem [ q ] . hh . b0 := 3 ;
                                                                                      mem [ q + 3 ] . int := 65536 ;
                                                                                    End ;
                                                                                  mem [ q ] . hh . rh := p ;
                                                                                End ;
                                                                         makechoices ( p ) ;
                                                                         curtype := 9 ;
                                                                         curexp := p ;
                                                                       End
                                                                     Else
                                                                       Begin
                                                                         getxnext ;
                                                                         scantertiary ;
                                                                         If d <> 49 Then dobinary ( p , c )
                                                                         Else
                                                                           Begin
                                                                             backinput ;
                                                                             binarymac ( p , c , macname ) ;
                                                                             mem [ c ] . hh . lh := mem [ c ] . hh . lh - 1 ;
                                                                             getxnext ;
                                                                             goto 20 ;
                                                                           End ;
                                                                       End ;
                                                                     goto 22 ;
                                                                   End ;
                  10 :
                End ;
                Procedure getboolean ;
                Begin
                  getxnext ;
                  scanexpression ;
                  If curtype <> 2 Then
                    Begin
                      disperr ( 0 , 832 ) ;
                      Begin
                        helpptr := 2 ;
                        helpline [ 1 ] := 833 ;
                        helpline [ 0 ] := 834 ;
                      End ;
                      putgetflusherror ( 31 ) ;
                      curtype := 2 ;
                    End ;
                End ;
                Procedure printcapsule ;
                Begin
                  printchar ( 40 ) ;
                  printexp ( gpointer , 0 ) ;
                  printchar ( 41 ) ;
                End ;
                Procedure tokenrecycle ;
                Begin
                  recyclevalue ( gpointer ) ;
                End ;
                Procedure closefilesandterminate ;

                Var k : integer ;
                  lh : integer ;
                  lkoffset : 0 .. 256 ;
                  p : halfword ;
                  x : scaled ;
                Begin ;
                  If ( gfprevptr > 0 ) Or ( internal [ 33 ] > 0 ) Then
                    Begin
                      rover := 23 ;
                      mem [ rover ] . hh . rh := 65535 ;
                      lomemmax := himemmin - 1 ;
                      If lomemmax - rover > 65535 Then lomemmax := 65535 + rover ;
                      mem [ rover ] . hh . lh := lomemmax - rover ;
                      mem [ rover + 1 ] . hh . lh := rover ;
                      mem [ rover + 1 ] . hh . rh := rover ;
                      mem [ lomemmax ] . hh . rh := 0 ;
                      mem [ lomemmax ] . hh . lh := 0 ;
                      mem [ 29999 ] . hh . rh := 19 ;
                      For k := bc To ec Do
                        If charexists [ k ] Then tfmwidth [ k ] := sortin ( tfmwidth [ k ] ) ;
                      nw := skimp ( 255 ) + 1 ;
                      dimenhead [ 1 ] := mem [ 29999 ] . hh . rh ;
                      If perturbation >= 4096 Then tfmwarning ( 20 ) ;
                      fixdesignsize ;
                      fixchecksum ;
                      If internal [ 33 ] > 0 Then
                        Begin
                          mem [ 29999 ] . hh . rh := 19 ;
                          For k := bc To ec Do
                            If charexists [ k ] Then If tfmheight [ k ] = 0 Then tfmheight [ k ] := 15
                            Else tfmheight [ k ] := sortin ( tfmheight [ k ] ) ;
                          nh := skimp ( 15 ) + 1 ;
                          dimenhead [ 2 ] := mem [ 29999 ] . hh . rh ;
                          If perturbation >= 4096 Then tfmwarning ( 21 ) ;
                          mem [ 29999 ] . hh . rh := 19 ;
                          For k := bc To ec Do
                            If charexists [ k ] Then If tfmdepth [ k ] = 0 Then tfmdepth [ k ] := 15
                            Else tfmdepth [ k ] := sortin ( tfmdepth [ k ] ) ;
                          nd := skimp ( 15 ) + 1 ;
                          dimenhead [ 3 ] := mem [ 29999 ] . hh . rh ;
                          If perturbation >= 4096 Then tfmwarning ( 22 ) ;
                          mem [ 29999 ] . hh . rh := 19 ;
                          For k := bc To ec Do
                            If charexists [ k ] Then If tfmitalcorr [ k ] = 0 Then tfmitalcorr [ k ] := 15
                            Else tfmitalcorr [ k ] := sortin ( tfmitalcorr [ k ] ) ;
                          ni := skimp ( 63 ) + 1 ;
                          dimenhead [ 4 ] := mem [ 29999 ] . hh . rh ;
                          If perturbation >= 4096 Then tfmwarning ( 23 ) ;
                          internal [ 33 ] := 0 ;
                          If jobname = 0 Then openlogfile ;
                          packjobname ( 1045 ) ;
                          While Not bopenout ( tfmfile ) Do
                            promptfilename ( 1046 , 1045 ) ;
                          metricfilename := bmakenamestring ( tfmfile ) ;
                          k := headersize ;
                          While headerbyte [ k ] < 0 Do
                            k := k - 1 ;
                          lh := ( k + 3 ) Div 4 ;
                          If bc > ec Then bc := 1 ;
                          bchar := roundunscaled ( internal [ 41 ] ) ;
                          If ( bchar < 0 ) Or ( bchar > 255 ) Then
                            Begin
                              bchar := - 1 ;
                              lkstarted := false ;
                              lkoffset := 0 ;
                            End
                          Else
                            Begin
                              lkstarted := true ;
                              lkoffset := 1 ;
                            End ;
                          k := labelptr ;
                          If labelloc [ k ] + lkoffset > 255 Then
                            Begin
                              lkoffset := 0 ;
                              lkstarted := false ;
                              Repeat
                                charremainder [ labelchar [ k ] ] := lkoffset ;
                                While labelloc [ k - 1 ] = labelloc [ k ] Do
                                  Begin
                                    k := k - 1 ;
                                    charremainder [ labelchar [ k ] ] := lkoffset ;
                                  End ;
                                lkoffset := lkoffset + 1 ;
                                k := k - 1 ;
                              Until lkoffset + labelloc [ k ] < 256 ;
                            End ;
                          If lkoffset > 0 Then While k > 0 Do
                                                 Begin
                                                   charremainder [ labelchar [ k ] ] := charremainder [ labelchar [ k ] ] + lkoffset ;
                                                   k := k - 1 ;
                                                 End ;
                          If bchlabel < ligtablesize Then
                            Begin
                              ligkern [ nl ] . b0 := 255 ;
                              ligkern [ nl ] . b1 := 0 ;
                              ligkern [ nl ] . b2 := ( ( bchlabel + lkoffset ) Div 256 ) + 0 ;
                              ligkern [ nl ] . b3 := ( ( bchlabel + lkoffset ) Mod 256 ) + 0 ;
                              nl := nl + 1 ;
                            End ;
                          tfmtwo ( 6 + lh + ( ec - bc + 1 ) + nw + nh + nd + ni + nl + lkoffset + nk + ne + np ) ;
                          tfmtwo ( lh ) ;
                          tfmtwo ( bc ) ;
                          tfmtwo ( ec ) ;
                          tfmtwo ( nw ) ;
                          tfmtwo ( nh ) ;
                          tfmtwo ( nd ) ;
                          tfmtwo ( ni ) ;
                          tfmtwo ( nl + lkoffset ) ;
                          tfmtwo ( nk ) ;
                          tfmtwo ( ne ) ;
                          tfmtwo ( np ) ;
                          For k := 1 To 4 * lh Do
                            Begin
                              If headerbyte [ k ] < 0 Then headerbyte [ k ] := 0 ;
                              write ( tfmfile , headerbyte [ k ] ) ;
                            End ;
                          For k := bc To ec Do
                            If Not charexists [ k ] Then tfmfour ( 0 )
                            Else
                              Begin
                                write ( tfmfile , mem [ tfmwidth [ k ] ] . hh . lh ) ;
                                write ( tfmfile , ( mem [ tfmheight [ k ] ] . hh . lh ) * 16 + mem [ tfmdepth [ k ] ] . hh . lh ) ;
                                write ( tfmfile , ( mem [ tfmitalcorr [ k ] ] . hh . lh ) * 4 + chartag [ k ] ) ;
                                write ( tfmfile , charremainder [ k ] ) ;
                              End ;
                          tfmchanged := 0 ;
                          For k := 1 To 4 Do
                            Begin
                              tfmfour ( 0 ) ;
                              p := dimenhead [ k ] ;
                              While p <> 19 Do
                                Begin
                                  tfmfour ( dimenout ( mem [ p + 1 ] . int ) ) ;
                                  p := mem [ p ] . hh . rh ;
                                End ;
                            End ;
                          For k := 0 To 255 Do
                            If skiptable [ k ] < ligtablesize Then
                              Begin
                                printnl ( 1048 ) ;
                                printint ( k ) ;
                                print ( 1049 ) ;
                                ll := skiptable [ k ] ;
                                Repeat
                                  lll := ligkern [ ll ] . b0 - 0 ;
                                  ligkern [ ll ] . b0 := 128 ;
                                  ll := ll - lll ;
                                Until lll = 0 ;
                              End ;
                          If lkstarted Then
                            Begin
                              write ( tfmfile , 255 ) ;
                              write ( tfmfile , bchar ) ;
                              tfmtwo ( 0 ) ;
                            End
                          Else For k := 1 To lkoffset Do
                                 Begin
                                   ll := labelloc [ labelptr ] ;
                                   If bchar < 0 Then
                                     Begin
                                       write ( tfmfile , 254 ) ;
                                       write ( tfmfile , 0 ) ;
                                     End
                                   Else
                                     Begin
                                       write ( tfmfile , 255 ) ;
                                       write ( tfmfile , bchar ) ;
                                     End ;
                                   tfmtwo ( ll + lkoffset ) ;
                                   Repeat
                                     labelptr := labelptr - 1 ;
                                   Until labelloc [ labelptr ] < ll ;
                                 End ;
                          For k := 0 To nl - 1 Do
                            tfmqqqq ( ligkern [ k ] ) ;
                          For k := 0 To nk - 1 Do
                            tfmfour ( dimenout ( kern [ k ] ) ) ;
                          For k := 0 To ne - 1 Do
                            tfmqqqq ( exten [ k ] ) ;
                          For k := 1 To np Do
                            If k = 1 Then If abs ( param [ 1 ] ) < 134217728 Then tfmfour ( param [ 1 ] * 16 )
                            Else
                              Begin
                                tfmchanged := tfmchanged + 1 ;
                                If param [ 1 ] > 0 Then tfmfour ( 2147483647 )
                                Else tfmfour ( - 2147483647 ) ;
                              End
                            Else tfmfour ( dimenout ( param [ k ] ) ) ;
                          If tfmchanged > 0 Then
                            Begin
                              If tfmchanged = 1 Then printnl ( 1050 )
                              Else
                                Begin
                                  printnl ( 40 ) ;
                                  printint ( tfmchanged ) ;
                                  print ( 1051 ) ;
                                End ;
                              print ( 1052 ) ;
                            End ;
                          printnl ( 1047 ) ;
                          slowprint ( metricfilename ) ;
                          printchar ( 46 ) ;
                          bclose ( tfmfile ) ;
                        End ;
                      If gfprevptr > 0 Then
                        Begin
                          Begin
                            gfbuf [ gfptr ] := 248 ;
                            gfptr := gfptr + 1 ;
                            If gfptr = gflimit Then gfswap ;
                          End ;
                          gffour ( gfprevptr ) ;
                          gfprevptr := gfoffset + gfptr - 5 ;
                          gffour ( internal [ 26 ] * 16 ) ;
                          For k := 1 To 4 Do
                            Begin
                              gfbuf [ gfptr ] := headerbyte [ k ] ;
                              gfptr := gfptr + 1 ;
                              If gfptr = gflimit Then gfswap ;
                            End ;
                          gffour ( internal [ 27 ] ) ;
                          gffour ( internal [ 28 ] ) ;
                          gffour ( gfminm ) ;
                          gffour ( gfmaxm ) ;
                          gffour ( gfminn ) ;
                          gffour ( gfmaxn ) ;
                          For k := 0 To 255 Do
                            If charexists [ k ] Then
                              Begin
                                x := gfdx [ k ] Div 65536 ;
                                If ( gfdy [ k ] = 0 ) And ( x >= 0 ) And ( x < 256 ) And ( gfdx [ k ] = x * 65536 ) Then
                                  Begin
                                    Begin
                                      gfbuf [ gfptr ] := 246 ;
                                      gfptr := gfptr + 1 ;
                                      If gfptr = gflimit Then gfswap ;
                                    End ;
                                    Begin
                                      gfbuf [ gfptr ] := k ;
                                      gfptr := gfptr + 1 ;
                                      If gfptr = gflimit Then gfswap ;
                                    End ;
                                    Begin
                                      gfbuf [ gfptr ] := x ;
                                      gfptr := gfptr + 1 ;
                                      If gfptr = gflimit Then gfswap ;
                                    End ;
                                  End
                                Else
                                  Begin
                                    Begin
                                      gfbuf [ gfptr ] := 245 ;
                                      gfptr := gfptr + 1 ;
                                      If gfptr = gflimit Then gfswap ;
                                    End ;
                                    Begin
                                      gfbuf [ gfptr ] := k ;
                                      gfptr := gfptr + 1 ;
                                      If gfptr = gflimit Then gfswap ;
                                    End ;
                                    gffour ( gfdx [ k ] ) ;
                                    gffour ( gfdy [ k ] ) ;
                                  End ;
                                x := mem [ tfmwidth [ k ] + 1 ] . int ;
                                If abs ( x ) > maxtfmdimen Then If x > 0 Then x := 16777215
                                Else x := - 16777215
                                Else x := makescaled ( x * 16 , internal [ 26 ] ) ;
                                gffour ( x ) ;
                                gffour ( charptr [ k ] ) ;
                              End ;
                          Begin
                            gfbuf [ gfptr ] := 249 ;
                            gfptr := gfptr + 1 ;
                            If gfptr = gflimit Then gfswap ;
                          End ;
                          gffour ( gfprevptr ) ;
                          Begin
                            gfbuf [ gfptr ] := 131 ;
                            gfptr := gfptr + 1 ;
                            If gfptr = gflimit Then gfswap ;
                          End ;
                          k := 4 + ( ( gfbufsize - gfptr ) Mod 4 ) ;
                          While k > 0 Do
                            Begin
                              Begin
                                gfbuf [ gfptr ] := 223 ;
                                gfptr := gfptr + 1 ;
                                If gfptr = gflimit Then gfswap ;
                              End ;
                              k := k - 1 ;
                            End ;
                          If gflimit = halfbuf Then writegf ( halfbuf , gfbufsize - 1 ) ;
                          If gfptr > 0 Then writegf ( 0 , gfptr - 1 ) ;
                          printnl ( 1063 ) ;
                          slowprint ( outputfilename ) ;
                          print ( 558 ) ;
                          printint ( totalchars ) ;
                          print ( 1064 ) ;
                          If totalchars <> 1 Then printchar ( 115 ) ;
                          print ( 1065 ) ;
                          printint ( gfoffset + gfptr ) ;
                          print ( 1066 ) ;
                          bclose ( gffile ) ;
                        End ;
                    End ;
                  If logopened Then
                    Begin
                      writeln ( logfile ) ;
                      aclose ( logfile ) ;
                      selector := selector - 2 ;
                      If selector = 1 Then
                        Begin
                          printnl ( 1074 ) ;
                          slowprint ( logname ) ;
                          printchar ( 46 ) ;
                        End ;
                    End ;
                End ;
                Procedure finalcleanup ;

                Label 10 ;

                Var c : smallnumber ;
                Begin
                  c := curmod ;
                  If jobname = 0 Then openlogfile ;
                  While inputptr > 0 Do
                    If ( curinput . indexfield > 6 ) Then endtokenlist
                    Else endfilereading ;
                  While loopptr <> 0 Do
                    stopiteration ;
                  While openparens > 0 Do
                    Begin
                      print ( 1075 ) ;
                      openparens := openparens - 1 ;
                    End ;
                  While condptr <> 0 Do
                    Begin
                      printnl ( 1076 ) ;
                      printcmdmod ( 2 , curif ) ;
                      If ifline <> 0 Then
                        Begin
                          print ( 1077 ) ;
                          printint ( ifline ) ;
                        End ;
                      print ( 1078 ) ;
                      ifline := mem [ condptr + 1 ] . int ;
                      curif := mem [ condptr ] . hh . b1 ;
                      loopptr := condptr ;
                      condptr := mem [ condptr ] . hh . rh ;
                      freenode ( loopptr , 2 ) ;
                    End ;
                  If history <> 0 Then If ( ( history = 1 ) Or ( interaction < 3 ) ) Then If selector = 3 Then
                                                                                            Begin
                                                                                              selector := 1 ;
                                                                                              printnl ( 1079 ) ;
                                                                                              selector := 3 ;
                                                                                            End ;
                  If c = 1 Then
                    Begin
                      storebasefile ;
                      goto 10 ;
                      printnl ( 1080 ) ;
                      goto 10 ;
                    End ;
                  10 :
                End ;
                Procedure initprim ;
                Begin
                  primitive ( 410 , 40 , 1 ) ;
                  primitive ( 411 , 40 , 2 ) ;
                  primitive ( 412 , 40 , 3 ) ;
                  primitive ( 413 , 40 , 4 ) ;
                  primitive ( 414 , 40 , 5 ) ;
                  primitive ( 415 , 40 , 6 ) ;
                  primitive ( 416 , 40 , 7 ) ;
                  primitive ( 417 , 40 , 8 ) ;
                  primitive ( 418 , 40 , 9 ) ;
                  primitive ( 419 , 40 , 10 ) ;
                  primitive ( 420 , 40 , 11 ) ;
                  primitive ( 421 , 40 , 12 ) ;
                  primitive ( 422 , 40 , 13 ) ;
                  primitive ( 423 , 40 , 14 ) ;
                  primitive ( 424 , 40 , 15 ) ;
                  primitive ( 425 , 40 , 16 ) ;
                  primitive ( 426 , 40 , 17 ) ;
                  primitive ( 427 , 40 , 18 ) ;
                  primitive ( 428 , 40 , 19 ) ;
                  primitive ( 429 , 40 , 20 ) ;
                  primitive ( 430 , 40 , 21 ) ;
                  primitive ( 431 , 40 , 22 ) ;
                  primitive ( 432 , 40 , 23 ) ;
                  primitive ( 433 , 40 , 24 ) ;
                  primitive ( 434 , 40 , 25 ) ;
                  primitive ( 435 , 40 , 26 ) ;
                  primitive ( 436 , 40 , 27 ) ;
                  primitive ( 437 , 40 , 28 ) ;
                  primitive ( 438 , 40 , 29 ) ;
                  primitive ( 439 , 40 , 30 ) ;
                  primitive ( 440 , 40 , 31 ) ;
                  primitive ( 441 , 40 , 32 ) ;
                  primitive ( 442 , 40 , 33 ) ;
                  primitive ( 443 , 40 , 34 ) ;
                  primitive ( 444 , 40 , 35 ) ;
                  primitive ( 445 , 40 , 36 ) ;
                  primitive ( 446 , 40 , 37 ) ;
                  primitive ( 447 , 40 , 38 ) ;
                  primitive ( 448 , 40 , 39 ) ;
                  primitive ( 449 , 40 , 40 ) ;
                  primitive ( 450 , 40 , 41 ) ;
                  primitive ( 409 , 47 , 0 ) ;
                  primitive ( 91 , 63 , 0 ) ;
                  eqtb [ 2360 ] := eqtb [ cursym ] ;
                  primitive ( 93 , 64 , 0 ) ;
                  primitive ( 125 , 65 , 0 ) ;
                  primitive ( 123 , 46 , 0 ) ;
                  primitive ( 58 , 81 , 0 ) ;
                  eqtb [ 2362 ] := eqtb [ cursym ] ;
                  primitive ( 459 , 80 , 0 ) ;
                  primitive ( 460 , 79 , 0 ) ;
                  primitive ( 461 , 77 , 0 ) ;
                  primitive ( 44 , 82 , 0 ) ;
                  primitive ( 59 , 83 , 0 ) ;
                  eqtb [ 2363 ] := eqtb [ cursym ] ;
                  primitive ( 92 , 7 , 0 ) ;
                  primitive ( 462 , 18 , 0 ) ;
                  primitive ( 463 , 72 , 0 ) ;
                  primitive ( 464 , 59 , 0 ) ;
                  primitive ( 465 , 32 , 0 ) ;
                  bgloc := cursym ;
                  primitive ( 466 , 57 , 0 ) ;
                  primitive ( 467 , 19 , 0 ) ;
                  primitive ( 468 , 60 , 0 ) ;
                  primitive ( 469 , 27 , 0 ) ;
                  primitive ( 470 , 11 , 0 ) ;
                  primitive ( 453 , 84 , 0 ) ;
                  eqtb [ 2367 ] := eqtb [ cursym ] ;
                  egloc := cursym ;
                  primitive ( 471 , 26 , 0 ) ;
                  primitive ( 472 , 6 , 0 ) ;
                  primitive ( 473 , 9 , 0 ) ;
                  primitive ( 474 , 70 , 0 ) ;
                  primitive ( 475 , 73 , 0 ) ;
                  primitive ( 476 , 13 , 0 ) ;
                  primitive ( 477 , 14 , 0 ) ;
                  primitive ( 478 , 15 , 0 ) ;
                  primitive ( 479 , 69 , 0 ) ;
                  primitive ( 480 , 28 , 0 ) ;
                  primitive ( 481 , 24 , 0 ) ;
                  primitive ( 482 , 12 , 0 ) ;
                  primitive ( 483 , 8 , 0 ) ;
                  primitive ( 484 , 17 , 0 ) ;
                  primitive ( 485 , 78 , 0 ) ;
                  primitive ( 486 , 74 , 0 ) ;
                  primitive ( 487 , 35 , 0 ) ;
                  primitive ( 488 , 58 , 0 ) ;
                  primitive ( 489 , 71 , 0 ) ;
                  primitive ( 490 , 75 , 0 ) ;
                  primitive ( 654 , 16 , 1 ) ;
                  primitive ( 655 , 16 , 2 ) ;
                  primitive ( 656 , 16 , 53 ) ;
                  primitive ( 657 , 16 , 44 ) ;
                  primitive ( 658 , 16 , 49 ) ;
                  primitive ( 454 , 16 , 0 ) ;
                  eqtb [ 2365 ] := eqtb [ cursym ] ;
                  primitive ( 659 , 4 , 2370 ) ;
                  primitive ( 660 , 4 , 2520 ) ;
                  primitive ( 661 , 4 , 1 ) ;
                  primitive ( 455 , 4 , 0 ) ;
                  eqtb [ 2364 ] := eqtb [ cursym ] ;
                  primitive ( 662 , 61 , 0 ) ;
                  primitive ( 663 , 61 , 1 ) ;
                  primitive ( 64 , 61 , 2 ) ;
                  primitive ( 664 , 61 , 3 ) ;
                  primitive ( 675 , 56 , 2370 ) ;
                  primitive ( 676 , 56 , 2520 ) ;
                  primitive ( 677 , 56 , 2670 ) ;
                  primitive ( 678 , 56 , 1 ) ;
                  primitive ( 679 , 56 , 2 ) ;
                  primitive ( 680 , 56 , 3 ) ;
                  primitive ( 690 , 3 , 0 ) ;
                  primitive ( 616 , 3 , 1 ) ;
                  primitive ( 717 , 1 , 1 ) ;
                  primitive ( 452 , 2 , 2 ) ;
                  eqtb [ 2366 ] := eqtb [ cursym ] ;
                  primitive ( 718 , 2 , 3 ) ;
                  primitive ( 719 , 2 , 4 ) ;
                  primitive ( 348 , 33 , 30 ) ;
                  primitive ( 349 , 33 , 31 ) ;
                  primitive ( 350 , 33 , 32 ) ;
                  primitive ( 351 , 33 , 33 ) ;
                  primitive ( 352 , 33 , 34 ) ;
                  primitive ( 353 , 33 , 35 ) ;
                  primitive ( 354 , 33 , 36 ) ;
                  primitive ( 355 , 33 , 37 ) ;
                  primitive ( 356 , 34 , 38 ) ;
                  primitive ( 357 , 34 , 39 ) ;
                  primitive ( 358 , 34 , 40 ) ;
                  primitive ( 359 , 34 , 41 ) ;
                  primitive ( 360 , 34 , 42 ) ;
                  primitive ( 361 , 34 , 43 ) ;
                  primitive ( 362 , 34 , 44 ) ;
                  primitive ( 363 , 34 , 45 ) ;
                  primitive ( 364 , 34 , 46 ) ;
                  primitive ( 365 , 34 , 47 ) ;
                  primitive ( 366 , 34 , 48 ) ;
                  primitive ( 367 , 34 , 49 ) ;
                  primitive ( 368 , 34 , 50 ) ;
                  primitive ( 369 , 34 , 51 ) ;
                  primitive ( 370 , 34 , 52 ) ;
                  primitive ( 371 , 34 , 53 ) ;
                  primitive ( 372 , 34 , 54 ) ;
                  primitive ( 373 , 34 , 55 ) ;
                  primitive ( 374 , 34 , 56 ) ;
                  primitive ( 375 , 34 , 57 ) ;
                  primitive ( 376 , 34 , 58 ) ;
                  primitive ( 377 , 34 , 59 ) ;
                  primitive ( 378 , 34 , 60 ) ;
                  primitive ( 379 , 34 , 61 ) ;
                  primitive ( 380 , 34 , 62 ) ;
                  primitive ( 381 , 34 , 63 ) ;
                  primitive ( 382 , 34 , 64 ) ;
                  primitive ( 383 , 34 , 65 ) ;
                  primitive ( 384 , 34 , 66 ) ;
                  primitive ( 385 , 34 , 67 ) ;
                  primitive ( 386 , 36 , 68 ) ;
                  primitive ( 43 , 43 , 69 ) ;
                  primitive ( 45 , 43 , 70 ) ;
                  primitive ( 42 , 55 , 71 ) ;
                  primitive ( 47 , 54 , 72 ) ;
                  eqtb [ 2361 ] := eqtb [ cursym ] ;
                  primitive ( 387 , 45 , 73 ) ;
                  primitive ( 311 , 45 , 74 ) ;
                  primitive ( 389 , 52 , 76 ) ;
                  primitive ( 388 , 45 , 75 ) ;
                  primitive ( 60 , 50 , 77 ) ;
                  primitive ( 390 , 50 , 78 ) ;
                  primitive ( 62 , 50 , 79 ) ;
                  primitive ( 391 , 50 , 80 ) ;
                  primitive ( 61 , 51 , 81 ) ;
                  primitive ( 392 , 50 , 82 ) ;
                  primitive ( 402 , 37 , 94 ) ;
                  primitive ( 403 , 37 , 95 ) ;
                  primitive ( 404 , 37 , 96 ) ;
                  primitive ( 405 , 37 , 97 ) ;
                  primitive ( 406 , 37 , 98 ) ;
                  primitive ( 407 , 37 , 99 ) ;
                  primitive ( 408 , 37 , 100 ) ;
                  primitive ( 38 , 48 , 83 ) ;
                  primitive ( 393 , 55 , 84 ) ;
                  primitive ( 394 , 55 , 85 ) ;
                  primitive ( 395 , 55 , 86 ) ;
                  primitive ( 396 , 55 , 87 ) ;
                  primitive ( 397 , 55 , 88 ) ;
                  primitive ( 398 , 55 , 89 ) ;
                  primitive ( 399 , 55 , 90 ) ;
                  primitive ( 400 , 55 , 91 ) ;
                  primitive ( 401 , 45 , 92 ) ;
                  primitive ( 341 , 30 , 15 ) ;
                  primitive ( 327 , 30 , 4 ) ;
                  primitive ( 325 , 30 , 2 ) ;
                  primitive ( 332 , 30 , 9 ) ;
                  primitive ( 329 , 30 , 6 ) ;
                  primitive ( 334 , 30 , 11 ) ;
                  primitive ( 336 , 30 , 13 ) ;
                  primitive ( 337 , 30 , 14 ) ;
                  primitive ( 912 , 85 , 0 ) ;
                  primitive ( 913 , 85 , 1 ) ;
                  primitive ( 273 , 23 , 0 ) ;
                  primitive ( 274 , 23 , 1 ) ;
                  primitive ( 275 , 23 , 2 ) ;
                  primitive ( 919 , 23 , 3 ) ;
                  primitive ( 920 , 21 , 0 ) ;
                  primitive ( 921 , 21 , 1 ) ;
                  primitive ( 935 , 22 , 0 ) ;
                  primitive ( 936 , 22 , 1 ) ;
                  primitive ( 937 , 22 , 2 ) ;
                  primitive ( 938 , 22 , 3 ) ;
                  primitive ( 939 , 22 , 4 ) ;
                  primitive ( 956 , 68 , 1 ) ;
                  primitive ( 957 , 68 , 0 ) ;
                  primitive ( 958 , 68 , 2 ) ;
                  primitive ( 959 , 66 , 6 ) ;
                  primitive ( 960 , 66 , 16 ) ;
                  primitive ( 961 , 67 , 0 ) ;
                  primitive ( 962 , 67 , 1 ) ;
                  primitive ( 992 , 25 , 0 ) ;
                  primitive ( 993 , 25 , 1 ) ;
                  primitive ( 994 , 25 , 2 ) ;
                  primitive ( 1004 , 20 , 0 ) ;
                  primitive ( 1005 , 20 , 1 ) ;
                  primitive ( 1006 , 20 , 2 ) ;
                  primitive ( 1007 , 20 , 3 ) ;
                  primitive ( 1008 , 20 , 4 ) ;
                  primitive ( 1026 , 76 , 0 ) ;
                  primitive ( 1027 , 76 , 1 ) ;
                  primitive ( 1028 , 76 , 5 ) ;
                  primitive ( 1029 , 76 , 2 ) ;
                  primitive ( 1030 , 76 , 6 ) ;
                  primitive ( 1031 , 76 , 3 ) ;
                  primitive ( 1032 , 76 , 7 ) ;
                  primitive ( 1033 , 76 , 11 ) ;
                  primitive ( 1034 , 76 , 128 ) ;
                  primitive ( 1058 , 29 , 4 ) ;
                  primitive ( 1059 , 29 , 16 ) ; ;
                End ;
                Procedure inittab ;

                Var k : integer ;
                Begin
                  rover := 23 ;
                  mem [ rover ] . hh . rh := 65535 ;
                  mem [ rover ] . hh . lh := 1000 ;
                  mem [ rover + 1 ] . hh . lh := rover ;
                  mem [ rover + 1 ] . hh . rh := rover ;
                  lomemmax := rover + 1000 ;
                  mem [ lomemmax ] . hh . rh := 0 ;
                  mem [ lomemmax ] . hh . lh := 0 ;
                  For k := 29998 To 30000 Do
                    mem [ k ] := mem [ lomemmax ] ;
                  avail := 0 ;
                  memend := 30000 ;
                  himemmin := 29998 ;
                  varused := 23 ;
                  dynused := 30001 - himemmin ;
                  intname [ 1 ] := 410 ;
                  intname [ 2 ] := 411 ;
                  intname [ 3 ] := 412 ;
                  intname [ 4 ] := 413 ;
                  intname [ 5 ] := 414 ;
                  intname [ 6 ] := 415 ;
                  intname [ 7 ] := 416 ;
                  intname [ 8 ] := 417 ;
                  intname [ 9 ] := 418 ;
                  intname [ 10 ] := 419 ;
                  intname [ 11 ] := 420 ;
                  intname [ 12 ] := 421 ;
                  intname [ 13 ] := 422 ;
                  intname [ 14 ] := 423 ;
                  intname [ 15 ] := 424 ;
                  intname [ 16 ] := 425 ;
                  intname [ 17 ] := 426 ;
                  intname [ 18 ] := 427 ;
                  intname [ 19 ] := 428 ;
                  intname [ 20 ] := 429 ;
                  intname [ 21 ] := 430 ;
                  intname [ 22 ] := 431 ;
                  intname [ 23 ] := 432 ;
                  intname [ 24 ] := 433 ;
                  intname [ 25 ] := 434 ;
                  intname [ 26 ] := 435 ;
                  intname [ 27 ] := 436 ;
                  intname [ 28 ] := 437 ;
                  intname [ 29 ] := 438 ;
                  intname [ 30 ] := 439 ;
                  intname [ 31 ] := 440 ;
                  intname [ 32 ] := 441 ;
                  intname [ 33 ] := 442 ;
                  intname [ 34 ] := 443 ;
                  intname [ 35 ] := 444 ;
                  intname [ 36 ] := 445 ;
                  intname [ 37 ] := 446 ;
                  intname [ 38 ] := 447 ;
                  intname [ 39 ] := 448 ;
                  intname [ 40 ] := 449 ;
                  intname [ 41 ] := 450 ;
                  hashused := 2357 ;
                  stcount := 0 ;
                  hash [ 2368 ] . rh := 451 ;
                  hash [ 2366 ] . rh := 452 ;
                  hash [ 2367 ] . rh := 453 ;
                  hash [ 2365 ] . rh := 454 ;
                  hash [ 2364 ] . rh := 455 ;
                  hash [ 2363 ] . rh := 59 ;
                  hash [ 2362 ] . rh := 58 ;
                  hash [ 2361 ] . rh := 47 ;
                  hash [ 2360 ] . rh := 91 ;
                  hash [ 2359 ] . rh := 41 ;
                  hash [ 2357 ] . rh := 456 ;
                  eqtb [ 2359 ] . lh := 62 ;
                  mem [ 19 ] . hh . lh := 2370 ;
                  mem [ 19 ] . hh . rh := 0 ;
                  mem [ 30000 ] . hh . lh := 65535 ;
                  mem [ 3 ] . hh . lh := 0 ;
                  mem [ 3 ] . hh . rh := 0 ;
                  mem [ 4 ] . hh . lh := 1 ;
                  mem [ 4 ] . hh . rh := 0 ;
                  For k := 5 To 11 Do
                    mem [ k ] := mem [ 4 ] ;
                  mem [ 12 ] . int := 0 ;
                  mem [ 0 ] . hh . rh := 0 ;
                  mem [ 0 ] . hh . lh := 0 ;
                  mem [ 1 ] . int := 0 ;
                  mem [ 2 ] . int := 0 ;
                  serialno := 0 ;
                  mem [ 13 ] . hh . rh := 13 ;
                  mem [ 14 ] . hh . lh := 13 ;
                  mem [ 13 ] . hh . lh := 0 ;
                  mem [ 14 ] . hh . rh := 0 ;
                  mem [ 21 ] . hh . b1 := 0 ;
                  mem [ 21 ] . hh . rh := 2368 ;
                  eqtb [ 2368 ] . rh := 21 ;
                  eqtb [ 2368 ] . lh := 41 ;
                  eqtb [ 2358 ] . lh := 91 ;
                  hash [ 2358 ] . rh := 734 ;
                  mem [ 17 ] . hh . b1 := 11 ;
                  mem [ 20 ] . int := 1073741824 ;
                  mem [ 16 ] . int := 0 ;
                  mem [ 15 ] . hh . lh := 0 ;
                  baseident := 1067 ;
                End ;
                Begin
                  history := 3 ;
                  rewrite ( termout , 'TTY:' , '/O' ) ;
                  If readyalready = 314159 Then goto 1 ;
                  bad := 0 ;
                  If ( halferrorline < 30 ) Or ( halferrorline > errorline - 15 ) Then bad := 1 ;
                  If maxprintline < 60 Then bad := 2 ;
                  If gfbufsize Mod 8 <> 0 Then bad := 3 ;
                  If 1100 > 30000 Then bad := 4 ;
                  If 1777 > 2100 Then bad := 5 ;
                  If headersize Mod 4 <> 0 Then bad := 6 ;
                  If ( ligtablesize < 255 ) Or ( ligtablesize > 32510 ) Then bad := 7 ;
                  If memmax <> 30000 Then bad := 10 ;
                  If memmax < 30000 Then bad := 10 ;
                  If ( 0 > 0 ) Or ( 255 < 127 ) Then bad := 11 ;
                  If ( 0 > 0 ) Or ( 65535 < 32767 ) Then bad := 12 ;
                  If ( 0 < 0 ) Or ( 255 > 65535 ) Then bad := 13 ;
                  If ( 0 < 0 ) Or ( memmax >= 65535 ) Then bad := 14 ;
                  If maxstrings > 65535 Then bad := 15 ;
                  If bufsize > 65535 Then bad := 16 ;
                  If ( 255 < 255 ) Or ( 65535 < 65535 ) Then bad := 17 ;
                  If 2369 + maxinternal > 65535 Then bad := 21 ;
                  If 2820 > 65535 Then bad := 22 ;
                  If 15 * 11 > bistacksize Then bad := 31 ;
                  If 20 + 17 * 45 > bistacksize Then bad := 32 ;
                  If 18 > filenamesize Then bad := 41 ;
                  If bad > 0 Then
                    Begin
                      writeln ( termout , 'Ouch---my internal constants have been clobbered!' , '---case ' , bad : 1 ) ;
                      goto 9999 ;
                    End ;
                  initialize ;
                  If Not getstringsstarted Then goto 9999 ;
                  inittab ;
                  initprim ;
                  initstrptr := strptr ;
                  initpoolptr := poolptr ;
                  maxstrptr := strptr ;
                  maxpoolptr := poolptr ;
                  fixdateandtime ;
                  readyalready := 314159 ;
                  1 : selector := 1 ;
                  tally := 0 ;
                  termoffset := 0 ;
                  fileoffset := 0 ;
                  write ( termout , 'This is METAFONT, Version 2.7182818' ) ;
                  If baseident = 0 Then writeln ( termout , ' (no base preloaded)' )
                  Else
                    Begin
                      slowprint ( baseident ) ;
                      println ;
                    End ;
                  break ( termout ) ;
                  jobname := 0 ;
                  logopened := false ;
                  outputfilename := 0 ; ;
                  Begin
                    Begin
                      inputptr := 0 ;
                      maxinstack := 0 ;
                      inopen := 0 ;
                      openparens := 0 ;
                      maxbufstack := 0 ;
                      paramptr := 0 ;
                      maxparamstack := 0 ;
                      first := 1 ;
                      curinput . startfield := 1 ;
                      curinput . indexfield := 0 ;
                      line := 0 ;
                      curinput . namefield := 0 ;
                      forceeof := false ;
                      If Not initterminal Then goto 9999 ;
                      curinput . limitfield := last ;
                      first := last + 1 ;
                    End ;
                    scannerstatus := 0 ; ;
                    If ( baseident = 0 ) Or ( buffer [ curinput . locfield ] = 38 ) Then
                      Begin
                        If baseident <> 0 Then initialize ;
                        If Not openbasefile Then goto 9999 ;
                        If Not loadbasefile Then
                          Begin
                            wclose ( basefile ) ;
                            goto 9999 ;
                          End ;
                        wclose ( basefile ) ;
                        While ( curinput . locfield < curinput . limitfield ) And ( buffer [ curinput . locfield ] = 32 ) Do
                          curinput . locfield := curinput . locfield + 1 ;
                      End ;
                    buffer [ curinput . limitfield ] := 37 ;
                    fixdateandtime ;
                    initrandoms ( ( internal [ 17 ] Div 65536 ) + internal [ 16 ] ) ;
                    If interaction = 0 Then selector := 0
                    Else selector := 1 ;
                    If curinput . locfield < curinput . limitfield Then If buffer [ curinput . locfield ] <> 92 Then startinput ;
                  End ;
                  history := 0 ;
                  If startsym > 0 Then
                    Begin
                      cursym := startsym ;
                      backinput ;
                    End ;
                  maincontrol ;
                  finalcleanup ;
                  9998 : closefilesandterminate ;
                  9999 : readyalready := 0 ;
                End .
