
Program TEX ;

Label 1 , 9998 , 9999 ;

Const memmax = 30000 ;
  memmin = 0 ;
  bufsize = 500 ;
  errorline = 72 ;
  halferrorline = 42 ;
  maxprintline = 79 ;
  stacksize = 200 ;
  maxinopen = 6 ;
  fontmax = 75 ;
  fontmemsize = 20000 ;
  paramsize = 60 ;
  nestsize = 40 ;
  maxstrings = 3000 ;
  stringvacancies = 8000 ;
  poolsize = 32000 ;
  savesize = 600 ;
  triesize = 8000 ;
  trieopsize = 500 ;
  dvibufsize = 800 ;
  filenamesize = 40 ;
  poolname = 'TeXformats:TEX.POOL                     ' ;

Type ASCIIcode = 0 .. 255 ;
  eightbits = 0 .. 255 ;
  alphafile = packed file Of char ;
  bytefile = packed file Of eightbits ;
  poolpointer = 0 .. poolsize ;
  strnumber = 0 .. maxstrings ;
  packedASCIIcode = 0 .. 255 ;
  scaled = integer ;
  nonnegativeinteger = 0 .. 2147483647 ;
  smallnumber = 0 .. 63 ;
  glueratio = real ;
  quarterword = 0 .. 255 ;
  halfword = 0 .. 65535 ;
  twochoices = 1 .. 2 ;
  fourchoices = 1 .. 4 ;
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
    Case fourchoices Of 
      1 : ( int : integer ) ;
      2 : ( gr : glueratio ) ;
      3 : ( hh : twohalves ) ;
      4 : ( qqqq : fourquarters ) ;
  End ;
  wordfile = file Of memoryword ;
  glueord = 0 .. 3 ;
  liststaterecord = Record
    modefield : - 203 .. 203 ;
    headfield , tailfield : halfword ;
    pgfield , mlfield : integer ;
    auxfield : memoryword ;
  End ;
  groupcode = 0 .. 16 ;
  instaterecord = Record
    statefield , indexfield : quarterword ;
    startfield , locfield , limitfield , namefield : halfword ;
  End ;
  internalfontnumber = 0 .. fontmax ;
  fontindex = 0 .. fontmemsize ;
  dviindex = 0 .. dvibufsize ;
  triepointer = 0 .. triesize ;
  hyphpointer = 0 .. 307 ;

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
  poolfile : alphafile ;
  logfile : alphafile ;
  selector : 0 .. 21 ;
  dig : array [ 0 .. 22 ] Of 0 .. 15 ;
  tally : integer ;
  termoffset : 0 .. maxprintline ;
  fileoffset : 0 .. maxprintline ;
  trickbuf : array [ 0 .. errorline ] Of ASCIIcode ;
  trickcount : integer ;
  firstcount : integer ;
  interaction : 0 .. 3 ;
  deletionsallowed : boolean ;
  setboxallowed : boolean ;
  history : 0 .. 3 ;
  errorcount : - 1 .. 100 ;
  helpline : array [ 0 .. 5 ] Of strnumber ;
  helpptr : 0 .. 6 ;
  useerrhelp : boolean ;
  interrupt : integer ;
  OKtointerrupt : boolean ;
  aritherror : boolean ;
  remainder : scaled ;
  tempptr : halfword ;
  mem : array [ memmin .. memmax ] Of memoryword ;
  lomemmax : halfword ;
  himemmin : halfword ;
  varused , dynused : integer ;
  avail : halfword ;
  memend : halfword ;
  rover : halfword ;
  fontinshortdisplay : integer ;
  depththreshold : integer ;
  breadthmax : integer ;
  nest : array [ 0 .. nestsize ] Of liststaterecord ;
  nestptr : 0 .. nestsize ;
  maxneststack : 0 .. nestsize ;
  curlist : liststaterecord ;
  shownmode : - 203 .. 203 ;
  oldsetting : 0 .. 21 ;
  eqtb : array [ 1 .. 6106 ] Of memoryword ;
  xeqlevel : array [ 5263 .. 6106 ] Of quarterword ;
  hash : array [ 514 .. 2880 ] Of twohalves ;
  hashused : halfword ;
  nonewcontrolsequence : boolean ;
  cscount : integer ;
  savestack : array [ 0 .. savesize ] Of memoryword ;
  saveptr : 0 .. savesize ;
  maxsavestack : 0 .. savesize ;
  curlevel : quarterword ;
  curgroup : groupcode ;
  curboundary : 0 .. savesize ;
  magset : integer ;
  curcmd : eightbits ;
  curchr : halfword ;
  curcs : halfword ;
  curtok : halfword ;
  inputstack : array [ 0 .. stacksize ] Of instaterecord ;
  inputptr : 0 .. stacksize ;
  maxinstack : 0 .. stacksize ;
  curinput : instaterecord ;
  inopen : 0 .. maxinopen ;
  openparens : 0 .. maxinopen ;
  inputfile : array [ 1 .. maxinopen ] Of alphafile ;
  line : integer ;
  linestack : array [ 1 .. maxinopen ] Of integer ;
  scannerstatus : 0 .. 5 ;
  warningindex : halfword ;
  defref : halfword ;
  paramstack : array [ 0 .. paramsize ] Of halfword ;
  paramptr : 0 .. paramsize ;
  maxparamstack : integer ;
  alignstate : integer ;
  baseptr : 0 .. stacksize ;
  parloc : halfword ;
  partoken : halfword ;
  forceeof : boolean ;
  curmark : array [ 0 .. 4 ] Of halfword ;
  longstate : 111 .. 114 ;
  pstack : array [ 0 .. 8 ] Of halfword ;
  curval : integer ;
  curvallevel : 0 .. 5 ;
  radix : smallnumber ;
  curorder : glueord ;
  readfile : array [ 0 .. 15 ] Of alphafile ;
  readopen : array [ 0 .. 16 ] Of 0 .. 2 ;
  condptr : halfword ;
  iflimit : 0 .. 4 ;
  curif : smallnumber ;
  ifline : integer ;
  skipline : integer ;
  curname : strnumber ;
  curarea : strnumber ;
  curext : strnumber ;
  areadelimiter : poolpointer ;
  extdelimiter : poolpointer ;
  TEXformatdefault : packed array [ 1 .. 20 ] Of char ;
  nameinprogress : boolean ;
  jobname : strnumber ;
  logopened : boolean ;
  dvifile : bytefile ;
  outputfilename : strnumber ;
  logname : strnumber ;
  tfmfile : bytefile ;
  fontinfo : array [ fontindex ] Of memoryword ;
  fmemptr : fontindex ;
  fontptr : internalfontnumber ;
  fontcheck : array [ internalfontnumber ] Of fourquarters ;
  fontsize : array [ internalfontnumber ] Of scaled ;
  fontdsize : array [ internalfontnumber ] Of scaled ;
  fontparams : array [ internalfontnumber ] Of fontindex ;
  fontname : array [ internalfontnumber ] Of strnumber ;
  fontarea : array [ internalfontnumber ] Of strnumber ;
  fontbc : array [ internalfontnumber ] Of eightbits ;
  fontec : array [ internalfontnumber ] Of eightbits ;
  fontglue : array [ internalfontnumber ] Of halfword ;
  fontused : array [ internalfontnumber ] Of boolean ;
  hyphenchar : array [ internalfontnumber ] Of integer ;
  skewchar : array [ internalfontnumber ] Of integer ;
  bcharlabel : array [ internalfontnumber ] Of fontindex ;
  fontbchar : array [ internalfontnumber ] Of 0 .. 256 ;
  fontfalsebchar : array [ internalfontnumber ] Of 0 .. 256 ;
  charbase : array [ internalfontnumber ] Of integer ;
  widthbase : array [ internalfontnumber ] Of integer ;
  heightbase : array [ internalfontnumber ] Of integer ;
  depthbase : array [ internalfontnumber ] Of integer ;
  italicbase : array [ internalfontnumber ] Of integer ;
  ligkernbase : array [ internalfontnumber ] Of integer ;
  kernbase : array [ internalfontnumber ] Of integer ;
  extenbase : array [ internalfontnumber ] Of integer ;
  parambase : array [ internalfontnumber ] Of integer ;
  nullcharacter : fourquarters ;
  totalpages : integer ;
  maxv : scaled ;
  maxh : scaled ;
  maxpush : integer ;
  lastbop : integer ;
  deadcycles : integer ;
  doingleaders : boolean ;
  c , f : quarterword ;
  ruleht , ruledp , rulewd : scaled ;
  g : halfword ;
  lq , lr : integer ;
  dvibuf : array [ dviindex ] Of eightbits ;
  halfbuf : dviindex ;
  dvilimit : dviindex ;
  dviptr : dviindex ;
  dvioffset : integer ;
  dvigone : integer ;
  downptr , rightptr : halfword ;
  dvih , dviv : scaled ;
  curh , curv : scaled ;
  dvif : internalfontnumber ;
  curs : integer ;
  totalstretch , totalshrink : array [ glueord ] Of scaled ;
  lastbadness : integer ;
  adjusttail : halfword ;
  packbeginline : integer ;
  emptyfield : twohalves ;
  nulldelimiter : fourquarters ;
  curmlist : halfword ;
  curstyle : smallnumber ;
  cursize : smallnumber ;
  curmu : scaled ;
  mlistpenalties : boolean ;
  curf : internalfontnumber ;
  curc : quarterword ;
  curi : fourquarters ;
  magicoffset : integer ;
  curalign : halfword ;
  curspan : halfword ;
  curloop : halfword ;
  alignptr : halfword ;
  curhead , curtail : halfword ;
  justbox : halfword ;
  passive : halfword ;
  printednode : halfword ;
  passnumber : halfword ;
  activewidth : array [ 1 .. 6 ] Of scaled ;
  curactivewidth : array [ 1 .. 6 ] Of scaled ;
  background : array [ 1 .. 6 ] Of scaled ;
  breakwidth : array [ 1 .. 6 ] Of scaled ;
  noshrinkerroryet : boolean ;
  curp : halfword ;
  secondpass : boolean ;
  finalpass : boolean ;
  threshold : integer ;
  minimaldemerits : array [ 0 .. 3 ] Of integer ;
  minimumdemerits : integer ;
  bestplace : array [ 0 .. 3 ] Of halfword ;
  bestplline : array [ 0 .. 3 ] Of halfword ;
  discwidth : scaled ;
  easyline : halfword ;
  lastspecialline : halfword ;
  firstwidth : scaled ;
  secondwidth : scaled ;
  firstindent : scaled ;
  secondindent : scaled ;
  bestbet : halfword ;
  fewestdemerits : integer ;
  bestline : halfword ;
  actuallooseness : integer ;
  linediff : integer ;
  hc : array [ 0 .. 65 ] Of 0 .. 256 ;
  hn : smallnumber ;
  ha , hb : halfword ;
  hf : internalfontnumber ;
  hu : array [ 0 .. 63 ] Of 0 .. 256 ;
  hyfchar : integer ;
  curlang , initcurlang : ASCIIcode ;
  lhyf , rhyf , initlhyf , initrhyf : integer ;
  hyfbchar : halfword ;
  hyf : array [ 0 .. 64 ] Of 0 .. 9 ;
  initlist : halfword ;
  initlig : boolean ;
  initlft : boolean ;
  hyphenpassed : smallnumber ;
  curl , curr : halfword ;
  curq : halfword ;
  ligstack : halfword ;
  ligaturepresent : boolean ;
  lfthit , rthit : boolean ;
  trie : array [ triepointer ] Of twohalves ;
  hyfdistance : array [ 1 .. trieopsize ] Of smallnumber ;
  hyfnum : array [ 1 .. trieopsize ] Of smallnumber ;
  hyfnext : array [ 1 .. trieopsize ] Of quarterword ;
  opstart : array [ ASCIIcode ] Of 0 .. trieopsize ;
  hyphword : array [ hyphpointer ] Of strnumber ;
  hyphlist : array [ hyphpointer ] Of halfword ;
  hyphcount : hyphpointer ;
  trieophash : array [ - trieopsize .. trieopsize ] Of 0 .. trieopsize ;
  trieused : array [ ASCIIcode ] Of quarterword ;
  trieoplang : array [ 1 .. trieopsize ] Of ASCIIcode ;
  trieopval : array [ 1 .. trieopsize ] Of quarterword ;
  trieopptr : 0 .. trieopsize ;
  triec : packed array [ triepointer ] Of packedASCIIcode ;
  trieo : packed array [ triepointer ] Of quarterword ;
  triel : packed array [ triepointer ] Of triepointer ;
  trier : packed array [ triepointer ] Of triepointer ;
  trieptr : triepointer ;
  triehash : packed array [ triepointer ] Of triepointer ;
  trietaken : packed array [ 1 .. triesize ] Of boolean ;
  triemin : array [ ASCIIcode ] Of triepointer ;
  triemax : triepointer ;
  trienotready : boolean ;
  bestheightplusdepth : scaled ;
  pagetail : halfword ;
  pagecontents : 0 .. 2 ;
  pagemaxdepth : scaled ;
  bestpagebreak : halfword ;
  leastpagecost : integer ;
  bestsize : scaled ;
  pagesofar : array [ 0 .. 7 ] Of scaled ;
  lastglue : halfword ;
  lastpenalty : integer ;
  lastkern : scaled ;
  insertpenalties : integer ;
  outputactive : boolean ;
  mainf : internalfontnumber ;
  maini : fourquarters ;
  mainj : fourquarters ;
  maink : fontindex ;
  mainp : halfword ;
  mains : integer ;
  bchar : halfword ;
  falsebchar : halfword ;
  cancelboundary : boolean ;
  insdisc : boolean ;
  curbox : halfword ;
  aftertoken : halfword ;
  longhelpseen : boolean ;
  formatident : strnumber ;
  fmtfile : wordfile ;
  readyalready : integer ;
  writefile : array [ 0 .. 15 ] Of alphafile ;
  writeopen : array [ 0 .. 17 ] Of boolean ;
  writeloc : halfword ;
Procedure initialize ;

Var i : integer ;
  k : integer ;
  z : hyphpointer ;
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
  setboxallowed := true ;
  errorcount := 0 ;
  helpptr := 0 ;
  useerrhelp := false ;
  interrupt := 0 ;
  OKtointerrupt := true ;
  nestptr := 0 ;
  maxneststack := 0 ;
  curlist . modefield := 1 ;
  curlist . headfield := 29999 ;
  curlist . tailfield := 29999 ;
  curlist . auxfield . int := - 65536000 ;
  curlist . mlfield := 0 ;
  curlist . pgfield := 0 ;
  shownmode := 0 ;
  pagecontents := 0 ;
  pagetail := 29998 ;
  mem [ 29998 ] . hh . rh := 0 ;
  lastglue := 65535 ;
  lastpenalty := 0 ;
  lastkern := 0 ;
  pagesofar [ 7 ] := 0 ;
  pagemaxdepth := 0 ;
  For k := 5263 To 6106 Do
    xeqlevel [ k ] := 1 ;
  nonewcontrolsequence := true ;
  hash [ 514 ] . lh := 0 ;
  hash [ 514 ] . rh := 0 ;
  For k := 515 To 2880 Do
    hash [ k ] := hash [ 514 ] ;
  saveptr := 0 ;
  curlevel := 1 ;
  curgroup := 0 ;
  curboundary := 0 ;
  maxsavestack := 0 ;
  magset := 0 ;
  curmark [ 0 ] := 0 ;
  curmark [ 1 ] := 0 ;
  curmark [ 2 ] := 0 ;
  curmark [ 3 ] := 0 ;
  curmark [ 4 ] := 0 ;
  curval := 0 ;
  curvallevel := 0 ;
  radix := 0 ;
  curorder := 0 ;
  For k := 0 To 16 Do
    readopen [ k ] := 2 ;
  condptr := 0 ;
  iflimit := 0 ;
  curif := 0 ;
  ifline := 0 ;
  TEXformatdefault := 'TeXformats:plain.fmt' ;
  For k := 0 To fontmax Do
    fontused [ k ] := false ;
  nullcharacter . b0 := 0 ;
  nullcharacter . b1 := 0 ;
  nullcharacter . b2 := 0 ;
  nullcharacter . b3 := 0 ;
  totalpages := 0 ;
  maxv := 0 ;
  maxh := 0 ;
  maxpush := 0 ;
  lastbop := - 1 ;
  doingleaders := false ;
  deadcycles := 0 ;
  curs := - 1 ;
  halfbuf := dvibufsize Div 2 ;
  dvilimit := dvibufsize ;
  dviptr := 0 ;
  dvioffset := 0 ;
  dvigone := 0 ;
  downptr := 0 ;
  rightptr := 0 ;
  adjusttail := 0 ;
  lastbadness := 0 ;
  packbeginline := 0 ;
  emptyfield . rh := 0 ;
  emptyfield . lh := 0 ;
  nulldelimiter . b0 := 0 ;
  nulldelimiter . b1 := 0 ;
  nulldelimiter . b2 := 0 ;
  nulldelimiter . b3 := 0 ;
  alignptr := 0 ;
  curalign := 0 ;
  curspan := 0 ;
  curloop := 0 ;
  curhead := 0 ;
  curtail := 0 ;
  For z := 0 To 307 Do
    Begin
      hyphword [ z ] := 0 ;
      hyphlist [ z ] := 0 ;
    End ;
  hyphcount := 0 ;
  outputactive := false ;
  insertpenalties := 0 ;
  ligaturepresent := false ;
  cancelboundary := false ;
  lfthit := false ;
  rthit := false ;
  insdisc := false ;
  aftertoken := 0 ;
  longhelpseen := false ;
  formatident := 0 ;
  For k := 0 To 17 Do
    writeopen [ k ] := false ;
  For k := 1 To 19 Do
    mem [ k ] . int := 0 ;
  k := 0 ;
  While k <= 19 Do
    Begin
      mem [ k ] . hh . rh := 1 ;
      mem [ k ] . hh . b0 := 0 ;
      mem [ k ] . hh . b1 := 0 ;
      k := k + 4 ;
    End ;
  mem [ 6 ] . int := 65536 ;
  mem [ 4 ] . hh . b0 := 1 ;
  mem [ 10 ] . int := 65536 ;
  mem [ 8 ] . hh . b0 := 2 ;
  mem [ 14 ] . int := 65536 ;
  mem [ 12 ] . hh . b0 := 1 ;
  mem [ 15 ] . int := 65536 ;
  mem [ 12 ] . hh . b1 := 1 ;
  mem [ 18 ] . int := - 65536 ;
  mem [ 16 ] . hh . b0 := 1 ;
  rover := 20 ;
  mem [ rover ] . hh . rh := 65535 ;
  mem [ rover ] . hh . lh := 1000 ;
  mem [ rover + 1 ] . hh . lh := rover ;
  mem [ rover + 1 ] . hh . rh := rover ;
  lomemmax := rover + 1000 ;
  mem [ lomemmax ] . hh . rh := 0 ;
  mem [ lomemmax ] . hh . lh := 0 ;
  For k := 29987 To 30000 Do
    mem [ k ] := mem [ lomemmax ] ;
  mem [ 29990 ] . hh . lh := 6714 ;
  mem [ 29991 ] . hh . rh := 256 ;
  mem [ 29991 ] . hh . lh := 0 ;
  mem [ 29993 ] . hh . b0 := 1 ;
  mem [ 29994 ] . hh . lh := 65535 ;
  mem [ 29993 ] . hh . b1 := 0 ;
  mem [ 30000 ] . hh . b1 := 255 ;
  mem [ 30000 ] . hh . b0 := 1 ;
  mem [ 30000 ] . hh . rh := 30000 ;
  mem [ 29998 ] . hh . b0 := 10 ;
  mem [ 29998 ] . hh . b1 := 0 ; ;
  avail := 0 ;
  memend := 30000 ;
  himemmin := 29987 ;
  varused := 20 ;
  dynused := 14 ;
  eqtb [ 2881 ] . hh . b0 := 101 ;
  eqtb [ 2881 ] . hh . rh := 0 ;
  eqtb [ 2881 ] . hh . b1 := 0 ;
  For k := 1 To 2880 Do
    eqtb [ k ] := eqtb [ 2881 ] ;
  eqtb [ 2882 ] . hh . rh := 0 ;
  eqtb [ 2882 ] . hh . b1 := 1 ;
  eqtb [ 2882 ] . hh . b0 := 117 ;
  For k := 2883 To 3411 Do
    eqtb [ k ] := eqtb [ 2882 ] ;
  mem [ 0 ] . hh . rh := mem [ 0 ] . hh . rh + 530 ;
  eqtb [ 3412 ] . hh . rh := 0 ;
  eqtb [ 3412 ] . hh . b0 := 118 ;
  eqtb [ 3412 ] . hh . b1 := 1 ;
  For k := 3413 To 3677 Do
    eqtb [ k ] := eqtb [ 2881 ] ;
  eqtb [ 3678 ] . hh . rh := 0 ;
  eqtb [ 3678 ] . hh . b0 := 119 ;
  eqtb [ 3678 ] . hh . b1 := 1 ;
  For k := 3679 To 3933 Do
    eqtb [ k ] := eqtb [ 3678 ] ;
  eqtb [ 3934 ] . hh . rh := 0 ;
  eqtb [ 3934 ] . hh . b0 := 120 ;
  eqtb [ 3934 ] . hh . b1 := 1 ;
  For k := 3935 To 3982 Do
    eqtb [ k ] := eqtb [ 3934 ] ;
  eqtb [ 3983 ] . hh . rh := 0 ;
  eqtb [ 3983 ] . hh . b0 := 120 ;
  eqtb [ 3983 ] . hh . b1 := 1 ;
  For k := 3984 To 5262 Do
    eqtb [ k ] := eqtb [ 3983 ] ;
  For k := 0 To 255 Do
    Begin
      eqtb [ 3983 + k ] . hh . rh := 12 ;
      eqtb [ 5007 + k ] . hh . rh := k + 0 ;
      eqtb [ 4751 + k ] . hh . rh := 1000 ;
    End ;
  eqtb [ 3996 ] . hh . rh := 5 ;
  eqtb [ 4015 ] . hh . rh := 10 ;
  eqtb [ 4075 ] . hh . rh := 0 ;
  eqtb [ 4020 ] . hh . rh := 14 ;
  eqtb [ 4110 ] . hh . rh := 15 ;
  eqtb [ 3983 ] . hh . rh := 9 ;
  For k := 48 To 57 Do
    eqtb [ 5007 + k ] . hh . rh := k + 28672 ;
  For k := 65 To 90 Do
    Begin
      eqtb [ 3983 + k ] . hh . rh := 11 ;
      eqtb [ 3983 + k + 32 ] . hh . rh := 11 ;
      eqtb [ 5007 + k ] . hh . rh := k + 28928 ;
      eqtb [ 5007 + k + 32 ] . hh . rh := k + 28960 ;
      eqtb [ 4239 + k ] . hh . rh := k + 32 ;
      eqtb [ 4239 + k + 32 ] . hh . rh := k + 32 ;
      eqtb [ 4495 + k ] . hh . rh := k ;
      eqtb [ 4495 + k + 32 ] . hh . rh := k ;
      eqtb [ 4751 + k ] . hh . rh := 999 ;
    End ;
  For k := 5263 To 5573 Do
    eqtb [ k ] . int := 0 ;
  eqtb [ 5280 ] . int := 1000 ;
  eqtb [ 5264 ] . int := 10000 ;
  eqtb [ 5304 ] . int := 1 ;
  eqtb [ 5303 ] . int := 25 ;
  eqtb [ 5308 ] . int := 92 ;
  eqtb [ 5311 ] . int := 13 ;
  For k := 0 To 255 Do
    eqtb [ 5574 + k ] . int := - 1 ;
  eqtb [ 5620 ] . int := 0 ;
  For k := 5830 To 6106 Do
    eqtb [ k ] . int := 0 ;
  hashused := 2614 ;
  cscount := 0 ;
  eqtb [ 2623 ] . hh . b0 := 116 ;
  hash [ 2623 ] . rh := 502 ;
  fontptr := 0 ;
  fmemptr := 7 ;
  fontname [ 0 ] := 800 ;
  fontarea [ 0 ] := 338 ;
  hyphenchar [ 0 ] := 45 ;
  skewchar [ 0 ] := - 1 ;
  bcharlabel [ 0 ] := 0 ;
  fontbchar [ 0 ] := 256 ;
  fontfalsebchar [ 0 ] := 256 ;
  fontbc [ 0 ] := 1 ;
  fontec [ 0 ] := 0 ;
  fontsize [ 0 ] := 0 ;
  fontdsize [ 0 ] := 0 ;
  charbase [ 0 ] := 0 ;
  widthbase [ 0 ] := 0 ;
  heightbase [ 0 ] := 0 ;
  depthbase [ 0 ] := 0 ;
  italicbase [ 0 ] := 0 ;
  ligkernbase [ 0 ] := 0 ;
  kernbase [ 0 ] := 0 ;
  extenbase [ 0 ] := 0 ;
  fontglue [ 0 ] := 0 ;
  fontparams [ 0 ] := 7 ;
  parambase [ 0 ] := - 1 ;
  For k := 0 To 6 Do
    fontinfo [ k ] . int := 0 ;
  For k := - trieopsize To trieopsize Do
    trieophash [ k ] := 0 ;
  For k := 0 To 255 Do
    trieused [ k ] := 0 ;
  trieopptr := 0 ;
  trienotready := true ;
  triel [ 0 ] := 0 ;
  triec [ 0 ] := 0 ;
  trieptr := 0 ;
  hash [ 2614 ] . rh := 1189 ;
  formatident := 1256 ;
  hash [ 2622 ] . rh := 1295 ;
  eqtb [ 2622 ] . hh . b1 := 1 ;
  eqtb [ 2622 ] . hh . b0 := 113 ;
  eqtb [ 2622 ] . hh . rh := 0 ;
End ;
Procedure println ;
Begin
  Case selector Of 
    19 :
         Begin
           writeln ( termout ) ;
           writeln ( logfile ) ;
           termoffset := 0 ;
           fileoffset := 0 ;
         End ;
    18 :
         Begin
           writeln ( logfile ) ;
           fileoffset := 0 ;
         End ;
    17 :
         Begin
           writeln ( termout ) ;
           termoffset := 0 ;
         End ;
    16 , 20 , 21 : ;
    others : writeln ( writefile [ selector ] )
  End ;
End ;
Procedure printchar ( s : ASCIIcode ) ;

Label 10 ;
Begin
  If s = eqtb [ 5312 ] . int Then If selector < 20 Then
                                    Begin
                                      println ;
                                      goto 10 ;
                                    End ;
  Case selector Of 
    19 :
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
    18 :
         Begin
           write ( logfile , xchr [ s ] ) ;
           fileoffset := fileoffset + 1 ;
           If fileoffset = maxprintline Then println ;
         End ;
    17 :
         Begin
           write ( termout , xchr [ s ] ) ;
           termoffset := termoffset + 1 ;
           If termoffset = maxprintline Then println ;
         End ;
    16 : ;
    20 : If tally < trickcount Then trickbuf [ tally mod errorline ] := s ;
    21 :
         Begin
           If poolptr < poolsize Then
             Begin
               strpool [ poolptr ] := s ;
               poolptr := poolptr + 1 ;
             End ;
         End ;
    others : write ( writefile [ selector ] , xchr [ s ] )
  End ;
  tally := tally + 1 ;
  10 :
End ;
Procedure print ( s : integer ) ;

Label 10 ;

Var j : poolpointer ;
  nl : integer ;
Begin
  If s >= strptr Then s := 259
  Else If s < 256 Then If s < 0 Then s := 259
  Else
    Begin
      If selector > 20 Then
        Begin
          printchar ( s ) ;
          goto 10 ;
        End ;
      If ( s = eqtb [ 5312 ] . int ) Then If selector < 20 Then
                                            Begin
                                              println ;
                                              goto 10 ;
                                            End ;
      nl := eqtb [ 5312 ] . int ;
      eqtb [ 5312 ] . int := - 1 ;
      j := strstart [ s ] ;
      While j < strstart [ s + 1 ] Do
        Begin
          printchar ( strpool [ j ] ) ;
          j := j + 1 ;
        End ;
      eqtb [ 5312 ] . int := nl ;
      goto 10 ;
    End ;
  j := strstart [ s ] ;
  While j < strstart [ s + 1 ] Do
    Begin
      printchar ( strpool [ j ] ) ;
      j := j + 1 ;
    End ;
  10 :
End ;
Procedure slowprint ( s : integer ) ;

Var j : poolpointer ;
Begin
  If ( s >= strptr ) Or ( s < 256 ) Then print ( s )
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
  If ( ( termoffset > 0 ) And ( odd ( selector ) ) ) Or ( ( fileoffset > 0 ) And ( selector >= 18 ) ) Then println ;
  print ( s ) ;
End ;
Procedure printesc ( s : strnumber ) ;

Var c : integer ;
Begin
  c := eqtb [ 5308 ] . int ;
  If c >= 0 Then If c < 256 Then print ( c ) ;
  slowprint ( s ) ;
End ;
Procedure printthedigs ( k : eightbits ) ;
Begin
  While k > 0 Do
    Begin
      k := k - 1 ;
      If dig [ k ] < 10 Then printchar ( 48 + dig [ k ] )
      Else printchar ( 55 + dig [ k ] ) ;
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
Procedure printcs ( p : integer ) ;
Begin
  If p < 514 Then If p >= 257 Then If p = 513 Then
                                     Begin
                                       printesc ( 504 ) ;
                                       printesc ( 505 ) ;
                                       printchar ( 32 ) ;
                                     End
  Else
    Begin
      printesc ( p - 257 ) ;
      If eqtb [ 3983 + p - 257 ] . hh . rh = 11 Then printchar ( 32 ) ;
    End
  Else If p < 1 Then printesc ( 506 )
  Else print ( p - 1 )
  Else If p >= 2881 Then printesc ( 506 )
  Else If ( hash [ p ] . rh < 0 ) Or ( hash [ p ] . rh >= strptr ) Then printesc ( 507 )
  Else
    Begin
      printesc ( hash [ p ] . rh ) ;
      printchar ( 32 ) ;
    End ;
End ;
Procedure sprintcs ( p : halfword ) ;
Begin
  If p < 514 Then If p < 257 Then print ( p - 1 )
  Else If p < 513 Then printesc ( p - 257 )
  Else
    Begin
      printesc ( 504 ) ;
      printesc ( 505 ) ;
    End
  Else printesc ( hash [ p ] . rh ) ;
End ;
Procedure printfilename ( n , a , e : integer ) ;
Begin
  slowprint ( a ) ;
  slowprint ( n ) ;
  slowprint ( e ) ;
End ;
Procedure printsize ( s : integer ) ;
Begin
  If s = 0 Then printesc ( 412 )
  Else If s = 16 Then printesc ( 413 )
  Else printesc ( 414 ) ;
End ;
Procedure printwritewhatsit ( s : strnumber ; p : halfword ) ;
Begin
  printesc ( s ) ;
  If mem [ p + 1 ] . hh . lh < 16 Then printint ( mem [ p + 1 ] . hh . lh )
  Else If mem [ p + 1 ] . hh . lh = 16 Then printchar ( 42 )
  Else printchar ( 45 ) ;
End ;
Procedure normalizeselector ;
forward ;
Procedure gettoken ;
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
Procedure giveerrhelp ;
forward ;
Procedure jumpout ;
Begin
  goto 9998 ;
End ;
Procedure error ;

Label 22 , 10 ;

Var c : ASCIIcode ;
  s1 , s2 , s3 , s4 : integer ;
Begin
  If history < 2 Then history := 2 ;
  printchar ( 46 ) ;
  showcontext ;
  If interaction = 3 Then While true Do
                            Begin
                              22 : clearforerrorprompt ;
                              Begin ;
                                print ( 264 ) ;
                                terminput ;
                              End ;
                              If last = first Then goto 10 ;
                              c := buffer [ first ] ;
                              If c >= 97 Then c := c - 32 ;
                              Case c Of 
                                48 , 49 , 50 , 51 , 52 , 53 , 54 , 55 , 56 , 57 : If deletionsallowed Then
                                                                                    Begin
                                                                                      s1 := curtok ;
                                                                                      s2 := curcmd ;
                                                                                      s3 := curchr ;
                                                                                      s4 := alignstate ;
                                                                                      alignstate := 1000000 ;
                                                                                      OKtointerrupt := false ;
                                                                                      If ( last > first + 1 ) And ( buffer [ first + 1 ] >= 48 ) And ( buffer [ first + 1 ] <= 57 ) Then c := c * 10 + buffer [ first + 1 ] - 48 * 11
                                                                                      Else c := c - 48 ;
                                                                                      While c > 0 Do
                                                                                        Begin
                                                                                          gettoken ;
                                                                                          c := c - 1 ;
                                                                                        End ;
                                                                                      curtok := s1 ;
                                                                                      curcmd := s2 ;
                                                                                      curchr := s3 ;
                                                                                      alignstate := s4 ;
                                                                                      OKtointerrupt := true ;
                                                                                      Begin
                                                                                        helpptr := 2 ;
                                                                                        helpline [ 1 ] := 279 ;
                                                                                        helpline [ 0 ] := 280 ;
                                                                                      End ;
                                                                                      showcontext ;
                                                                                      goto 22 ;
                                                                                    End ;
                                69 : If baseptr > 0 Then
                                       Begin
                                         printnl ( 265 ) ;
                                         slowprint ( inputstack [ baseptr ] . namefield ) ;
                                         print ( 266 ) ;
                                         printint ( line ) ;
                                         interaction := 2 ;
                                         jumpout ;
                                       End ;
                                72 :
                                     Begin
                                       If useerrhelp Then
                                         Begin
                                           giveerrhelp ;
                                           useerrhelp := false ;
                                         End
                                       Else
                                         Begin
                                           If helpptr = 0 Then
                                             Begin
                                               helpptr := 2 ;
                                               helpline [ 1 ] := 281 ;
                                               helpline [ 0 ] := 282 ;
                                             End ;
                                           Repeat
                                             helpptr := helpptr - 1 ;
                                             print ( helpline [ helpptr ] ) ;
                                             println ;
                                           Until helpptr = 0 ;
                                         End ;
                                       Begin
                                         helpptr := 4 ;
                                         helpline [ 3 ] := 283 ;
                                         helpline [ 2 ] := 282 ;
                                         helpline [ 1 ] := 284 ;
                                         helpline [ 0 ] := 285 ;
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
                                             print ( 278 ) ;
                                             terminput ;
                                           End ;
                                           curinput . locfield := first ;
                                         End ;
                                       first := last ;
                                       curinput . limitfield := last - 1 ;
                                       goto 10 ;
                                     End ;
                                81 , 82 , 83 :
                                               Begin
                                                 errorcount := 0 ;
                                                 interaction := 0 + c - 81 ;
                                                 print ( 273 ) ;
                                                 Case c Of 
                                                   81 :
                                                        Begin
                                                          printesc ( 274 ) ;
                                                          selector := selector - 1 ;
                                                        End ;
                                                   82 : printesc ( 275 ) ;
                                                   83 : printesc ( 276 ) ;
                                                 End ;
                                                 print ( 277 ) ;
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
                                print ( 267 ) ;
                                printnl ( 268 ) ;
                                printnl ( 269 ) ;
                                If baseptr > 0 Then print ( 270 ) ;
                                If deletionsallowed Then printnl ( 271 ) ;
                                printnl ( 272 ) ;
                              End ;
                            End ;
  errorcount := errorcount + 1 ;
  If errorcount = 100 Then
    Begin
      printnl ( 263 ) ;
      history := 3 ;
      jumpout ;
    End ;
  If interaction > 0 Then selector := selector - 1 ;
  If useerrhelp Then
    Begin
      println ;
      giveerrhelp ;
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
    printnl ( 262 ) ;
    print ( 287 ) ;
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
    printnl ( 262 ) ;
    print ( 288 ) ;
  End ;
  print ( s ) ;
  printchar ( 61 ) ;
  printint ( n ) ;
  printchar ( 93 ) ;
  Begin
    helpptr := 2 ;
    helpline [ 1 ] := 289 ;
    helpline [ 0 ] := 290 ;
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
        printnl ( 262 ) ;
        print ( 291 ) ;
      End ;
      print ( s ) ;
      printchar ( 41 ) ;
      Begin
        helpptr := 1 ;
        helpline [ 0 ] := 292 ;
      End ;
    End
  Else
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 293 ) ;
      End ;
      Begin
        helpptr := 2 ;
        helpline [ 1 ] := 294 ;
        helpline [ 0 ] := 295 ;
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
Function bopenin ( Var f : bytefile ) : boolean ;
Begin
  reset ( f , nameoffile , '/O' ) ;
  bopenin := erstat ( f ) = 0 ;
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
              If maxbufstack = bufsize Then If formatident = 0 Then
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
  If strptr = maxstrings Then overflow ( 258 , maxstrings - initstrptr ) ;
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
Function streqstr ( s , t : strnumber ) : boolean ;

Label 45 ;

Var j , k : poolpointer ;
  result : boolean ;
Begin
  result := false ;
  If ( strstart [ s + 1 ] - strstart [ s ] ) <> ( strstart [ t + 1 ] - strstart [ t ] ) Then goto 45 ;
  j := strstart [ s ] ;
  k := strstart [ t ] ;
  While j < strstart [ s + 1 ] Do
    Begin
      If strpool [ j ] <> strpool [ k ] Then goto 45 ;
      j := j + 1 ;
      k := k + 1 ;
    End ;
  result := true ;
  45 : streqstr := result ;
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
    End ;
  nameoffile := poolname ;
  If aopenin ( poolfile ) Then
    Begin
      c := false ;
      Repeat
        Begin
          If eof ( poolfile ) Then
            Begin ;
              writeln ( termout , '! TEX.POOL has no check sum.' ) ;
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
                      writeln ( termout , '! TEX.POOL check sum doesn''t have nine digits.' ) ;
                      aclose ( poolfile ) ;
                      getstringsstarted := false ;
                      goto 10 ;
                    End ;
                  a := 10 * a + xord [ n ] - 48 ;
                  If k = 9 Then goto 30 ;
                  k := k + 1 ;
                  read ( poolfile , n ) ;
                End ;
              30 : If a <> 117275187 Then
                     Begin ;
                       writeln ( termout , '! TEX.POOL doesn''t match; TANGLE me again.' ) ;
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
                  writeln ( termout , '! TEX.POOL line doesn''t begin with two digits.' ) ;
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
            End ;
        End ;
      Until c ;
      aclose ( poolfile ) ;
      getstringsstarted := true ;
    End
  Else
    Begin ;
      writeln ( termout , '! I can''t read TEX.POOL.' ) ;
      aclose ( poolfile ) ;
      getstringsstarted := false ;
      goto 10 ;
    End ;
  10 :
End ;
Procedure printtwo ( n : integer ) ;
Begin
  n := abs ( n ) Mod 100 ;
  printchar ( 48 + ( n Div 10 ) ) ;
  printchar ( 48 + ( n Mod 10 ) ) ;
End ;
Procedure printhex ( n : integer ) ;

Var k : 0 .. 22 ;
Begin
  k := 0 ;
  printchar ( 34 ) ;
  Repeat
    dig [ k ] := n Mod 16 ;
    n := n Div 16 ;
    k := k + 1 ;
  Until n = 0 ;
  printthedigs ( k ) ;
End ;
Procedure printromanint ( n : integer ) ;

Label 10 ;

Var j , k : poolpointer ;
  u , v : nonnegativeinteger ;
Begin
  j := strstart [ 260 ] ;
  v := 1000 ;
  While true Do
    Begin
      While n >= v Do
        Begin
          printchar ( strpool [ j ] ) ;
          n := n - v ;
        End ;
      If n <= 0 Then goto 10 ;
      k := j + 2 ;
      u := v Div ( strpool [ k - 1 ] - 48 ) ;
      If strpool [ k - 1 ] = 50 Then
        Begin
          k := k + 2 ;
          u := u Div ( strpool [ k - 1 ] - 48 ) ;
        End ;
      If n + u >= v Then
        Begin
          printchar ( strpool [ k ] ) ;
          n := n + u ;
        End
      Else
        Begin
          j := j + 2 ;
          v := v Div ( strpool [ j - 1 ] - 48 ) ;
        End ;
    End ;
  10 :
End ;
Procedure printcurrentstring ;

Var j : poolpointer ;
Begin
  j := strstart [ strptr ] ;
  While j < poolptr Do
    Begin
      printchar ( strpool [ j ] ) ;
      j := j + 1 ;
    End ;
End ;
Procedure terminput ;

Var k : 0 .. bufsize ;
Begin
  break ( termout ) ;
  If Not inputln ( termin , true ) Then fatalerror ( 261 ) ;
  termoffset := 0 ;
  selector := selector - 1 ;
  If last <> first Then For k := first To last - 1 Do
                          print ( buffer [ k ] ) ;
  println ;
  selector := selector + 1 ;
End ;
Procedure interror ( n : integer ) ;
Begin
  print ( 286 ) ;
  printint ( n ) ;
  printchar ( 41 ) ;
  error ;
End ;
Procedure normalizeselector ;
Begin
  If logopened Then selector := 19
  Else selector := 17 ;
  If jobname = 0 Then openlogfile ;
  If interaction = 0 Then selector := selector - 1 ;
End ;
Procedure pauseforinstructions ;
Begin
  If OKtointerrupt Then
    Begin
      interaction := 3 ;
      If ( selector = 18 ) Or ( selector = 16 ) Then selector := selector + 1 ;
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 296 ) ;
      End ;
      Begin
        helpptr := 3 ;
        helpline [ 2 ] := 297 ;
        helpline [ 1 ] := 298 ;
        helpline [ 0 ] := 299 ;
      End ;
      deletionsallowed := false ;
      error ;
      deletionsallowed := true ;
      interrupt := 0 ;
    End ;
End ;
Function half ( x : integer ) : integer ;
Begin
  If odd ( x ) Then half := ( x + 1 ) Div 2
  Else half := x Div 2 ;
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
Procedure printscaled ( s : scaled ) ;

Var delta : scaled ;
Begin
  If s < 0 Then
    Begin
      printchar ( 45 ) ;
      s := - s ;
    End ;
  printint ( s Div 65536 ) ;
  printchar ( 46 ) ;
  s := 10 * ( s Mod 65536 ) + 5 ;
  delta := 10 ;
  Repeat
    If delta > 65536 Then s := s - 17232 ;
    printchar ( 48 + ( s Div 65536 ) ) ;
    s := 10 * ( s Mod 65536 ) ;
    delta := delta * 10 ;
  Until s <= delta ;
End ;
Function multandadd ( n : integer ; x , y , maxanswer : scaled ) : scaled ;
Begin
  If n < 0 Then
    Begin
      x := - x ;
      n := - n ;
    End ;
  If n = 0 Then multandadd := y
  Else If ( ( x <= ( maxanswer - y ) Div n ) And ( - x <= ( maxanswer + y ) Div n ) ) Then multandadd := n * x + y
  Else
    Begin
      aritherror := true ;
      multandadd := 0 ;
    End ;
End ;
Function xovern ( x : scaled ; n : integer ) : scaled ;

Var negative : boolean ;
Begin
  negative := false ;
  If n = 0 Then
    Begin
      aritherror := true ;
      xovern := 0 ;
      remainder := x ;
    End
  Else
    Begin
      If n < 0 Then
        Begin
          x := - x ;
          n := - n ;
          negative := true ;
        End ;
      If x >= 0 Then
        Begin
          xovern := x Div n ;
          remainder := x Mod n ;
        End
      Else
        Begin
          xovern := - ( ( - x ) Div n ) ;
          remainder := - ( ( - x ) Mod n ) ;
        End ;
    End ;
  If negative Then remainder := - remainder ;
End ;
Function xnoverd ( x : scaled ; n , d : integer ) : scaled ;

Var positive : boolean ;
  t , u , v : nonnegativeinteger ;
Begin
  If x >= 0 Then positive := true
  Else
    Begin
      x := - x ;
      positive := false ;
    End ;
  t := ( x Mod 32768 ) * n ;
  u := ( x Div 32768 ) * n + ( t Div 32768 ) ;
  v := ( u Mod d ) * 32768 + ( t Mod 32768 ) ;
  If u Div d >= 32768 Then aritherror := true
  Else u := 32768 * ( u Div d ) + ( v Div d ) ;
  If positive Then
    Begin
      xnoverd := u ;
      remainder := v Mod d ;
    End
  Else
    Begin
      xnoverd := - u ;
      remainder := - ( v Mod d ) ;
    End ;
End ;
Function badness ( t , s : scaled ) : halfword ;

Var r : integer ;
Begin
  If t = 0 Then badness := 0
  Else If s <= 0 Then badness := 10000
  Else
    Begin
      If t <= 7230584 Then r := ( t * 297 ) Div s
      Else If s >= 1663497 Then r := t Div ( s Div 297 )
      Else r := t ;
      If r > 1290 Then badness := 10000
      Else badness := ( r * r * r + 131072 ) Div 262144 ;
    End ;
End ;
Procedure showtokenlist ( p , q : integer ; l : integer ) ;

Label 10 ;

Var m , c : integer ;
  matchchr : ASCIIcode ;
  n : ASCIIcode ;
Begin
  matchchr := 35 ;
  n := 48 ;
  tally := 0 ;
  While ( p <> 0 ) And ( tally < l ) Do
    Begin
      If p = q Then
        Begin
          firstcount := tally ;
          trickcount := tally + 1 + errorline - halferrorline ;
          If trickcount < errorline Then trickcount := errorline ;
        End ;
      If ( p < himemmin ) Or ( p > memend ) Then
        Begin
          printesc ( 309 ) ;
          goto 10 ;
        End ;
      If mem [ p ] . hh . lh >= 4095 Then printcs ( mem [ p ] . hh . lh - 4095 )
      Else
        Begin
          m := mem [ p ] . hh . lh Div 256 ;
          c := mem [ p ] . hh . lh Mod 256 ;
          If mem [ p ] . hh . lh < 0 Then printesc ( 555 )
          Else Case m Of 
                 1 , 2 , 3 , 4 , 7 , 8 , 10 , 11 , 12 : print ( c ) ;
                 6 :
                     Begin
                       print ( c ) ;
                       print ( c ) ;
                     End ;
                 5 :
                     Begin
                       print ( matchchr ) ;
                       If c <= 9 Then printchar ( c + 48 )
                       Else
                         Begin
                           printchar ( 33 ) ;
                           goto 10 ;
                         End ;
                     End ;
                 13 :
                      Begin
                        matchchr := c ;
                        print ( c ) ;
                        n := n + 1 ;
                        printchar ( n ) ;
                        If n > 57 Then goto 10 ;
                      End ;
                 14 : print ( 556 ) ;
                 others : printesc ( 555 )
            End ;
        End ;
      p := mem [ p ] . hh . rh ;
    End ;
  If p <> 0 Then printesc ( 554 ) ;
  10 :
End ;
Procedure runaway ;

Var p : halfword ;
Begin
  If scannerstatus > 1 Then
    Begin
      printnl ( 569 ) ;
      Case scannerstatus Of 
        2 :
            Begin
              print ( 570 ) ;
              p := defref ;
            End ;
        3 :
            Begin
              print ( 571 ) ;
              p := 29997 ;
            End ;
        4 :
            Begin
              print ( 572 ) ;
              p := 29996 ;
            End ;
        5 :
            Begin
              print ( 573 ) ;
              p := defref ;
            End ;
      End ;
      printchar ( 63 ) ;
      println ;
      showtokenlist ( mem [ p ] . hh . rh , 0 , errorline - 10 ) ;
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
          overflow ( 300 , memmax + 1 - memmin ) ;
        End ;
    End ;
  mem [ p ] . hh . rh := 0 ;
  getavail := p ;
End ;
Procedure flushlist ( p : halfword ) ;

Var q , r : halfword ;
Begin
  If p <> 0 Then
    Begin
      r := p ;
      Repeat
        q := r ;
        r := mem [ r ] . hh . rh ;
      Until r = 0 ;
      mem [ q ] . hh . rh := avail ;
      avail := p ;
    End ;
End ;
Function getnode ( s : integer ) : halfword ;

Label 40 , 10 , 20 ;

Var p : halfword ;
  q : halfword ;
  r : integer ;
  t : integer ;
Begin
  20 : p := rover ;
  Repeat
    q := p + mem [ p ] . hh . lh ;
    While ( mem [ q ] . hh . rh = 65535 ) Do
      Begin
        t := mem [ q + 1 ] . hh . rh ;
        If q = rover Then rover := t ;
        mem [ t + 1 ] . hh . lh := mem [ q + 1 ] . hh . lh ;
        mem [ mem [ q + 1 ] . hh . lh + 1 ] . hh . rh := t ;
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
                                      p := mem [ rover + 1 ] . hh . lh ;
                                      q := lomemmax ;
                                      mem [ p + 1 ] . hh . rh := q ;
                                      mem [ rover + 1 ] . hh . lh := q ;
                                      If t > 65535 Then t := 65535 ;
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
  overflow ( 300 , memmax + 1 - memmin ) ;
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
Function newnullbox : halfword ;

Var p : halfword ;
Begin
  p := getnode ( 7 ) ;
  mem [ p ] . hh . b0 := 0 ;
  mem [ p ] . hh . b1 := 0 ;
  mem [ p + 1 ] . int := 0 ;
  mem [ p + 2 ] . int := 0 ;
  mem [ p + 3 ] . int := 0 ;
  mem [ p + 4 ] . int := 0 ;
  mem [ p + 5 ] . hh . rh := 0 ;
  mem [ p + 5 ] . hh . b0 := 0 ;
  mem [ p + 5 ] . hh . b1 := 0 ;
  mem [ p + 6 ] . gr := 0.0 ;
  newnullbox := p ;
End ;
Function newrule : halfword ;

Var p : halfword ;
Begin
  p := getnode ( 4 ) ;
  mem [ p ] . hh . b0 := 2 ;
  mem [ p ] . hh . b1 := 0 ;
  mem [ p + 1 ] . int := - 1073741824 ;
  mem [ p + 2 ] . int := - 1073741824 ;
  mem [ p + 3 ] . int := - 1073741824 ;
  newrule := p ;
End ;
Function newligature ( f , c : quarterword ; q : halfword ) : halfword ;

Var p : halfword ;
Begin
  p := getnode ( 2 ) ;
  mem [ p ] . hh . b0 := 6 ;
  mem [ p + 1 ] . hh . b0 := f ;
  mem [ p + 1 ] . hh . b1 := c ;
  mem [ p + 1 ] . hh . rh := q ;
  mem [ p ] . hh . b1 := 0 ;
  newligature := p ;
End ;
Function newligitem ( c : quarterword ) : halfword ;

Var p : halfword ;
Begin
  p := getnode ( 2 ) ;
  mem [ p ] . hh . b1 := c ;
  mem [ p + 1 ] . hh . rh := 0 ;
  newligitem := p ;
End ;
Function newdisc : halfword ;

Var p : halfword ;
Begin
  p := getnode ( 2 ) ;
  mem [ p ] . hh . b0 := 7 ;
  mem [ p ] . hh . b1 := 0 ;
  mem [ p + 1 ] . hh . lh := 0 ;
  mem [ p + 1 ] . hh . rh := 0 ;
  newdisc := p ;
End ;
Function newmath ( w : scaled ; s : smallnumber ) : halfword ;

Var p : halfword ;
Begin
  p := getnode ( 2 ) ;
  mem [ p ] . hh . b0 := 9 ;
  mem [ p ] . hh . b1 := s ;
  mem [ p + 1 ] . int := w ;
  newmath := p ;
End ;
Function newspec ( p : halfword ) : halfword ;

Var q : halfword ;
Begin
  q := getnode ( 4 ) ;
  mem [ q ] := mem [ p ] ;
  mem [ q ] . hh . rh := 0 ;
  mem [ q + 1 ] . int := mem [ p + 1 ] . int ;
  mem [ q + 2 ] . int := mem [ p + 2 ] . int ;
  mem [ q + 3 ] . int := mem [ p + 3 ] . int ;
  newspec := q ;
End ;
Function newparamglue ( n : smallnumber ) : halfword ;

Var p : halfword ;
  q : halfword ;
Begin
  p := getnode ( 2 ) ;
  mem [ p ] . hh . b0 := 10 ;
  mem [ p ] . hh . b1 := n + 1 ;
  mem [ p + 1 ] . hh . rh := 0 ;
  q := eqtb [ 2882 + n ] . hh . rh ;
  mem [ p + 1 ] . hh . lh := q ;
  mem [ q ] . hh . rh := mem [ q ] . hh . rh + 1 ;
  newparamglue := p ;
End ;
Function newglue ( q : halfword ) : halfword ;

Var p : halfword ;
Begin
  p := getnode ( 2 ) ;
  mem [ p ] . hh . b0 := 10 ;
  mem [ p ] . hh . b1 := 0 ;
  mem [ p + 1 ] . hh . rh := 0 ;
  mem [ p + 1 ] . hh . lh := q ;
  mem [ q ] . hh . rh := mem [ q ] . hh . rh + 1 ;
  newglue := p ;
End ;
Function newskipparam ( n : smallnumber ) : halfword ;

Var p : halfword ;
Begin
  tempptr := newspec ( eqtb [ 2882 + n ] . hh . rh ) ;
  p := newglue ( tempptr ) ;
  mem [ tempptr ] . hh . rh := 0 ;
  mem [ p ] . hh . b1 := n + 1 ;
  newskipparam := p ;
End ;
Function newkern ( w : scaled ) : halfword ;

Var p : halfword ;
Begin
  p := getnode ( 2 ) ;
  mem [ p ] . hh . b0 := 11 ;
  mem [ p ] . hh . b1 := 0 ;
  mem [ p + 1 ] . int := w ;
  newkern := p ;
End ;
Function newpenalty ( m : integer ) : halfword ;

Var p : halfword ;
Begin
  p := getnode ( 2 ) ;
  mem [ p ] . hh . b0 := 12 ;
  mem [ p ] . hh . b1 := 0 ;
  mem [ p + 1 ] . int := m ;
  newpenalty := p ;
End ;
Procedure shortdisplay ( p : integer ) ;

Var n : integer ;
Begin
  While p > memmin Do
    Begin
      If ( p >= himemmin ) Then
        Begin
          If p <= memend Then
            Begin
              If mem [ p ] . hh . b0 <> fontinshortdisplay Then
                Begin
                  If ( mem [ p ] . hh . b0 < 0 ) Or ( mem [ p ] . hh . b0 > fontmax ) Then printchar ( 42 )
                  Else printesc ( hash [ 2624 + mem [ p ] . hh . b0 ] . rh ) ;
                  printchar ( 32 ) ;
                  fontinshortdisplay := mem [ p ] . hh . b0 ;
                End ;
              print ( mem [ p ] . hh . b1 - 0 ) ;
            End ;
        End
      Else Case mem [ p ] . hh . b0 Of 
             0 , 1 , 3 , 8 , 4 , 5 , 13 : print ( 308 ) ;
             2 : printchar ( 124 ) ;
             10 : If mem [ p + 1 ] . hh . lh <> 0 Then printchar ( 32 ) ;
             9 : printchar ( 36 ) ;
             6 : shortdisplay ( mem [ p + 1 ] . hh . rh ) ;
             7 :
                 Begin
                   shortdisplay ( mem [ p + 1 ] . hh . lh ) ;
                   shortdisplay ( mem [ p + 1 ] . hh . rh ) ;
                   n := mem [ p ] . hh . b1 ;
                   While n > 0 Do
                     Begin
                       If mem [ p ] . hh . rh <> 0 Then p := mem [ p ] . hh . rh ;
                       n := n - 1 ;
                     End ;
                 End ;
             others :
        End ;
      p := mem [ p ] . hh . rh ;
    End ;
End ;
Procedure printfontandchar ( p : integer ) ;
Begin
  If p > memend Then printesc ( 309 )
  Else
    Begin
      If ( mem [ p ] . hh . b0 < 0 ) Or ( mem [ p ] . hh . b0 > fontmax ) Then printchar ( 42 )
      Else printesc ( hash [ 2624 + mem [ p ] . hh . b0 ] . rh ) ;
      printchar ( 32 ) ;
      print ( mem [ p ] . hh . b1 - 0 ) ;
    End ;
End ;
Procedure printmark ( p : integer ) ;
Begin
  printchar ( 123 ) ;
  If ( p < himemmin ) Or ( p > memend ) Then printesc ( 309 )
  Else showtokenlist ( mem [ p ] . hh . rh , 0 , maxprintline - 10 ) ;
  printchar ( 125 ) ;
End ;
Procedure printruledimen ( d : scaled ) ;
Begin
  If ( d = - 1073741824 ) Then printchar ( 42 )
  Else printscaled ( d ) ;
End ;
Procedure printglue ( d : scaled ; order : integer ; s : strnumber ) ;
Begin
  printscaled ( d ) ;
  If ( order < 0 ) Or ( order > 3 ) Then print ( 310 )
  Else If order > 0 Then
         Begin
           print ( 311 ) ;
           While order > 1 Do
             Begin
               printchar ( 108 ) ;
               order := order - 1 ;
             End ;
         End
  Else If s <> 0 Then print ( s ) ;
End ;
Procedure printspec ( p : integer ; s : strnumber ) ;
Begin
  If ( p < memmin ) Or ( p >= lomemmax ) Then printchar ( 42 )
  Else
    Begin
      printscaled ( mem [ p + 1 ] . int ) ;
      If s <> 0 Then print ( s ) ;
      If mem [ p + 2 ] . int <> 0 Then
        Begin
          print ( 312 ) ;
          printglue ( mem [ p + 2 ] . int , mem [ p ] . hh . b0 , s ) ;
        End ;
      If mem [ p + 3 ] . int <> 0 Then
        Begin
          print ( 313 ) ;
          printglue ( mem [ p + 3 ] . int , mem [ p ] . hh . b1 , s ) ;
        End ;
    End ;
End ;
Procedure printfamandchar ( p : halfword ) ;
Begin
  printesc ( 464 ) ;
  printint ( mem [ p ] . hh . b0 ) ;
  printchar ( 32 ) ;
  print ( mem [ p ] . hh . b1 - 0 ) ;
End ;
Procedure printdelimiter ( p : halfword ) ;

Var a : integer ;
Begin
  a := mem [ p ] . qqqq . b0 * 256 + mem [ p ] . qqqq . b1 - 0 ;
  a := a * 4096 + mem [ p ] . qqqq . b2 * 256 + mem [ p ] . qqqq . b3 - 0 ;
  If a < 0 Then printint ( a )
  Else printhex ( a ) ;
End ;
Procedure showinfo ;
forward ;
Procedure printsubsidiarydata ( p : halfword ; c : ASCIIcode ) ;
Begin
  If ( poolptr - strstart [ strptr ] ) >= depththreshold Then
    Begin
      If mem [ p ] . hh . rh <> 0 Then print ( 314 ) ;
    End
  Else
    Begin
      Begin
        strpool [ poolptr ] := c ;
        poolptr := poolptr + 1 ;
      End ;
      tempptr := p ;
      Case mem [ p ] . hh . rh Of 
        1 :
            Begin
              println ;
              printcurrentstring ;
              printfamandchar ( p ) ;
            End ;
        2 : showinfo ;
        3 : If mem [ p ] . hh . lh = 0 Then
              Begin
                println ;
                printcurrentstring ;
                print ( 859 ) ;
              End
            Else showinfo ;
        others :
      End ;
      poolptr := poolptr - 1 ;
    End ;
End ;
Procedure printstyle ( c : integer ) ;
Begin
  Case c Div 2 Of 
    0 : printesc ( 860 ) ;
    1 : printesc ( 861 ) ;
    2 : printesc ( 862 ) ;
    3 : printesc ( 863 ) ;
    others : print ( 864 )
  End ;
End ;
Procedure printskipparam ( n : integer ) ;
Begin
  Case n Of 
    0 : printesc ( 376 ) ;
    1 : printesc ( 377 ) ;
    2 : printesc ( 378 ) ;
    3 : printesc ( 379 ) ;
    4 : printesc ( 380 ) ;
    5 : printesc ( 381 ) ;
    6 : printesc ( 382 ) ;
    7 : printesc ( 383 ) ;
    8 : printesc ( 384 ) ;
    9 : printesc ( 385 ) ;
    10 : printesc ( 386 ) ;
    11 : printesc ( 387 ) ;
    12 : printesc ( 388 ) ;
    13 : printesc ( 389 ) ;
    14 : printesc ( 390 ) ;
    15 : printesc ( 391 ) ;
    16 : printesc ( 392 ) ;
    17 : printesc ( 393 ) ;
    others : print ( 394 )
  End ;
End ;
Procedure shownodelist ( p : integer ) ;

Label 10 ;

Var n : integer ;
  g : real ;
Begin
  If ( poolptr - strstart [ strptr ] ) > depththreshold Then
    Begin
      If p > 0 Then print ( 314 ) ;
      goto 10 ;
    End ;
  n := 0 ;
  While p > memmin Do
    Begin
      println ;
      printcurrentstring ;
      If p > memend Then
        Begin
          print ( 315 ) ;
          goto 10 ;
        End ;
      n := n + 1 ;
      If n > breadthmax Then
        Begin
          print ( 316 ) ;
          goto 10 ;
        End ;
      If ( p >= himemmin ) Then printfontandchar ( p )
      Else Case mem [ p ] . hh . b0 Of 
             0 , 1 , 13 :
                          Begin
                            If mem [ p ] . hh . b0 = 0 Then printesc ( 104 )
                            Else If mem [ p ] . hh . b0 = 1 Then printesc ( 118 )
                            Else printesc ( 318 ) ;
                            print ( 319 ) ;
                            printscaled ( mem [ p + 3 ] . int ) ;
                            printchar ( 43 ) ;
                            printscaled ( mem [ p + 2 ] . int ) ;
                            print ( 320 ) ;
                            printscaled ( mem [ p + 1 ] . int ) ;
                            If mem [ p ] . hh . b0 = 13 Then
                              Begin
                                If mem [ p ] . hh . b1 <> 0 Then
                                  Begin
                                    print ( 286 ) ;
                                    printint ( mem [ p ] . hh . b1 + 1 ) ;
                                    print ( 322 ) ;
                                  End ;
                                If mem [ p + 6 ] . int <> 0 Then
                                  Begin
                                    print ( 323 ) ;
                                    printglue ( mem [ p + 6 ] . int , mem [ p + 5 ] . hh . b1 , 0 ) ;
                                  End ;
                                If mem [ p + 4 ] . int <> 0 Then
                                  Begin
                                    print ( 324 ) ;
                                    printglue ( mem [ p + 4 ] . int , mem [ p + 5 ] . hh . b0 , 0 ) ;
                                  End ;
                              End
                            Else
                              Begin
                                g := mem [ p + 6 ] . gr ;
                                If ( g <> 0.0 ) And ( mem [ p + 5 ] . hh . b0 <> 0 ) Then
                                  Begin
                                    print ( 325 ) ;
                                    If mem [ p + 5 ] . hh . b0 = 2 Then print ( 326 ) ;
                                    If abs ( mem [ p + 6 ] . int ) < 1048576 Then print ( 327 )
                                    Else If abs ( g ) > 20000.0 Then
                                           Begin
                                             If g > 0.0 Then printchar ( 62 )
                                             Else print ( 328 ) ;
                                             printglue ( 20000 * 65536 , mem [ p + 5 ] . hh . b1 , 0 ) ;
                                           End
                                    Else printglue ( round ( 65536 * g ) , mem [ p + 5 ] . hh . b1 , 0 ) ;
                                  End ;
                                If mem [ p + 4 ] . int <> 0 Then
                                  Begin
                                    print ( 321 ) ;
                                    printscaled ( mem [ p + 4 ] . int ) ;
                                  End ;
                              End ;
                            Begin
                              Begin
                                strpool [ poolptr ] := 46 ;
                                poolptr := poolptr + 1 ;
                              End ;
                              shownodelist ( mem [ p + 5 ] . hh . rh ) ;
                              poolptr := poolptr - 1 ;
                            End ;
                          End ;
             2 :
                 Begin
                   printesc ( 329 ) ;
                   printruledimen ( mem [ p + 3 ] . int ) ;
                   printchar ( 43 ) ;
                   printruledimen ( mem [ p + 2 ] . int ) ;
                   print ( 320 ) ;
                   printruledimen ( mem [ p + 1 ] . int ) ;
                 End ;
             3 :
                 Begin
                   printesc ( 330 ) ;
                   printint ( mem [ p ] . hh . b1 - 0 ) ;
                   print ( 331 ) ;
                   printscaled ( mem [ p + 3 ] . int ) ;
                   print ( 332 ) ;
                   printspec ( mem [ p + 4 ] . hh . rh , 0 ) ;
                   printchar ( 44 ) ;
                   printscaled ( mem [ p + 2 ] . int ) ;
                   print ( 333 ) ;
                   printint ( mem [ p + 1 ] . int ) ;
                   Begin
                     Begin
                       strpool [ poolptr ] := 46 ;
                       poolptr := poolptr + 1 ;
                     End ;
                     shownodelist ( mem [ p + 4 ] . hh . lh ) ;
                     poolptr := poolptr - 1 ;
                   End ;
                 End ;
             8 : Case mem [ p ] . hh . b1 Of 
                   0 :
                       Begin
                         printwritewhatsit ( 1284 , p ) ;
                         printchar ( 61 ) ;
                         printfilename ( mem [ p + 1 ] . hh . rh , mem [ p + 2 ] . hh . lh , mem [ p + 2 ] . hh . rh ) ;
                       End ;
                   1 :
                       Begin
                         printwritewhatsit ( 594 , p ) ;
                         printmark ( mem [ p + 1 ] . hh . rh ) ;
                       End ;
                   2 : printwritewhatsit ( 1285 , p ) ;
                   3 :
                       Begin
                         printesc ( 1286 ) ;
                         printmark ( mem [ p + 1 ] . hh . rh ) ;
                       End ;
                   4 :
                       Begin
                         printesc ( 1288 ) ;
                         printint ( mem [ p + 1 ] . hh . rh ) ;
                         print ( 1291 ) ;
                         printint ( mem [ p + 1 ] . hh . b0 ) ;
                         printchar ( 44 ) ;
                         printint ( mem [ p + 1 ] . hh . b1 ) ;
                         printchar ( 41 ) ;
                       End ;
                   others : print ( 1292 )
                 End ;
             10 : If mem [ p ] . hh . b1 >= 100 Then
                    Begin
                      printesc ( 338 ) ;
                      If mem [ p ] . hh . b1 = 101 Then printchar ( 99 )
                      Else If mem [ p ] . hh . b1 = 102 Then printchar ( 120 ) ;
                      print ( 339 ) ;
                      printspec ( mem [ p + 1 ] . hh . lh , 0 ) ;
                      Begin
                        Begin
                          strpool [ poolptr ] := 46 ;
                          poolptr := poolptr + 1 ;
                        End ;
                        shownodelist ( mem [ p + 1 ] . hh . rh ) ;
                        poolptr := poolptr - 1 ;
                      End ;
                    End
                  Else
                    Begin
                      printesc ( 334 ) ;
                      If mem [ p ] . hh . b1 <> 0 Then
                        Begin
                          printchar ( 40 ) ;
                          If mem [ p ] . hh . b1 < 98 Then printskipparam ( mem [ p ] . hh . b1 - 1 )
                          Else If mem [ p ] . hh . b1 = 98 Then printesc ( 335 )
                          Else printesc ( 336 ) ;
                          printchar ( 41 ) ;
                        End ;
                      If mem [ p ] . hh . b1 <> 98 Then
                        Begin
                          printchar ( 32 ) ;
                          If mem [ p ] . hh . b1 < 98 Then printspec ( mem [ p + 1 ] . hh . lh , 0 )
                          Else printspec ( mem [ p + 1 ] . hh . lh , 337 ) ;
                        End ;
                    End ;
             11 : If mem [ p ] . hh . b1 <> 99 Then
                    Begin
                      printesc ( 340 ) ;
                      If mem [ p ] . hh . b1 <> 0 Then printchar ( 32 ) ;
                      printscaled ( mem [ p + 1 ] . int ) ;
                      If mem [ p ] . hh . b1 = 2 Then print ( 341 ) ;
                    End
                  Else
                    Begin
                      printesc ( 342 ) ;
                      printscaled ( mem [ p + 1 ] . int ) ;
                      print ( 337 ) ;
                    End ;
             9 :
                 Begin
                   printesc ( 343 ) ;
                   If mem [ p ] . hh . b1 = 0 Then print ( 344 )
                   Else print ( 345 ) ;
                   If mem [ p + 1 ] . int <> 0 Then
                     Begin
                       print ( 346 ) ;
                       printscaled ( mem [ p + 1 ] . int ) ;
                     End ;
                 End ;
             6 :
                 Begin
                   printfontandchar ( p + 1 ) ;
                   print ( 347 ) ;
                   If mem [ p ] . hh . b1 > 1 Then printchar ( 124 ) ;
                   fontinshortdisplay := mem [ p + 1 ] . hh . b0 ;
                   shortdisplay ( mem [ p + 1 ] . hh . rh ) ;
                   If odd ( mem [ p ] . hh . b1 ) Then printchar ( 124 ) ;
                   printchar ( 41 ) ;
                 End ;
             12 :
                  Begin
                    printesc ( 348 ) ;
                    printint ( mem [ p + 1 ] . int ) ;
                  End ;
             7 :
                 Begin
                   printesc ( 349 ) ;
                   If mem [ p ] . hh . b1 > 0 Then
                     Begin
                       print ( 350 ) ;
                       printint ( mem [ p ] . hh . b1 ) ;
                     End ;
                   Begin
                     Begin
                       strpool [ poolptr ] := 46 ;
                       poolptr := poolptr + 1 ;
                     End ;
                     shownodelist ( mem [ p + 1 ] . hh . lh ) ;
                     poolptr := poolptr - 1 ;
                   End ;
                   Begin
                     strpool [ poolptr ] := 124 ;
                     poolptr := poolptr + 1 ;
                   End ;
                   shownodelist ( mem [ p + 1 ] . hh . rh ) ;
                   poolptr := poolptr - 1 ;
                 End ;
             4 :
                 Begin
                   printesc ( 351 ) ;
                   printmark ( mem [ p + 1 ] . int ) ;
                 End ;
             5 :
                 Begin
                   printesc ( 352 ) ;
                   Begin
                     Begin
                       strpool [ poolptr ] := 46 ;
                       poolptr := poolptr + 1 ;
                     End ;
                     shownodelist ( mem [ p + 1 ] . int ) ;
                     poolptr := poolptr - 1 ;
                   End ;
                 End ;
             14 : printstyle ( mem [ p ] . hh . b1 ) ;
             15 :
                  Begin
                    printesc ( 525 ) ;
                    Begin
                      strpool [ poolptr ] := 68 ;
                      poolptr := poolptr + 1 ;
                    End ;
                    shownodelist ( mem [ p + 1 ] . hh . lh ) ;
                    poolptr := poolptr - 1 ;
                    Begin
                      strpool [ poolptr ] := 84 ;
                      poolptr := poolptr + 1 ;
                    End ;
                    shownodelist ( mem [ p + 1 ] . hh . rh ) ;
                    poolptr := poolptr - 1 ;
                    Begin
                      strpool [ poolptr ] := 83 ;
                      poolptr := poolptr + 1 ;
                    End ;
                    shownodelist ( mem [ p + 2 ] . hh . lh ) ;
                    poolptr := poolptr - 1 ;
                    Begin
                      strpool [ poolptr ] := 115 ;
                      poolptr := poolptr + 1 ;
                    End ;
                    shownodelist ( mem [ p + 2 ] . hh . rh ) ;
                    poolptr := poolptr - 1 ;
                  End ;
             16 , 17 , 18 , 19 , 20 , 21 , 22 , 23 , 24 , 27 , 26 , 29 , 28 , 30 , 31 :
                                                                                        Begin
                                                                                          Case mem [ p ] . hh . b0 Of 
                                                                                            16 : printesc ( 865 ) ;
                                                                                            17 : printesc ( 866 ) ;
                                                                                            18 : printesc ( 867 ) ;
                                                                                            19 : printesc ( 868 ) ;
                                                                                            20 : printesc ( 869 ) ;
                                                                                            21 : printesc ( 870 ) ;
                                                                                            22 : printesc ( 871 ) ;
                                                                                            23 : printesc ( 872 ) ;
                                                                                            27 : printesc ( 873 ) ;
                                                                                            26 : printesc ( 874 ) ;
                                                                                            29 : printesc ( 539 ) ;
                                                                                            24 :
                                                                                                 Begin
                                                                                                   printesc ( 533 ) ;
                                                                                                   printdelimiter ( p + 4 ) ;
                                                                                                 End ;
                                                                                            28 :
                                                                                                 Begin
                                                                                                   printesc ( 508 ) ;
                                                                                                   printfamandchar ( p + 4 ) ;
                                                                                                 End ;
                                                                                            30 :
                                                                                                 Begin
                                                                                                   printesc ( 875 ) ;
                                                                                                   printdelimiter ( p + 1 ) ;
                                                                                                 End ;
                                                                                            31 :
                                                                                                 Begin
                                                                                                   printesc ( 876 ) ;
                                                                                                   printdelimiter ( p + 1 ) ;
                                                                                                 End ;
                                                                                          End ;
                                                                                          If mem [ p ] . hh . b1 <> 0 Then If mem [ p ] . hh . b1 = 1 Then printesc ( 877 )
                                                                                          Else printesc ( 878 ) ;
                                                                                          If mem [ p ] . hh . b0 < 30 Then printsubsidiarydata ( p + 1 , 46 ) ;
                                                                                          printsubsidiarydata ( p + 2 , 94 ) ;
                                                                                          printsubsidiarydata ( p + 3 , 95 ) ;
                                                                                        End ;
             25 :
                  Begin
                    printesc ( 879 ) ;
                    If mem [ p + 1 ] . int = 1073741824 Then print ( 880 )
                    Else printscaled ( mem [ p + 1 ] . int ) ;
                    If ( mem [ p + 4 ] . qqqq . b0 <> 0 ) Or ( mem [ p + 4 ] . qqqq . b1 <> 0 ) Or ( mem [ p + 4 ] . qqqq . b2 <> 0 ) Or ( mem [ p + 4 ] . qqqq . b3 <> 0 ) Then
                      Begin
                        print ( 881 ) ;
                        printdelimiter ( p + 4 ) ;
                      End ;
                    If ( mem [ p + 5 ] . qqqq . b0 <> 0 ) Or ( mem [ p + 5 ] . qqqq . b1 <> 0 ) Or ( mem [ p + 5 ] . qqqq . b2 <> 0 ) Or ( mem [ p + 5 ] . qqqq . b3 <> 0 ) Then
                      Begin
                        print ( 882 ) ;
                        printdelimiter ( p + 5 ) ;
                      End ;
                    printsubsidiarydata ( p + 2 , 92 ) ;
                    printsubsidiarydata ( p + 3 , 47 ) ;
                  End ;
             others : print ( 317 )
        End ;
      p := mem [ p ] . hh . rh ;
    End ;
  10 :
End ;
Procedure showbox ( p : halfword ) ;
Begin
  depththreshold := eqtb [ 5288 ] . int ;
  breadthmax := eqtb [ 5287 ] . int ;
  If breadthmax <= 0 Then breadthmax := 5 ;
  If poolptr + depththreshold >= poolsize Then depththreshold := poolsize - poolptr - 1 ;
  shownodelist ( p ) ;
  println ;
End ;
Procedure deletetokenref ( p : halfword ) ;
Begin
  If mem [ p ] . hh . lh = 0 Then flushlist ( p )
  Else mem [ p ] . hh . lh := mem [ p ] . hh . lh - 1 ;
End ;
Procedure deleteglueref ( p : halfword ) ;
Begin
  If mem [ p ] . hh . rh = 0 Then freenode ( p , 4 )
  Else mem [ p ] . hh . rh := mem [ p ] . hh . rh - 1 ;
End ;
Procedure flushnodelist ( p : halfword ) ;

Label 30 ;

Var q : halfword ;
Begin
  While p <> 0 Do
    Begin
      q := mem [ p ] . hh . rh ;
      If ( p >= himemmin ) Then
        Begin
          mem [ p ] . hh . rh := avail ;
          avail := p ;
        End
      Else
        Begin
          Case mem [ p ] . hh . b0 Of 
            0 , 1 , 13 :
                         Begin
                           flushnodelist ( mem [ p + 5 ] . hh . rh ) ;
                           freenode ( p , 7 ) ;
                           goto 30 ;
                         End ;
            2 :
                Begin
                  freenode ( p , 4 ) ;
                  goto 30 ;
                End ;
            3 :
                Begin
                  flushnodelist ( mem [ p + 4 ] . hh . lh ) ;
                  deleteglueref ( mem [ p + 4 ] . hh . rh ) ;
                  freenode ( p , 5 ) ;
                  goto 30 ;
                End ;
            8 :
                Begin
                  Case mem [ p ] . hh . b1 Of 
                    0 : freenode ( p , 3 ) ;
                    1 , 3 :
                            Begin
                              deletetokenref ( mem [ p + 1 ] . hh . rh ) ;
                              freenode ( p , 2 ) ;
                              goto 30 ;
                            End ;
                    2 , 4 : freenode ( p , 2 ) ;
                    others : confusion ( 1294 )
                  End ;
                  goto 30 ;
                End ;
            10 :
                 Begin
                   Begin
                     If mem [ mem [ p + 1 ] . hh . lh ] . hh . rh = 0 Then freenode ( mem [ p + 1 ] . hh . lh , 4 )
                     Else mem [ mem [ p + 1 ] . hh . lh ] . hh . rh := mem [ mem [ p + 1 ] . hh . lh ] . hh . rh - 1 ;
                   End ;
                   If mem [ p + 1 ] . hh . rh <> 0 Then flushnodelist ( mem [ p + 1 ] . hh . rh ) ;
                 End ;
            11 , 9 , 12 : ;
            6 : flushnodelist ( mem [ p + 1 ] . hh . rh ) ;
            4 : deletetokenref ( mem [ p + 1 ] . int ) ;
            7 :
                Begin
                  flushnodelist ( mem [ p + 1 ] . hh . lh ) ;
                  flushnodelist ( mem [ p + 1 ] . hh . rh ) ;
                End ;
            5 : flushnodelist ( mem [ p + 1 ] . int ) ;
            14 :
                 Begin
                   freenode ( p , 3 ) ;
                   goto 30 ;
                 End ;
            15 :
                 Begin
                   flushnodelist ( mem [ p + 1 ] . hh . lh ) ;
                   flushnodelist ( mem [ p + 1 ] . hh . rh ) ;
                   flushnodelist ( mem [ p + 2 ] . hh . lh ) ;
                   flushnodelist ( mem [ p + 2 ] . hh . rh ) ;
                   freenode ( p , 3 ) ;
                   goto 30 ;
                 End ;
            16 , 17 , 18 , 19 , 20 , 21 , 22 , 23 , 24 , 27 , 26 , 29 , 28 :
                                                                             Begin
                                                                               If mem [ p + 1 ] . hh . rh >= 2 Then flushnodelist ( mem [ p + 1 ] . hh . lh ) ;
                                                                               If mem [ p + 2 ] . hh . rh >= 2 Then flushnodelist ( mem [ p + 2 ] . hh . lh ) ;
                                                                               If mem [ p + 3 ] . hh . rh >= 2 Then flushnodelist ( mem [ p + 3 ] . hh . lh ) ;
                                                                               If mem [ p ] . hh . b0 = 24 Then freenode ( p , 5 )
                                                                               Else If mem [ p ] . hh . b0 = 28 Then freenode ( p , 5 )
                                                                               Else freenode ( p , 4 ) ;
                                                                               goto 30 ;
                                                                             End ;
            30 , 31 :
                      Begin
                        freenode ( p , 4 ) ;
                        goto 30 ;
                      End ;
            25 :
                 Begin
                   flushnodelist ( mem [ p + 2 ] . hh . lh ) ;
                   flushnodelist ( mem [ p + 3 ] . hh . lh ) ;
                   freenode ( p , 6 ) ;
                   goto 30 ;
                 End ;
            others : confusion ( 353 )
          End ;
          freenode ( p , 2 ) ;
          30 :
        End ;
      p := q ;
    End ;
End ;
Function copynodelist ( p : halfword ) : halfword ;

Var h : halfword ;
  q : halfword ;
  r : halfword ;
  words : 0 .. 5 ;
Begin
  h := getavail ;
  q := h ;
  While p <> 0 Do
    Begin
      words := 1 ;
      If ( p >= himemmin ) Then r := getavail
      Else Case mem [ p ] . hh . b0 Of 
             0 , 1 , 13 :
                          Begin
                            r := getnode ( 7 ) ;
                            mem [ r + 6 ] := mem [ p + 6 ] ;
                            mem [ r + 5 ] := mem [ p + 5 ] ;
                            mem [ r + 5 ] . hh . rh := copynodelist ( mem [ p + 5 ] . hh . rh ) ;
                            words := 5 ;
                          End ;
             2 :
                 Begin
                   r := getnode ( 4 ) ;
                   words := 4 ;
                 End ;
             3 :
                 Begin
                   r := getnode ( 5 ) ;
                   mem [ r + 4 ] := mem [ p + 4 ] ;
                   mem [ mem [ p + 4 ] . hh . rh ] . hh . rh := mem [ mem [ p + 4 ] . hh . rh ] . hh . rh + 1 ;
                   mem [ r + 4 ] . hh . lh := copynodelist ( mem [ p + 4 ] . hh . lh ) ;
                   words := 4 ;
                 End ;
             8 : Case mem [ p ] . hh . b1 Of 
                   0 :
                       Begin
                         r := getnode ( 3 ) ;
                         words := 3 ;
                       End ;
                   1 , 3 :
                           Begin
                             r := getnode ( 2 ) ;
                             mem [ mem [ p + 1 ] . hh . rh ] . hh . lh := mem [ mem [ p + 1 ] . hh . rh ] . hh . lh + 1 ;
                             words := 2 ;
                           End ;
                   2 , 4 :
                           Begin
                             r := getnode ( 2 ) ;
                             words := 2 ;
                           End ;
                   others : confusion ( 1293 )
                 End ;
             10 :
                  Begin
                    r := getnode ( 2 ) ;
                    mem [ mem [ p + 1 ] . hh . lh ] . hh . rh := mem [ mem [ p + 1 ] . hh . lh ] . hh . rh + 1 ;
                    mem [ r + 1 ] . hh . lh := mem [ p + 1 ] . hh . lh ;
                    mem [ r + 1 ] . hh . rh := copynodelist ( mem [ p + 1 ] . hh . rh ) ;
                  End ;
             11 , 9 , 12 :
                           Begin
                             r := getnode ( 2 ) ;
                             words := 2 ;
                           End ;
             6 :
                 Begin
                   r := getnode ( 2 ) ;
                   mem [ r + 1 ] := mem [ p + 1 ] ;
                   mem [ r + 1 ] . hh . rh := copynodelist ( mem [ p + 1 ] . hh . rh ) ;
                 End ;
             7 :
                 Begin
                   r := getnode ( 2 ) ;
                   mem [ r + 1 ] . hh . lh := copynodelist ( mem [ p + 1 ] . hh . lh ) ;
                   mem [ r + 1 ] . hh . rh := copynodelist ( mem [ p + 1 ] . hh . rh ) ;
                 End ;
             4 :
                 Begin
                   r := getnode ( 2 ) ;
                   mem [ mem [ p + 1 ] . int ] . hh . lh := mem [ mem [ p + 1 ] . int ] . hh . lh + 1 ;
                   words := 2 ;
                 End ;
             5 :
                 Begin
                   r := getnode ( 2 ) ;
                   mem [ r + 1 ] . int := copynodelist ( mem [ p + 1 ] . int ) ;
                 End ;
             others : confusion ( 354 )
        End ;
      While words > 0 Do
        Begin
          words := words - 1 ;
          mem [ r + words ] := mem [ p + words ] ;
        End ;
      mem [ q ] . hh . rh := r ;
      q := r ;
      p := mem [ p ] . hh . rh ;
    End ;
  mem [ q ] . hh . rh := 0 ;
  q := mem [ h ] . hh . rh ;
  Begin
    mem [ h ] . hh . rh := avail ;
    avail := h ;
  End ;
  copynodelist := q ;
End ;
Procedure printmode ( m : integer ) ;
Begin
  If m > 0 Then Case m Div ( 101 ) Of 
                  0 : print ( 355 ) ;
                  1 : print ( 356 ) ;
                  2 : print ( 357 ) ;
    End
  Else If m = 0 Then print ( 358 )
  Else Case ( - m ) Div ( 101 ) Of 
         0 : print ( 359 ) ;
         1 : print ( 360 ) ;
         2 : print ( 343 ) ;
    End ;
  print ( 361 ) ;
End ;
Procedure pushnest ;
Begin
  If nestptr > maxneststack Then
    Begin
      maxneststack := nestptr ;
      If nestptr = nestsize Then overflow ( 362 , nestsize ) ;
    End ;
  nest [ nestptr ] := curlist ;
  nestptr := nestptr + 1 ;
  curlist . headfield := getavail ;
  curlist . tailfield := curlist . headfield ;
  curlist . pgfield := 0 ;
  curlist . mlfield := line ;
End ;
Procedure popnest ;
Begin
  Begin
    mem [ curlist . headfield ] . hh . rh := avail ;
    avail := curlist . headfield ;
  End ;
  nestptr := nestptr - 1 ;
  curlist := nest [ nestptr ] ;
End ;
Procedure printtotals ;
forward ;
Procedure showactivities ;

Var p : 0 .. nestsize ;
  m : - 203 .. 203 ;
  a : memoryword ;
  q , r : halfword ;
  t : integer ;
Begin
  nest [ nestptr ] := curlist ;
  printnl ( 338 ) ;
  println ;
  For p := nestptr Downto 0 Do
    Begin
      m := nest [ p ] . modefield ;
      a := nest [ p ] . auxfield ;
      printnl ( 363 ) ;
      printmode ( m ) ;
      print ( 364 ) ;
      printint ( abs ( nest [ p ] . mlfield ) ) ;
      If m = 102 Then If nest [ p ] . pgfield <> 8585216 Then
                        Begin
                          print ( 365 ) ;
                          printint ( nest [ p ] . pgfield Mod 65536 ) ;
                          print ( 366 ) ;
                          printint ( nest [ p ] . pgfield Div 4194304 ) ;
                          printchar ( 44 ) ;
                          printint ( ( nest [ p ] . pgfield Div 65536 ) mod 64 ) ;
                          printchar ( 41 ) ;
                        End ;
      If nest [ p ] . mlfield < 0 Then print ( 367 ) ;
      If p = 0 Then
        Begin
          If 29998 <> pagetail Then
            Begin
              printnl ( 979 ) ;
              If outputactive Then print ( 980 ) ;
              showbox ( mem [ 29998 ] . hh . rh ) ;
              If pagecontents > 0 Then
                Begin
                  printnl ( 981 ) ;
                  printtotals ;
                  printnl ( 982 ) ;
                  printscaled ( pagesofar [ 0 ] ) ;
                  r := mem [ 30000 ] . hh . rh ;
                  While r <> 30000 Do
                    Begin
                      println ;
                      printesc ( 330 ) ;
                      t := mem [ r ] . hh . b1 - 0 ;
                      printint ( t ) ;
                      print ( 983 ) ;
                      If eqtb [ 5318 + t ] . int = 1000 Then t := mem [ r + 3 ] . int
                      Else t := xovern ( mem [ r + 3 ] . int , 1000 ) * eqtb [ 5318 + t ] . int ;
                      printscaled ( t ) ;
                      If mem [ r ] . hh . b0 = 1 Then
                        Begin
                          q := 29998 ;
                          t := 0 ;
                          Repeat
                            q := mem [ q ] . hh . rh ;
                            If ( mem [ q ] . hh . b0 = 3 ) And ( mem [ q ] . hh . b1 = mem [ r ] . hh . b1 ) Then t := t + 1 ;
                          Until q = mem [ r + 1 ] . hh . lh ;
                          print ( 984 ) ;
                          printint ( t ) ;
                          print ( 985 ) ;
                        End ;
                      r := mem [ r ] . hh . rh ;
                    End ;
                End ;
            End ;
          If mem [ 29999 ] . hh . rh <> 0 Then printnl ( 368 ) ;
        End ;
      showbox ( mem [ nest [ p ] . headfield ] . hh . rh ) ;
      Case abs ( m ) Div ( 101 ) Of 
        0 :
            Begin
              printnl ( 369 ) ;
              If a . int <= - 65536000 Then print ( 370 )
              Else printscaled ( a . int ) ;
              If nest [ p ] . pgfield <> 0 Then
                Begin
                  print ( 371 ) ;
                  printint ( nest [ p ] . pgfield ) ;
                  print ( 372 ) ;
                  If nest [ p ] . pgfield <> 1 Then printchar ( 115 ) ;
                End ;
            End ;
        1 :
            Begin
              printnl ( 373 ) ;
              printint ( a . hh . lh ) ;
              If m > 0 Then If a . hh . rh > 0 Then
                              Begin
                                print ( 374 ) ;
                                printint ( a . hh . rh ) ;
                              End ;
            End ;
        2 : If a . int <> 0 Then
              Begin
                print ( 375 ) ;
                showbox ( a . int ) ;
              End ;
      End ;
    End ;
End ;
Procedure printparam ( n : integer ) ;
Begin
  Case n Of 
    0 : printesc ( 420 ) ;
    1 : printesc ( 421 ) ;
    2 : printesc ( 422 ) ;
    3 : printesc ( 423 ) ;
    4 : printesc ( 424 ) ;
    5 : printesc ( 425 ) ;
    6 : printesc ( 426 ) ;
    7 : printesc ( 427 ) ;
    8 : printesc ( 428 ) ;
    9 : printesc ( 429 ) ;
    10 : printesc ( 430 ) ;
    11 : printesc ( 431 ) ;
    12 : printesc ( 432 ) ;
    13 : printesc ( 433 ) ;
    14 : printesc ( 434 ) ;
    15 : printesc ( 435 ) ;
    16 : printesc ( 436 ) ;
    17 : printesc ( 437 ) ;
    18 : printesc ( 438 ) ;
    19 : printesc ( 439 ) ;
    20 : printesc ( 440 ) ;
    21 : printesc ( 441 ) ;
    22 : printesc ( 442 ) ;
    23 : printesc ( 443 ) ;
    24 : printesc ( 444 ) ;
    25 : printesc ( 445 ) ;
    26 : printesc ( 446 ) ;
    27 : printesc ( 447 ) ;
    28 : printesc ( 448 ) ;
    29 : printesc ( 449 ) ;
    30 : printesc ( 450 ) ;
    31 : printesc ( 451 ) ;
    32 : printesc ( 452 ) ;
    33 : printesc ( 453 ) ;
    34 : printesc ( 454 ) ;
    35 : printesc ( 455 ) ;
    36 : printesc ( 456 ) ;
    37 : printesc ( 457 ) ;
    38 : printesc ( 458 ) ;
    39 : printesc ( 459 ) ;
    40 : printesc ( 460 ) ;
    41 : printesc ( 461 ) ;
    42 : printesc ( 462 ) ;
    43 : printesc ( 463 ) ;
    44 : printesc ( 464 ) ;
    45 : printesc ( 465 ) ;
    46 : printesc ( 466 ) ;
    47 : printesc ( 467 ) ;
    48 : printesc ( 468 ) ;
    49 : printesc ( 469 ) ;
    50 : printesc ( 470 ) ;
    51 : printesc ( 471 ) ;
    52 : printesc ( 472 ) ;
    53 : printesc ( 473 ) ;
    54 : printesc ( 474 ) ;
    others : print ( 475 )
  End ;
End ;
Procedure fixdateandtime ;
Begin
  eqtb [ 5283 ] . int := 12 * 60 ;
  eqtb [ 5284 ] . int := 4 ;
  eqtb [ 5285 ] . int := 7 ;
  eqtb [ 5286 ] . int := 1776 ;
End ;
Procedure begindiagnostic ;
Begin
  oldsetting := selector ;
  If ( eqtb [ 5292 ] . int <= 0 ) And ( selector = 19 ) Then
    Begin
      selector := selector - 1 ;
      If history = 0 Then history := 1 ;
    End ;
End ;
Procedure enddiagnostic ( blankline : boolean ) ;
Begin
  printnl ( 338 ) ;
  If blankline Then println ;
  selector := oldsetting ;
End ;
Procedure printlengthparam ( n : integer ) ;
Begin
  Case n Of 
    0 : printesc ( 478 ) ;
    1 : printesc ( 479 ) ;
    2 : printesc ( 480 ) ;
    3 : printesc ( 481 ) ;
    4 : printesc ( 482 ) ;
    5 : printesc ( 483 ) ;
    6 : printesc ( 484 ) ;
    7 : printesc ( 485 ) ;
    8 : printesc ( 486 ) ;
    9 : printesc ( 487 ) ;
    10 : printesc ( 488 ) ;
    11 : printesc ( 489 ) ;
    12 : printesc ( 490 ) ;
    13 : printesc ( 491 ) ;
    14 : printesc ( 492 ) ;
    15 : printesc ( 493 ) ;
    16 : printesc ( 494 ) ;
    17 : printesc ( 495 ) ;
    18 : printesc ( 496 ) ;
    19 : printesc ( 497 ) ;
    20 : printesc ( 498 ) ;
    others : print ( 499 )
  End ;
End ;
Procedure printcmdchr ( cmd : quarterword ; chrcode : halfword ) ;
Begin
  Case cmd Of 
    1 :
        Begin
          print ( 557 ) ;
          print ( chrcode ) ;
        End ;
    2 :
        Begin
          print ( 558 ) ;
          print ( chrcode ) ;
        End ;
    3 :
        Begin
          print ( 559 ) ;
          print ( chrcode ) ;
        End ;
    6 :
        Begin
          print ( 560 ) ;
          print ( chrcode ) ;
        End ;
    7 :
        Begin
          print ( 561 ) ;
          print ( chrcode ) ;
        End ;
    8 :
        Begin
          print ( 562 ) ;
          print ( chrcode ) ;
        End ;
    9 : print ( 563 ) ;
    10 :
         Begin
           print ( 564 ) ;
           print ( chrcode ) ;
         End ;
    11 :
         Begin
           print ( 565 ) ;
           print ( chrcode ) ;
         End ;
    12 :
         Begin
           print ( 566 ) ;
           print ( chrcode ) ;
         End ;
    75 , 76 : If chrcode < 2900 Then printskipparam ( chrcode - 2882 )
              Else If chrcode < 3156 Then
                     Begin
                       printesc ( 395 ) ;
                       printint ( chrcode - 2900 ) ;
                     End
              Else
                Begin
                  printesc ( 396 ) ;
                  printint ( chrcode - 3156 ) ;
                End ;
    72 : If chrcode >= 3422 Then
           Begin
             printesc ( 407 ) ;
             printint ( chrcode - 3422 ) ;
           End
         Else Case chrcode Of 
                3413 : printesc ( 398 ) ;
                3414 : printesc ( 399 ) ;
                3415 : printesc ( 400 ) ;
                3416 : printesc ( 401 ) ;
                3417 : printesc ( 402 ) ;
                3418 : printesc ( 403 ) ;
                3419 : printesc ( 404 ) ;
                3420 : printesc ( 405 ) ;
                others : printesc ( 406 )
           End ;
    73 : If chrcode < 5318 Then printparam ( chrcode - 5263 )
         Else
           Begin
             printesc ( 476 ) ;
             printint ( chrcode - 5318 ) ;
           End ;
    74 : If chrcode < 5851 Then printlengthparam ( chrcode - 5830 )
         Else
           Begin
             printesc ( 500 ) ;
             printint ( chrcode - 5851 ) ;
           End ;
    45 : printesc ( 508 ) ;
    90 : printesc ( 509 ) ;
    40 : printesc ( 510 ) ;
    41 : printesc ( 511 ) ;
    77 : printesc ( 519 ) ;
    61 : printesc ( 512 ) ;
    42 : printesc ( 531 ) ;
    16 : printesc ( 513 ) ;
    107 : printesc ( 504 ) ;
    88 : printesc ( 518 ) ;
    15 : printesc ( 514 ) ;
    92 : printesc ( 515 ) ;
    67 : printesc ( 505 ) ;
    62 : printesc ( 516 ) ;
    64 : printesc ( 32 ) ;
    102 : printesc ( 517 ) ;
    32 : printesc ( 520 ) ;
    36 : printesc ( 521 ) ;
    39 : printesc ( 522 ) ;
    37 : printesc ( 330 ) ;
    44 : printesc ( 47 ) ;
    18 : printesc ( 351 ) ;
    46 : printesc ( 523 ) ;
    17 : printesc ( 524 ) ;
    54 : printesc ( 525 ) ;
    91 : printesc ( 526 ) ;
    34 : printesc ( 527 ) ;
    65 : printesc ( 528 ) ;
    103 : printesc ( 529 ) ;
    55 : printesc ( 335 ) ;
    63 : printesc ( 530 ) ;
    66 : printesc ( 533 ) ;
    96 : printesc ( 534 ) ;
    0 : printesc ( 535 ) ;
    98 : printesc ( 536 ) ;
    80 : printesc ( 532 ) ;
    84 : printesc ( 408 ) ;
    109 : printesc ( 537 ) ;
    71 : printesc ( 407 ) ;
    38 : printesc ( 352 ) ;
    33 : printesc ( 538 ) ;
    56 : printesc ( 539 ) ;
    35 : printesc ( 540 ) ;
    13 : printesc ( 597 ) ;
    104 : If chrcode = 0 Then printesc ( 629 )
          Else printesc ( 630 ) ;
    110 : Case chrcode Of 
            1 : printesc ( 632 ) ;
            2 : printesc ( 633 ) ;
            3 : printesc ( 634 ) ;
            4 : printesc ( 635 ) ;
            others : printesc ( 631 )
          End ;
    89 : If chrcode = 0 Then printesc ( 476 )
         Else If chrcode = 1 Then printesc ( 500 )
         Else If chrcode = 2 Then printesc ( 395 )
         Else printesc ( 396 ) ;
    79 : If chrcode = 1 Then printesc ( 669 )
         Else printesc ( 668 ) ;
    82 : If chrcode = 0 Then printesc ( 670 )
         Else printesc ( 671 ) ;
    83 : If chrcode = 1 Then printesc ( 672 )
         Else If chrcode = 3 Then printesc ( 673 )
         Else printesc ( 674 ) ;
    70 : Case chrcode Of 
           0 : printesc ( 675 ) ;
           1 : printesc ( 676 ) ;
           2 : printesc ( 677 ) ;
           3 : printesc ( 678 ) ;
           others : printesc ( 679 )
         End ;
    108 : Case chrcode Of 
            0 : printesc ( 735 ) ;
            1 : printesc ( 736 ) ;
            2 : printesc ( 737 ) ;
            3 : printesc ( 738 ) ;
            4 : printesc ( 739 ) ;
            others : printesc ( 740 )
          End ;
    105 : Case chrcode Of 
            1 : printesc ( 757 ) ;
            2 : printesc ( 758 ) ;
            3 : printesc ( 759 ) ;
            4 : printesc ( 760 ) ;
            5 : printesc ( 761 ) ;
            6 : printesc ( 762 ) ;
            7 : printesc ( 763 ) ;
            8 : printesc ( 764 ) ;
            9 : printesc ( 765 ) ;
            10 : printesc ( 766 ) ;
            11 : printesc ( 767 ) ;
            12 : printesc ( 768 ) ;
            13 : printesc ( 769 ) ;
            14 : printesc ( 770 ) ;
            15 : printesc ( 771 ) ;
            16 : printesc ( 772 ) ;
            others : printesc ( 756 )
          End ;
    106 : If chrcode = 2 Then printesc ( 773 )
          Else If chrcode = 4 Then printesc ( 774 )
          Else printesc ( 775 ) ;
    4 : If chrcode = 256 Then printesc ( 897 )
        Else
          Begin
            print ( 901 ) ;
            print ( chrcode ) ;
          End ;
    5 : If chrcode = 257 Then printesc ( 898 )
        Else printesc ( 899 ) ;
    81 : Case chrcode Of 
           0 : printesc ( 969 ) ;
           1 : printesc ( 970 ) ;
           2 : printesc ( 971 ) ;
           3 : printesc ( 972 ) ;
           4 : printesc ( 973 ) ;
           5 : printesc ( 974 ) ;
           6 : printesc ( 975 ) ;
           others : printesc ( 976 )
         End ;
    14 : If chrcode = 1 Then printesc ( 1025 )
         Else printesc ( 1024 ) ;
    26 : Case chrcode Of 
           4 : printesc ( 1026 ) ;
           0 : printesc ( 1027 ) ;
           1 : printesc ( 1028 ) ;
           2 : printesc ( 1029 ) ;
           others : printesc ( 1030 )
         End ;
    27 : Case chrcode Of 
           4 : printesc ( 1031 ) ;
           0 : printesc ( 1032 ) ;
           1 : printesc ( 1033 ) ;
           2 : printesc ( 1034 ) ;
           others : printesc ( 1035 )
         End ;
    28 : printesc ( 336 ) ;
    29 : printesc ( 340 ) ;
    30 : printesc ( 342 ) ;
    21 : If chrcode = 1 Then printesc ( 1053 )
         Else printesc ( 1054 ) ;
    22 : If chrcode = 1 Then printesc ( 1055 )
         Else printesc ( 1056 ) ;
    20 : Case chrcode Of 
           0 : printesc ( 409 ) ;
           1 : printesc ( 1057 ) ;
           2 : printesc ( 1058 ) ;
           3 : printesc ( 964 ) ;
           4 : printesc ( 1059 ) ;
           5 : printesc ( 966 ) ;
           others : printesc ( 1060 )
         End ;
    31 : If chrcode = 100 Then printesc ( 1062 )
         Else If chrcode = 101 Then printesc ( 1063 )
         Else If chrcode = 102 Then printesc ( 1064 )
         Else printesc ( 1061 ) ;
    43 : If chrcode = 0 Then printesc ( 1080 )
         Else printesc ( 1079 ) ;
    25 : If chrcode = 10 Then printesc ( 1091 )
         Else If chrcode = 11 Then printesc ( 1090 )
         Else printesc ( 1089 ) ;
    23 : If chrcode = 1 Then printesc ( 1093 )
         Else printesc ( 1092 ) ;
    24 : If chrcode = 1 Then printesc ( 1095 )
         Else printesc ( 1094 ) ;
    47 : If chrcode = 1 Then printesc ( 45 )
         Else printesc ( 349 ) ;
    48 : If chrcode = 1 Then printesc ( 1127 )
         Else printesc ( 1126 ) ;
    50 : Case chrcode Of 
           16 : printesc ( 865 ) ;
           17 : printesc ( 866 ) ;
           18 : printesc ( 867 ) ;
           19 : printesc ( 868 ) ;
           20 : printesc ( 869 ) ;
           21 : printesc ( 870 ) ;
           22 : printesc ( 871 ) ;
           23 : printesc ( 872 ) ;
           26 : printesc ( 874 ) ;
           others : printesc ( 873 )
         End ;
    51 : If chrcode = 1 Then printesc ( 877 )
         Else If chrcode = 2 Then printesc ( 878 )
         Else printesc ( 1128 ) ;
    53 : printstyle ( chrcode ) ;
    52 : Case chrcode Of 
           1 : printesc ( 1147 ) ;
           2 : printesc ( 1148 ) ;
           3 : printesc ( 1149 ) ;
           4 : printesc ( 1150 ) ;
           5 : printesc ( 1151 ) ;
           others : printesc ( 1146 )
         End ;
    49 : If chrcode = 30 Then printesc ( 875 )
         Else printesc ( 876 ) ;
    93 : If chrcode = 1 Then printesc ( 1170 )
         Else If chrcode = 2 Then printesc ( 1171 )
         Else printesc ( 1172 ) ;
    97 : If chrcode = 0 Then printesc ( 1173 )
         Else If chrcode = 1 Then printesc ( 1174 )
         Else If chrcode = 2 Then printesc ( 1175 )
         Else printesc ( 1176 ) ;
    94 : If chrcode <> 0 Then printesc ( 1191 )
         Else printesc ( 1190 ) ;
    95 : Case chrcode Of 
           0 : printesc ( 1192 ) ;
           1 : printesc ( 1193 ) ;
           2 : printesc ( 1194 ) ;
           3 : printesc ( 1195 ) ;
           4 : printesc ( 1196 ) ;
           5 : printesc ( 1197 ) ;
           others : printesc ( 1198 )
         End ;
    68 :
         Begin
           printesc ( 513 ) ;
           printhex ( chrcode ) ;
         End ;
    69 :
         Begin
           printesc ( 524 ) ;
           printhex ( chrcode ) ;
         End ;
    85 : If chrcode = 3983 Then printesc ( 415 )
         Else If chrcode = 5007 Then printesc ( 419 )
         Else If chrcode = 4239 Then printesc ( 416 )
         Else If chrcode = 4495 Then printesc ( 417 )
         Else If chrcode = 4751 Then printesc ( 418 )
         Else printesc ( 477 ) ;
    86 : printsize ( chrcode - 3935 ) ;
    99 : If chrcode = 1 Then printesc ( 952 )
         Else printesc ( 940 ) ;
    78 : If chrcode = 0 Then printesc ( 1216 )
         Else printesc ( 1217 ) ;
    87 :
         Begin
           print ( 1225 ) ;
           slowprint ( fontname [ chrcode ] ) ;
           If fontsize [ chrcode ] <> fontdsize [ chrcode ] Then
             Begin
               print ( 741 ) ;
               printscaled ( fontsize [ chrcode ] ) ;
               print ( 397 ) ;
             End ;
         End ;
    100 : Case chrcode Of 
            0 : printesc ( 274 ) ;
            1 : printesc ( 275 ) ;
            2 : printesc ( 276 ) ;
            others : printesc ( 1226 )
          End ;
    60 : If chrcode = 0 Then printesc ( 1228 )
         Else printesc ( 1227 ) ;
    58 : If chrcode = 0 Then printesc ( 1229 )
         Else printesc ( 1230 ) ;
    57 : If chrcode = 4239 Then printesc ( 1236 )
         Else printesc ( 1237 ) ;
    19 : Case chrcode Of 
           1 : printesc ( 1239 ) ;
           2 : printesc ( 1240 ) ;
           3 : printesc ( 1241 ) ;
           others : printesc ( 1238 )
         End ;
    101 : print ( 1248 ) ;
    111 : print ( 1249 ) ;
    112 : printesc ( 1250 ) ;
    113 : printesc ( 1251 ) ;
    114 :
          Begin
            printesc ( 1170 ) ;
            printesc ( 1251 ) ;
          End ;
    115 : printesc ( 1252 ) ;
    59 : Case chrcode Of 
           0 : printesc ( 1284 ) ;
           1 : printesc ( 594 ) ;
           2 : printesc ( 1285 ) ;
           3 : printesc ( 1286 ) ;
           4 : printesc ( 1287 ) ;
           5 : printesc ( 1288 ) ;
           others : print ( 1289 )
         End ;
    others : print ( 567 )
  End ;
End ;
Function idlookup ( j , l : integer ) : halfword ;

Label 40 ;

Var h : integer ;
  d : integer ;
  p : halfword ;
  k : halfword ;
Begin
  h := buffer [ j ] ;
  For k := j + 1 To j + l - 1 Do
    Begin
      h := h + h + buffer [ k ] ;
      While h >= 1777 Do
        h := h - 1777 ;
    End ;
  p := h + 514 ;
  While true Do
    Begin
      If hash [ p ] . rh > 0 Then If ( strstart [ hash [ p ] . rh + 1 ] - strstart [ hash [ p ] . rh ] ) = l Then If streqbuf ( hash [ p ] . rh , j ) Then goto 40 ;
      If hash [ p ] . lh = 0 Then
        Begin
          If nonewcontrolsequence Then p := 2881
          Else
            Begin
              If hash [ p ] . rh > 0 Then
                Begin
                  Repeat
                    If ( hashused = 514 ) Then overflow ( 503 , 2100 ) ;
                    hashused := hashused - 1 ;
                  Until hash [ hashused ] . rh = 0 ;
                  hash [ p ] . lh := hashused ;
                  p := hashused ;
                End ;
              Begin
                If poolptr + l > poolsize Then overflow ( 257 , poolsize - initpoolptr ) ;
              End ;
              d := ( poolptr - strstart [ strptr ] ) ;
              While poolptr > strstart [ strptr ] Do
                Begin
                  poolptr := poolptr - 1 ;
                  strpool [ poolptr + l ] := strpool [ poolptr ] ;
                End ;
              For k := j To j + l - 1 Do
                Begin
                  strpool [ poolptr ] := buffer [ k ] ;
                  poolptr := poolptr + 1 ;
                End ;
              hash [ p ] . rh := makestring ;
              poolptr := poolptr + d ;
            End ;
          goto 40 ;
        End ;
      p := hash [ p ] . lh ;
    End ;
  40 : idlookup := p ;
End ;
Procedure primitive ( s : strnumber ; c : quarterword ; o : halfword ) ;

Var k : poolpointer ;
  j : smallnumber ;
  l : smallnumber ;
Begin
  If s < 256 Then curval := s + 257
  Else
    Begin
      k := strstart [ s ] ;
      l := strstart [ s + 1 ] - k ;
      For j := 0 To l - 1 Do
        buffer [ j ] := strpool [ k + j ] ;
      curval := idlookup ( 0 , l ) ;
      Begin
        strptr := strptr - 1 ;
        poolptr := strstart [ strptr ] ;
      End ;
      hash [ curval ] . rh := s ;
    End ;
  eqtb [ curval ] . hh . b1 := 1 ;
  eqtb [ curval ] . hh . b0 := c ;
  eqtb [ curval ] . hh . rh := o ;
End ;
Procedure newsavelevel ( c : groupcode ) ;
Begin
  If saveptr > maxsavestack Then
    Begin
      maxsavestack := saveptr ;
      If maxsavestack > savesize - 6 Then overflow ( 541 , savesize ) ;
    End ;
  savestack [ saveptr ] . hh . b0 := 3 ;
  savestack [ saveptr ] . hh . b1 := curgroup ;
  savestack [ saveptr ] . hh . rh := curboundary ;
  If curlevel = 255 Then overflow ( 542 , 255 ) ;
  curboundary := saveptr ;
  curlevel := curlevel + 1 ;
  saveptr := saveptr + 1 ;
  curgroup := c ;
End ;
Procedure eqdestroy ( w : memoryword ) ;

Var q : halfword ;
Begin
  Case w . hh . b0 Of 
    111 , 112 , 113 , 114 : deletetokenref ( w . hh . rh ) ;
    117 : deleteglueref ( w . hh . rh ) ;
    118 :
          Begin
            q := w . hh . rh ;
            If q <> 0 Then freenode ( q , mem [ q ] . hh . lh + mem [ q ] . hh . lh + 1 ) ;
          End ;
    119 : flushnodelist ( w . hh . rh ) ;
    others :
  End ;
End ;
Procedure eqsave ( p : halfword ; l : quarterword ) ;
Begin
  If saveptr > maxsavestack Then
    Begin
      maxsavestack := saveptr ;
      If maxsavestack > savesize - 6 Then overflow ( 541 , savesize ) ;
    End ;
  If l = 0 Then savestack [ saveptr ] . hh . b0 := 1
  Else
    Begin
      savestack [ saveptr ] := eqtb [ p ] ;
      saveptr := saveptr + 1 ;
      savestack [ saveptr ] . hh . b0 := 0 ;
    End ;
  savestack [ saveptr ] . hh . b1 := l ;
  savestack [ saveptr ] . hh . rh := p ;
  saveptr := saveptr + 1 ;
End ;
Procedure eqdefine ( p : halfword ; t : quarterword ; e : halfword ) ;
Begin
  If eqtb [ p ] . hh . b1 = curlevel Then eqdestroy ( eqtb [ p ] )
  Else If curlevel > 1 Then eqsave ( p , eqtb [ p ] . hh . b1 ) ;
  eqtb [ p ] . hh . b1 := curlevel ;
  eqtb [ p ] . hh . b0 := t ;
  eqtb [ p ] . hh . rh := e ;
End ;
Procedure eqworddefine ( p : halfword ; w : integer ) ;
Begin
  If xeqlevel [ p ] <> curlevel Then
    Begin
      eqsave ( p , xeqlevel [ p ] ) ;
      xeqlevel [ p ] := curlevel ;
    End ;
  eqtb [ p ] . int := w ;
End ;
Procedure geqdefine ( p : halfword ; t : quarterword ; e : halfword ) ;
Begin
  eqdestroy ( eqtb [ p ] ) ;
  eqtb [ p ] . hh . b1 := 1 ;
  eqtb [ p ] . hh . b0 := t ;
  eqtb [ p ] . hh . rh := e ;
End ;
Procedure geqworddefine ( p : halfword ; w : integer ) ;
Begin
  eqtb [ p ] . int := w ;
  xeqlevel [ p ] := 1 ;
End ;
Procedure saveforafter ( t : halfword ) ;
Begin
  If curlevel > 1 Then
    Begin
      If saveptr > maxsavestack Then
        Begin
          maxsavestack := saveptr ;
          If maxsavestack > savesize - 6 Then overflow ( 541 , savesize ) ;
        End ;
      savestack [ saveptr ] . hh . b0 := 2 ;
      savestack [ saveptr ] . hh . b1 := 0 ;
      savestack [ saveptr ] . hh . rh := t ;
      saveptr := saveptr + 1 ;
    End ;
End ;
Procedure backinput ;
forward ;
Procedure unsave ;

Label 30 ;

Var p : halfword ;
  l : quarterword ;
  t : halfword ;
Begin
  If curlevel > 1 Then
    Begin
      curlevel := curlevel - 1 ;
      While true Do
        Begin
          saveptr := saveptr - 1 ;
          If savestack [ saveptr ] . hh . b0 = 3 Then goto 30 ;
          p := savestack [ saveptr ] . hh . rh ;
          If savestack [ saveptr ] . hh . b0 = 2 Then
            Begin
              t := curtok ;
              curtok := p ;
              backinput ;
              curtok := t ;
            End
          Else
            Begin
              If savestack [ saveptr ] . hh . b0 = 0 Then
                Begin
                  l := savestack [ saveptr ] . hh . b1 ;
                  saveptr := saveptr - 1 ;
                End
              Else savestack [ saveptr ] := eqtb [ 2881 ] ;
              If p < 5263 Then If eqtb [ p ] . hh . b1 = 1 Then
                                 Begin
                                   eqdestroy ( savestack [ saveptr ] ) ;
                                 End
              Else
                Begin
                  eqdestroy ( eqtb [ p ] ) ;
                  eqtb [ p ] := savestack [ saveptr ] ;
                End
              Else If xeqlevel [ p ] <> 1 Then
                     Begin
                       eqtb [ p ] := savestack [ saveptr ] ;
                       xeqlevel [ p ] := l ;
                     End
              Else
                Begin
                End ;
            End ;
        End ;
      30 : curgroup := savestack [ saveptr ] . hh . b1 ;
      curboundary := savestack [ saveptr ] . hh . rh ;
    End
  Else confusion ( 543 ) ;
End ;
Procedure preparemag ;
Begin
  If ( magset > 0 ) And ( eqtb [ 5280 ] . int <> magset ) Then
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 547 ) ;
      End ;
      printint ( eqtb [ 5280 ] . int ) ;
      print ( 548 ) ;
      printnl ( 549 ) ;
      Begin
        helpptr := 2 ;
        helpline [ 1 ] := 550 ;
        helpline [ 0 ] := 551 ;
      End ;
      interror ( magset ) ;
      geqworddefine ( 5280 , magset ) ;
    End ;
  If ( eqtb [ 5280 ] . int <= 0 ) Or ( eqtb [ 5280 ] . int > 32768 ) Then
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 552 ) ;
      End ;
      Begin
        helpptr := 1 ;
        helpline [ 0 ] := 553 ;
      End ;
      interror ( eqtb [ 5280 ] . int ) ;
      geqworddefine ( 5280 , 1000 ) ;
    End ;
  magset := eqtb [ 5280 ] . int ;
End ;
Procedure tokenshow ( p : halfword ) ;
Begin
  If p <> 0 Then showtokenlist ( mem [ p ] . hh . rh , 0 , 10000000 ) ;
End ;
Procedure printmeaning ;
Begin
  printcmdchr ( curcmd , curchr ) ;
  If curcmd >= 111 Then
    Begin
      printchar ( 58 ) ;
      println ;
      tokenshow ( curchr ) ;
    End
  Else If curcmd = 110 Then
         Begin
           printchar ( 58 ) ;
           println ;
           tokenshow ( curmark [ curchr ] ) ;
         End ;
End ;
Procedure showcurcmdchr ;
Begin
  begindiagnostic ;
  printnl ( 123 ) ;
  If curlist . modefield <> shownmode Then
    Begin
      printmode ( curlist . modefield ) ;
      print ( 568 ) ;
      shownmode := curlist . modefield ;
    End ;
  printcmdchr ( curcmd , curchr ) ;
  printchar ( 125 ) ;
  enddiagnostic ( false ) ;
End ;
Procedure showcontext ;

Label 30 ;

Var oldsetting : 0 .. 21 ;
  nn : integer ;
  bottomline : boolean ;
  i : 0 .. bufsize ;
  j : 0 .. bufsize ;
  l : 0 .. halferrorline ;
  m : integer ;
  n : 0 .. errorline ;
  p : integer ;
  q : integer ;
Begin
  baseptr := inputptr ;
  inputstack [ baseptr ] := curinput ;
  nn := - 1 ;
  bottomline := false ;
  While true Do
    Begin
      curinput := inputstack [ baseptr ] ;
      If ( curinput . statefield <> 0 ) Then If ( curinput . namefield > 17 ) Or ( baseptr = 0 ) Then bottomline := true ;
      If ( baseptr = inputptr ) Or bottomline Or ( nn < eqtb [ 5317 ] . int ) Then
        Begin
          If ( baseptr = inputptr ) Or ( curinput . statefield <> 0 ) Or ( curinput . indexfield <> 3 ) Or ( curinput . locfield <> 0 ) Then
            Begin
              tally := 0 ;
              oldsetting := selector ;
              If curinput . statefield <> 0 Then
                Begin
                  If curinput . namefield <= 17 Then If ( curinput . namefield = 0 ) Then If baseptr = 0 Then printnl ( 574 )
                  Else printnl ( 575 )
                  Else
                    Begin
                      printnl ( 576 ) ;
                      If curinput . namefield = 17 Then printchar ( 42 )
                      Else printint ( curinput . namefield - 1 ) ;
                      printchar ( 62 ) ;
                    End
                  Else
                    Begin
                      printnl ( 577 ) ;
                      printint ( line ) ;
                    End ;
                  printchar ( 32 ) ;
                  Begin
                    l := tally ;
                    tally := 0 ;
                    selector := 20 ;
                    trickcount := 1000000 ;
                  End ;
                  If buffer [ curinput . limitfield ] = eqtb [ 5311 ] . int Then j := curinput . limitfield
                  Else j := curinput . limitfield + 1 ;
                  If j > 0 Then For i := curinput . startfield To j - 1 Do
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
                    0 : printnl ( 578 ) ;
                    1 , 2 : printnl ( 579 ) ;
                    3 : If curinput . locfield = 0 Then printnl ( 580 )
                        Else printnl ( 581 ) ;
                    4 : printnl ( 582 ) ;
                    5 :
                        Begin
                          println ;
                          printcs ( curinput . namefield ) ;
                        End ;
                    6 : printnl ( 583 ) ;
                    7 : printnl ( 584 ) ;
                    8 : printnl ( 585 ) ;
                    9 : printnl ( 586 ) ;
                    10 : printnl ( 587 ) ;
                    11 : printnl ( 588 ) ;
                    12 : printnl ( 589 ) ;
                    13 : printnl ( 590 ) ;
                    14 : printnl ( 591 ) ;
                    15 : printnl ( 592 ) ;
                    others : printnl ( 63 )
                  End ;
                  Begin
                    l := tally ;
                    tally := 0 ;
                    selector := 20 ;
                    trickcount := 1000000 ;
                  End ;
                  If curinput . indexfield < 5 Then showtokenlist ( curinput . startfield , curinput . locfield , 100000 )
                  Else showtokenlist ( mem [ curinput . startfield ] . hh . rh , curinput . locfield , 100000 ) ;
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
                  print ( 277 ) ;
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
              If m + n > errorline Then print ( 277 ) ;
              nn := nn + 1 ;
            End ;
        End
      Else If nn = eqtb [ 5317 ] . int Then
             Begin
               printnl ( 277 ) ;
               nn := nn + 1 ;
             End ;
      If bottomline Then goto 30 ;
      baseptr := baseptr - 1 ;
    End ;
  30 : curinput := inputstack [ inputptr ] ;
End ;
Procedure begintokenlist ( p : halfword ; t : quarterword ) ;
Begin
  Begin
    If inputptr > maxinstack Then
      Begin
        maxinstack := inputptr ;
        If inputptr = stacksize Then overflow ( 593 , stacksize ) ;
      End ;
    inputstack [ inputptr ] := curinput ;
    inputptr := inputptr + 1 ;
  End ;
  curinput . statefield := 0 ;
  curinput . startfield := p ;
  curinput . indexfield := t ;
  If t >= 5 Then
    Begin
      mem [ p ] . hh . lh := mem [ p ] . hh . lh + 1 ;
      If t = 5 Then curinput . limitfield := paramptr
      Else
        Begin
          curinput . locfield := mem [ p ] . hh . rh ;
          If eqtb [ 5293 ] . int > 1 Then
            Begin
              begindiagnostic ;
              printnl ( 338 ) ;
              Case t Of 
                14 : printesc ( 351 ) ;
                15 : printesc ( 594 ) ;
                others : printcmdchr ( 72 , t + 3407 )
              End ;
              print ( 556 ) ;
              tokenshow ( p ) ;
              enddiagnostic ( false ) ;
            End ;
        End ;
    End
  Else curinput . locfield := p ;
End ;
Procedure endtokenlist ;
Begin
  If curinput . indexfield >= 3 Then
    Begin
      If curinput . indexfield <= 4 Then flushlist ( curinput . startfield )
      Else
        Begin
          deletetokenref ( curinput . startfield ) ;
          If curinput . indexfield = 5 Then While paramptr > curinput . limitfield Do
                                              Begin
                                                paramptr := paramptr - 1 ;
                                                flushlist ( paramstack [ paramptr ] ) ;
                                              End ;
        End ;
    End
  Else If curinput . indexfield = 1 Then If alignstate > 500000 Then alignstate := 0
  Else fatalerror ( 595 ) ;
  Begin
    inputptr := inputptr - 1 ;
    curinput := inputstack [ inputptr ] ;
  End ;
  Begin
    If interrupt <> 0 Then pauseforinstructions ;
  End ;
End ;
Procedure backinput ;

Var p : halfword ;
Begin
  While ( curinput . statefield = 0 ) And ( curinput . locfield = 0 ) And ( curinput . indexfield <> 2 ) Do
    endtokenlist ;
  p := getavail ;
  mem [ p ] . hh . lh := curtok ;
  If curtok < 768 Then If curtok < 512 Then alignstate := alignstate - 1
  Else alignstate := alignstate + 1 ;
  Begin
    If inputptr > maxinstack Then
      Begin
        maxinstack := inputptr ;
        If inputptr = stacksize Then overflow ( 593 , stacksize ) ;
      End ;
    inputstack [ inputptr ] := curinput ;
    inputptr := inputptr + 1 ;
  End ;
  curinput . statefield := 0 ;
  curinput . startfield := p ;
  curinput . indexfield := 3 ;
  curinput . locfield := p ;
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
  curinput . indexfield := 4 ;
  OKtointerrupt := true ;
  error ;
End ;
Procedure beginfilereading ;
Begin
  If inopen = maxinopen Then overflow ( 596 , maxinopen ) ;
  If first = bufsize Then overflow ( 256 , bufsize ) ;
  inopen := inopen + 1 ;
  Begin
    If inputptr > maxinstack Then
      Begin
        maxinstack := inputptr ;
        If inputptr = stacksize Then overflow ( 593 , stacksize ) ;
      End ;
    inputstack [ inputptr ] := curinput ;
    inputptr := inputptr + 1 ;
  End ;
  curinput . indexfield := inopen ;
  linestack [ curinput . indexfield ] := line ;
  curinput . startfield := first ;
  curinput . statefield := 1 ;
  curinput . namefield := 0 ;
End ;
Procedure endfilereading ;
Begin
  first := curinput . startfield ;
  line := linestack [ curinput . indexfield ] ;
  If curinput . namefield > 17 Then aclose ( inputfile [ curinput . indexfield ] ) ;
  Begin
    inputptr := inputptr - 1 ;
    curinput := inputstack [ inputptr ] ;
  End ;
  inopen := inopen - 1 ;
End ;
Procedure clearforerrorprompt ;
Begin
  While ( curinput . statefield <> 0 ) And ( curinput . namefield = 0 ) And ( inputptr > 0 ) And ( curinput . locfield > curinput . limitfield ) Do
    endfilereading ;
  println ;
  breakin ( termin , true ) ;
End ;
Procedure checkoutervalidity ;

Var p : halfword ;
  q : halfword ;
Begin
  If scannerstatus <> 0 Then
    Begin
      deletionsallowed := false ;
      If curcs <> 0 Then
        Begin
          If ( curinput . statefield = 0 ) Or ( curinput . namefield < 1 ) Or ( curinput . namefield > 17 ) Then
            Begin
              p := getavail ;
              mem [ p ] . hh . lh := 4095 + curcs ;
              begintokenlist ( p , 3 ) ;
            End ;
          curcmd := 10 ;
          curchr := 32 ;
        End ;
      If scannerstatus > 1 Then
        Begin
          runaway ;
          If curcs = 0 Then
            Begin
              If interaction = 3 Then ;
              printnl ( 262 ) ;
              print ( 604 ) ;
            End
          Else
            Begin
              curcs := 0 ;
              Begin
                If interaction = 3 Then ;
                printnl ( 262 ) ;
                print ( 605 ) ;
              End ;
            End ;
          print ( 606 ) ;
          p := getavail ;
          Case scannerstatus Of 
            2 :
                Begin
                  print ( 570 ) ;
                  mem [ p ] . hh . lh := 637 ;
                End ;
            3 :
                Begin
                  print ( 612 ) ;
                  mem [ p ] . hh . lh := partoken ;
                  longstate := 113 ;
                End ;
            4 :
                Begin
                  print ( 572 ) ;
                  mem [ p ] . hh . lh := 637 ;
                  q := p ;
                  p := getavail ;
                  mem [ p ] . hh . rh := q ;
                  mem [ p ] . hh . lh := 6710 ;
                  alignstate := - 1000000 ;
                End ;
            5 :
                Begin
                  print ( 573 ) ;
                  mem [ p ] . hh . lh := 637 ;
                End ;
          End ;
          begintokenlist ( p , 4 ) ;
          print ( 607 ) ;
          sprintcs ( warningindex ) ;
          Begin
            helpptr := 4 ;
            helpline [ 3 ] := 608 ;
            helpline [ 2 ] := 609 ;
            helpline [ 1 ] := 610 ;
            helpline [ 0 ] := 611 ;
          End ;
          error ;
        End
      Else
        Begin
          Begin
            If interaction = 3 Then ;
            printnl ( 262 ) ;
            print ( 598 ) ;
          End ;
          printcmdchr ( 105 , curif ) ;
          print ( 599 ) ;
          printint ( skipline ) ;
          Begin
            helpptr := 3 ;
            helpline [ 2 ] := 600 ;
            helpline [ 1 ] := 601 ;
            helpline [ 0 ] := 602 ;
          End ;
          If curcs <> 0 Then curcs := 0
          Else helpline [ 2 ] := 603 ;
          curtok := 6713 ;
          inserror ;
        End ;
      deletionsallowed := true ;
    End ;
End ;
Procedure firmuptheline ;
forward ;
Procedure getnext ;

Label 20 , 25 , 21 , 26 , 40 , 10 ;

Var k : 0 .. bufsize ;
  t : halfword ;
  cat : 0 .. 15 ;
  c , cc : ASCIIcode ;
  d : 2 .. 3 ;
Begin
  20 : curcs := 0 ;
  If curinput . statefield <> 0 Then
    Begin
      25 : If curinput . locfield <= curinput . limitfield Then
             Begin
               curchr := buffer [ curinput . locfield ] ;
               curinput . locfield := curinput . locfield + 1 ;
               21 : curcmd := eqtb [ 3983 + curchr ] . hh . rh ;
               Case curinput . statefield + curcmd Of 
                 10 , 26 , 42 , 27 , 43 : goto 25 ;
                 1 , 17 , 33 :
                               Begin
                                 If curinput . locfield > curinput . limitfield Then curcs := 513
                                 Else
                                   Begin
                                     26 : k := curinput . locfield ;
                                     curchr := buffer [ k ] ;
                                     cat := eqtb [ 3983 + curchr ] . hh . rh ;
                                     k := k + 1 ;
                                     If cat = 11 Then curinput . statefield := 17
                                     Else If cat = 10 Then curinput . statefield := 17
                                     Else curinput . statefield := 1 ;
                                     If ( cat = 11 ) And ( k <= curinput . limitfield ) Then
                                       Begin
                                         Repeat
                                           curchr := buffer [ k ] ;
                                           cat := eqtb [ 3983 + curchr ] . hh . rh ;
                                           k := k + 1 ;
                                         Until ( cat <> 11 ) Or ( k > curinput . limitfield ) ;
                                         Begin
                                           If buffer [ k ] = curchr Then If cat = 7 Then If k < curinput . limitfield Then
                                                                                           Begin
                                                                                             c := buffer [ k + 1 ] ;
                                                                                             If c < 128 Then
                                                                                               Begin
                                                                                                 d := 2 ;
                                                                                                 If ( ( ( c >= 48 ) And ( c <= 57 ) ) Or ( ( c >= 97 ) And ( c <= 102 ) ) ) Then If k + 2 <= curinput . limitfield Then
                                                                                                                                                                                   Begin
                                                                                                                                                                                     cc := buffer [ k + 2 ] ;
                                                                                                                                                                                     If ( ( ( cc >= 48 ) And ( cc <= 57 ) ) Or ( ( cc >= 97 ) And ( cc <= 102 ) ) ) Then d := d + 1 ;
                                                                                                                                                                                   End ;
                                                                                                 If d > 2 Then
                                                                                                   Begin
                                                                                                     If c <= 57 Then curchr := c - 48
                                                                                                     Else curchr := c - 87 ;
                                                                                                     If cc <= 57 Then curchr := 16 * curchr + cc - 48
                                                                                                     Else curchr := 16 * curchr + cc - 87 ;
                                                                                                     buffer [ k - 1 ] := curchr ;
                                                                                                   End
                                                                                                 Else If c < 64 Then buffer [ k - 1 ] := c + 64
                                                                                                 Else buffer [ k - 1 ] := c - 64 ;
                                                                                                 curinput . limitfield := curinput . limitfield - d ;
                                                                                                 first := first - d ;
                                                                                                 While k <= curinput . limitfield Do
                                                                                                   Begin
                                                                                                     buffer [ k ] := buffer [ k + d ] ;
                                                                                                     k := k + 1 ;
                                                                                                   End ;
                                                                                                 goto 26 ;
                                                                                               End ;
                                                                                           End ;
                                         End ;
                                         If cat <> 11 Then k := k - 1 ;
                                         If k > curinput . locfield + 1 Then
                                           Begin
                                             curcs := idlookup ( curinput . locfield , k - curinput . locfield ) ;
                                             curinput . locfield := k ;
                                             goto 40 ;
                                           End ;
                                       End
                                     Else
                                       Begin
                                         If buffer [ k ] = curchr Then If cat = 7 Then If k < curinput . limitfield Then
                                                                                         Begin
                                                                                           c := buffer [ k + 1 ] ;
                                                                                           If c < 128 Then
                                                                                             Begin
                                                                                               d := 2 ;
                                                                                               If ( ( ( c >= 48 ) And ( c <= 57 ) ) Or ( ( c >= 97 ) And ( c <= 102 ) ) ) Then If k + 2 <= curinput . limitfield Then
                                                                                                                                                                                 Begin
                                                                                                                                                                                   cc := buffer [ k + 2 ] ;
                                                                                                                                                                                   If ( ( ( cc >= 48 ) And ( cc <= 57 ) ) Or ( ( cc >= 97 ) And ( cc <= 102 ) ) ) Then d := d + 1 ;
                                                                                                                                                                                 End ;
                                                                                               If d > 2 Then
                                                                                                 Begin
                                                                                                   If c <= 57 Then curchr := c - 48
                                                                                                   Else curchr := c - 87 ;
                                                                                                   If cc <= 57 Then curchr := 16 * curchr + cc - 48
                                                                                                   Else curchr := 16 * curchr + cc - 87 ;
                                                                                                   buffer [ k - 1 ] := curchr ;
                                                                                                 End
                                                                                               Else If c < 64 Then buffer [ k - 1 ] := c + 64
                                                                                               Else buffer [ k - 1 ] := c - 64 ;
                                                                                               curinput . limitfield := curinput . limitfield - d ;
                                                                                               first := first - d ;
                                                                                               While k <= curinput . limitfield Do
                                                                                                 Begin
                                                                                                   buffer [ k ] := buffer [ k + d ] ;
                                                                                                   k := k + 1 ;
                                                                                                 End ;
                                                                                               goto 26 ;
                                                                                             End ;
                                                                                         End ;
                                       End ;
                                     curcs := 257 + buffer [ curinput . locfield ] ;
                                     curinput . locfield := curinput . locfield + 1 ;
                                   End ;
                                 40 : curcmd := eqtb [ curcs ] . hh . b0 ;
                                 curchr := eqtb [ curcs ] . hh . rh ;
                                 If curcmd >= 113 Then checkoutervalidity ;
                               End ;
                 14 , 30 , 46 :
                                Begin
                                  curcs := curchr + 1 ;
                                  curcmd := eqtb [ curcs ] . hh . b0 ;
                                  curchr := eqtb [ curcs ] . hh . rh ;
                                  curinput . statefield := 1 ;
                                  If curcmd >= 113 Then checkoutervalidity ;
                                End ;
                 8 , 24 , 40 :
                               Begin
                                 If curchr = buffer [ curinput . locfield ] Then If curinput . locfield < curinput . limitfield Then
                                                                                   Begin
                                                                                     c := buffer [ curinput . locfield + 1 ] ;
                                                                                     If c < 128 Then
                                                                                       Begin
                                                                                         curinput . locfield := curinput . locfield + 2 ;
                                                                                         If ( ( ( c >= 48 ) And ( c <= 57 ) ) Or ( ( c >= 97 ) And ( c <= 102 ) ) ) Then If curinput . locfield <= curinput . limitfield Then
                                                                                                                                                                           Begin
                                                                                                                                                                             cc := buffer [ curinput . locfield ] ;
                                                                                                                                                                             If ( ( ( cc >= 48 ) And ( cc <= 57 ) ) Or ( ( cc >= 97 ) And ( cc <= 102 ) ) ) Then
                                                                                                                                                                               Begin
                                                                                                                                                                                 curinput . locfield := curinput . locfield + 1 ;
                                                                                                                                                                                 If c <= 57 Then curchr := c - 48
                                                                                                                                                                                 Else curchr := c - 87 ;
                                                                                                                                                                                 If cc <= 57 Then curchr := 16 * curchr + cc - 48
                                                                                                                                                                                 Else curchr := 16 * curchr + cc - 87 ;
                                                                                                                                                                                 goto 21 ;
                                                                                                                                                                               End ;
                                                                                                                                                                           End ;
                                                                                         If c < 64 Then curchr := c + 64
                                                                                         Else curchr := c - 64 ;
                                                                                         goto 21 ;
                                                                                       End ;
                                                                                   End ;
                                 curinput . statefield := 1 ;
                               End ;
                 16 , 32 , 48 :
                                Begin
                                  Begin
                                    If interaction = 3 Then ;
                                    printnl ( 262 ) ;
                                    print ( 613 ) ;
                                  End ;
                                  Begin
                                    helpptr := 2 ;
                                    helpline [ 1 ] := 614 ;
                                    helpline [ 0 ] := 615 ;
                                  End ;
                                  deletionsallowed := false ;
                                  error ;
                                  deletionsallowed := true ;
                                  goto 20 ;
                                End ;
                 11 :
                      Begin
                        curinput . statefield := 17 ;
                        curchr := 32 ;
                      End ;
                 6 :
                     Begin
                       curinput . locfield := curinput . limitfield + 1 ;
                       curcmd := 10 ;
                       curchr := 32 ;
                     End ;
                 22 , 15 , 31 , 47 :
                                     Begin
                                       curinput . locfield := curinput . limitfield + 1 ;
                                       goto 25 ;
                                     End ;
                 38 :
                      Begin
                        curinput . locfield := curinput . limitfield + 1 ;
                        curcs := parloc ;
                        curcmd := eqtb [ curcs ] . hh . b0 ;
                        curchr := eqtb [ curcs ] . hh . rh ;
                        If curcmd >= 113 Then checkoutervalidity ;
                      End ;
                 2 : alignstate := alignstate + 1 ;
                 18 , 34 :
                           Begin
                             curinput . statefield := 1 ;
                             alignstate := alignstate + 1 ;
                           End ;
                 3 : alignstate := alignstate - 1 ;
                 19 , 35 :
                           Begin
                             curinput . statefield := 1 ;
                             alignstate := alignstate - 1 ;
                           End ;
                 20 , 21 , 23 , 25 , 28 , 29 , 36 , 37 , 39 , 41 , 44 , 45 : curinput . statefield := 1 ;
                 others :
               End ;
             End
           Else
             Begin
               curinput . statefield := 33 ;
               If curinput . namefield > 17 Then
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
                       checkoutervalidity ;
                       goto 20 ;
                     End ;
                   If ( eqtb [ 5311 ] . int < 0 ) Or ( eqtb [ 5311 ] . int > 255 ) Then curinput . limitfield := curinput . limitfield - 1
                   Else buffer [ curinput . limitfield ] := eqtb [ 5311 ] . int ;
                   first := curinput . limitfield + 1 ;
                   curinput . locfield := curinput . startfield ;
                 End
               Else
                 Begin
                   If Not ( curinput . namefield = 0 ) Then
                     Begin
                       curcmd := 0 ;
                       curchr := 0 ;
                       goto 10 ;
                     End ;
                   If inputptr > 0 Then
                     Begin
                       endfilereading ;
                       goto 20 ;
                     End ;
                   If selector < 18 Then openlogfile ;
                   If interaction > 1 Then
                     Begin
                       If ( eqtb [ 5311 ] . int < 0 ) Or ( eqtb [ 5311 ] . int > 255 ) Then curinput . limitfield := curinput . limitfield + 1 ;
                       If curinput . limitfield = curinput . startfield Then printnl ( 616 ) ;
                       println ;
                       first := curinput . startfield ;
                       Begin ;
                         print ( 42 ) ;
                         terminput ;
                       End ;
                       curinput . limitfield := last ;
                       If ( eqtb [ 5311 ] . int < 0 ) Or ( eqtb [ 5311 ] . int > 255 ) Then curinput . limitfield := curinput . limitfield - 1
                       Else buffer [ curinput . limitfield ] := eqtb [ 5311 ] . int ;
                       first := curinput . limitfield + 1 ;
                       curinput . locfield := curinput . startfield ;
                     End
                   Else fatalerror ( 617 ) ;
                 End ;
               Begin
                 If interrupt <> 0 Then pauseforinstructions ;
               End ;
               goto 25 ;
             End ;
    End
  Else If curinput . locfield <> 0 Then
         Begin
           t := mem [ curinput . locfield ] . hh . lh ;
           curinput . locfield := mem [ curinput . locfield ] . hh . rh ;
           If t >= 4095 Then
             Begin
               curcs := t - 4095 ;
               curcmd := eqtb [ curcs ] . hh . b0 ;
               curchr := eqtb [ curcs ] . hh . rh ;
               If curcmd >= 113 Then If curcmd = 116 Then
                                       Begin
                                         curcs := mem [ curinput . locfield ] . hh . lh - 4095 ;
                                         curinput . locfield := 0 ;
                                         curcmd := eqtb [ curcs ] . hh . b0 ;
                                         curchr := eqtb [ curcs ] . hh . rh ;
                                         If curcmd > 100 Then
                                           Begin
                                             curcmd := 0 ;
                                             curchr := 257 ;
                                           End ;
                                       End
               Else checkoutervalidity ;
             End
           Else
             Begin
               curcmd := t Div 256 ;
               curchr := t Mod 256 ;
               Case curcmd Of 
                 1 : alignstate := alignstate + 1 ;
                 2 : alignstate := alignstate - 1 ;
                 5 :
                     Begin
                       begintokenlist ( paramstack [ curinput . limitfield + curchr - 1 ] , 0 ) ;
                       goto 20 ;
                     End ;
                 others :
               End ;
             End ;
         End
  Else
    Begin
      endtokenlist ;
      goto 20 ;
    End ;
  If curcmd <= 5 Then If curcmd >= 4 Then If alignstate = 0 Then
                                            Begin
                                              If ( scannerstatus = 4 ) Or ( curalign = 0 ) Then fatalerror ( 595 ) ;
                                              curcmd := mem [ curalign + 5 ] . hh . lh ;
                                              mem [ curalign + 5 ] . hh . lh := curchr ;
                                              If curcmd = 63 Then begintokenlist ( 29990 , 2 )
                                              Else begintokenlist ( mem [ curalign + 2 ] . int , 2 ) ;
                                              alignstate := 1000000 ;
                                              goto 20 ;
                                            End ;
  10 :
End ;
Procedure firmuptheline ;

Var k : 0 .. bufsize ;
Begin
  curinput . limitfield := last ;
  If eqtb [ 5291 ] . int > 0 Then If interaction > 1 Then
                                    Begin ;
                                      println ;
                                      If curinput . startfield < curinput . limitfield Then For k := curinput . startfield To curinput . limitfield - 1 Do
                                                                                              print ( buffer [ k ] ) ;
                                      first := curinput . limitfield ;
                                      Begin ;
                                        print ( 618 ) ;
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
Procedure gettoken ;
Begin
  nonewcontrolsequence := false ;
  getnext ;
  nonewcontrolsequence := true ;
  If curcs = 0 Then curtok := ( curcmd * 256 ) + curchr
  Else curtok := 4095 + curcs ;
End ;
Procedure macrocall ;

Label 10 , 22 , 30 , 31 , 40 ;

Var r : halfword ;
  p : halfword ;
  q : halfword ;
  s : halfword ;
  t : halfword ;
  u , v : halfword ;
  rbraceptr : halfword ;
  n : smallnumber ;
  unbalance : halfword ;
  m : halfword ;
  refcount : halfword ;
  savescannerstatus : smallnumber ;
  savewarningindex : halfword ;
  matchchr : ASCIIcode ;
Begin
  savescannerstatus := scannerstatus ;
  savewarningindex := warningindex ;
  warningindex := curcs ;
  refcount := curchr ;
  r := mem [ refcount ] . hh . rh ;
  n := 0 ;
  If eqtb [ 5293 ] . int > 0 Then
    Begin
      begindiagnostic ;
      println ;
      printcs ( warningindex ) ;
      tokenshow ( refcount ) ;
      enddiagnostic ( false ) ;
    End ;
  If mem [ r ] . hh . lh <> 3584 Then
    Begin
      scannerstatus := 3 ;
      unbalance := 0 ;
      longstate := eqtb [ curcs ] . hh . b0 ;
      If longstate >= 113 Then longstate := longstate - 2 ;
      Repeat
        mem [ 29997 ] . hh . rh := 0 ;
        If ( mem [ r ] . hh . lh > 3583 ) Or ( mem [ r ] . hh . lh < 3328 ) Then s := 0
        Else
          Begin
            matchchr := mem [ r ] . hh . lh - 3328 ;
            s := mem [ r ] . hh . rh ;
            r := s ;
            p := 29997 ;
            m := 0 ;
          End ;
        22 : gettoken ;
        If curtok = mem [ r ] . hh . lh Then
          Begin
            r := mem [ r ] . hh . rh ;
            If ( mem [ r ] . hh . lh >= 3328 ) And ( mem [ r ] . hh . lh <= 3584 ) Then
              Begin
                If curtok < 512 Then alignstate := alignstate - 1 ;
                goto 40 ;
              End
            Else goto 22 ;
          End ;
        If s <> r Then If s = 0 Then
                         Begin
                           Begin
                             If interaction = 3 Then ;
                             printnl ( 262 ) ;
                             print ( 650 ) ;
                           End ;
                           sprintcs ( warningindex ) ;
                           print ( 651 ) ;
                           Begin
                             helpptr := 4 ;
                             helpline [ 3 ] := 652 ;
                             helpline [ 2 ] := 653 ;
                             helpline [ 1 ] := 654 ;
                             helpline [ 0 ] := 655 ;
                           End ;
                           error ;
                           goto 10 ;
                         End
        Else
          Begin
            t := s ;
            Repeat
              Begin
                q := getavail ;
                mem [ p ] . hh . rh := q ;
                mem [ q ] . hh . lh := mem [ t ] . hh . lh ;
                p := q ;
              End ;
              m := m + 1 ;
              u := mem [ t ] . hh . rh ;
              v := s ;
              While true Do
                Begin
                  If u = r Then If curtok <> mem [ v ] . hh . lh Then goto 30
                  Else
                    Begin
                      r := mem [ v ] . hh . rh ;
                      goto 22 ;
                    End ;
                  If mem [ u ] . hh . lh <> mem [ v ] . hh . lh Then goto 30 ;
                  u := mem [ u ] . hh . rh ;
                  v := mem [ v ] . hh . rh ;
                End ;
              30 : t := mem [ t ] . hh . rh ;
            Until t = r ;
            r := s ;
          End ;
        If curtok = partoken Then If longstate <> 112 Then
                                    Begin
                                      If longstate = 111 Then
                                        Begin
                                          runaway ;
                                          Begin
                                            If interaction = 3 Then ;
                                            printnl ( 262 ) ;
                                            print ( 645 ) ;
                                          End ;
                                          sprintcs ( warningindex ) ;
                                          print ( 646 ) ;
                                          Begin
                                            helpptr := 3 ;
                                            helpline [ 2 ] := 647 ;
                                            helpline [ 1 ] := 648 ;
                                            helpline [ 0 ] := 649 ;
                                          End ;
                                          backerror ;
                                        End ;
                                      pstack [ n ] := mem [ 29997 ] . hh . rh ;
                                      alignstate := alignstate - unbalance ;
                                      For m := 0 To n Do
                                        flushlist ( pstack [ m ] ) ;
                                      goto 10 ;
                                    End ;
        If curtok < 768 Then If curtok < 512 Then
                               Begin
                                 unbalance := 1 ;
                                 While true Do
                                   Begin
                                     Begin
                                       Begin
                                         q := avail ;
                                         If q = 0 Then q := getavail
                                         Else
                                           Begin
                                             avail := mem [ q ] . hh . rh ;
                                             mem [ q ] . hh . rh := 0 ;
                                           End ;
                                       End ;
                                       mem [ p ] . hh . rh := q ;
                                       mem [ q ] . hh . lh := curtok ;
                                       p := q ;
                                     End ;
                                     gettoken ;
                                     If curtok = partoken Then If longstate <> 112 Then
                                                                 Begin
                                                                   If longstate = 111 Then
                                                                     Begin
                                                                       runaway ;
                                                                       Begin
                                                                         If interaction = 3 Then ;
                                                                         printnl ( 262 ) ;
                                                                         print ( 645 ) ;
                                                                       End ;
                                                                       sprintcs ( warningindex ) ;
                                                                       print ( 646 ) ;
                                                                       Begin
                                                                         helpptr := 3 ;
                                                                         helpline [ 2 ] := 647 ;
                                                                         helpline [ 1 ] := 648 ;
                                                                         helpline [ 0 ] := 649 ;
                                                                       End ;
                                                                       backerror ;
                                                                     End ;
                                                                   pstack [ n ] := mem [ 29997 ] . hh . rh ;
                                                                   alignstate := alignstate - unbalance ;
                                                                   For m := 0 To n Do
                                                                     flushlist ( pstack [ m ] ) ;
                                                                   goto 10 ;
                                                                 End ;
                                     If curtok < 768 Then If curtok < 512 Then unbalance := unbalance + 1
                                     Else
                                       Begin
                                         unbalance := unbalance - 1 ;
                                         If unbalance = 0 Then goto 31 ;
                                       End ;
                                   End ;
                                 31 : rbraceptr := p ;
                                 Begin
                                   q := getavail ;
                                   mem [ p ] . hh . rh := q ;
                                   mem [ q ] . hh . lh := curtok ;
                                   p := q ;
                                 End ;
                               End
        Else
          Begin
            backinput ;
            Begin
              If interaction = 3 Then ;
              printnl ( 262 ) ;
              print ( 637 ) ;
            End ;
            sprintcs ( warningindex ) ;
            print ( 638 ) ;
            Begin
              helpptr := 6 ;
              helpline [ 5 ] := 639 ;
              helpline [ 4 ] := 640 ;
              helpline [ 3 ] := 641 ;
              helpline [ 2 ] := 642 ;
              helpline [ 1 ] := 643 ;
              helpline [ 0 ] := 644 ;
            End ;
            alignstate := alignstate + 1 ;
            longstate := 111 ;
            curtok := partoken ;
            inserror ;
            goto 22 ;
          End
        Else
          Begin
            If curtok = 2592 Then If mem [ r ] . hh . lh <= 3584 Then If mem [ r ] . hh . lh >= 3328 Then goto 22 ;
            Begin
              q := getavail ;
              mem [ p ] . hh . rh := q ;
              mem [ q ] . hh . lh := curtok ;
              p := q ;
            End ;
          End ;
        m := m + 1 ;
        If mem [ r ] . hh . lh > 3584 Then goto 22 ;
        If mem [ r ] . hh . lh < 3328 Then goto 22 ;
        40 : If s <> 0 Then
               Begin
                 If ( m = 1 ) And ( mem [ p ] . hh . lh < 768 ) And ( p <> 29997 ) Then
                   Begin
                     mem [ rbraceptr ] . hh . rh := 0 ;
                     Begin
                       mem [ p ] . hh . rh := avail ;
                       avail := p ;
                     End ;
                     p := mem [ 29997 ] . hh . rh ;
                     pstack [ n ] := mem [ p ] . hh . rh ;
                     Begin
                       mem [ p ] . hh . rh := avail ;
                       avail := p ;
                     End ;
                   End
                 Else pstack [ n ] := mem [ 29997 ] . hh . rh ;
                 n := n + 1 ;
                 If eqtb [ 5293 ] . int > 0 Then
                   Begin
                     begindiagnostic ;
                     printnl ( matchchr ) ;
                     printint ( n ) ;
                     print ( 656 ) ;
                     showtokenlist ( pstack [ n - 1 ] , 0 , 1000 ) ;
                     enddiagnostic ( false ) ;
                   End ;
               End ;
      Until mem [ r ] . hh . lh = 3584 ;
    End ;
  While ( curinput . statefield = 0 ) And ( curinput . locfield = 0 ) And ( curinput . indexfield <> 2 ) Do
    endtokenlist ;
  begintokenlist ( refcount , 5 ) ;
  curinput . namefield := warningindex ;
  curinput . locfield := mem [ r ] . hh . rh ;
  If n > 0 Then
    Begin
      If paramptr + n > maxparamstack Then
        Begin
          maxparamstack := paramptr + n ;
          If maxparamstack > paramsize Then overflow ( 636 , paramsize ) ;
        End ;
      For m := 0 To n - 1 Do
        paramstack [ paramptr + m ] := pstack [ m ] ;
      paramptr := paramptr + n ;
    End ;
  10 : scannerstatus := savescannerstatus ;
  warningindex := savewarningindex ;
End ;
Procedure insertrelax ;
Begin
  curtok := 4095 + curcs ;
  backinput ;
  curtok := 6716 ;
  backinput ;
  curinput . indexfield := 4 ;
End ;
Procedure passtext ;
forward ;
Procedure startinput ;
forward ;
Procedure conditional ;
forward ;
Procedure getxtoken ;
forward ;
Procedure convtoks ;
forward ;
Procedure insthetoks ;
forward ;
Procedure expand ;

Var t : halfword ;
  p , q , r : halfword ;
  j : 0 .. bufsize ;
  cvbackup : integer ;
  cvlbackup , radixbackup , cobackup : smallnumber ;
  backupbackup : halfword ;
  savescannerstatus : smallnumber ;
Begin
  cvbackup := curval ;
  cvlbackup := curvallevel ;
  radixbackup := radix ;
  cobackup := curorder ;
  backupbackup := mem [ 29987 ] . hh . rh ;
  If curcmd < 111 Then
    Begin
      If eqtb [ 5299 ] . int > 1 Then showcurcmdchr ;
      Case curcmd Of 
        110 :
              Begin
                If curmark [ curchr ] <> 0 Then begintokenlist ( curmark [ curchr ] , 14 ) ;
              End ;
        102 :
              Begin
                gettoken ;
                t := curtok ;
                gettoken ;
                If curcmd > 100 Then expand
                Else backinput ;
                curtok := t ;
                backinput ;
              End ;
        103 :
              Begin
                savescannerstatus := scannerstatus ;
                scannerstatus := 0 ;
                gettoken ;
                scannerstatus := savescannerstatus ;
                t := curtok ;
                backinput ;
                If t >= 4095 Then
                  Begin
                    p := getavail ;
                    mem [ p ] . hh . lh := 6718 ;
                    mem [ p ] . hh . rh := curinput . locfield ;
                    curinput . startfield := p ;
                    curinput . locfield := p ;
                  End ;
              End ;
        107 :
              Begin
                r := getavail ;
                p := r ;
                Repeat
                  getxtoken ;
                  If curcs = 0 Then
                    Begin
                      q := getavail ;
                      mem [ p ] . hh . rh := q ;
                      mem [ q ] . hh . lh := curtok ;
                      p := q ;
                    End ;
                Until curcs <> 0 ;
                If curcmd <> 67 Then
                  Begin
                    Begin
                      If interaction = 3 Then ;
                      printnl ( 262 ) ;
                      print ( 625 ) ;
                    End ;
                    printesc ( 505 ) ;
                    print ( 626 ) ;
                    Begin
                      helpptr := 2 ;
                      helpline [ 1 ] := 627 ;
                      helpline [ 0 ] := 628 ;
                    End ;
                    backerror ;
                  End ;
                j := first ;
                p := mem [ r ] . hh . rh ;
                While p <> 0 Do
                  Begin
                    If j >= maxbufstack Then
                      Begin
                        maxbufstack := j + 1 ;
                        If maxbufstack = bufsize Then overflow ( 256 , bufsize ) ;
                      End ;
                    buffer [ j ] := mem [ p ] . hh . lh Mod 256 ;
                    j := j + 1 ;
                    p := mem [ p ] . hh . rh ;
                  End ;
                If j > first + 1 Then
                  Begin
                    nonewcontrolsequence := false ;
                    curcs := idlookup ( first , j - first ) ;
                    nonewcontrolsequence := true ;
                  End
                Else If j = first Then curcs := 513
                Else curcs := 257 + buffer [ first ] ;
                flushlist ( r ) ;
                If eqtb [ curcs ] . hh . b0 = 101 Then
                  Begin
                    eqdefine ( curcs , 0 , 256 ) ;
                  End ;
                curtok := curcs + 4095 ;
                backinput ;
              End ;
        108 : convtoks ;
        109 : insthetoks ;
        105 : conditional ;
        106 : If curchr > iflimit Then If iflimit = 1 Then insertrelax
              Else
                Begin
                  Begin
                    If interaction = 3 Then ;
                    printnl ( 262 ) ;
                    print ( 776 ) ;
                  End ;
                  printcmdchr ( 106 , curchr ) ;
                  Begin
                    helpptr := 1 ;
                    helpline [ 0 ] := 777 ;
                  End ;
                  error ;
                End
              Else
                Begin
                  While curchr <> 2 Do
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
        104 : If curchr > 0 Then forceeof := true
              Else If nameinprogress Then insertrelax
              Else startinput ;
        others :
                 Begin
                   Begin
                     If interaction = 3 Then ;
                     printnl ( 262 ) ;
                     print ( 619 ) ;
                   End ;
                   Begin
                     helpptr := 5 ;
                     helpline [ 4 ] := 620 ;
                     helpline [ 3 ] := 621 ;
                     helpline [ 2 ] := 622 ;
                     helpline [ 1 ] := 623 ;
                     helpline [ 0 ] := 624 ;
                   End ;
                   error ;
                 End
      End ;
    End
  Else If curcmd < 115 Then macrocall
  Else
    Begin
      curtok := 6715 ;
      backinput ;
    End ;
  curval := cvbackup ;
  curvallevel := cvlbackup ;
  radix := radixbackup ;
  curorder := cobackup ;
  mem [ 29987 ] . hh . rh := backupbackup ;
End ;
Procedure getxtoken ;

Label 20 , 30 ;
Begin
  20 : getnext ;
  If curcmd <= 100 Then goto 30 ;
  If curcmd >= 111 Then If curcmd < 115 Then macrocall
  Else
    Begin
      curcs := 2620 ;
      curcmd := 9 ;
      goto 30 ;
    End
  Else expand ;
  goto 20 ;
  30 : If curcs = 0 Then curtok := ( curcmd * 256 ) + curchr
       Else curtok := 4095 + curcs ;
End ;
Procedure xtoken ;
Begin
  While curcmd > 100 Do
    Begin
      expand ;
      getnext ;
    End ;
  If curcs = 0 Then curtok := ( curcmd * 256 ) + curchr
  Else curtok := 4095 + curcs ;
End ;
Procedure scanleftbrace ;
Begin
  Repeat
    getxtoken ;
  Until ( curcmd <> 10 ) And ( curcmd <> 0 ) ;
  If curcmd <> 1 Then
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 657 ) ;
      End ;
      Begin
        helpptr := 4 ;
        helpline [ 3 ] := 658 ;
        helpline [ 2 ] := 659 ;
        helpline [ 1 ] := 660 ;
        helpline [ 0 ] := 661 ;
      End ;
      backerror ;
      curtok := 379 ;
      curcmd := 1 ;
      curchr := 123 ;
      alignstate := alignstate + 1 ;
    End ;
End ;
Procedure scanoptionalequals ;
Begin
  Repeat
    getxtoken ;
  Until curcmd <> 10 ;
  If curtok <> 3133 Then backinput ;
End ;
Function scankeyword ( s : strnumber ) : boolean ;

Label 10 ;

Var p : halfword ;
  q : halfword ;
  k : poolpointer ;
Begin
  p := 29987 ;
  mem [ p ] . hh . rh := 0 ;
  k := strstart [ s ] ;
  While k < strstart [ s + 1 ] Do
    Begin
      getxtoken ;
      If ( curcs = 0 ) And ( ( curchr = strpool [ k ] ) Or ( curchr = strpool [ k ] - 32 ) ) Then
        Begin
          Begin
            q := getavail ;
            mem [ p ] . hh . rh := q ;
            mem [ q ] . hh . lh := curtok ;
            p := q ;
          End ;
          k := k + 1 ;
        End
      Else If ( curcmd <> 10 ) Or ( p <> 29987 ) Then
             Begin
               backinput ;
               If p <> 29987 Then begintokenlist ( mem [ 29987 ] . hh . rh , 3 ) ;
               scankeyword := false ;
               goto 10 ;
             End ;
    End ;
  flushlist ( mem [ 29987 ] . hh . rh ) ;
  scankeyword := true ;
  10 :
End ;
Procedure muerror ;
Begin
  Begin
    If interaction = 3 Then ;
    printnl ( 262 ) ;
    print ( 662 ) ;
  End ;
  Begin
    helpptr := 1 ;
    helpline [ 0 ] := 663 ;
  End ;
  error ;
End ;
Procedure scanint ;
forward ;
Procedure scaneightbitint ;
Begin
  scanint ;
  If ( curval < 0 ) Or ( curval > 255 ) Then
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 687 ) ;
      End ;
      Begin
        helpptr := 2 ;
        helpline [ 1 ] := 688 ;
        helpline [ 0 ] := 689 ;
      End ;
      interror ( curval ) ;
      curval := 0 ;
    End ;
End ;
Procedure scancharnum ;
Begin
  scanint ;
  If ( curval < 0 ) Or ( curval > 255 ) Then
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 690 ) ;
      End ;
      Begin
        helpptr := 2 ;
        helpline [ 1 ] := 691 ;
        helpline [ 0 ] := 689 ;
      End ;
      interror ( curval ) ;
      curval := 0 ;
    End ;
End ;
Procedure scanfourbitint ;
Begin
  scanint ;
  If ( curval < 0 ) Or ( curval > 15 ) Then
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 692 ) ;
      End ;
      Begin
        helpptr := 2 ;
        helpline [ 1 ] := 693 ;
        helpline [ 0 ] := 689 ;
      End ;
      interror ( curval ) ;
      curval := 0 ;
    End ;
End ;
Procedure scanfifteenbitint ;
Begin
  scanint ;
  If ( curval < 0 ) Or ( curval > 32767 ) Then
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 694 ) ;
      End ;
      Begin
        helpptr := 2 ;
        helpline [ 1 ] := 695 ;
        helpline [ 0 ] := 689 ;
      End ;
      interror ( curval ) ;
      curval := 0 ;
    End ;
End ;
Procedure scantwentysevenbitint ;
Begin
  scanint ;
  If ( curval < 0 ) Or ( curval > 134217727 ) Then
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 696 ) ;
      End ;
      Begin
        helpptr := 2 ;
        helpline [ 1 ] := 697 ;
        helpline [ 0 ] := 689 ;
      End ;
      interror ( curval ) ;
      curval := 0 ;
    End ;
End ;
Procedure scanfontident ;

Var f : internalfontnumber ;
  m : halfword ;
Begin
  Repeat
    getxtoken ;
  Until curcmd <> 10 ;
  If curcmd = 88 Then f := eqtb [ 3934 ] . hh . rh
  Else If curcmd = 87 Then f := curchr
  Else If curcmd = 86 Then
         Begin
           m := curchr ;
           scanfourbitint ;
           f := eqtb [ m + curval ] . hh . rh ;
         End
  Else
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 816 ) ;
      End ;
      Begin
        helpptr := 2 ;
        helpline [ 1 ] := 817 ;
        helpline [ 0 ] := 818 ;
      End ;
      backerror ;
      f := 0 ;
    End ;
  curval := f ;
End ;
Procedure findfontdimen ( writing : boolean ) ;

Var f : internalfontnumber ;
  n : integer ;
Begin
  scanint ;
  n := curval ;
  scanfontident ;
  f := curval ;
  If n <= 0 Then curval := fmemptr
  Else
    Begin
      If writing And ( n <= 4 ) And ( n >= 2 ) And ( fontglue [ f ] <> 0 ) Then
        Begin
          deleteglueref ( fontglue [ f ] ) ;
          fontglue [ f ] := 0 ;
        End ;
      If n > fontparams [ f ] Then If f < fontptr Then curval := fmemptr
      Else
        Begin
          Repeat
            If fmemptr = fontmemsize Then overflow ( 823 , fontmemsize ) ;
            fontinfo [ fmemptr ] . int := 0 ;
            fmemptr := fmemptr + 1 ;
            fontparams [ f ] := fontparams [ f ] + 1 ;
          Until n = fontparams [ f ] ;
          curval := fmemptr - 1 ;
        End
      Else curval := n + parambase [ f ] ;
    End ;
  If curval = fmemptr Then
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 801 ) ;
      End ;
      printesc ( hash [ 2624 + f ] . rh ) ;
      print ( 819 ) ;
      printint ( fontparams [ f ] ) ;
      print ( 820 ) ;
      Begin
        helpptr := 2 ;
        helpline [ 1 ] := 821 ;
        helpline [ 0 ] := 822 ;
      End ;
      error ;
    End ;
End ;
Procedure scansomethinginternal ( level : smallnumber ; negative : boolean ) ;

Var m : halfword ;
  p : 0 .. nestsize ;
Begin
  m := curchr ;
  Case curcmd Of 
    85 :
         Begin
           scancharnum ;
           If m = 5007 Then
             Begin
               curval := eqtb [ 5007 + curval ] . hh . rh - 0 ;
               curvallevel := 0 ;
             End
           Else If m < 5007 Then
                  Begin
                    curval := eqtb [ m + curval ] . hh . rh ;
                    curvallevel := 0 ;
                  End
           Else
             Begin
               curval := eqtb [ m + curval ] . int ;
               curvallevel := 0 ;
             End ;
         End ;
    71 , 72 , 86 , 87 , 88 : If level <> 5 Then
                               Begin
                                 Begin
                                   If interaction = 3 Then ;
                                   printnl ( 262 ) ;
                                   print ( 664 ) ;
                                 End ;
                                 Begin
                                   helpptr := 3 ;
                                   helpline [ 2 ] := 665 ;
                                   helpline [ 1 ] := 666 ;
                                   helpline [ 0 ] := 667 ;
                                 End ;
                                 backerror ;
                                 Begin
                                   curval := 0 ;
                                   curvallevel := 1 ;
                                 End ;
                               End
                             Else If curcmd <= 72 Then
                                    Begin
                                      If curcmd < 72 Then
                                        Begin
                                          scaneightbitint ;
                                          m := 3422 + curval ;
                                        End ;
                                      Begin
                                        curval := eqtb [ m ] . hh . rh ;
                                        curvallevel := 5 ;
                                      End ;
                                    End
                             Else
                               Begin
                                 backinput ;
                                 scanfontident ;
                                 Begin
                                   curval := 2624 + curval ;
                                   curvallevel := 4 ;
                                 End ;
                               End ;
    73 :
         Begin
           curval := eqtb [ m ] . int ;
           curvallevel := 0 ;
         End ;
    74 :
         Begin
           curval := eqtb [ m ] . int ;
           curvallevel := 1 ;
         End ;
    75 :
         Begin
           curval := eqtb [ m ] . hh . rh ;
           curvallevel := 2 ;
         End ;
    76 :
         Begin
           curval := eqtb [ m ] . hh . rh ;
           curvallevel := 3 ;
         End ;
    79 : If abs ( curlist . modefield ) <> m Then
           Begin
             Begin
               If interaction = 3 Then ;
               printnl ( 262 ) ;
               print ( 680 ) ;
             End ;
             printcmdchr ( 79 , m ) ;
             Begin
               helpptr := 4 ;
               helpline [ 3 ] := 681 ;
               helpline [ 2 ] := 682 ;
               helpline [ 1 ] := 683 ;
               helpline [ 0 ] := 684 ;
             End ;
             error ;
             If level <> 5 Then
               Begin
                 curval := 0 ;
                 curvallevel := 1 ;
               End
             Else
               Begin
                 curval := 0 ;
                 curvallevel := 0 ;
               End ;
           End
         Else If m = 1 Then
                Begin
                  curval := curlist . auxfield . int ;
                  curvallevel := 1 ;
                End
         Else
           Begin
             curval := curlist . auxfield . hh . lh ;
             curvallevel := 0 ;
           End ;
    80 : If curlist . modefield = 0 Then
           Begin
             curval := 0 ;
             curvallevel := 0 ;
           End
         Else
           Begin
             nest [ nestptr ] := curlist ;
             p := nestptr ;
             While abs ( nest [ p ] . modefield ) <> 1 Do
               p := p - 1 ;
             Begin
               curval := nest [ p ] . pgfield ;
               curvallevel := 0 ;
             End ;
           End ;
    82 :
         Begin
           If m = 0 Then curval := deadcycles
           Else curval := insertpenalties ;
           curvallevel := 0 ;
         End ;
    81 :
         Begin
           If ( pagecontents = 0 ) And ( Not outputactive ) Then If m = 0 Then curval := 1073741823
           Else curval := 0
           Else curval := pagesofar [ m ] ;
           curvallevel := 1 ;
         End ;
    84 :
         Begin
           If eqtb [ 3412 ] . hh . rh = 0 Then curval := 0
           Else curval := mem [ eqtb [ 3412 ] . hh . rh ] . hh . lh ;
           curvallevel := 0 ;
         End ;
    83 :
         Begin
           scaneightbitint ;
           If eqtb [ 3678 + curval ] . hh . rh = 0 Then curval := 0
           Else curval := mem [ eqtb [ 3678 + curval ] . hh . rh + m ] . int ;
           curvallevel := 1 ;
         End ;
    68 , 69 :
              Begin
                curval := curchr ;
                curvallevel := 0 ;
              End ;
    77 :
         Begin
           findfontdimen ( false ) ;
           fontinfo [ fmemptr ] . int := 0 ;
           Begin
             curval := fontinfo [ curval ] . int ;
             curvallevel := 1 ;
           End ;
         End ;
    78 :
         Begin
           scanfontident ;
           If m = 0 Then
             Begin
               curval := hyphenchar [ curval ] ;
               curvallevel := 0 ;
             End
           Else
             Begin
               curval := skewchar [ curval ] ;
               curvallevel := 0 ;
             End ;
         End ;
    89 :
         Begin
           scaneightbitint ;
           Case m Of 
             0 : curval := eqtb [ 5318 + curval ] . int ;
             1 : curval := eqtb [ 5851 + curval ] . int ;
             2 : curval := eqtb [ 2900 + curval ] . hh . rh ;
             3 : curval := eqtb [ 3156 + curval ] . hh . rh ;
           End ;
           curvallevel := m ;
         End ;
    70 : If curchr > 2 Then
           Begin
             If curchr = 3 Then curval := line
             Else curval := lastbadness ;
             curvallevel := 0 ;
           End
         Else
           Begin
             If curchr = 2 Then curval := 0
             Else curval := 0 ;
             curvallevel := curchr ;
             If Not ( curlist . tailfield >= himemmin ) And ( curlist . modefield <> 0 ) Then Case curchr Of 
                                                                                                0 : If mem [ curlist . tailfield ] . hh . b0 = 12 Then curval := mem [ curlist . tailfield + 1 ] . int ;
                                                                                                1 : If mem [ curlist . tailfield ] . hh . b0 = 11 Then curval := mem [ curlist . tailfield + 1 ] . int ;
                                                                                                2 : If mem [ curlist . tailfield ] . hh . b0 = 10 Then
                                                                                                      Begin
                                                                                                        curval := mem [ curlist . tailfield + 1 ] . hh . lh ;
                                                                                                        If mem [ curlist . tailfield ] . hh . b1 = 99 Then curvallevel := 3 ;
                                                                                                      End ;
               End
             Else If ( curlist . modefield = 1 ) And ( curlist . tailfield = curlist . headfield ) Then Case curchr Of 
                                                                                                          0 : curval := lastpenalty ;
                                                                                                          1 : curval := lastkern ;
                                                                                                          2 : If lastglue <> 65535 Then curval := lastglue ;
                    End ;
           End ;
    others :
             Begin
               Begin
                 If interaction = 3 Then ;
                 printnl ( 262 ) ;
                 print ( 685 ) ;
               End ;
               printcmdchr ( curcmd , curchr ) ;
               print ( 686 ) ;
               printesc ( 537 ) ;
               Begin
                 helpptr := 1 ;
                 helpline [ 0 ] := 684 ;
               End ;
               error ;
               If level <> 5 Then
                 Begin
                   curval := 0 ;
                   curvallevel := 1 ;
                 End
               Else
                 Begin
                   curval := 0 ;
                   curvallevel := 0 ;
                 End ;
             End
  End ;
  While curvallevel > level Do
    Begin
      If curvallevel = 2 Then curval := mem [ curval + 1 ] . int
      Else If curvallevel = 3 Then muerror ;
      curvallevel := curvallevel - 1 ;
    End ;
  If negative Then If curvallevel >= 2 Then
                     Begin
                       curval := newspec ( curval ) ;
                       Begin
                         mem [ curval + 1 ] . int := - mem [ curval + 1 ] . int ;
                         mem [ curval + 2 ] . int := - mem [ curval + 2 ] . int ;
                         mem [ curval + 3 ] . int := - mem [ curval + 3 ] . int ;
                       End ;
                     End
  Else curval := - curval
  Else If ( curvallevel >= 2 ) And ( curvallevel <= 3 ) Then mem [ curval ] . hh . rh := mem [ curval ] . hh . rh + 1 ;
End ;
Procedure scanint ;

Label 30 ;

Var negative : boolean ;
  m : integer ;
  d : smallnumber ;
  vacuous : boolean ;
  OKsofar : boolean ;
Begin
  radix := 0 ;
  OKsofar := true ;
  negative := false ;
  Repeat
    Repeat
      getxtoken ;
    Until curcmd <> 10 ;
    If curtok = 3117 Then
      Begin
        negative := Not negative ;
        curtok := 3115 ;
      End ;
  Until curtok <> 3115 ;
  If curtok = 3168 Then
    Begin
      gettoken ;
      If curtok < 4095 Then
        Begin
          curval := curchr ;
          If curcmd <= 2 Then If curcmd = 2 Then alignstate := alignstate + 1
          Else alignstate := alignstate - 1 ;
        End
      Else If curtok < 4352 Then curval := curtok - 4096
      Else curval := curtok - 4352 ;
      If curval > 255 Then
        Begin
          Begin
            If interaction = 3 Then ;
            printnl ( 262 ) ;
            print ( 698 ) ;
          End ;
          Begin
            helpptr := 2 ;
            helpline [ 1 ] := 699 ;
            helpline [ 0 ] := 700 ;
          End ;
          curval := 48 ;
          backerror ;
        End
      Else
        Begin
          getxtoken ;
          If curcmd <> 10 Then backinput ;
        End ;
    End
  Else If ( curcmd >= 68 ) And ( curcmd <= 89 ) Then scansomethinginternal ( 0 , false )
  Else
    Begin
      radix := 10 ;
      m := 214748364 ;
      If curtok = 3111 Then
        Begin
          radix := 8 ;
          m := 268435456 ;
          getxtoken ;
        End
      Else If curtok = 3106 Then
             Begin
               radix := 16 ;
               m := 134217728 ;
               getxtoken ;
             End ;
      vacuous := true ;
      curval := 0 ;
      While true Do
        Begin
          If ( curtok < 3120 + radix ) And ( curtok >= 3120 ) And ( curtok <= 3129 ) Then d := curtok - 3120
          Else If radix = 16 Then If ( curtok <= 2886 ) And ( curtok >= 2881 ) Then d := curtok - 2871
          Else If ( curtok <= 3142 ) And ( curtok >= 3137 ) Then d := curtok - 3127
          Else goto 30
          Else goto 30 ;
          vacuous := false ;
          If ( curval >= m ) And ( ( curval > m ) Or ( d > 7 ) Or ( radix <> 10 ) ) Then
            Begin
              If OKsofar Then
                Begin
                  Begin
                    If interaction = 3 Then ;
                    printnl ( 262 ) ;
                    print ( 701 ) ;
                  End ;
                  Begin
                    helpptr := 2 ;
                    helpline [ 1 ] := 702 ;
                    helpline [ 0 ] := 703 ;
                  End ;
                  error ;
                  curval := 2147483647 ;
                  OKsofar := false ;
                End ;
            End
          Else curval := curval * radix + d ;
          getxtoken ;
        End ;
      30 : ;
      If vacuous Then
        Begin
          Begin
            If interaction = 3 Then ;
            printnl ( 262 ) ;
            print ( 664 ) ;
          End ;
          Begin
            helpptr := 3 ;
            helpline [ 2 ] := 665 ;
            helpline [ 1 ] := 666 ;
            helpline [ 0 ] := 667 ;
          End ;
          backerror ;
        End
      Else If curcmd <> 10 Then backinput ;
    End ;
  If negative Then curval := - curval ;
End ;
Procedure scandimen ( mu , inf , shortcut : boolean ) ;

Label 30 , 31 , 32 , 40 , 45 , 88 , 89 ;

Var negative : boolean ;
  f : integer ;
  num , denom : 1 .. 65536 ;
  k , kk : smallnumber ;
  p , q : halfword ;
  v : scaled ;
  savecurval : integer ;
Begin
  f := 0 ;
  aritherror := false ;
  curorder := 0 ;
  negative := false ;
  If Not shortcut Then
    Begin
      negative := false ;
      Repeat
        Repeat
          getxtoken ;
        Until curcmd <> 10 ;
        If curtok = 3117 Then
          Begin
            negative := Not negative ;
            curtok := 3115 ;
          End ;
      Until curtok <> 3115 ;
      If ( curcmd >= 68 ) And ( curcmd <= 89 ) Then If mu Then
                                                      Begin
                                                        scansomethinginternal ( 3 , false ) ;
                                                        If curvallevel >= 2 Then
                                                          Begin
                                                            v := mem [ curval + 1 ] . int ;
                                                            deleteglueref ( curval ) ;
                                                            curval := v ;
                                                          End ;
                                                        If curvallevel = 3 Then goto 89 ;
                                                        If curvallevel <> 0 Then muerror ;
                                                      End
      Else
        Begin
          scansomethinginternal ( 1 , false ) ;
          If curvallevel = 1 Then goto 89 ;
        End
      Else
        Begin
          backinput ;
          If curtok = 3116 Then curtok := 3118 ;
          If curtok <> 3118 Then scanint
          Else
            Begin
              radix := 10 ;
              curval := 0 ;
            End ;
          If curtok = 3116 Then curtok := 3118 ;
          If ( radix = 10 ) And ( curtok = 3118 ) Then
            Begin
              k := 0 ;
              p := 0 ;
              gettoken ;
              While true Do
                Begin
                  getxtoken ;
                  If ( curtok > 3129 ) Or ( curtok < 3120 ) Then goto 31 ;
                  If k < 17 Then
                    Begin
                      q := getavail ;
                      mem [ q ] . hh . rh := p ;
                      mem [ q ] . hh . lh := curtok - 3120 ;
                      p := q ;
                      k := k + 1 ;
                    End ;
                End ;
              31 : For kk := k Downto 1 Do
                     Begin
                       dig [ kk - 1 ] := mem [ p ] . hh . lh ;
                       q := p ;
                       p := mem [ p ] . hh . rh ;
                       Begin
                         mem [ q ] . hh . rh := avail ;
                         avail := q ;
                       End ;
                     End ;
              f := rounddecimals ( k ) ;
              If curcmd <> 10 Then backinput ;
            End ;
        End ;
    End ;
  If curval < 0 Then
    Begin
      negative := Not negative ;
      curval := - curval ;
    End ;
  If inf Then If scankeyword ( 311 ) Then
                Begin
                  curorder := 1 ;
                  While scankeyword ( 108 ) Do
                    Begin
                      If curorder = 3 Then
                        Begin
                          Begin
                            If interaction = 3 Then ;
                            printnl ( 262 ) ;
                            print ( 705 ) ;
                          End ;
                          print ( 706 ) ;
                          Begin
                            helpptr := 1 ;
                            helpline [ 0 ] := 707 ;
                          End ;
                          error ;
                        End
                      Else curorder := curorder + 1 ;
                    End ;
                  goto 88 ;
                End ;
  savecurval := curval ;
  Repeat
    getxtoken ;
  Until curcmd <> 10 ;
  If ( curcmd < 68 ) Or ( curcmd > 89 ) Then backinput
  Else
    Begin
      If mu Then
        Begin
          scansomethinginternal ( 3 , false ) ;
          If curvallevel >= 2 Then
            Begin
              v := mem [ curval + 1 ] . int ;
              deleteglueref ( curval ) ;
              curval := v ;
            End ;
          If curvallevel <> 3 Then muerror ;
        End
      Else scansomethinginternal ( 1 , false ) ;
      v := curval ;
      goto 40 ;
    End ;
  If mu Then goto 45 ;
  If scankeyword ( 708 ) Then v := ( fontinfo [ 6 + parambase [ eqtb [ 3934 ] . hh . rh ] ] . int )
  Else If scankeyword ( 709 ) Then v := ( fontinfo [ 5 + parambase [ eqtb [ 3934 ] . hh . rh ] ] . int )
  Else goto 45 ;
  Begin
    getxtoken ;
    If curcmd <> 10 Then backinput ;
  End ;
  40 : curval := multandadd ( savecurval , v , xnoverd ( v , f , 65536 ) , 1073741823 ) ;
  goto 89 ;
  45 : ;
  If mu Then If scankeyword ( 337 ) Then goto 88
  Else
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 705 ) ;
      End ;
      print ( 710 ) ;
      Begin
        helpptr := 4 ;
        helpline [ 3 ] := 711 ;
        helpline [ 2 ] := 712 ;
        helpline [ 1 ] := 713 ;
        helpline [ 0 ] := 714 ;
      End ;
      error ;
      goto 88 ;
    End ;
  If scankeyword ( 704 ) Then
    Begin
      preparemag ;
      If eqtb [ 5280 ] . int <> 1000 Then
        Begin
          curval := xnoverd ( curval , 1000 , eqtb [ 5280 ] . int ) ;
          f := ( 1000 * f + 65536 * remainder ) Div eqtb [ 5280 ] . int ;
          curval := curval + ( f Div 65536 ) ;
          f := f Mod 65536 ;
        End ;
    End ;
  If scankeyword ( 397 ) Then goto 88 ;
  If scankeyword ( 715 ) Then
    Begin
      num := 7227 ;
      denom := 100 ;
    End
  Else If scankeyword ( 716 ) Then
         Begin
           num := 12 ;
           denom := 1 ;
         End
  Else If scankeyword ( 717 ) Then
         Begin
           num := 7227 ;
           denom := 254 ;
         End
  Else If scankeyword ( 718 ) Then
         Begin
           num := 7227 ;
           denom := 2540 ;
         End
  Else If scankeyword ( 719 ) Then
         Begin
           num := 7227 ;
           denom := 7200 ;
         End
  Else If scankeyword ( 720 ) Then
         Begin
           num := 1238 ;
           denom := 1157 ;
         End
  Else If scankeyword ( 721 ) Then
         Begin
           num := 14856 ;
           denom := 1157 ;
         End
  Else If scankeyword ( 722 ) Then goto 30
  Else
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 705 ) ;
      End ;
      print ( 723 ) ;
      Begin
        helpptr := 6 ;
        helpline [ 5 ] := 724 ;
        helpline [ 4 ] := 725 ;
        helpline [ 3 ] := 726 ;
        helpline [ 2 ] := 712 ;
        helpline [ 1 ] := 713 ;
        helpline [ 0 ] := 714 ;
      End ;
      error ;
      goto 32 ;
    End ;
  curval := xnoverd ( curval , num , denom ) ;
  f := ( num * f + 65536 * remainder ) Div denom ;
  curval := curval + ( f Div 65536 ) ;
  f := f Mod 65536 ;
  32 : ;
  88 : If curval >= 16384 Then aritherror := true
       Else curval := curval * 65536 + f ;
  30 : ;
  Begin
    getxtoken ;
    If curcmd <> 10 Then backinput ;
  End ;
  89 : If aritherror Or ( abs ( curval ) >= 1073741824 ) Then
         Begin
           Begin
             If interaction = 3 Then ;
             printnl ( 262 ) ;
             print ( 727 ) ;
           End ;
           Begin
             helpptr := 2 ;
             helpline [ 1 ] := 728 ;
             helpline [ 0 ] := 729 ;
           End ;
           error ;
           curval := 1073741823 ;
           aritherror := false ;
         End ;
  If negative Then curval := - curval ;
End ;
Procedure scanglue ( level : smallnumber ) ;

Label 10 ;

Var negative : boolean ;
  q : halfword ;
  mu : boolean ;
Begin
  mu := ( level = 3 ) ;
  negative := false ;
  Repeat
    Repeat
      getxtoken ;
    Until curcmd <> 10 ;
    If curtok = 3117 Then
      Begin
        negative := Not negative ;
        curtok := 3115 ;
      End ;
  Until curtok <> 3115 ;
  If ( curcmd >= 68 ) And ( curcmd <= 89 ) Then
    Begin
      scansomethinginternal ( level , negative ) ;
      If curvallevel >= 2 Then
        Begin
          If curvallevel <> level Then muerror ;
          goto 10 ;
        End ;
      If curvallevel = 0 Then scandimen ( mu , false , true )
      Else If level = 3 Then muerror ;
    End
  Else
    Begin
      backinput ;
      scandimen ( mu , false , false ) ;
      If negative Then curval := - curval ;
    End ;
  q := newspec ( 0 ) ;
  mem [ q + 1 ] . int := curval ;
  If scankeyword ( 730 ) Then
    Begin
      scandimen ( mu , true , false ) ;
      mem [ q + 2 ] . int := curval ;
      mem [ q ] . hh . b0 := curorder ;
    End ;
  If scankeyword ( 731 ) Then
    Begin
      scandimen ( mu , true , false ) ;
      mem [ q + 3 ] . int := curval ;
      mem [ q ] . hh . b1 := curorder ;
    End ;
  curval := q ;
  10 :
End ;
Function scanrulespec : halfword ;

Label 21 ;

Var q : halfword ;
Begin
  q := newrule ;
  If curcmd = 35 Then mem [ q + 1 ] . int := 26214
  Else
    Begin
      mem [ q + 3 ] . int := 26214 ;
      mem [ q + 2 ] . int := 0 ;
    End ;
  21 : If scankeyword ( 732 ) Then
         Begin
           scandimen ( false , false , false ) ;
           mem [ q + 1 ] . int := curval ;
           goto 21 ;
         End ;
  If scankeyword ( 733 ) Then
    Begin
      scandimen ( false , false , false ) ;
      mem [ q + 3 ] . int := curval ;
      goto 21 ;
    End ;
  If scankeyword ( 734 ) Then
    Begin
      scandimen ( false , false , false ) ;
      mem [ q + 2 ] . int := curval ;
      goto 21 ;
    End ;
  scanrulespec := q ;
End ;
Function strtoks ( b : poolpointer ) : halfword ;

Var p : halfword ;
  q : halfword ;
  t : halfword ;
  k : poolpointer ;
Begin
  Begin
    If poolptr + 1 > poolsize Then overflow ( 257 , poolsize - initpoolptr ) ;
  End ;
  p := 29997 ;
  mem [ p ] . hh . rh := 0 ;
  k := b ;
  While k < poolptr Do
    Begin
      t := strpool [ k ] ;
      If t = 32 Then t := 2592
      Else t := 3072 + t ;
      Begin
        Begin
          q := avail ;
          If q = 0 Then q := getavail
          Else
            Begin
              avail := mem [ q ] . hh . rh ;
              mem [ q ] . hh . rh := 0 ;
            End ;
        End ;
        mem [ p ] . hh . rh := q ;
        mem [ q ] . hh . lh := t ;
        p := q ;
      End ;
      k := k + 1 ;
    End ;
  poolptr := b ;
  strtoks := p ;
End ;
Function thetoks : halfword ;

Var oldsetting : 0 .. 21 ;
  p , q , r : halfword ;
  b : poolpointer ;
Begin
  getxtoken ;
  scansomethinginternal ( 5 , false ) ;
  If curvallevel >= 4 Then
    Begin
      p := 29997 ;
      mem [ p ] . hh . rh := 0 ;
      If curvallevel = 4 Then
        Begin
          q := getavail ;
          mem [ p ] . hh . rh := q ;
          mem [ q ] . hh . lh := 4095 + curval ;
          p := q ;
        End
      Else If curval <> 0 Then
             Begin
               r := mem [ curval ] . hh . rh ;
               While r <> 0 Do
                 Begin
                   Begin
                     Begin
                       q := avail ;
                       If q = 0 Then q := getavail
                       Else
                         Begin
                           avail := mem [ q ] . hh . rh ;
                           mem [ q ] . hh . rh := 0 ;
                         End ;
                     End ;
                     mem [ p ] . hh . rh := q ;
                     mem [ q ] . hh . lh := mem [ r ] . hh . lh ;
                     p := q ;
                   End ;
                   r := mem [ r ] . hh . rh ;
                 End ;
             End ;
      thetoks := p ;
    End
  Else
    Begin
      oldsetting := selector ;
      selector := 21 ;
      b := poolptr ;
      Case curvallevel Of 
        0 : printint ( curval ) ;
        1 :
            Begin
              printscaled ( curval ) ;
              print ( 397 ) ;
            End ;
        2 :
            Begin
              printspec ( curval , 397 ) ;
              deleteglueref ( curval ) ;
            End ;
        3 :
            Begin
              printspec ( curval , 337 ) ;
              deleteglueref ( curval ) ;
            End ;
      End ;
      selector := oldsetting ;
      thetoks := strtoks ( b ) ;
    End ;
End ;
Procedure insthetoks ;
Begin
  mem [ 29988 ] . hh . rh := thetoks ;
  begintokenlist ( mem [ 29997 ] . hh . rh , 4 ) ;
End ;
Procedure convtoks ;

Var oldsetting : 0 .. 21 ;
  c : 0 .. 5 ;
  savescannerstatus : smallnumber ;
  b : poolpointer ;
Begin
  c := curchr ;
  Case c Of 
    0 , 1 : scanint ;
    2 , 3 :
            Begin
              savescannerstatus := scannerstatus ;
              scannerstatus := 0 ;
              gettoken ;
              scannerstatus := savescannerstatus ;
            End ;
    4 : scanfontident ;
    5 : If jobname = 0 Then openlogfile ;
  End ;
  oldsetting := selector ;
  selector := 21 ;
  b := poolptr ;
  Case c Of 
    0 : printint ( curval ) ;
    1 : printromanint ( curval ) ;
    2 : If curcs <> 0 Then sprintcs ( curcs )
        Else printchar ( curchr ) ;
    3 : printmeaning ;
    4 :
        Begin
          print ( fontname [ curval ] ) ;
          If fontsize [ curval ] <> fontdsize [ curval ] Then
            Begin
              print ( 741 ) ;
              printscaled ( fontsize [ curval ] ) ;
              print ( 397 ) ;
            End ;
        End ;
    5 : print ( jobname ) ;
  End ;
  selector := oldsetting ;
  mem [ 29988 ] . hh . rh := strtoks ( b ) ;
  begintokenlist ( mem [ 29997 ] . hh . rh , 4 ) ;
End ;
Function scantoks ( macrodef , xpand : boolean ) : halfword ;

Label 40 , 30 , 31 , 32 ;

Var t : halfword ;
  s : halfword ;
  p : halfword ;
  q : halfword ;
  unbalance : halfword ;
  hashbrace : halfword ;
Begin
  If macrodef Then scannerstatus := 2
  Else scannerstatus := 5 ;
  warningindex := curcs ;
  defref := getavail ;
  mem [ defref ] . hh . lh := 0 ;
  p := defref ;
  hashbrace := 0 ;
  t := 3120 ;
  If macrodef Then
    Begin
      While true Do
        Begin
          gettoken ;
          If curtok < 768 Then goto 31 ;
          If curcmd = 6 Then
            Begin
              s := 3328 + curchr ;
              gettoken ;
              If curcmd = 1 Then
                Begin
                  hashbrace := curtok ;
                  Begin
                    q := getavail ;
                    mem [ p ] . hh . rh := q ;
                    mem [ q ] . hh . lh := curtok ;
                    p := q ;
                  End ;
                  Begin
                    q := getavail ;
                    mem [ p ] . hh . rh := q ;
                    mem [ q ] . hh . lh := 3584 ;
                    p := q ;
                  End ;
                  goto 30 ;
                End ;
              If t = 3129 Then
                Begin
                  Begin
                    If interaction = 3 Then ;
                    printnl ( 262 ) ;
                    print ( 744 ) ;
                  End ;
                  Begin
                    helpptr := 1 ;
                    helpline [ 0 ] := 745 ;
                  End ;
                  error ;
                End
              Else
                Begin
                  t := t + 1 ;
                  If curtok <> t Then
                    Begin
                      Begin
                        If interaction = 3 Then ;
                        printnl ( 262 ) ;
                        print ( 746 ) ;
                      End ;
                      Begin
                        helpptr := 2 ;
                        helpline [ 1 ] := 747 ;
                        helpline [ 0 ] := 748 ;
                      End ;
                      backerror ;
                    End ;
                  curtok := s ;
                End ;
            End ;
          Begin
            q := getavail ;
            mem [ p ] . hh . rh := q ;
            mem [ q ] . hh . lh := curtok ;
            p := q ;
          End ;
        End ;
      31 :
           Begin
             q := getavail ;
             mem [ p ] . hh . rh := q ;
             mem [ q ] . hh . lh := 3584 ;
             p := q ;
           End ;
      If curcmd = 2 Then
        Begin
          Begin
            If interaction = 3 Then ;
            printnl ( 262 ) ;
            print ( 657 ) ;
          End ;
          alignstate := alignstate + 1 ;
          Begin
            helpptr := 2 ;
            helpline [ 1 ] := 742 ;
            helpline [ 0 ] := 743 ;
          End ;
          error ;
          goto 40 ;
        End ;
      30 :
    End
  Else scanleftbrace ;
  unbalance := 1 ;
  While true Do
    Begin
      If xpand Then
        Begin
          While true Do
            Begin
              getnext ;
              If curcmd <= 100 Then goto 32 ;
              If curcmd <> 109 Then expand
              Else
                Begin
                  q := thetoks ;
                  If mem [ 29997 ] . hh . rh <> 0 Then
                    Begin
                      mem [ p ] . hh . rh := mem [ 29997 ] . hh . rh ;
                      p := q ;
                    End ;
                End ;
            End ;
          32 : xtoken
        End
      Else gettoken ;
      If curtok < 768 Then If curcmd < 2 Then unbalance := unbalance + 1
      Else
        Begin
          unbalance := unbalance - 1 ;
          If unbalance = 0 Then goto 40 ;
        End
      Else If curcmd = 6 Then If macrodef Then
                                Begin
                                  s := curtok ;
                                  If xpand Then getxtoken
                                  Else gettoken ;
                                  If curcmd <> 6 Then If ( curtok <= 3120 ) Or ( curtok > t ) Then
                                                        Begin
                                                          Begin
                                                            If interaction = 3 Then ;
                                                            printnl ( 262 ) ;
                                                            print ( 749 ) ;
                                                          End ;
                                                          sprintcs ( warningindex ) ;
                                                          Begin
                                                            helpptr := 3 ;
                                                            helpline [ 2 ] := 750 ;
                                                            helpline [ 1 ] := 751 ;
                                                            helpline [ 0 ] := 752 ;
                                                          End ;
                                                          backerror ;
                                                          curtok := s ;
                                                        End
                                  Else curtok := 1232 + curchr ;
                                End ;
      Begin
        q := getavail ;
        mem [ p ] . hh . rh := q ;
        mem [ q ] . hh . lh := curtok ;
        p := q ;
      End ;
    End ;
  40 : scannerstatus := 0 ;
  If hashbrace <> 0 Then
    Begin
      q := getavail ;
      mem [ p ] . hh . rh := q ;
      mem [ q ] . hh . lh := hashbrace ;
      p := q ;
    End ;
  scantoks := p ;
End ;
Procedure readtoks ( n : integer ; r : halfword ) ;

Label 30 ;

Var p : halfword ;
  q : halfword ;
  s : integer ;
  m : smallnumber ;
Begin
  scannerstatus := 2 ;
  warningindex := r ;
  defref := getavail ;
  mem [ defref ] . hh . lh := 0 ;
  p := defref ;
  Begin
    q := getavail ;
    mem [ p ] . hh . rh := q ;
    mem [ q ] . hh . lh := 3584 ;
    p := q ;
  End ;
  If ( n < 0 ) Or ( n > 15 ) Then m := 16
  Else m := n ;
  s := alignstate ;
  alignstate := 1000000 ;
  Repeat
    beginfilereading ;
    curinput . namefield := m + 1 ;
    If readopen [ m ] = 2 Then If interaction > 1 Then If n < 0 Then
                                                         Begin ;
                                                           print ( 338 ) ;
                                                           terminput ;
                                                         End
    Else
      Begin ;
        println ;
        sprintcs ( r ) ;
        Begin ;
          print ( 61 ) ;
          terminput ;
        End ;
        n := - 1 ;
      End
    Else fatalerror ( 753 )
    Else If readopen [ m ] = 1 Then If inputln ( readfile [ m ] , false ) Then readopen [ m ] := 0
    Else
      Begin
        aclose ( readfile [ m ] ) ;
        readopen [ m ] := 2 ;
      End
    Else
      Begin
        If Not inputln ( readfile [ m ] , true ) Then
          Begin
            aclose ( readfile [ m ] ) ;
            readopen [ m ] := 2 ;
            If alignstate <> 1000000 Then
              Begin
                runaway ;
                Begin
                  If interaction = 3 Then ;
                  printnl ( 262 ) ;
                  print ( 754 ) ;
                End ;
                printesc ( 534 ) ;
                Begin
                  helpptr := 1 ;
                  helpline [ 0 ] := 755 ;
                End ;
                alignstate := 1000000 ;
                error ;
              End ;
          End ;
      End ;
    curinput . limitfield := last ;
    If ( eqtb [ 5311 ] . int < 0 ) Or ( eqtb [ 5311 ] . int > 255 ) Then curinput . limitfield := curinput . limitfield - 1
    Else buffer [ curinput . limitfield ] := eqtb [ 5311 ] . int ;
    first := curinput . limitfield + 1 ;
    curinput . locfield := curinput . startfield ;
    curinput . statefield := 33 ;
    While true Do
      Begin
        gettoken ;
        If curtok = 0 Then goto 30 ;
        If alignstate < 1000000 Then
          Begin
            Repeat
              gettoken ;
            Until curtok = 0 ;
            alignstate := 1000000 ;
            goto 30 ;
          End ;
        Begin
          q := getavail ;
          mem [ p ] . hh . rh := q ;
          mem [ q ] . hh . lh := curtok ;
          p := q ;
        End ;
      End ;
    30 : endfilereading ;
  Until alignstate = 1000000 ;
  curval := defref ;
  scannerstatus := 0 ;
  alignstate := s ;
End ;
Procedure passtext ;

Label 30 ;

Var l : integer ;
  savescannerstatus : smallnumber ;
Begin
  savescannerstatus := scannerstatus ;
  scannerstatus := 1 ;
  l := 0 ;
  skipline := line ;
  While true Do
    Begin
      getnext ;
      If curcmd = 106 Then
        Begin
          If l = 0 Then goto 30 ;
          If curchr = 2 Then l := l - 1 ;
        End
      Else If curcmd = 105 Then l := l + 1 ;
    End ;
  30 : scannerstatus := savescannerstatus ;
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
          If q = 0 Then confusion ( 756 ) ;
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
Procedure conditional ;

Label 10 , 50 ;

Var b : boolean ;
  r : 60 .. 62 ;
  m , n : integer ;
  p , q : halfword ;
  savescannerstatus : smallnumber ;
  savecondptr : halfword ;
  thisif : smallnumber ;
Begin
  Begin
    p := getnode ( 2 ) ;
    mem [ p ] . hh . rh := condptr ;
    mem [ p ] . hh . b0 := iflimit ;
    mem [ p ] . hh . b1 := curif ;
    mem [ p + 1 ] . int := ifline ;
    condptr := p ;
    curif := curchr ;
    iflimit := 1 ;
    ifline := line ;
  End ;
  savecondptr := condptr ;
  thisif := curchr ;
  Case thisif Of 
    0 , 1 :
            Begin
              Begin
                getxtoken ;
                If curcmd = 0 Then If curchr = 257 Then
                                     Begin
                                       curcmd := 13 ;
                                       curchr := curtok - 4096 ;
                                     End ;
              End ;
              If ( curcmd > 13 ) Or ( curchr > 255 ) Then
                Begin
                  m := 0 ;
                  n := 256 ;
                End
              Else
                Begin
                  m := curcmd ;
                  n := curchr ;
                End ;
              Begin
                getxtoken ;
                If curcmd = 0 Then If curchr = 257 Then
                                     Begin
                                       curcmd := 13 ;
                                       curchr := curtok - 4096 ;
                                     End ;
              End ;
              If ( curcmd > 13 ) Or ( curchr > 255 ) Then
                Begin
                  curcmd := 0 ;
                  curchr := 256 ;
                End ;
              If thisif = 0 Then b := ( n = curchr )
              Else b := ( m = curcmd ) ;
            End ;
    2 , 3 :
            Begin
              If thisif = 2 Then scanint
              Else scandimen ( false , false , false ) ;
              n := curval ;
              Repeat
                getxtoken ;
              Until curcmd <> 10 ;
              If ( curtok >= 3132 ) And ( curtok <= 3134 ) Then r := curtok - 3072
              Else
                Begin
                  Begin
                    If interaction = 3 Then ;
                    printnl ( 262 ) ;
                    print ( 780 ) ;
                  End ;
                  printcmdchr ( 105 , thisif ) ;
                  Begin
                    helpptr := 1 ;
                    helpline [ 0 ] := 781 ;
                  End ;
                  backerror ;
                  r := 61 ;
                End ;
              If thisif = 2 Then scanint
              Else scandimen ( false , false , false ) ;
              Case r Of 
                60 : b := ( n < curval ) ;
                61 : b := ( n = curval ) ;
                62 : b := ( n > curval ) ;
              End ;
            End ;
    4 :
        Begin
          scanint ;
          b := odd ( curval ) ;
        End ;
    5 : b := ( abs ( curlist . modefield ) = 1 ) ;
    6 : b := ( abs ( curlist . modefield ) = 102 ) ;
    7 : b := ( abs ( curlist . modefield ) = 203 ) ;
    8 : b := ( curlist . modefield < 0 ) ;
    9 , 10 , 11 :
                  Begin
                    scaneightbitint ;
                    p := eqtb [ 3678 + curval ] . hh . rh ;
                    If thisif = 9 Then b := ( p = 0 )
                    Else If p = 0 Then b := false
                    Else If thisif = 10 Then b := ( mem [ p ] . hh . b0 = 0 )
                    Else b := ( mem [ p ] . hh . b0 = 1 ) ;
                  End ;
    12 :
         Begin
           savescannerstatus := scannerstatus ;
           scannerstatus := 0 ;
           getnext ;
           n := curcs ;
           p := curcmd ;
           q := curchr ;
           getnext ;
           If curcmd <> p Then b := false
           Else If curcmd < 111 Then b := ( curchr = q )
           Else
             Begin
               p := mem [ curchr ] . hh . rh ;
               q := mem [ eqtb [ n ] . hh . rh ] . hh . rh ;
               If p = q Then b := true
               Else
                 Begin
                   While ( p <> 0 ) And ( q <> 0 ) Do
                     If mem [ p ] . hh . lh <> mem [ q ] . hh . lh Then p := 0
                     Else
                       Begin
                         p := mem [ p ] . hh . rh ;
                         q := mem [ q ] . hh . rh ;
                       End ;
                   b := ( ( p = 0 ) And ( q = 0 ) ) ;
                 End ;
             End ;
           scannerstatus := savescannerstatus ;
         End ;
    13 :
         Begin
           scanfourbitint ;
           b := ( readopen [ curval ] = 2 ) ;
         End ;
    14 : b := true ;
    15 : b := false ;
    16 :
         Begin
           scanint ;
           n := curval ;
           If eqtb [ 5299 ] . int > 1 Then
             Begin
               begindiagnostic ;
               print ( 782 ) ;
               printint ( n ) ;
               printchar ( 125 ) ;
               enddiagnostic ( false ) ;
             End ;
           While n <> 0 Do
             Begin
               passtext ;
               If condptr = savecondptr Then If curchr = 4 Then n := n - 1
               Else goto 50
               Else If curchr = 2 Then
                      Begin
                        p := condptr ;
                        ifline := mem [ p + 1 ] . int ;
                        curif := mem [ p ] . hh . b1 ;
                        iflimit := mem [ p ] . hh . b0 ;
                        condptr := mem [ p ] . hh . rh ;
                        freenode ( p , 2 ) ;
                      End ;
             End ;
           changeiflimit ( 4 , savecondptr ) ;
           goto 10 ;
         End ;
  End ;
  If eqtb [ 5299 ] . int > 1 Then
    Begin
      begindiagnostic ;
      If b Then print ( 778 )
      Else print ( 779 ) ;
      enddiagnostic ( false ) ;
    End ;
  If b Then
    Begin
      changeiflimit ( 3 , savecondptr ) ;
      goto 10 ;
    End ;
  While true Do
    Begin
      passtext ;
      If condptr = savecondptr Then
        Begin
          If curchr <> 4 Then goto 50 ;
          Begin
            If interaction = 3 Then ;
            printnl ( 262 ) ;
            print ( 776 ) ;
          End ;
          printesc ( 774 ) ;
          Begin
            helpptr := 1 ;
            helpline [ 0 ] := 777 ;
          End ;
          error ;
        End
      Else If curchr = 2 Then
             Begin
               p := condptr ;
               ifline := mem [ p + 1 ] . int ;
               curif := mem [ p ] . hh . b1 ;
               iflimit := mem [ p ] . hh . b0 ;
               condptr := mem [ p ] . hh . rh ;
               freenode ( p , 2 ) ;
             End ;
    End ;
  50 : If curchr = 2 Then
         Begin
           p := condptr ;
           ifline := mem [ p + 1 ] . int ;
           curif := mem [ p ] . hh . b1 ;
           iflimit := mem [ p ] . hh . b0 ;
           condptr := mem [ p ] . hh . rh ;
           freenode ( p , 2 ) ;
         End
       Else iflimit := 2 ;
  10 :
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
      Begin
        If poolptr + 1 > poolsize Then overflow ( 257 , poolsize - initpoolptr ) ;
      End ;
      Begin
        strpool [ poolptr ] := c ;
        poolptr := poolptr + 1 ;
      End ;
      If ( c = 62 ) Or ( c = 58 ) Then
        Begin
          areadelimiter := ( poolptr - strstart [ strptr ] ) ;
          extdelimiter := 0 ;
        End
      Else If ( c = 46 ) And ( extdelimiter = 0 ) Then extdelimiter := ( poolptr - strstart [ strptr ] ) ;
      morename := true ;
    End ;
End ;
Procedure endname ;
Begin
  If strptr + 3 > maxstrings Then overflow ( 258 , maxstrings - initstrptr ) ;
  If areadelimiter = 0 Then curarea := 338
  Else
    Begin
      curarea := strptr ;
      strstart [ strptr + 1 ] := strstart [ strptr ] + areadelimiter ;
      strptr := strptr + 1 ;
    End ;
  If extdelimiter = 0 Then
    Begin
      curext := 338 ;
      curname := makestring ;
    End
  Else
    Begin
      curname := strptr ;
      strstart [ strptr + 1 ] := strstart [ strptr ] + extdelimiter - areadelimiter - 1 ;
      strptr := strptr + 1 ;
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
  If n + b - a + 5 > filenamesize Then b := a + filenamesize - n - 5 ;
  k := 0 ;
  For j := 1 To n Do
    Begin
      c := xord [ TEXformatdefault [ j ] ] ;
      k := k + 1 ;
      If k <= filenamesize Then nameoffile [ k ] := xchr [ c ] ;
    End ;
  For j := a To b Do
    Begin
      c := buffer [ j ] ;
      k := k + 1 ;
      If k <= filenamesize Then nameoffile [ k ] := xchr [ c ] ;
    End ;
  For j := 17 To 20 Do
    Begin
      c := xord [ TEXformatdefault [ j ] ] ;
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
  If ( poolptr + namelength > poolsize ) Or ( strptr = maxstrings ) Or ( ( poolptr - strstart [ strptr ] ) > 0 ) Then makenamestring := 63
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
  nameinprogress := true ;
  beginname ;
  Repeat
    getxtoken ;
  Until curcmd <> 10 ;
  While true Do
    Begin
      If ( curcmd > 12 ) Or ( curchr > 255 ) Then
        Begin
          backinput ;
          goto 30 ;
        End ;
      If Not morename ( curchr ) Then goto 30 ;
      getxtoken ;
    End ;
  30 : endname ;
  nameinprogress := false ;
End ;
Procedure packjobname ( s : strnumber ) ;
Begin
  curarea := 338 ;
  curext := s ;
  curname := jobname ;
  packfilename ( curname , curarea , curext ) ;
End ;
Procedure promptfilename ( s , e : strnumber ) ;

Label 30 ;

Var k : 0 .. bufsize ;
Begin
  If interaction = 2 Then ;
  If s = 786 Then
    Begin
      If interaction = 3 Then ;
      printnl ( 262 ) ;
      print ( 787 ) ;
    End
  Else
    Begin
      If interaction = 3 Then ;
      printnl ( 262 ) ;
      print ( 788 ) ;
    End ;
  printfilename ( curname , curarea , curext ) ;
  print ( 789 ) ;
  If e = 790 Then showcontext ;
  printnl ( 791 ) ;
  print ( s ) ;
  If interaction < 2 Then fatalerror ( 792 ) ;
  breakin ( termin , true ) ;
  Begin ;
    print ( 568 ) ;
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
  If curext = 338 Then curext := e ;
  packfilename ( curname , curarea , curext ) ;
End ;
Procedure openlogfile ;

Var oldsetting : 0 .. 21 ;
  k : 0 .. bufsize ;
  l : 0 .. bufsize ;
  months : packed array [ 1 .. 36 ] Of char ;
Begin
  oldsetting := selector ;
  If jobname = 0 Then jobname := 795 ;
  packjobname ( 796 ) ;
  While Not aopenout ( logfile ) Do
    Begin
      selector := 17 ;
      promptfilename ( 798 , 796 ) ;
    End ;
  logname := amakenamestring ( logfile ) ;
  selector := 18 ;
  logopened := true ;
  Begin
    write ( logfile , 'This is TeX, Version 3.14159265' ) ;
    slowprint ( formatident ) ;
    print ( 799 ) ;
    printint ( eqtb [ 5284 ] . int ) ;
    printchar ( 32 ) ;
    months := 'JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC' ;
    For k := 3 * eqtb [ 5285 ] . int - 2 To 3 * eqtb [ 5285 ] . int Do
      write ( logfile , months [ k ] ) ;
    printchar ( 32 ) ;
    printint ( eqtb [ 5286 ] . int ) ;
    printchar ( 32 ) ;
    printtwo ( eqtb [ 5283 ] . int Div 60 ) ;
    printchar ( 58 ) ;
    printtwo ( eqtb [ 5283 ] . int Mod 60 ) ;
  End ;
  inputstack [ inputptr ] := curinput ;
  printnl ( 797 ) ;
  l := inputstack [ 0 ] . limitfield ;
  If buffer [ l ] = eqtb [ 5311 ] . int Then l := l - 1 ;
  For k := 1 To l Do
    print ( buffer [ k ] ) ;
  println ;
  selector := oldsetting + 2 ;
End ;
Procedure startinput ;

Label 30 ;
Begin
  scanfilename ;
  If curext = 338 Then curext := 790 ;
  packfilename ( curname , curarea , curext ) ;
  While true Do
    Begin
      beginfilereading ;
      If aopenin ( inputfile [ curinput . indexfield ] ) Then goto 30 ;
      If curarea = 338 Then
        Begin
          packfilename ( curname , 783 , curext ) ;
          If aopenin ( inputfile [ curinput . indexfield ] ) Then goto 30 ;
        End ;
      endfilereading ;
      promptfilename ( 786 , 790 ) ;
    End ;
  30 : curinput . namefield := amakenamestring ( inputfile [ curinput . indexfield ] ) ;
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
  curinput . statefield := 33 ;
  If curinput . namefield = strptr - 1 Then
    Begin
      Begin
        strptr := strptr - 1 ;
        poolptr := strstart [ strptr ] ;
      End ;
      curinput . namefield := curname ;
    End ;
  Begin
    line := 1 ;
    If inputln ( inputfile [ curinput . indexfield ] , false ) Then ;
    firmuptheline ;
    If ( eqtb [ 5311 ] . int < 0 ) Or ( eqtb [ 5311 ] . int > 255 ) Then curinput . limitfield := curinput . limitfield - 1
    Else buffer [ curinput . limitfield ] := eqtb [ 5311 ] . int ;
    first := curinput . limitfield + 1 ;
    curinput . locfield := curinput . startfield ;
  End ;
End ;
Function readfontinfo ( u : halfword ; nom , aire : strnumber ; s : scaled ) : internalfontnumber ;

Label 30 , 11 , 45 ;

Var k : fontindex ;
  fileopened : boolean ;
  lf , lh , bc , ec , nw , nh , nd , ni , nl , nk , ne , np : halfword ;
  f : internalfontnumber ;
  g : internalfontnumber ;
  a , b , c , d : eightbits ;
  qw : fourquarters ;
  sw : scaled ;
  bchlabel : integer ;
  bchar : 0 .. 256 ;
  z : scaled ;
  alpha : integer ;
  beta : 1 .. 16 ;
Begin
  g := 0 ;
  fileopened := false ;
  If aire = 338 Then packfilename ( nom , 784 , 810 )
  Else packfilename ( nom , aire , 810 ) ;
  If Not bopenin ( tfmfile ) Then goto 11 ;
  fileopened := true ;
  Begin
    Begin
      lf := tfmfile ^ ;
      If lf > 127 Then goto 11 ;
      get ( tfmfile ) ;
      lf := lf * 256 + tfmfile ^ ;
    End ;
    get ( tfmfile ) ;
    Begin
      lh := tfmfile ^ ;
      If lh > 127 Then goto 11 ;
      get ( tfmfile ) ;
      lh := lh * 256 + tfmfile ^ ;
    End ;
    get ( tfmfile ) ;
    Begin
      bc := tfmfile ^ ;
      If bc > 127 Then goto 11 ;
      get ( tfmfile ) ;
      bc := bc * 256 + tfmfile ^ ;
    End ;
    get ( tfmfile ) ;
    Begin
      ec := tfmfile ^ ;
      If ec > 127 Then goto 11 ;
      get ( tfmfile ) ;
      ec := ec * 256 + tfmfile ^ ;
    End ;
    If ( bc > ec + 1 ) Or ( ec > 255 ) Then goto 11 ;
    If bc > 255 Then
      Begin
        bc := 1 ;
        ec := 0 ;
      End ;
    get ( tfmfile ) ;
    Begin
      nw := tfmfile ^ ;
      If nw > 127 Then goto 11 ;
      get ( tfmfile ) ;
      nw := nw * 256 + tfmfile ^ ;
    End ;
    get ( tfmfile ) ;
    Begin
      nh := tfmfile ^ ;
      If nh > 127 Then goto 11 ;
      get ( tfmfile ) ;
      nh := nh * 256 + tfmfile ^ ;
    End ;
    get ( tfmfile ) ;
    Begin
      nd := tfmfile ^ ;
      If nd > 127 Then goto 11 ;
      get ( tfmfile ) ;
      nd := nd * 256 + tfmfile ^ ;
    End ;
    get ( tfmfile ) ;
    Begin
      ni := tfmfile ^ ;
      If ni > 127 Then goto 11 ;
      get ( tfmfile ) ;
      ni := ni * 256 + tfmfile ^ ;
    End ;
    get ( tfmfile ) ;
    Begin
      nl := tfmfile ^ ;
      If nl > 127 Then goto 11 ;
      get ( tfmfile ) ;
      nl := nl * 256 + tfmfile ^ ;
    End ;
    get ( tfmfile ) ;
    Begin
      nk := tfmfile ^ ;
      If nk > 127 Then goto 11 ;
      get ( tfmfile ) ;
      nk := nk * 256 + tfmfile ^ ;
    End ;
    get ( tfmfile ) ;
    Begin
      ne := tfmfile ^ ;
      If ne > 127 Then goto 11 ;
      get ( tfmfile ) ;
      ne := ne * 256 + tfmfile ^ ;
    End ;
    get ( tfmfile ) ;
    Begin
      np := tfmfile ^ ;
      If np > 127 Then goto 11 ;
      get ( tfmfile ) ;
      np := np * 256 + tfmfile ^ ;
    End ;
    If lf <> 6 + lh + ( ec - bc + 1 ) + nw + nh + nd + ni + nl + nk + ne + np Then goto 11 ;
    If ( nw = 0 ) Or ( nh = 0 ) Or ( nd = 0 ) Or ( ni = 0 ) Then goto 11 ;
  End ;
  lf := lf - 6 - lh ;
  If np < 7 Then lf := lf + 7 - np ;
  If ( fontptr = fontmax ) Or ( fmemptr + lf > fontmemsize ) Then
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 801 ) ;
      End ;
      sprintcs ( u ) ;
      printchar ( 61 ) ;
      printfilename ( nom , aire , 338 ) ;
      If s >= 0 Then
        Begin
          print ( 741 ) ;
          printscaled ( s ) ;
          print ( 397 ) ;
        End
      Else If s <> - 1000 Then
             Begin
               print ( 802 ) ;
               printint ( - s ) ;
             End ;
      print ( 811 ) ;
      Begin
        helpptr := 4 ;
        helpline [ 3 ] := 812 ;
        helpline [ 2 ] := 813 ;
        helpline [ 1 ] := 814 ;
        helpline [ 0 ] := 815 ;
      End ;
      error ;
      goto 30 ;
    End ;
  f := fontptr + 1 ;
  charbase [ f ] := fmemptr - bc ;
  widthbase [ f ] := charbase [ f ] + ec + 1 ;
  heightbase [ f ] := widthbase [ f ] + nw ;
  depthbase [ f ] := heightbase [ f ] + nh ;
  italicbase [ f ] := depthbase [ f ] + nd ;
  ligkernbase [ f ] := italicbase [ f ] + ni ;
  kernbase [ f ] := ligkernbase [ f ] + nl - 256 * ( 128 ) ;
  extenbase [ f ] := kernbase [ f ] + 256 * ( 128 ) + nk ;
  parambase [ f ] := extenbase [ f ] + ne ;
  Begin
    If lh < 2 Then goto 11 ;
    Begin
      get ( tfmfile ) ;
      a := tfmfile ^ ;
      qw . b0 := a + 0 ;
      get ( tfmfile ) ;
      b := tfmfile ^ ;
      qw . b1 := b + 0 ;
      get ( tfmfile ) ;
      c := tfmfile ^ ;
      qw . b2 := c + 0 ;
      get ( tfmfile ) ;
      d := tfmfile ^ ;
      qw . b3 := d + 0 ;
      fontcheck [ f ] := qw ;
    End ;
    get ( tfmfile ) ;
    Begin
      z := tfmfile ^ ;
      If z > 127 Then goto 11 ;
      get ( tfmfile ) ;
      z := z * 256 + tfmfile ^ ;
    End ;
    get ( tfmfile ) ;
    z := z * 256 + tfmfile ^ ;
    get ( tfmfile ) ;
    z := ( z * 16 ) + ( tfmfile ^ Div 16 ) ;
    If z < 65536 Then goto 11 ;
    While lh > 2 Do
      Begin
        get ( tfmfile ) ;
        get ( tfmfile ) ;
        get ( tfmfile ) ;
        get ( tfmfile ) ;
        lh := lh - 1 ;
      End ;
    fontdsize [ f ] := z ;
    If s <> - 1000 Then If s >= 0 Then z := s
    Else z := xnoverd ( z , - s , 1000 ) ;
    fontsize [ f ] := z ;
  End ;
  For k := fmemptr To widthbase [ f ] - 1 Do
    Begin
      Begin
        get ( tfmfile ) ;
        a := tfmfile ^ ;
        qw . b0 := a + 0 ;
        get ( tfmfile ) ;
        b := tfmfile ^ ;
        qw . b1 := b + 0 ;
        get ( tfmfile ) ;
        c := tfmfile ^ ;
        qw . b2 := c + 0 ;
        get ( tfmfile ) ;
        d := tfmfile ^ ;
        qw . b3 := d + 0 ;
        fontinfo [ k ] . qqqq := qw ;
      End ;
      If ( a >= nw ) Or ( b Div 16 >= nh ) Or ( b Mod 16 >= nd ) Or ( c Div 4 >= ni ) Then goto 11 ;
      Case c Mod 4 Of 
        1 : If d >= nl Then goto 11 ;
        3 : If d >= ne Then goto 11 ;
        2 :
            Begin
              Begin
                If ( d < bc ) Or ( d > ec ) Then goto 11
              End ;
              While d < k + bc - fmemptr Do
                Begin
                  qw := fontinfo [ charbase [ f ] + d ] . qqqq ;
                  If ( ( qw . b2 - 0 ) Mod 4 ) <> 2 Then goto 45 ;
                  d := qw . b3 - 0 ;
                End ;
              If d = k + bc - fmemptr Then goto 11 ;
              45 :
            End ;
        others :
      End ;
    End ;
  Begin
    Begin
      alpha := 16 ;
      While z >= 8388608 Do
        Begin
          z := z Div 2 ;
          alpha := alpha + alpha ;
        End ;
      beta := 256 Div alpha ;
      alpha := alpha * z ;
    End ;
    For k := widthbase [ f ] To ligkernbase [ f ] - 1 Do
      Begin
        get ( tfmfile ) ;
        a := tfmfile ^ ;
        get ( tfmfile ) ;
        b := tfmfile ^ ;
        get ( tfmfile ) ;
        c := tfmfile ^ ;
        get ( tfmfile ) ;
        d := tfmfile ^ ;
        sw := ( ( ( ( ( d * z ) Div 256 ) + ( c * z ) ) Div 256 ) + ( b * z ) ) Div beta ;
        If a = 0 Then fontinfo [ k ] . int := sw
        Else If a = 255 Then fontinfo [ k ] . int := sw - alpha
        Else goto 11 ;
      End ;
    If fontinfo [ widthbase [ f ] ] . int <> 0 Then goto 11 ;
    If fontinfo [ heightbase [ f ] ] . int <> 0 Then goto 11 ;
    If fontinfo [ depthbase [ f ] ] . int <> 0 Then goto 11 ;
    If fontinfo [ italicbase [ f ] ] . int <> 0 Then goto 11 ;
  End ;
  bchlabel := 32767 ;
  bchar := 256 ;
  If nl > 0 Then
    Begin
      For k := ligkernbase [ f ] To kernbase [ f ] + 256 * ( 128 ) - 1 Do
        Begin
          Begin
            get ( tfmfile ) ;
            a := tfmfile ^ ;
            qw . b0 := a + 0 ;
            get ( tfmfile ) ;
            b := tfmfile ^ ;
            qw . b1 := b + 0 ;
            get ( tfmfile ) ;
            c := tfmfile ^ ;
            qw . b2 := c + 0 ;
            get ( tfmfile ) ;
            d := tfmfile ^ ;
            qw . b3 := d + 0 ;
            fontinfo [ k ] . qqqq := qw ;
          End ;
          If a > 128 Then
            Begin
              If 256 * c + d >= nl Then goto 11 ;
              If a = 255 Then If k = ligkernbase [ f ] Then bchar := b ;
            End
          Else
            Begin
              If b <> bchar Then
                Begin
                  Begin
                    If ( b < bc ) Or ( b > ec ) Then goto 11
                  End ;
                  qw := fontinfo [ charbase [ f ] + b ] . qqqq ;
                  If Not ( qw . b0 > 0 ) Then goto 11 ;
                End ;
              If c < 128 Then
                Begin
                  Begin
                    If ( d < bc ) Or ( d > ec ) Then goto 11
                  End ;
                  qw := fontinfo [ charbase [ f ] + d ] . qqqq ;
                  If Not ( qw . b0 > 0 ) Then goto 11 ;
                End
              Else If 256 * ( c - 128 ) + d >= nk Then goto 11 ;
              If a < 128 Then If k - ligkernbase [ f ] + a + 1 >= nl Then goto 11 ;
            End ;
        End ;
      If a = 255 Then bchlabel := 256 * c + d ;
    End ;
  For k := kernbase [ f ] + 256 * ( 128 ) To extenbase [ f ] - 1 Do
    Begin
      get ( tfmfile ) ;
      a := tfmfile ^ ;
      get ( tfmfile ) ;
      b := tfmfile ^ ;
      get ( tfmfile ) ;
      c := tfmfile ^ ;
      get ( tfmfile ) ;
      d := tfmfile ^ ;
      sw := ( ( ( ( ( d * z ) Div 256 ) + ( c * z ) ) Div 256 ) + ( b * z ) ) Div beta ;
      If a = 0 Then fontinfo [ k ] . int := sw
      Else If a = 255 Then fontinfo [ k ] . int := sw - alpha
      Else goto 11 ;
    End ; ;
  For k := extenbase [ f ] To parambase [ f ] - 1 Do
    Begin
      Begin
        get ( tfmfile ) ;
        a := tfmfile ^ ;
        qw . b0 := a + 0 ;
        get ( tfmfile ) ;
        b := tfmfile ^ ;
        qw . b1 := b + 0 ;
        get ( tfmfile ) ;
        c := tfmfile ^ ;
        qw . b2 := c + 0 ;
        get ( tfmfile ) ;
        d := tfmfile ^ ;
        qw . b3 := d + 0 ;
        fontinfo [ k ] . qqqq := qw ;
      End ;
      If a <> 0 Then
        Begin
          Begin
            If ( a < bc ) Or ( a > ec ) Then goto 11
          End ;
          qw := fontinfo [ charbase [ f ] + a ] . qqqq ;
          If Not ( qw . b0 > 0 ) Then goto 11 ;
        End ;
      If b <> 0 Then
        Begin
          Begin
            If ( b < bc ) Or ( b > ec ) Then goto 11
          End ;
          qw := fontinfo [ charbase [ f ] + b ] . qqqq ;
          If Not ( qw . b0 > 0 ) Then goto 11 ;
        End ;
      If c <> 0 Then
        Begin
          Begin
            If ( c < bc ) Or ( c > ec ) Then goto 11
          End ;
          qw := fontinfo [ charbase [ f ] + c ] . qqqq ;
          If Not ( qw . b0 > 0 ) Then goto 11 ;
        End ;
      Begin
        Begin
          If ( d < bc ) Or ( d > ec ) Then goto 11
        End ;
        qw := fontinfo [ charbase [ f ] + d ] . qqqq ;
        If Not ( qw . b0 > 0 ) Then goto 11 ;
      End ;
    End ;
  Begin
    For k := 1 To np Do
      If k = 1 Then
        Begin
          get ( tfmfile ) ;
          sw := tfmfile ^ ;
          If sw > 127 Then sw := sw - 256 ;
          get ( tfmfile ) ;
          sw := sw * 256 + tfmfile ^ ;
          get ( tfmfile ) ;
          sw := sw * 256 + tfmfile ^ ;
          get ( tfmfile ) ;
          fontinfo [ parambase [ f ] ] . int := ( sw * 16 ) + ( tfmfile ^ Div 16 ) ;
        End
      Else
        Begin
          get ( tfmfile ) ;
          a := tfmfile ^ ;
          get ( tfmfile ) ;
          b := tfmfile ^ ;
          get ( tfmfile ) ;
          c := tfmfile ^ ;
          get ( tfmfile ) ;
          d := tfmfile ^ ;
          sw := ( ( ( ( ( d * z ) Div 256 ) + ( c * z ) ) Div 256 ) + ( b * z ) ) Div beta ;
          If a = 0 Then fontinfo [ parambase [ f ] + k - 1 ] . int := sw
          Else If a = 255 Then fontinfo [ parambase [ f ] + k - 1 ] . int := sw - alpha
          Else goto 11 ;
        End ;
    If eof ( tfmfile ) Then goto 11 ;
    For k := np + 1 To 7 Do
      fontinfo [ parambase [ f ] + k - 1 ] . int := 0 ;
  End ;
  If np >= 7 Then fontparams [ f ] := np
  Else fontparams [ f ] := 7 ;
  hyphenchar [ f ] := eqtb [ 5309 ] . int ;
  skewchar [ f ] := eqtb [ 5310 ] . int ;
  If bchlabel < nl Then bcharlabel [ f ] := bchlabel + ligkernbase [ f ]
  Else bcharlabel [ f ] := 0 ;
  fontbchar [ f ] := bchar + 0 ;
  fontfalsebchar [ f ] := bchar + 0 ;
  If bchar <= ec Then If bchar >= bc Then
                        Begin
                          qw := fontinfo [ charbase [ f ] + bchar ] . qqqq ;
                          If ( qw . b0 > 0 ) Then fontfalsebchar [ f ] := 256 ;
                        End ;
  fontname [ f ] := nom ;
  fontarea [ f ] := aire ;
  fontbc [ f ] := bc ;
  fontec [ f ] := ec ;
  fontglue [ f ] := 0 ;
  charbase [ f ] := charbase [ f ] - 0 ;
  widthbase [ f ] := widthbase [ f ] - 0 ;
  ligkernbase [ f ] := ligkernbase [ f ] - 0 ;
  kernbase [ f ] := kernbase [ f ] - 0 ;
  extenbase [ f ] := extenbase [ f ] - 0 ;
  parambase [ f ] := parambase [ f ] - 1 ;
  fmemptr := fmemptr + lf ;
  fontptr := f ;
  g := f ;
  goto 30 ;
  11 :
       Begin
         If interaction = 3 Then ;
         printnl ( 262 ) ;
         print ( 801 ) ;
       End ;
  sprintcs ( u ) ;
  printchar ( 61 ) ;
  printfilename ( nom , aire , 338 ) ;
  If s >= 0 Then
    Begin
      print ( 741 ) ;
      printscaled ( s ) ;
      print ( 397 ) ;
    End
  Else If s <> - 1000 Then
         Begin
           print ( 802 ) ;
           printint ( - s ) ;
         End ;
  If fileopened Then print ( 803 )
  Else print ( 804 ) ;
  Begin
    helpptr := 5 ;
    helpline [ 4 ] := 805 ;
    helpline [ 3 ] := 806 ;
    helpline [ 2 ] := 807 ;
    helpline [ 1 ] := 808 ;
    helpline [ 0 ] := 809 ;
  End ;
  error ;
  30 : If fileopened Then bclose ( tfmfile ) ;
  readfontinfo := g ;
End ;
Procedure charwarning ( f : internalfontnumber ; c : eightbits ) ;
Begin
  If eqtb [ 5298 ] . int > 0 Then
    Begin
      begindiagnostic ;
      printnl ( 824 ) ;
      print ( c ) ;
      print ( 825 ) ;
      slowprint ( fontname [ f ] ) ;
      printchar ( 33 ) ;
      enddiagnostic ( false ) ;
    End ;
End ;
Function newcharacter ( f : internalfontnumber ; c : eightbits ) : halfword ;

Label 10 ;

Var p : halfword ;
Begin
  If fontbc [ f ] <= c Then If fontec [ f ] >= c Then If ( fontinfo [ charbase [ f ] + c + 0 ] . qqqq . b0 > 0 ) Then
                                                        Begin
                                                          p := getavail ;
                                                          mem [ p ] . hh . b0 := f ;
                                                          mem [ p ] . hh . b1 := c + 0 ;
                                                          newcharacter := p ;
                                                          goto 10 ;
                                                        End ;
  charwarning ( f , c ) ;
  newcharacter := 0 ;
  10 :
End ;
Procedure writedvi ( a , b : dviindex ) ;

Var k : dviindex ;
Begin
  For k := a To b Do
    write ( dvifile , dvibuf [ k ] ) ;
End ;
Procedure dviswap ;
Begin
  If dvilimit = dvibufsize Then
    Begin
      writedvi ( 0 , halfbuf - 1 ) ;
      dvilimit := halfbuf ;
      dvioffset := dvioffset + dvibufsize ;
      dviptr := 0 ;
    End
  Else
    Begin
      writedvi ( halfbuf , dvibufsize - 1 ) ;
      dvilimit := dvibufsize ;
    End ;
  dvigone := dvigone + halfbuf ;
End ;
Procedure dvifour ( x : integer ) ;
Begin
  If x >= 0 Then
    Begin
      dvibuf [ dviptr ] := x Div 16777216 ;
      dviptr := dviptr + 1 ;
      If dviptr = dvilimit Then dviswap ;
    End
  Else
    Begin
      x := x + 1073741824 ;
      x := x + 1073741824 ;
      Begin
        dvibuf [ dviptr ] := ( x Div 16777216 ) + 128 ;
        dviptr := dviptr + 1 ;
        If dviptr = dvilimit Then dviswap ;
      End ;
    End ;
  x := x Mod 16777216 ;
  Begin
    dvibuf [ dviptr ] := x Div 65536 ;
    dviptr := dviptr + 1 ;
    If dviptr = dvilimit Then dviswap ;
  End ;
  x := x Mod 65536 ;
  Begin
    dvibuf [ dviptr ] := x Div 256 ;
    dviptr := dviptr + 1 ;
    If dviptr = dvilimit Then dviswap ;
  End ;
  Begin
    dvibuf [ dviptr ] := x Mod 256 ;
    dviptr := dviptr + 1 ;
    If dviptr = dvilimit Then dviswap ;
  End ;
End ;
Procedure dvipop ( l : integer ) ;
Begin
  If ( l = dvioffset + dviptr ) And ( dviptr > 0 ) Then dviptr := dviptr - 1
  Else
    Begin
      dvibuf [ dviptr ] := 142 ;
      dviptr := dviptr + 1 ;
      If dviptr = dvilimit Then dviswap ;
    End ;
End ;
Procedure dvifontdef ( f : internalfontnumber ) ;

Var k : poolpointer ;
Begin
  Begin
    dvibuf [ dviptr ] := 243 ;
    dviptr := dviptr + 1 ;
    If dviptr = dvilimit Then dviswap ;
  End ;
  Begin
    dvibuf [ dviptr ] := f - 1 ;
    dviptr := dviptr + 1 ;
    If dviptr = dvilimit Then dviswap ;
  End ;
  Begin
    dvibuf [ dviptr ] := fontcheck [ f ] . b0 - 0 ;
    dviptr := dviptr + 1 ;
    If dviptr = dvilimit Then dviswap ;
  End ;
  Begin
    dvibuf [ dviptr ] := fontcheck [ f ] . b1 - 0 ;
    dviptr := dviptr + 1 ;
    If dviptr = dvilimit Then dviswap ;
  End ;
  Begin
    dvibuf [ dviptr ] := fontcheck [ f ] . b2 - 0 ;
    dviptr := dviptr + 1 ;
    If dviptr = dvilimit Then dviswap ;
  End ;
  Begin
    dvibuf [ dviptr ] := fontcheck [ f ] . b3 - 0 ;
    dviptr := dviptr + 1 ;
    If dviptr = dvilimit Then dviswap ;
  End ;
  dvifour ( fontsize [ f ] ) ;
  dvifour ( fontdsize [ f ] ) ;
  Begin
    dvibuf [ dviptr ] := ( strstart [ fontarea [ f ] + 1 ] - strstart [ fontarea [ f ] ] ) ;
    dviptr := dviptr + 1 ;
    If dviptr = dvilimit Then dviswap ;
  End ;
  Begin
    dvibuf [ dviptr ] := ( strstart [ fontname [ f ] + 1 ] - strstart [ fontname [ f ] ] ) ;
    dviptr := dviptr + 1 ;
    If dviptr = dvilimit Then dviswap ;
  End ;
  For k := strstart [ fontarea [ f ] ] To strstart [ fontarea [ f ] + 1 ] - 1 Do
    Begin
      dvibuf [ dviptr ] := strpool [ k ] ;
      dviptr := dviptr + 1 ;
      If dviptr = dvilimit Then dviswap ;
    End ;
  For k := strstart [ fontname [ f ] ] To strstart [ fontname [ f ] + 1 ] - 1 Do
    Begin
      dvibuf [ dviptr ] := strpool [ k ] ;
      dviptr := dviptr + 1 ;
      If dviptr = dvilimit Then dviswap ;
    End ;
End ;
Procedure movement ( w : scaled ; o : eightbits ) ;

Label 10 , 40 , 45 , 2 , 1 ;

Var mstate : smallnumber ;
  p , q : halfword ;
  k : integer ;
Begin
  q := getnode ( 3 ) ;
  mem [ q + 1 ] . int := w ;
  mem [ q + 2 ] . int := dvioffset + dviptr ;
  If o = 157 Then
    Begin
      mem [ q ] . hh . rh := downptr ;
      downptr := q ;
    End
  Else
    Begin
      mem [ q ] . hh . rh := rightptr ;
      rightptr := q ;
    End ;
  p := mem [ q ] . hh . rh ;
  mstate := 0 ;
  While p <> 0 Do
    Begin
      If mem [ p + 1 ] . int = w Then Case mstate + mem [ p ] . hh . lh Of 
                                        3 , 4 , 15 , 16 : If mem [ p + 2 ] . int < dvigone Then goto 45
                                                          Else
                                                            Begin
                                                              k := mem [ p + 2 ] . int - dvioffset ;
                                                              If k < 0 Then k := k + dvibufsize ;
                                                              dvibuf [ k ] := dvibuf [ k ] + 5 ;
                                                              mem [ p ] . hh . lh := 1 ;
                                                              goto 40 ;
                                                            End ;
                                        5 , 9 , 11 : If mem [ p + 2 ] . int < dvigone Then goto 45
                                                     Else
                                                       Begin
                                                         k := mem [ p + 2 ] . int - dvioffset ;
                                                         If k < 0 Then k := k + dvibufsize ;
                                                         dvibuf [ k ] := dvibuf [ k ] + 10 ;
                                                         mem [ p ] . hh . lh := 2 ;
                                                         goto 40 ;
                                                       End ;
                                        1 , 2 , 8 , 13 : goto 40 ;
                                        others :
        End
      Else Case mstate + mem [ p ] . hh . lh Of 
             1 : mstate := 6 ;
             2 : mstate := 12 ;
             8 , 13 : goto 45 ;
             others :
        End ;
      p := mem [ p ] . hh . rh ;
    End ;
  45 : ;
  mem [ q ] . hh . lh := 3 ;
  If abs ( w ) >= 8388608 Then
    Begin
      Begin
        dvibuf [ dviptr ] := o + 3 ;
        dviptr := dviptr + 1 ;
        If dviptr = dvilimit Then dviswap ;
      End ;
      dvifour ( w ) ;
      goto 10 ;
    End ;
  If abs ( w ) >= 32768 Then
    Begin
      Begin
        dvibuf [ dviptr ] := o + 2 ;
        dviptr := dviptr + 1 ;
        If dviptr = dvilimit Then dviswap ;
      End ;
      If w < 0 Then w := w + 16777216 ;
      Begin
        dvibuf [ dviptr ] := w Div 65536 ;
        dviptr := dviptr + 1 ;
        If dviptr = dvilimit Then dviswap ;
      End ;
      w := w Mod 65536 ;
      goto 2 ;
    End ;
  If abs ( w ) >= 128 Then
    Begin
      Begin
        dvibuf [ dviptr ] := o + 1 ;
        dviptr := dviptr + 1 ;
        If dviptr = dvilimit Then dviswap ;
      End ;
      If w < 0 Then w := w + 65536 ;
      goto 2 ;
    End ;
  Begin
    dvibuf [ dviptr ] := o ;
    dviptr := dviptr + 1 ;
    If dviptr = dvilimit Then dviswap ;
  End ;
  If w < 0 Then w := w + 256 ;
  goto 1 ;
  2 :
      Begin
        dvibuf [ dviptr ] := w Div 256 ;
        dviptr := dviptr + 1 ;
        If dviptr = dvilimit Then dviswap ;
      End ;
  1 :
      Begin
        dvibuf [ dviptr ] := w Mod 256 ;
        dviptr := dviptr + 1 ;
        If dviptr = dvilimit Then dviswap ;
      End ;
  goto 10 ;
  40 : mem [ q ] . hh . lh := mem [ p ] . hh . lh ;
  If mem [ q ] . hh . lh = 1 Then
    Begin
      Begin
        dvibuf [ dviptr ] := o + 4 ;
        dviptr := dviptr + 1 ;
        If dviptr = dvilimit Then dviswap ;
      End ;
      While mem [ q ] . hh . rh <> p Do
        Begin
          q := mem [ q ] . hh . rh ;
          Case mem [ q ] . hh . lh Of 
            3 : mem [ q ] . hh . lh := 5 ;
            4 : mem [ q ] . hh . lh := 6 ;
            others :
          End ;
        End ;
    End
  Else
    Begin
      Begin
        dvibuf [ dviptr ] := o + 9 ;
        dviptr := dviptr + 1 ;
        If dviptr = dvilimit Then dviswap ;
      End ;
      While mem [ q ] . hh . rh <> p Do
        Begin
          q := mem [ q ] . hh . rh ;
          Case mem [ q ] . hh . lh Of 
            3 : mem [ q ] . hh . lh := 4 ;
            5 : mem [ q ] . hh . lh := 6 ;
            others :
          End ;
        End ;
    End ;
  10 :
End ;
Procedure prunemovements ( l : integer ) ;

Label 30 , 10 ;

Var p : halfword ;
Begin
  While downptr <> 0 Do
    Begin
      If mem [ downptr + 2 ] . int < l Then goto 30 ;
      p := downptr ;
      downptr := mem [ p ] . hh . rh ;
      freenode ( p , 3 ) ;
    End ;
  30 : While rightptr <> 0 Do
         Begin
           If mem [ rightptr + 2 ] . int < l Then goto 10 ;
           p := rightptr ;
           rightptr := mem [ p ] . hh . rh ;
           freenode ( p , 3 ) ;
         End ;
  10 :
End ;
Procedure vlistout ;
forward ;
Procedure specialout ( p : halfword ) ;

Var oldsetting : 0 .. 21 ;
  k : poolpointer ;
Begin
  If curh <> dvih Then
    Begin
      movement ( curh - dvih , 143 ) ;
      dvih := curh ;
    End ;
  If curv <> dviv Then
    Begin
      movement ( curv - dviv , 157 ) ;
      dviv := curv ;
    End ;
  oldsetting := selector ;
  selector := 21 ;
  showtokenlist ( mem [ mem [ p + 1 ] . hh . rh ] . hh . rh , 0 , poolsize - poolptr ) ;
  selector := oldsetting ;
  Begin
    If poolptr + 1 > poolsize Then overflow ( 257 , poolsize - initpoolptr ) ;
  End ;
  If ( poolptr - strstart [ strptr ] ) < 256 Then
    Begin
      Begin
        dvibuf [ dviptr ] := 239 ;
        dviptr := dviptr + 1 ;
        If dviptr = dvilimit Then dviswap ;
      End ;
      Begin
        dvibuf [ dviptr ] := ( poolptr - strstart [ strptr ] ) ;
        dviptr := dviptr + 1 ;
        If dviptr = dvilimit Then dviswap ;
      End ;
    End
  Else
    Begin
      Begin
        dvibuf [ dviptr ] := 242 ;
        dviptr := dviptr + 1 ;
        If dviptr = dvilimit Then dviswap ;
      End ;
      dvifour ( ( poolptr - strstart [ strptr ] ) ) ;
    End ;
  For k := strstart [ strptr ] To poolptr - 1 Do
    Begin
      dvibuf [ dviptr ] := strpool [ k ] ;
      dviptr := dviptr + 1 ;
      If dviptr = dvilimit Then dviswap ;
    End ;
  poolptr := strstart [ strptr ] ;
End ;
Procedure writeout ( p : halfword ) ;

Var oldsetting : 0 .. 21 ;
  oldmode : integer ;
  j : smallnumber ;
  q , r : halfword ;
Begin
  q := getavail ;
  mem [ q ] . hh . lh := 637 ;
  r := getavail ;
  mem [ q ] . hh . rh := r ;
  mem [ r ] . hh . lh := 6717 ;
  begintokenlist ( q , 4 ) ;
  begintokenlist ( mem [ p + 1 ] . hh . rh , 15 ) ;
  q := getavail ;
  mem [ q ] . hh . lh := 379 ;
  begintokenlist ( q , 4 ) ;
  oldmode := curlist . modefield ;
  curlist . modefield := 0 ;
  curcs := writeloc ;
  q := scantoks ( false , true ) ;
  gettoken ;
  If curtok <> 6717 Then
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 1296 ) ;
      End ;
      Begin
        helpptr := 2 ;
        helpline [ 1 ] := 1297 ;
        helpline [ 0 ] := 1011 ;
      End ;
      error ;
      Repeat
        gettoken ;
      Until curtok = 6717 ;
    End ;
  curlist . modefield := oldmode ;
  endtokenlist ;
  oldsetting := selector ;
  j := mem [ p + 1 ] . hh . lh ;
  If writeopen [ j ] Then selector := j
  Else
    Begin
      If ( j = 17 ) And ( selector = 19 ) Then selector := 18 ;
      printnl ( 338 ) ;
    End ;
  tokenshow ( defref ) ;
  println ;
  flushlist ( defref ) ;
  selector := oldsetting ;
End ;
Procedure outwhat ( p : halfword ) ;

Var j : smallnumber ;
Begin
  Case mem [ p ] . hh . b1 Of 
    0 , 1 , 2 : If Not doingleaders Then
                  Begin
                    j := mem [ p + 1 ] . hh . lh ;
                    If mem [ p ] . hh . b1 = 1 Then writeout ( p )
                    Else
                      Begin
                        If writeopen [ j ] Then aclose ( writefile [ j ] ) ;
                        If mem [ p ] . hh . b1 = 2 Then writeopen [ j ] := false
                        Else If j < 16 Then
                               Begin
                                 curname := mem [ p + 1 ] . hh . rh ;
                                 curarea := mem [ p + 2 ] . hh . lh ;
                                 curext := mem [ p + 2 ] . hh . rh ;
                                 If curext = 338 Then curext := 790 ;
                                 packfilename ( curname , curarea , curext ) ;
                                 While Not aopenout ( writefile [ j ] ) Do
                                   promptfilename ( 1299 , 790 ) ;
                                 writeopen [ j ] := true ;
                               End ;
                      End ;
                  End ;
    3 : specialout ( p ) ;
    4 : ;
    others : confusion ( 1298 )
  End ;
End ;
Procedure hlistout ;

Label 21 , 13 , 14 , 15 ;

Var baseline : scaled ;
  leftedge : scaled ;
  saveh , savev : scaled ;
  thisbox : halfword ;
  gorder : glueord ;
  gsign : 0 .. 2 ;
  p : halfword ;
  saveloc : integer ;
  leaderbox : halfword ;
  leaderwd : scaled ;
  lx : scaled ;
  outerdoingleaders : boolean ;
  edge : scaled ;
  gluetemp : real ;
  curglue : real ;
  curg : scaled ;
Begin
  curg := 0 ;
  curglue := 0.0 ;
  thisbox := tempptr ;
  gorder := mem [ thisbox + 5 ] . hh . b1 ;
  gsign := mem [ thisbox + 5 ] . hh . b0 ;
  p := mem [ thisbox + 5 ] . hh . rh ;
  curs := curs + 1 ;
  If curs > 0 Then
    Begin
      dvibuf [ dviptr ] := 141 ;
      dviptr := dviptr + 1 ;
      If dviptr = dvilimit Then dviswap ;
    End ;
  If curs > maxpush Then maxpush := curs ;
  saveloc := dvioffset + dviptr ;
  baseline := curv ;
  leftedge := curh ;
  While p <> 0 Do
    21 : If ( p >= himemmin ) Then
           Begin
             If curh <> dvih Then
               Begin
                 movement ( curh - dvih , 143 ) ;
                 dvih := curh ;
               End ;
             If curv <> dviv Then
               Begin
                 movement ( curv - dviv , 157 ) ;
                 dviv := curv ;
               End ;
             Repeat
               f := mem [ p ] . hh . b0 ;
               c := mem [ p ] . hh . b1 ;
               If f <> dvif Then
                 Begin
                   If Not fontused [ f ] Then
                     Begin
                       dvifontdef ( f ) ;
                       fontused [ f ] := true ;
                     End ;
                   If f <= 64 Then
                     Begin
                       dvibuf [ dviptr ] := f + 170 ;
                       dviptr := dviptr + 1 ;
                       If dviptr = dvilimit Then dviswap ;
                     End
                   Else
                     Begin
                       Begin
                         dvibuf [ dviptr ] := 235 ;
                         dviptr := dviptr + 1 ;
                         If dviptr = dvilimit Then dviswap ;
                       End ;
                       Begin
                         dvibuf [ dviptr ] := f - 1 ;
                         dviptr := dviptr + 1 ;
                         If dviptr = dvilimit Then dviswap ;
                       End ;
                     End ;
                   dvif := f ;
                 End ;
               If c >= 128 Then
                 Begin
                   dvibuf [ dviptr ] := 128 ;
                   dviptr := dviptr + 1 ;
                   If dviptr = dvilimit Then dviswap ;
                 End ;
               Begin
                 dvibuf [ dviptr ] := c - 0 ;
                 dviptr := dviptr + 1 ;
                 If dviptr = dvilimit Then dviswap ;
               End ;
               curh := curh + fontinfo [ widthbase [ f ] + fontinfo [ charbase [ f ] + c ] . qqqq . b0 ] . int ;
               p := mem [ p ] . hh . rh ;
             Until Not ( p >= himemmin ) ;
             dvih := curh ;
           End
         Else
           Begin
             Case mem [ p ] . hh . b0 Of 
               0 , 1 : If mem [ p + 5 ] . hh . rh = 0 Then curh := curh + mem [ p + 1 ] . int
                       Else
                         Begin
                           saveh := dvih ;
                           savev := dviv ;
                           curv := baseline + mem [ p + 4 ] . int ;
                           tempptr := p ;
                           edge := curh ;
                           If mem [ p ] . hh . b0 = 1 Then vlistout
                           Else hlistout ;
                           dvih := saveh ;
                           dviv := savev ;
                           curh := edge + mem [ p + 1 ] . int ;
                           curv := baseline ;
                         End ;
               2 :
                   Begin
                     ruleht := mem [ p + 3 ] . int ;
                     ruledp := mem [ p + 2 ] . int ;
                     rulewd := mem [ p + 1 ] . int ;
                     goto 14 ;
                   End ;
               8 : outwhat ( p ) ;
               10 :
                    Begin
                      g := mem [ p + 1 ] . hh . lh ;
                      rulewd := mem [ g + 1 ] . int - curg ;
                      If gsign <> 0 Then
                        Begin
                          If gsign = 1 Then
                            Begin
                              If mem [ g ] . hh . b0 = gorder Then
                                Begin
                                  curglue := curglue + mem [ g + 2 ] . int ;
                                  gluetemp := mem [ thisbox + 6 ] . gr * curglue ;
                                  If gluetemp > 1000000000.0 Then gluetemp := 1000000000.0
                                  Else If gluetemp < - 1000000000.0 Then gluetemp := - 1000000000.0 ;
                                  curg := round ( gluetemp ) ;
                                End ;
                            End
                          Else If mem [ g ] . hh . b1 = gorder Then
                                 Begin
                                   curglue := curglue - mem [ g + 3 ] . int ;
                                   gluetemp := mem [ thisbox + 6 ] . gr * curglue ;
                                   If gluetemp > 1000000000.0 Then gluetemp := 1000000000.0
                                   Else If gluetemp < - 1000000000.0 Then gluetemp := - 1000000000.0 ;
                                   curg := round ( gluetemp ) ;
                                 End ;
                        End ;
                      rulewd := rulewd + curg ;
                      If mem [ p ] . hh . b1 >= 100 Then
                        Begin
                          leaderbox := mem [ p + 1 ] . hh . rh ;
                          If mem [ leaderbox ] . hh . b0 = 2 Then
                            Begin
                              ruleht := mem [ leaderbox + 3 ] . int ;
                              ruledp := mem [ leaderbox + 2 ] . int ;
                              goto 14 ;
                            End ;
                          leaderwd := mem [ leaderbox + 1 ] . int ;
                          If ( leaderwd > 0 ) And ( rulewd > 0 ) Then
                            Begin
                              rulewd := rulewd + 10 ;
                              edge := curh + rulewd ;
                              lx := 0 ;
                              If mem [ p ] . hh . b1 = 100 Then
                                Begin
                                  saveh := curh ;
                                  curh := leftedge + leaderwd * ( ( curh - leftedge ) Div leaderwd ) ;
                                  If curh < saveh Then curh := curh + leaderwd ;
                                End
                              Else
                                Begin
                                  lq := rulewd Div leaderwd ;
                                  lr := rulewd Mod leaderwd ;
                                  If mem [ p ] . hh . b1 = 101 Then curh := curh + ( lr Div 2 )
                                  Else
                                    Begin
                                      lx := lr Div ( lq + 1 ) ;
                                      curh := curh + ( ( lr - ( lq - 1 ) * lx ) Div 2 ) ;
                                    End ;
                                End ;
                              While curh + leaderwd <= edge Do
                                Begin
                                  curv := baseline + mem [ leaderbox + 4 ] . int ;
                                  If curv <> dviv Then
                                    Begin
                                      movement ( curv - dviv , 157 ) ;
                                      dviv := curv ;
                                    End ;
                                  savev := dviv ;
                                  If curh <> dvih Then
                                    Begin
                                      movement ( curh - dvih , 143 ) ;
                                      dvih := curh ;
                                    End ;
                                  saveh := dvih ;
                                  tempptr := leaderbox ;
                                  outerdoingleaders := doingleaders ;
                                  doingleaders := true ;
                                  If mem [ leaderbox ] . hh . b0 = 1 Then vlistout
                                  Else hlistout ;
                                  doingleaders := outerdoingleaders ;
                                  dviv := savev ;
                                  dvih := saveh ;
                                  curv := baseline ;
                                  curh := saveh + leaderwd + lx ;
                                End ;
                              curh := edge - 10 ;
                              goto 15 ;
                            End ;
                        End ;
                      goto 13 ;
                    End ;
               11 , 9 : curh := curh + mem [ p + 1 ] . int ;
               6 :
                   Begin
                     mem [ 29988 ] := mem [ p + 1 ] ;
                     mem [ 29988 ] . hh . rh := mem [ p ] . hh . rh ;
                     p := 29988 ;
                     goto 21 ;
                   End ;
               others :
             End ;
             goto 15 ;
             14 : If ( ruleht = - 1073741824 ) Then ruleht := mem [ thisbox + 3 ] . int ;
             If ( ruledp = - 1073741824 ) Then ruledp := mem [ thisbox + 2 ] . int ;
             ruleht := ruleht + ruledp ;
             If ( ruleht > 0 ) And ( rulewd > 0 ) Then
               Begin
                 If curh <> dvih Then
                   Begin
                     movement ( curh - dvih , 143 ) ;
                     dvih := curh ;
                   End ;
                 curv := baseline + ruledp ;
                 If curv <> dviv Then
                   Begin
                     movement ( curv - dviv , 157 ) ;
                     dviv := curv ;
                   End ;
                 Begin
                   dvibuf [ dviptr ] := 132 ;
                   dviptr := dviptr + 1 ;
                   If dviptr = dvilimit Then dviswap ;
                 End ;
                 dvifour ( ruleht ) ;
                 dvifour ( rulewd ) ;
                 curv := baseline ;
                 dvih := dvih + rulewd ;
               End ;
             13 : curh := curh + rulewd ;
             15 : p := mem [ p ] . hh . rh ;
           End ;
  prunemovements ( saveloc ) ;
  If curs > 0 Then dvipop ( saveloc ) ;
  curs := curs - 1 ;
End ;
Procedure vlistout ;

Label 13 , 14 , 15 ;

Var leftedge : scaled ;
  topedge : scaled ;
  saveh , savev : scaled ;
  thisbox : halfword ;
  gorder : glueord ;
  gsign : 0 .. 2 ;
  p : halfword ;
  saveloc : integer ;
  leaderbox : halfword ;
  leaderht : scaled ;
  lx : scaled ;
  outerdoingleaders : boolean ;
  edge : scaled ;
  gluetemp : real ;
  curglue : real ;
  curg : scaled ;
Begin
  curg := 0 ;
  curglue := 0.0 ;
  thisbox := tempptr ;
  gorder := mem [ thisbox + 5 ] . hh . b1 ;
  gsign := mem [ thisbox + 5 ] . hh . b0 ;
  p := mem [ thisbox + 5 ] . hh . rh ;
  curs := curs + 1 ;
  If curs > 0 Then
    Begin
      dvibuf [ dviptr ] := 141 ;
      dviptr := dviptr + 1 ;
      If dviptr = dvilimit Then dviswap ;
    End ;
  If curs > maxpush Then maxpush := curs ;
  saveloc := dvioffset + dviptr ;
  leftedge := curh ;
  curv := curv - mem [ thisbox + 3 ] . int ;
  topedge := curv ;
  While p <> 0 Do
    Begin
      If ( p >= himemmin ) Then confusion ( 827 )
      Else
        Begin
          Case mem [ p ] . hh . b0 Of 
            0 , 1 : If mem [ p + 5 ] . hh . rh = 0 Then curv := curv + mem [ p + 3 ] . int + mem [ p + 2 ] . int
                    Else
                      Begin
                        curv := curv + mem [ p + 3 ] . int ;
                        If curv <> dviv Then
                          Begin
                            movement ( curv - dviv , 157 ) ;
                            dviv := curv ;
                          End ;
                        saveh := dvih ;
                        savev := dviv ;
                        curh := leftedge + mem [ p + 4 ] . int ;
                        tempptr := p ;
                        If mem [ p ] . hh . b0 = 1 Then vlistout
                        Else hlistout ;
                        dvih := saveh ;
                        dviv := savev ;
                        curv := savev + mem [ p + 2 ] . int ;
                        curh := leftedge ;
                      End ;
            2 :
                Begin
                  ruleht := mem [ p + 3 ] . int ;
                  ruledp := mem [ p + 2 ] . int ;
                  rulewd := mem [ p + 1 ] . int ;
                  goto 14 ;
                End ;
            8 : outwhat ( p ) ;
            10 :
                 Begin
                   g := mem [ p + 1 ] . hh . lh ;
                   ruleht := mem [ g + 1 ] . int - curg ;
                   If gsign <> 0 Then
                     Begin
                       If gsign = 1 Then
                         Begin
                           If mem [ g ] . hh . b0 = gorder Then
                             Begin
                               curglue := curglue + mem [ g + 2 ] . int ;
                               gluetemp := mem [ thisbox + 6 ] . gr * curglue ;
                               If gluetemp > 1000000000.0 Then gluetemp := 1000000000.0
                               Else If gluetemp < - 1000000000.0 Then gluetemp := - 1000000000.0 ;
                               curg := round ( gluetemp ) ;
                             End ;
                         End
                       Else If mem [ g ] . hh . b1 = gorder Then
                              Begin
                                curglue := curglue - mem [ g + 3 ] . int ;
                                gluetemp := mem [ thisbox + 6 ] . gr * curglue ;
                                If gluetemp > 1000000000.0 Then gluetemp := 1000000000.0
                                Else If gluetemp < - 1000000000.0 Then gluetemp := - 1000000000.0 ;
                                curg := round ( gluetemp ) ;
                              End ;
                     End ;
                   ruleht := ruleht + curg ;
                   If mem [ p ] . hh . b1 >= 100 Then
                     Begin
                       leaderbox := mem [ p + 1 ] . hh . rh ;
                       If mem [ leaderbox ] . hh . b0 = 2 Then
                         Begin
                           rulewd := mem [ leaderbox + 1 ] . int ;
                           ruledp := 0 ;
                           goto 14 ;
                         End ;
                       leaderht := mem [ leaderbox + 3 ] . int + mem [ leaderbox + 2 ] . int ;
                       If ( leaderht > 0 ) And ( ruleht > 0 ) Then
                         Begin
                           ruleht := ruleht + 10 ;
                           edge := curv + ruleht ;
                           lx := 0 ;
                           If mem [ p ] . hh . b1 = 100 Then
                             Begin
                               savev := curv ;
                               curv := topedge + leaderht * ( ( curv - topedge ) Div leaderht ) ;
                               If curv < savev Then curv := curv + leaderht ;
                             End
                           Else
                             Begin
                               lq := ruleht Div leaderht ;
                               lr := ruleht Mod leaderht ;
                               If mem [ p ] . hh . b1 = 101 Then curv := curv + ( lr Div 2 )
                               Else
                                 Begin
                                   lx := lr Div ( lq + 1 ) ;
                                   curv := curv + ( ( lr - ( lq - 1 ) * lx ) Div 2 ) ;
                                 End ;
                             End ;
                           While curv + leaderht <= edge Do
                             Begin
                               curh := leftedge + mem [ leaderbox + 4 ] . int ;
                               If curh <> dvih Then
                                 Begin
                                   movement ( curh - dvih , 143 ) ;
                                   dvih := curh ;
                                 End ;
                               saveh := dvih ;
                               curv := curv + mem [ leaderbox + 3 ] . int ;
                               If curv <> dviv Then
                                 Begin
                                   movement ( curv - dviv , 157 ) ;
                                   dviv := curv ;
                                 End ;
                               savev := dviv ;
                               tempptr := leaderbox ;
                               outerdoingleaders := doingleaders ;
                               doingleaders := true ;
                               If mem [ leaderbox ] . hh . b0 = 1 Then vlistout
                               Else hlistout ;
                               doingleaders := outerdoingleaders ;
                               dviv := savev ;
                               dvih := saveh ;
                               curh := leftedge ;
                               curv := savev - mem [ leaderbox + 3 ] . int + leaderht + lx ;
                             End ;
                           curv := edge - 10 ;
                           goto 15 ;
                         End ;
                     End ;
                   goto 13 ;
                 End ;
            11 : curv := curv + mem [ p + 1 ] . int ;
            others :
          End ;
          goto 15 ;
          14 : If ( rulewd = - 1073741824 ) Then rulewd := mem [ thisbox + 1 ] . int ;
          ruleht := ruleht + ruledp ;
          curv := curv + ruleht ;
          If ( ruleht > 0 ) And ( rulewd > 0 ) Then
            Begin
              If curh <> dvih Then
                Begin
                  movement ( curh - dvih , 143 ) ;
                  dvih := curh ;
                End ;
              If curv <> dviv Then
                Begin
                  movement ( curv - dviv , 157 ) ;
                  dviv := curv ;
                End ;
              Begin
                dvibuf [ dviptr ] := 137 ;
                dviptr := dviptr + 1 ;
                If dviptr = dvilimit Then dviswap ;
              End ;
              dvifour ( ruleht ) ;
              dvifour ( rulewd ) ;
            End ;
          goto 15 ;
          13 : curv := curv + ruleht ;
        End ;
      15 : p := mem [ p ] . hh . rh ;
    End ;
  prunemovements ( saveloc ) ;
  If curs > 0 Then dvipop ( saveloc ) ;
  curs := curs - 1 ;
End ;
Procedure shipout ( p : halfword ) ;

Label 30 ;

Var pageloc : integer ;
  j , k : 0 .. 9 ;
  s : poolpointer ;
  oldsetting : 0 .. 21 ;
Begin
  If eqtb [ 5297 ] . int > 0 Then
    Begin
      printnl ( 338 ) ;
      println ;
      print ( 828 ) ;
    End ;
  If termoffset > maxprintline - 9 Then println
  Else If ( termoffset > 0 ) Or ( fileoffset > 0 ) Then printchar ( 32 ) ;
  printchar ( 91 ) ;
  j := 9 ;
  While ( eqtb [ 5318 + j ] . int = 0 ) And ( j > 0 ) Do
    j := j - 1 ;
  For k := 0 To j Do
    Begin
      printint ( eqtb [ 5318 + k ] . int ) ;
      If k < j Then printchar ( 46 ) ;
    End ;
  break ( termout ) ;
  If eqtb [ 5297 ] . int > 0 Then
    Begin
      printchar ( 93 ) ;
      begindiagnostic ;
      showbox ( p ) ;
      enddiagnostic ( true ) ;
    End ;
  If ( mem [ p + 3 ] . int > 1073741823 ) Or ( mem [ p + 2 ] . int > 1073741823 ) Or ( mem [ p + 3 ] . int + mem [ p + 2 ] . int + eqtb [ 5849 ] . int > 1073741823 ) Or ( mem [ p + 1 ] . int + eqtb [ 5848 ] . int > 1073741823 ) Then
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 832 ) ;
      End ;
      Begin
        helpptr := 2 ;
        helpline [ 1 ] := 833 ;
        helpline [ 0 ] := 834 ;
      End ;
      error ;
      If eqtb [ 5297 ] . int <= 0 Then
        Begin
          begindiagnostic ;
          printnl ( 835 ) ;
          showbox ( p ) ;
          enddiagnostic ( true ) ;
        End ;
      goto 30 ;
    End ;
  If mem [ p + 3 ] . int + mem [ p + 2 ] . int + eqtb [ 5849 ] . int > maxv Then maxv := mem [ p + 3 ] . int + mem [ p + 2 ] . int + eqtb [ 5849 ] . int ;
  If mem [ p + 1 ] . int + eqtb [ 5848 ] . int > maxh Then maxh := mem [ p + 1 ] . int + eqtb [ 5848 ] . int ;
  dvih := 0 ;
  dviv := 0 ;
  curh := eqtb [ 5848 ] . int ;
  dvif := 0 ;
  If outputfilename = 0 Then
    Begin
      If jobname = 0 Then openlogfile ;
      packjobname ( 793 ) ;
      While Not bopenout ( dvifile ) Do
        promptfilename ( 794 , 793 ) ;
      outputfilename := bmakenamestring ( dvifile ) ;
    End ;
  If totalpages = 0 Then
    Begin
      Begin
        dvibuf [ dviptr ] := 247 ;
        dviptr := dviptr + 1 ;
        If dviptr = dvilimit Then dviswap ;
      End ;
      Begin
        dvibuf [ dviptr ] := 2 ;
        dviptr := dviptr + 1 ;
        If dviptr = dvilimit Then dviswap ;
      End ;
      dvifour ( 25400000 ) ;
      dvifour ( 473628672 ) ;
      preparemag ;
      dvifour ( eqtb [ 5280 ] . int ) ;
      oldsetting := selector ;
      selector := 21 ;
      print ( 826 ) ;
      printint ( eqtb [ 5286 ] . int ) ;
      printchar ( 46 ) ;
      printtwo ( eqtb [ 5285 ] . int ) ;
      printchar ( 46 ) ;
      printtwo ( eqtb [ 5284 ] . int ) ;
      printchar ( 58 ) ;
      printtwo ( eqtb [ 5283 ] . int Div 60 ) ;
      printtwo ( eqtb [ 5283 ] . int Mod 60 ) ;
      selector := oldsetting ;
      Begin
        dvibuf [ dviptr ] := ( poolptr - strstart [ strptr ] ) ;
        dviptr := dviptr + 1 ;
        If dviptr = dvilimit Then dviswap ;
      End ;
      For s := strstart [ strptr ] To poolptr - 1 Do
        Begin
          dvibuf [ dviptr ] := strpool [ s ] ;
          dviptr := dviptr + 1 ;
          If dviptr = dvilimit Then dviswap ;
        End ;
      poolptr := strstart [ strptr ] ;
    End ;
  pageloc := dvioffset + dviptr ;
  Begin
    dvibuf [ dviptr ] := 139 ;
    dviptr := dviptr + 1 ;
    If dviptr = dvilimit Then dviswap ;
  End ;
  For k := 0 To 9 Do
    dvifour ( eqtb [ 5318 + k ] . int ) ;
  dvifour ( lastbop ) ;
  lastbop := pageloc ;
  curv := mem [ p + 3 ] . int + eqtb [ 5849 ] . int ;
  tempptr := p ;
  If mem [ p ] . hh . b0 = 1 Then vlistout
  Else hlistout ;
  Begin
    dvibuf [ dviptr ] := 140 ;
    dviptr := dviptr + 1 ;
    If dviptr = dvilimit Then dviswap ;
  End ;
  totalpages := totalpages + 1 ;
  curs := - 1 ;
  30 : ;
  If eqtb [ 5297 ] . int <= 0 Then printchar ( 93 ) ;
  deadcycles := 0 ;
  break ( termout ) ;
  flushnodelist ( p ) ; ;
End ;
Procedure scanspec ( c : groupcode ; threecodes : boolean ) ;

Label 40 ;

Var s : integer ;
  speccode : 0 .. 1 ;
Begin
  If threecodes Then s := savestack [ saveptr + 0 ] . int ;
  If scankeyword ( 841 ) Then speccode := 0
  Else If scankeyword ( 842 ) Then speccode := 1
  Else
    Begin
      speccode := 1 ;
      curval := 0 ;
      goto 40 ;
    End ;
  scandimen ( false , false , false ) ;
  40 : If threecodes Then
         Begin
           savestack [ saveptr + 0 ] . int := s ;
           saveptr := saveptr + 1 ;
         End ;
  savestack [ saveptr + 0 ] . int := speccode ;
  savestack [ saveptr + 1 ] . int := curval ;
  saveptr := saveptr + 2 ;
  newsavelevel ( c ) ;
  scanleftbrace ;
End ;
Function hpack ( p : halfword ; w : scaled ; m : smallnumber ) : halfword ;

Label 21 , 50 , 10 ;

Var r : halfword ;
  q : halfword ;
  h , d , x : scaled ;
  s : scaled ;
  g : halfword ;
  o : glueord ;
  f : internalfontnumber ;
  i : fourquarters ;
  hd : eightbits ;
Begin
  lastbadness := 0 ;
  r := getnode ( 7 ) ;
  mem [ r ] . hh . b0 := 0 ;
  mem [ r ] . hh . b1 := 0 ;
  mem [ r + 4 ] . int := 0 ;
  q := r + 5 ;
  mem [ q ] . hh . rh := p ;
  h := 0 ;
  d := 0 ;
  x := 0 ;
  totalstretch [ 0 ] := 0 ;
  totalshrink [ 0 ] := 0 ;
  totalstretch [ 1 ] := 0 ;
  totalshrink [ 1 ] := 0 ;
  totalstretch [ 2 ] := 0 ;
  totalshrink [ 2 ] := 0 ;
  totalstretch [ 3 ] := 0 ;
  totalshrink [ 3 ] := 0 ;
  While p <> 0 Do
    Begin
      21 : While ( p >= himemmin ) Do
             Begin
               f := mem [ p ] . hh . b0 ;
               i := fontinfo [ charbase [ f ] + mem [ p ] . hh . b1 ] . qqqq ;
               hd := i . b1 - 0 ;
               x := x + fontinfo [ widthbase [ f ] + i . b0 ] . int ;
               s := fontinfo [ heightbase [ f ] + ( hd ) Div 16 ] . int ;
               If s > h Then h := s ;
               s := fontinfo [ depthbase [ f ] + ( hd ) Mod 16 ] . int ;
               If s > d Then d := s ;
               p := mem [ p ] . hh . rh ;
             End ;
      If p <> 0 Then
        Begin
          Case mem [ p ] . hh . b0 Of 
            0 , 1 , 2 , 13 :
                             Begin
                               x := x + mem [ p + 1 ] . int ;
                               If mem [ p ] . hh . b0 >= 2 Then s := 0
                               Else s := mem [ p + 4 ] . int ;
                               If mem [ p + 3 ] . int - s > h Then h := mem [ p + 3 ] . int - s ;
                               If mem [ p + 2 ] . int + s > d Then d := mem [ p + 2 ] . int + s ;
                             End ;
            3 , 4 , 5 : If adjusttail <> 0 Then
                          Begin
                            While mem [ q ] . hh . rh <> p Do
                              q := mem [ q ] . hh . rh ;
                            If mem [ p ] . hh . b0 = 5 Then
                              Begin
                                mem [ adjusttail ] . hh . rh := mem [ p + 1 ] . int ;
                                While mem [ adjusttail ] . hh . rh <> 0 Do
                                  adjusttail := mem [ adjusttail ] . hh . rh ;
                                p := mem [ p ] . hh . rh ;
                                freenode ( mem [ q ] . hh . rh , 2 ) ;
                              End
                            Else
                              Begin
                                mem [ adjusttail ] . hh . rh := p ;
                                adjusttail := p ;
                                p := mem [ p ] . hh . rh ;
                              End ;
                            mem [ q ] . hh . rh := p ;
                            p := q ;
                          End ;
            8 : ;
            10 :
                 Begin
                   g := mem [ p + 1 ] . hh . lh ;
                   x := x + mem [ g + 1 ] . int ;
                   o := mem [ g ] . hh . b0 ;
                   totalstretch [ o ] := totalstretch [ o ] + mem [ g + 2 ] . int ;
                   o := mem [ g ] . hh . b1 ;
                   totalshrink [ o ] := totalshrink [ o ] + mem [ g + 3 ] . int ;
                   If mem [ p ] . hh . b1 >= 100 Then
                     Begin
                       g := mem [ p + 1 ] . hh . rh ;
                       If mem [ g + 3 ] . int > h Then h := mem [ g + 3 ] . int ;
                       If mem [ g + 2 ] . int > d Then d := mem [ g + 2 ] . int ;
                     End ;
                 End ;
            11 , 9 : x := x + mem [ p + 1 ] . int ;
            6 :
                Begin
                  mem [ 29988 ] := mem [ p + 1 ] ;
                  mem [ 29988 ] . hh . rh := mem [ p ] . hh . rh ;
                  p := 29988 ;
                  goto 21 ;
                End ;
            others :
          End ;
          p := mem [ p ] . hh . rh ;
        End ;
    End ;
  If adjusttail <> 0 Then mem [ adjusttail ] . hh . rh := 0 ;
  mem [ r + 3 ] . int := h ;
  mem [ r + 2 ] . int := d ;
  If m = 1 Then w := x + w ;
  mem [ r + 1 ] . int := w ;
  x := w - x ;
  If x = 0 Then
    Begin
      mem [ r + 5 ] . hh . b0 := 0 ;
      mem [ r + 5 ] . hh . b1 := 0 ;
      mem [ r + 6 ] . gr := 0.0 ;
      goto 10 ;
    End
  Else If x > 0 Then
         Begin
           If totalstretch [ 3 ] <> 0 Then o := 3
           Else If totalstretch [ 2 ] <> 0 Then o := 2
           Else If totalstretch [ 1 ] <> 0 Then o := 1
           Else o := 0 ;
           mem [ r + 5 ] . hh . b1 := o ;
           mem [ r + 5 ] . hh . b0 := 1 ;
           If totalstretch [ o ] <> 0 Then mem [ r + 6 ] . gr := x / totalstretch [ o ]
           Else
             Begin
               mem [ r + 5 ] . hh . b0 := 0 ;
               mem [ r + 6 ] . gr := 0.0 ;
             End ;
           If o = 0 Then If mem [ r + 5 ] . hh . rh <> 0 Then
                           Begin
                             lastbadness := badness ( x , totalstretch [ 0 ] ) ;
                             If lastbadness > eqtb [ 5289 ] . int Then
                               Begin
                                 println ;
                                 If lastbadness > 100 Then printnl ( 843 )
                                 Else printnl ( 844 ) ;
                                 print ( 845 ) ;
                                 printint ( lastbadness ) ;
                                 goto 50 ;
                               End ;
                           End ;
           goto 10 ;
         End
  Else
    Begin
      If totalshrink [ 3 ] <> 0 Then o := 3
      Else If totalshrink [ 2 ] <> 0 Then o := 2
      Else If totalshrink [ 1 ] <> 0 Then o := 1
      Else o := 0 ;
      mem [ r + 5 ] . hh . b1 := o ;
      mem [ r + 5 ] . hh . b0 := 2 ;
      If totalshrink [ o ] <> 0 Then mem [ r + 6 ] . gr := ( - x ) / totalshrink [ o ]
      Else
        Begin
          mem [ r + 5 ] . hh . b0 := 0 ;
          mem [ r + 6 ] . gr := 0.0 ;
        End ;
      If ( totalshrink [ o ] < - x ) And ( o = 0 ) And ( mem [ r + 5 ] . hh . rh <> 0 ) Then
        Begin
          lastbadness := 1000000 ;
          mem [ r + 6 ] . gr := 1.0 ;
          If ( - x - totalshrink [ 0 ] > eqtb [ 5838 ] . int ) Or ( eqtb [ 5289 ] . int < 100 ) Then
            Begin
              If ( eqtb [ 5846 ] . int > 0 ) And ( - x - totalshrink [ 0 ] > eqtb [ 5838 ] . int ) Then
                Begin
                  While mem [ q ] . hh . rh <> 0 Do
                    q := mem [ q ] . hh . rh ;
                  mem [ q ] . hh . rh := newrule ;
                  mem [ mem [ q ] . hh . rh + 1 ] . int := eqtb [ 5846 ] . int ;
                End ;
              println ;
              printnl ( 851 ) ;
              printscaled ( - x - totalshrink [ 0 ] ) ;
              print ( 852 ) ;
              goto 50 ;
            End ;
        End
      Else If o = 0 Then If mem [ r + 5 ] . hh . rh <> 0 Then
                           Begin
                             lastbadness := badness ( - x , totalshrink [ 0 ] ) ;
                             If lastbadness > eqtb [ 5289 ] . int Then
                               Begin
                                 println ;
                                 printnl ( 853 ) ;
                                 printint ( lastbadness ) ;
                                 goto 50 ;
                               End ;
                           End ;
      goto 10 ;
    End ;
  50 : If outputactive Then print ( 846 )
       Else
         Begin
           If packbeginline <> 0 Then
             Begin
               If packbeginline > 0 Then print ( 847 )
               Else print ( 848 ) ;
               printint ( abs ( packbeginline ) ) ;
               print ( 849 ) ;
             End
           Else print ( 850 ) ;
           printint ( line ) ;
         End ;
  println ;
  fontinshortdisplay := 0 ;
  shortdisplay ( mem [ r + 5 ] . hh . rh ) ;
  println ;
  begindiagnostic ;
  showbox ( r ) ;
  enddiagnostic ( true ) ;
  10 : hpack := r ;
End ;
Function vpackage ( p : halfword ; h : scaled ; m : smallnumber ; l : scaled ) : halfword ;

Label 50 , 10 ;

Var r : halfword ;
  w , d , x : scaled ;
  s : scaled ;
  g : halfword ;
  o : glueord ;
Begin
  lastbadness := 0 ;
  r := getnode ( 7 ) ;
  mem [ r ] . hh . b0 := 1 ;
  mem [ r ] . hh . b1 := 0 ;
  mem [ r + 4 ] . int := 0 ;
  mem [ r + 5 ] . hh . rh := p ;
  w := 0 ;
  d := 0 ;
  x := 0 ;
  totalstretch [ 0 ] := 0 ;
  totalshrink [ 0 ] := 0 ;
  totalstretch [ 1 ] := 0 ;
  totalshrink [ 1 ] := 0 ;
  totalstretch [ 2 ] := 0 ;
  totalshrink [ 2 ] := 0 ;
  totalstretch [ 3 ] := 0 ;
  totalshrink [ 3 ] := 0 ;
  While p <> 0 Do
    Begin
      If ( p >= himemmin ) Then confusion ( 854 )
      Else Case mem [ p ] . hh . b0 Of 
             0 , 1 , 2 , 13 :
                              Begin
                                x := x + d + mem [ p + 3 ] . int ;
                                d := mem [ p + 2 ] . int ;
                                If mem [ p ] . hh . b0 >= 2 Then s := 0
                                Else s := mem [ p + 4 ] . int ;
                                If mem [ p + 1 ] . int + s > w Then w := mem [ p + 1 ] . int + s ;
                              End ;
             8 : ;
             10 :
                  Begin
                    x := x + d ;
                    d := 0 ;
                    g := mem [ p + 1 ] . hh . lh ;
                    x := x + mem [ g + 1 ] . int ;
                    o := mem [ g ] . hh . b0 ;
                    totalstretch [ o ] := totalstretch [ o ] + mem [ g + 2 ] . int ;
                    o := mem [ g ] . hh . b1 ;
                    totalshrink [ o ] := totalshrink [ o ] + mem [ g + 3 ] . int ;
                    If mem [ p ] . hh . b1 >= 100 Then
                      Begin
                        g := mem [ p + 1 ] . hh . rh ;
                        If mem [ g + 1 ] . int > w Then w := mem [ g + 1 ] . int ;
                      End ;
                  End ;
             11 :
                  Begin
                    x := x + d + mem [ p + 1 ] . int ;
                    d := 0 ;
                  End ;
             others :
        End ;
      p := mem [ p ] . hh . rh ;
    End ;
  mem [ r + 1 ] . int := w ;
  If d > l Then
    Begin
      x := x + d - l ;
      mem [ r + 2 ] . int := l ;
    End
  Else mem [ r + 2 ] . int := d ;
  If m = 1 Then h := x + h ;
  mem [ r + 3 ] . int := h ;
  x := h - x ;
  If x = 0 Then
    Begin
      mem [ r + 5 ] . hh . b0 := 0 ;
      mem [ r + 5 ] . hh . b1 := 0 ;
      mem [ r + 6 ] . gr := 0.0 ;
      goto 10 ;
    End
  Else If x > 0 Then
         Begin
           If totalstretch [ 3 ] <> 0 Then o := 3
           Else If totalstretch [ 2 ] <> 0 Then o := 2
           Else If totalstretch [ 1 ] <> 0 Then o := 1
           Else o := 0 ;
           mem [ r + 5 ] . hh . b1 := o ;
           mem [ r + 5 ] . hh . b0 := 1 ;
           If totalstretch [ o ] <> 0 Then mem [ r + 6 ] . gr := x / totalstretch [ o ]
           Else
             Begin
               mem [ r + 5 ] . hh . b0 := 0 ;
               mem [ r + 6 ] . gr := 0.0 ;
             End ;
           If o = 0 Then If mem [ r + 5 ] . hh . rh <> 0 Then
                           Begin
                             lastbadness := badness ( x , totalstretch [ 0 ] ) ;
                             If lastbadness > eqtb [ 5290 ] . int Then
                               Begin
                                 println ;
                                 If lastbadness > 100 Then printnl ( 843 )
                                 Else printnl ( 844 ) ;
                                 print ( 855 ) ;
                                 printint ( lastbadness ) ;
                                 goto 50 ;
                               End ;
                           End ;
           goto 10 ;
         End
  Else
    Begin
      If totalshrink [ 3 ] <> 0 Then o := 3
      Else If totalshrink [ 2 ] <> 0 Then o := 2
      Else If totalshrink [ 1 ] <> 0 Then o := 1
      Else o := 0 ;
      mem [ r + 5 ] . hh . b1 := o ;
      mem [ r + 5 ] . hh . b0 := 2 ;
      If totalshrink [ o ] <> 0 Then mem [ r + 6 ] . gr := ( - x ) / totalshrink [ o ]
      Else
        Begin
          mem [ r + 5 ] . hh . b0 := 0 ;
          mem [ r + 6 ] . gr := 0.0 ;
        End ;
      If ( totalshrink [ o ] < - x ) And ( o = 0 ) And ( mem [ r + 5 ] . hh . rh <> 0 ) Then
        Begin
          lastbadness := 1000000 ;
          mem [ r + 6 ] . gr := 1.0 ;
          If ( - x - totalshrink [ 0 ] > eqtb [ 5839 ] . int ) Or ( eqtb [ 5290 ] . int < 100 ) Then
            Begin
              println ;
              printnl ( 856 ) ;
              printscaled ( - x - totalshrink [ 0 ] ) ;
              print ( 857 ) ;
              goto 50 ;
            End ;
        End
      Else If o = 0 Then If mem [ r + 5 ] . hh . rh <> 0 Then
                           Begin
                             lastbadness := badness ( - x , totalshrink [ 0 ] ) ;
                             If lastbadness > eqtb [ 5290 ] . int Then
                               Begin
                                 println ;
                                 printnl ( 858 ) ;
                                 printint ( lastbadness ) ;
                                 goto 50 ;
                               End ;
                           End ;
      goto 10 ;
    End ;
  50 : If outputactive Then print ( 846 )
       Else
         Begin
           If packbeginline <> 0 Then
             Begin
               print ( 848 ) ;
               printint ( abs ( packbeginline ) ) ;
               print ( 849 ) ;
             End
           Else print ( 850 ) ;
           printint ( line ) ;
           println ;
         End ;
  begindiagnostic ;
  showbox ( r ) ;
  enddiagnostic ( true ) ;
  10 : vpackage := r ;
End ;
Procedure appendtovlist ( b : halfword ) ;

Var d : scaled ;
  p : halfword ;
Begin
  If curlist . auxfield . int > - 65536000 Then
    Begin
      d := mem [ eqtb [ 2883 ] . hh . rh + 1 ] . int - curlist . auxfield . int - mem [ b + 3 ] . int ;
      If d < eqtb [ 5832 ] . int Then p := newparamglue ( 0 )
      Else
        Begin
          p := newskipparam ( 1 ) ;
          mem [ tempptr + 1 ] . int := d ;
        End ;
      mem [ curlist . tailfield ] . hh . rh := p ;
      curlist . tailfield := p ;
    End ;
  mem [ curlist . tailfield ] . hh . rh := b ;
  curlist . tailfield := b ;
  curlist . auxfield . int := mem [ b + 2 ] . int ;
End ;
Function newnoad : halfword ;

Var p : halfword ;
Begin
  p := getnode ( 4 ) ;
  mem [ p ] . hh . b0 := 16 ;
  mem [ p ] . hh . b1 := 0 ;
  mem [ p + 1 ] . hh := emptyfield ;
  mem [ p + 3 ] . hh := emptyfield ;
  mem [ p + 2 ] . hh := emptyfield ;
  newnoad := p ;
End ;
Function newstyle ( s : smallnumber ) : halfword ;

Var p : halfword ;
Begin
  p := getnode ( 3 ) ;
  mem [ p ] . hh . b0 := 14 ;
  mem [ p ] . hh . b1 := s ;
  mem [ p + 1 ] . int := 0 ;
  mem [ p + 2 ] . int := 0 ;
  newstyle := p ;
End ;
Function newchoice : halfword ;

Var p : halfword ;
Begin
  p := getnode ( 3 ) ;
  mem [ p ] . hh . b0 := 15 ;
  mem [ p ] . hh . b1 := 0 ;
  mem [ p + 1 ] . hh . lh := 0 ;
  mem [ p + 1 ] . hh . rh := 0 ;
  mem [ p + 2 ] . hh . lh := 0 ;
  mem [ p + 2 ] . hh . rh := 0 ;
  newchoice := p ;
End ;
Procedure showinfo ;
Begin
  shownodelist ( mem [ tempptr ] . hh . lh ) ;
End ;
Function fractionrule ( t : scaled ) : halfword ;

Var p : halfword ;
Begin
  p := newrule ;
  mem [ p + 3 ] . int := t ;
  mem [ p + 2 ] . int := 0 ;
  fractionrule := p ;
End ;
Function overbar ( b : halfword ; k , t : scaled ) : halfword ;

Var p , q : halfword ;
Begin
  p := newkern ( k ) ;
  mem [ p ] . hh . rh := b ;
  q := fractionrule ( t ) ;
  mem [ q ] . hh . rh := p ;
  p := newkern ( t ) ;
  mem [ p ] . hh . rh := q ;
  overbar := vpackage ( p , 0 , 1 , 1073741823 ) ;
End ;
Function charbox ( f : internalfontnumber ; c : quarterword ) : halfword ;

Var q : fourquarters ;
  hd : eightbits ;
  b , p : halfword ;
Begin
  q := fontinfo [ charbase [ f ] + c ] . qqqq ;
  hd := q . b1 - 0 ;
  b := newnullbox ;
  mem [ b + 1 ] . int := fontinfo [ widthbase [ f ] + q . b0 ] . int + fontinfo [ italicbase [ f ] + ( q . b2 - 0 ) Div 4 ] . int ;
  mem [ b + 3 ] . int := fontinfo [ heightbase [ f ] + ( hd ) Div 16 ] . int ;
  mem [ b + 2 ] . int := fontinfo [ depthbase [ f ] + ( hd ) Mod 16 ] . int ;
  p := getavail ;
  mem [ p ] . hh . b1 := c ;
  mem [ p ] . hh . b0 := f ;
  mem [ b + 5 ] . hh . rh := p ;
  charbox := b ;
End ;
Procedure stackintobox ( b : halfword ; f : internalfontnumber ; c : quarterword ) ;

Var p : halfword ;
Begin
  p := charbox ( f , c ) ;
  mem [ p ] . hh . rh := mem [ b + 5 ] . hh . rh ;
  mem [ b + 5 ] . hh . rh := p ;
  mem [ b + 3 ] . int := mem [ p + 3 ] . int ;
End ;
Function heightplusdepth ( f : internalfontnumber ; c : quarterword ) : scaled ;

Var q : fourquarters ;
  hd : eightbits ;
Begin
  q := fontinfo [ charbase [ f ] + c ] . qqqq ;
  hd := q . b1 - 0 ;
  heightplusdepth := fontinfo [ heightbase [ f ] + ( hd ) Div 16 ] . int + fontinfo [ depthbase [ f ] + ( hd ) Mod 16 ] . int ;
End ;
Function vardelimiter ( d : halfword ; s : smallnumber ; v : scaled ) : halfword ;

Label 40 , 22 ;

Var b : halfword ;
  f , g : internalfontnumber ;
  c , x , y : quarterword ;
  m , n : integer ;
  u : scaled ;
  w : scaled ;
  q : fourquarters ;
  hd : eightbits ;
  r : fourquarters ;
  z : smallnumber ;
  largeattempt : boolean ;
Begin
  f := 0 ;
  w := 0 ;
  largeattempt := false ;
  z := mem [ d ] . qqqq . b0 ;
  x := mem [ d ] . qqqq . b1 ;
  While true Do
    Begin
      If ( z <> 0 ) Or ( x <> 0 ) Then
        Begin
          z := z + s + 16 ;
          Repeat
            z := z - 16 ;
            g := eqtb [ 3935 + z ] . hh . rh ;
            If g <> 0 Then
              Begin
                y := x ;
                If ( y - 0 >= fontbc [ g ] ) And ( y - 0 <= fontec [ g ] ) Then
                  Begin
                    22 : q := fontinfo [ charbase [ g ] + y ] . qqqq ;
                    If ( q . b0 > 0 ) Then
                      Begin
                        If ( ( q . b2 - 0 ) Mod 4 ) = 3 Then
                          Begin
                            f := g ;
                            c := y ;
                            goto 40 ;
                          End ;
                        hd := q . b1 - 0 ;
                        u := fontinfo [ heightbase [ g ] + ( hd ) Div 16 ] . int + fontinfo [ depthbase [ g ] + ( hd ) Mod 16 ] . int ;
                        If u > w Then
                          Begin
                            f := g ;
                            c := y ;
                            w := u ;
                            If u >= v Then goto 40 ;
                          End ;
                        If ( ( q . b2 - 0 ) Mod 4 ) = 2 Then
                          Begin
                            y := q . b3 ;
                            goto 22 ;
                          End ;
                      End ;
                  End ;
              End ;
          Until z < 16 ;
        End ;
      If largeattempt Then goto 40 ;
      largeattempt := true ;
      z := mem [ d ] . qqqq . b2 ;
      x := mem [ d ] . qqqq . b3 ;
    End ;
  40 : If f <> 0 Then If ( ( q . b2 - 0 ) Mod 4 ) = 3 Then
                        Begin
                          b := newnullbox ;
                          mem [ b ] . hh . b0 := 1 ;
                          r := fontinfo [ extenbase [ f ] + q . b3 ] . qqqq ;
                          c := r . b3 ;
                          u := heightplusdepth ( f , c ) ;
                          w := 0 ;
                          q := fontinfo [ charbase [ f ] + c ] . qqqq ;
                          mem [ b + 1 ] . int := fontinfo [ widthbase [ f ] + q . b0 ] . int + fontinfo [ italicbase [ f ] + ( q . b2 - 0 ) Div 4 ] . int ;
                          c := r . b2 ;
                          If c <> 0 Then w := w + heightplusdepth ( f , c ) ;
                          c := r . b1 ;
                          If c <> 0 Then w := w + heightplusdepth ( f , c ) ;
                          c := r . b0 ;
                          If c <> 0 Then w := w + heightplusdepth ( f , c ) ;
                          n := 0 ;
                          If u > 0 Then While w < v Do
                                          Begin
                                            w := w + u ;
                                            n := n + 1 ;
                                            If r . b1 <> 0 Then w := w + u ;
                                          End ;
                          c := r . b2 ;
                          If c <> 0 Then stackintobox ( b , f , c ) ;
                          c := r . b3 ;
                          For m := 1 To n Do
                            stackintobox ( b , f , c ) ;
                          c := r . b1 ;
                          If c <> 0 Then
                            Begin
                              stackintobox ( b , f , c ) ;
                              c := r . b3 ;
                              For m := 1 To n Do
                                stackintobox ( b , f , c ) ;
                            End ;
                          c := r . b0 ;
                          If c <> 0 Then stackintobox ( b , f , c ) ;
                          mem [ b + 2 ] . int := w - mem [ b + 3 ] . int ;
                        End
       Else b := charbox ( f , c )
       Else
         Begin
           b := newnullbox ;
           mem [ b + 1 ] . int := eqtb [ 5841 ] . int ;
         End ;
  mem [ b + 4 ] . int := half ( mem [ b + 3 ] . int - mem [ b + 2 ] . int ) - fontinfo [ 22 + parambase [ eqtb [ 3937 + s ] . hh . rh ] ] . int ;
  vardelimiter := b ;
End ;
Function rebox ( b : halfword ; w : scaled ) : halfword ;

Var p : halfword ;
  f : internalfontnumber ;
  v : scaled ;
Begin
  If ( mem [ b + 1 ] . int <> w ) And ( mem [ b + 5 ] . hh . rh <> 0 ) Then
    Begin
      If mem [ b ] . hh . b0 = 1 Then b := hpack ( b , 0 , 1 ) ;
      p := mem [ b + 5 ] . hh . rh ;
      If ( ( p >= himemmin ) ) And ( mem [ p ] . hh . rh = 0 ) Then
        Begin
          f := mem [ p ] . hh . b0 ;
          v := fontinfo [ widthbase [ f ] + fontinfo [ charbase [ f ] + mem [ p ] . hh . b1 ] . qqqq . b0 ] . int ;
          If v <> mem [ b + 1 ] . int Then mem [ p ] . hh . rh := newkern ( mem [ b + 1 ] . int - v ) ;
        End ;
      freenode ( b , 7 ) ;
      b := newglue ( 12 ) ;
      mem [ b ] . hh . rh := p ;
      While mem [ p ] . hh . rh <> 0 Do
        p := mem [ p ] . hh . rh ;
      mem [ p ] . hh . rh := newglue ( 12 ) ;
      rebox := hpack ( b , w , 0 ) ;
    End
  Else
    Begin
      mem [ b + 1 ] . int := w ;
      rebox := b ;
    End ;
End ;
Function mathglue ( g : halfword ; m : scaled ) : halfword ;

Var p : halfword ;
  n : integer ;
  f : scaled ;
Begin
  n := xovern ( m , 65536 ) ;
  f := remainder ;
  If f < 0 Then
    Begin
      n := n - 1 ;
      f := f + 65536 ;
    End ;
  p := getnode ( 4 ) ;
  mem [ p + 1 ] . int := multandadd ( n , mem [ g + 1 ] . int , xnoverd ( mem [ g + 1 ] . int , f , 65536 ) , 1073741823 ) ;
  mem [ p ] . hh . b0 := mem [ g ] . hh . b0 ;
  If mem [ p ] . hh . b0 = 0 Then mem [ p + 2 ] . int := multandadd ( n , mem [ g + 2 ] . int , xnoverd ( mem [ g + 2 ] . int , f , 65536 ) , 1073741823 )
  Else mem [ p + 2 ] . int := mem [ g + 2 ] . int ;
  mem [ p ] . hh . b1 := mem [ g ] . hh . b1 ;
  If mem [ p ] . hh . b1 = 0 Then mem [ p + 3 ] . int := multandadd ( n , mem [ g + 3 ] . int , xnoverd ( mem [ g + 3 ] . int , f , 65536 ) , 1073741823 )
  Else mem [ p + 3 ] . int := mem [ g + 3 ] . int ;
  mathglue := p ;
End ;
Procedure mathkern ( p : halfword ; m : scaled ) ;

Var n : integer ;
  f : scaled ;
Begin
  If mem [ p ] . hh . b1 = 99 Then
    Begin
      n := xovern ( m , 65536 ) ;
      f := remainder ;
      If f < 0 Then
        Begin
          n := n - 1 ;
          f := f + 65536 ;
        End ;
      mem [ p + 1 ] . int := multandadd ( n , mem [ p + 1 ] . int , xnoverd ( mem [ p + 1 ] . int , f , 65536 ) , 1073741823 ) ;
      mem [ p ] . hh . b1 := 1 ;
    End ;
End ;
Procedure flushmath ;
Begin
  flushnodelist ( mem [ curlist . headfield ] . hh . rh ) ;
  flushnodelist ( curlist . auxfield . int ) ;
  mem [ curlist . headfield ] . hh . rh := 0 ;
  curlist . tailfield := curlist . headfield ;
  curlist . auxfield . int := 0 ;
End ;
Procedure mlisttohlist ;
forward ;
Function cleanbox ( p : halfword ; s : smallnumber ) : halfword ;

Label 40 ;

Var q : halfword ;
  savestyle : smallnumber ;
  x : halfword ;
  r : halfword ;
Begin
  Case mem [ p ] . hh . rh Of 
    1 :
        Begin
          curmlist := newnoad ;
          mem [ curmlist + 1 ] := mem [ p ] ;
        End ;
    2 :
        Begin
          q := mem [ p ] . hh . lh ;
          goto 40 ;
        End ;
    3 : curmlist := mem [ p ] . hh . lh ;
    others :
             Begin
               q := newnullbox ;
               goto 40 ;
             End
  End ;
  savestyle := curstyle ;
  curstyle := s ;
  mlistpenalties := false ;
  mlisttohlist ;
  q := mem [ 29997 ] . hh . rh ;
  curstyle := savestyle ;
  Begin
    If curstyle < 4 Then cursize := 0
    Else cursize := 16 * ( ( curstyle - 2 ) Div 2 ) ;
    curmu := xovern ( fontinfo [ 6 + parambase [ eqtb [ 3937 + cursize ] . hh . rh ] ] . int , 18 ) ;
  End ;
  40 : If ( q >= himemmin ) Or ( q = 0 ) Then x := hpack ( q , 0 , 1 )
       Else If ( mem [ q ] . hh . rh = 0 ) And ( mem [ q ] . hh . b0 <= 1 ) And ( mem [ q + 4 ] . int = 0 ) Then x := q
       Else x := hpack ( q , 0 , 1 ) ;
  q := mem [ x + 5 ] . hh . rh ;
  If ( q >= himemmin ) Then
    Begin
      r := mem [ q ] . hh . rh ;
      If r <> 0 Then If mem [ r ] . hh . rh = 0 Then If Not ( r >= himemmin ) Then If mem [ r ] . hh . b0 = 11 Then
                                                                                     Begin
                                                                                       freenode ( r , 2 ) ;
                                                                                       mem [ q ] . hh . rh := 0 ;
                                                                                     End ;
    End ;
  cleanbox := x ;
End ;
Procedure fetch ( a : halfword ) ;
Begin
  curc := mem [ a ] . hh . b1 ;
  curf := eqtb [ 3935 + mem [ a ] . hh . b0 + cursize ] . hh . rh ;
  If curf = 0 Then
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 338 ) ;
      End ;
      printsize ( cursize ) ;
      printchar ( 32 ) ;
      printint ( mem [ a ] . hh . b0 ) ;
      print ( 883 ) ;
      print ( curc - 0 ) ;
      printchar ( 41 ) ;
      Begin
        helpptr := 4 ;
        helpline [ 3 ] := 884 ;
        helpline [ 2 ] := 885 ;
        helpline [ 1 ] := 886 ;
        helpline [ 0 ] := 887 ;
      End ;
      error ;
      curi := nullcharacter ;
      mem [ a ] . hh . rh := 0 ;
    End
  Else
    Begin
      If ( curc - 0 >= fontbc [ curf ] ) And ( curc - 0 <= fontec [ curf ] ) Then curi := fontinfo [ charbase [ curf ] + curc ] . qqqq
      Else curi := nullcharacter ;
      If Not ( ( curi . b0 > 0 ) ) Then
        Begin
          charwarning ( curf , curc - 0 ) ;
          mem [ a ] . hh . rh := 0 ;
        End ;
    End ;
End ;
Procedure makeover ( q : halfword ) ;
Begin
  mem [ q + 1 ] . hh . lh := overbar ( cleanbox ( q + 1 , 2 * ( curstyle Div 2 ) + 1 ) , 3 * fontinfo [ 8 + parambase [ eqtb [ 3938 + cursize ] . hh . rh ] ] . int , fontinfo [ 8 + parambase [ eqtb [ 3938 + cursize ] . hh . rh ] ] . int ) ;
  mem [ q + 1 ] . hh . rh := 2 ;
End ;
Procedure makeunder ( q : halfword ) ;

Var p , x , y : halfword ;
  delta : scaled ;
Begin
  x := cleanbox ( q + 1 , curstyle ) ;
  p := newkern ( 3 * fontinfo [ 8 + parambase [ eqtb [ 3938 + cursize ] . hh . rh ] ] . int ) ;
  mem [ x ] . hh . rh := p ;
  mem [ p ] . hh . rh := fractionrule ( fontinfo [ 8 + parambase [ eqtb [ 3938 + cursize ] . hh . rh ] ] . int ) ;
  y := vpackage ( x , 0 , 1 , 1073741823 ) ;
  delta := mem [ y + 3 ] . int + mem [ y + 2 ] . int + fontinfo [ 8 + parambase [ eqtb [ 3938 + cursize ] . hh . rh ] ] . int ;
  mem [ y + 3 ] . int := mem [ x + 3 ] . int ;
  mem [ y + 2 ] . int := delta - mem [ y + 3 ] . int ;
  mem [ q + 1 ] . hh . lh := y ;
  mem [ q + 1 ] . hh . rh := 2 ;
End ;
Procedure makevcenter ( q : halfword ) ;

Var v : halfword ;
  delta : scaled ;
Begin
  v := mem [ q + 1 ] . hh . lh ;
  If mem [ v ] . hh . b0 <> 1 Then confusion ( 539 ) ;
  delta := mem [ v + 3 ] . int + mem [ v + 2 ] . int ;
  mem [ v + 3 ] . int := fontinfo [ 22 + parambase [ eqtb [ 3937 + cursize ] . hh . rh ] ] . int + half ( delta ) ;
  mem [ v + 2 ] . int := delta - mem [ v + 3 ] . int ;
End ;
Procedure makeradical ( q : halfword ) ;

Var x , y : halfword ;
  delta , clr : scaled ;
Begin
  x := cleanbox ( q + 1 , 2 * ( curstyle Div 2 ) + 1 ) ;
  If curstyle < 2 Then clr := fontinfo [ 8 + parambase [ eqtb [ 3938 + cursize ] . hh . rh ] ] . int + ( abs ( fontinfo [ 5 + parambase [ eqtb [ 3937 + cursize ] . hh . rh ] ] . int ) Div 4 )
  Else
    Begin
      clr := fontinfo [ 8 + parambase [ eqtb [ 3938 + cursize ] . hh . rh ] ] . int ;
      clr := clr + ( abs ( clr ) Div 4 ) ;
    End ;
  y := vardelimiter ( q + 4 , cursize , mem [ x + 3 ] . int + mem [ x + 2 ] . int + clr + fontinfo [ 8 + parambase [ eqtb [ 3938 + cursize ] . hh . rh ] ] . int ) ;
  delta := mem [ y + 2 ] . int - ( mem [ x + 3 ] . int + mem [ x + 2 ] . int + clr ) ;
  If delta > 0 Then clr := clr + half ( delta ) ;
  mem [ y + 4 ] . int := - ( mem [ x + 3 ] . int + clr ) ;
  mem [ y ] . hh . rh := overbar ( x , clr , mem [ y + 3 ] . int ) ;
  mem [ q + 1 ] . hh . lh := hpack ( y , 0 , 1 ) ;
  mem [ q + 1 ] . hh . rh := 2 ;
End ;
Procedure makemathaccent ( q : halfword ) ;

Label 30 , 31 ;

Var p , x , y : halfword ;
  a : integer ;
  c : quarterword ;
  f : internalfontnumber ;
  i : fourquarters ;
  s : scaled ;
  h : scaled ;
  delta : scaled ;
  w : scaled ;
Begin
  fetch ( q + 4 ) ;
  If ( curi . b0 > 0 ) Then
    Begin
      i := curi ;
      c := curc ;
      f := curf ;
      s := 0 ;
      If mem [ q + 1 ] . hh . rh = 1 Then
        Begin
          fetch ( q + 1 ) ;
          If ( ( curi . b2 - 0 ) Mod 4 ) = 1 Then
            Begin
              a := ligkernbase [ curf ] + curi . b3 ;
              curi := fontinfo [ a ] . qqqq ;
              If curi . b0 > 128 Then
                Begin
                  a := ligkernbase [ curf ] + 256 * curi . b2 + curi . b3 + 32768 - 256 * ( 128 ) ;
                  curi := fontinfo [ a ] . qqqq ;
                End ;
              While true Do
                Begin
                  If curi . b1 - 0 = skewchar [ curf ] Then
                    Begin
                      If curi . b2 >= 128 Then If curi . b0 <= 128 Then s := fontinfo [ kernbase [ curf ] + 256 * curi . b2 + curi . b3 ] . int ;
                      goto 31 ;
                    End ;
                  If curi . b0 >= 128 Then goto 31 ;
                  a := a + curi . b0 + 1 ;
                  curi := fontinfo [ a ] . qqqq ;
                End ;
            End ;
        End ;
      31 : ;
      x := cleanbox ( q + 1 , 2 * ( curstyle Div 2 ) + 1 ) ;
      w := mem [ x + 1 ] . int ;
      h := mem [ x + 3 ] . int ;
      While true Do
        Begin
          If ( ( i . b2 - 0 ) Mod 4 ) <> 2 Then goto 30 ;
          y := i . b3 ;
          i := fontinfo [ charbase [ f ] + y ] . qqqq ;
          If Not ( i . b0 > 0 ) Then goto 30 ;
          If fontinfo [ widthbase [ f ] + i . b0 ] . int > w Then goto 30 ;
          c := y ;
        End ;
      30 : ;
      If h < fontinfo [ 5 + parambase [ f ] ] . int Then delta := h
      Else delta := fontinfo [ 5 + parambase [ f ] ] . int ;
      If ( mem [ q + 2 ] . hh . rh <> 0 ) Or ( mem [ q + 3 ] . hh . rh <> 0 ) Then If mem [ q + 1 ] . hh . rh = 1 Then
                                                                                     Begin
                                                                                       flushnodelist ( x ) ;
                                                                                       x := newnoad ;
                                                                                       mem [ x + 1 ] := mem [ q + 1 ] ;
                                                                                       mem [ x + 2 ] := mem [ q + 2 ] ;
                                                                                       mem [ x + 3 ] := mem [ q + 3 ] ;
                                                                                       mem [ q + 2 ] . hh := emptyfield ;
                                                                                       mem [ q + 3 ] . hh := emptyfield ;
                                                                                       mem [ q + 1 ] . hh . rh := 3 ;
                                                                                       mem [ q + 1 ] . hh . lh := x ;
                                                                                       x := cleanbox ( q + 1 , curstyle ) ;
                                                                                       delta := delta + mem [ x + 3 ] . int - h ;
                                                                                       h := mem [ x + 3 ] . int ;
                                                                                     End ;
      y := charbox ( f , c ) ;
      mem [ y + 4 ] . int := s + half ( w - mem [ y + 1 ] . int ) ;
      mem [ y + 1 ] . int := 0 ;
      p := newkern ( - delta ) ;
      mem [ p ] . hh . rh := x ;
      mem [ y ] . hh . rh := p ;
      y := vpackage ( y , 0 , 1 , 1073741823 ) ;
      mem [ y + 1 ] . int := mem [ x + 1 ] . int ;
      If mem [ y + 3 ] . int < h Then
        Begin
          p := newkern ( h - mem [ y + 3 ] . int ) ;
          mem [ p ] . hh . rh := mem [ y + 5 ] . hh . rh ;
          mem [ y + 5 ] . hh . rh := p ;
          mem [ y + 3 ] . int := h ;
        End ;
      mem [ q + 1 ] . hh . lh := y ;
      mem [ q + 1 ] . hh . rh := 2 ;
    End ;
End ;
Procedure makefraction ( q : halfword ) ;

Var p , v , x , y , z : halfword ;
  delta , delta1 , delta2 , shiftup , shiftdown , clr : scaled ;
Begin
  If mem [ q + 1 ] . int = 1073741824 Then mem [ q + 1 ] . int := fontinfo [ 8 + parambase [ eqtb [ 3938 + cursize ] . hh . rh ] ] . int ;
  x := cleanbox ( q + 2 , curstyle + 2 - 2 * ( curstyle Div 6 ) ) ;
  z := cleanbox ( q + 3 , 2 * ( curstyle Div 2 ) + 3 - 2 * ( curstyle Div 6 ) ) ;
  If mem [ x + 1 ] . int < mem [ z + 1 ] . int Then x := rebox ( x , mem [ z + 1 ] . int )
  Else z := rebox ( z , mem [ x + 1 ] . int ) ;
  If curstyle < 2 Then
    Begin
      shiftup := fontinfo [ 8 + parambase [ eqtb [ 3937 + cursize ] . hh . rh ] ] . int ;
      shiftdown := fontinfo [ 11 + parambase [ eqtb [ 3937 + cursize ] . hh . rh ] ] . int ;
    End
  Else
    Begin
      shiftdown := fontinfo [ 12 + parambase [ eqtb [ 3937 + cursize ] . hh . rh ] ] . int ;
      If mem [ q + 1 ] . int <> 0 Then shiftup := fontinfo [ 9 + parambase [ eqtb [ 3937 + cursize ] . hh . rh ] ] . int
      Else shiftup := fontinfo [ 10 + parambase [ eqtb [ 3937 + cursize ] . hh . rh ] ] . int ;
    End ;
  If mem [ q + 1 ] . int = 0 Then
    Begin
      If curstyle < 2 Then clr := 7 * fontinfo [ 8 + parambase [ eqtb [ 3938 + cursize ] . hh . rh ] ] . int
      Else clr := 3 * fontinfo [ 8 + parambase [ eqtb [ 3938 + cursize ] . hh . rh ] ] . int ;
      delta := half ( clr - ( ( shiftup - mem [ x + 2 ] . int ) - ( mem [ z + 3 ] . int - shiftdown ) ) ) ;
      If delta > 0 Then
        Begin
          shiftup := shiftup + delta ;
          shiftdown := shiftdown + delta ;
        End ;
    End
  Else
    Begin
      If curstyle < 2 Then clr := 3 * mem [ q + 1 ] . int
      Else clr := mem [ q + 1 ] . int ;
      delta := half ( mem [ q + 1 ] . int ) ;
      delta1 := clr - ( ( shiftup - mem [ x + 2 ] . int ) - ( fontinfo [ 22 + parambase [ eqtb [ 3937 + cursize ] . hh . rh ] ] . int + delta ) ) ;
      delta2 := clr - ( ( fontinfo [ 22 + parambase [ eqtb [ 3937 + cursize ] . hh . rh ] ] . int - delta ) - ( mem [ z + 3 ] . int - shiftdown ) ) ;
      If delta1 > 0 Then shiftup := shiftup + delta1 ;
      If delta2 > 0 Then shiftdown := shiftdown + delta2 ;
    End ;
  v := newnullbox ;
  mem [ v ] . hh . b0 := 1 ;
  mem [ v + 3 ] . int := shiftup + mem [ x + 3 ] . int ;
  mem [ v + 2 ] . int := mem [ z + 2 ] . int + shiftdown ;
  mem [ v + 1 ] . int := mem [ x + 1 ] . int ;
  If mem [ q + 1 ] . int = 0 Then
    Begin
      p := newkern ( ( shiftup - mem [ x + 2 ] . int ) - ( mem [ z + 3 ] . int - shiftdown ) ) ;
      mem [ p ] . hh . rh := z ;
    End
  Else
    Begin
      y := fractionrule ( mem [ q + 1 ] . int ) ;
      p := newkern ( ( fontinfo [ 22 + parambase [ eqtb [ 3937 + cursize ] . hh . rh ] ] . int - delta ) - ( mem [ z + 3 ] . int - shiftdown ) ) ;
      mem [ y ] . hh . rh := p ;
      mem [ p ] . hh . rh := z ;
      p := newkern ( ( shiftup - mem [ x + 2 ] . int ) - ( fontinfo [ 22 + parambase [ eqtb [ 3937 + cursize ] . hh . rh ] ] . int + delta ) ) ;
      mem [ p ] . hh . rh := y ;
    End ;
  mem [ x ] . hh . rh := p ;
  mem [ v + 5 ] . hh . rh := x ;
  If curstyle < 2 Then delta := fontinfo [ 20 + parambase [ eqtb [ 3937 + cursize ] . hh . rh ] ] . int
  Else delta := fontinfo [ 21 + parambase [ eqtb [ 3937 + cursize ] . hh . rh ] ] . int ;
  x := vardelimiter ( q + 4 , cursize , delta ) ;
  mem [ x ] . hh . rh := v ;
  z := vardelimiter ( q + 5 , cursize , delta ) ;
  mem [ v ] . hh . rh := z ;
  mem [ q + 1 ] . int := hpack ( x , 0 , 1 ) ;
End ;
Function makeop ( q : halfword ) : scaled ;

Var delta : scaled ;
  p , v , x , y , z : halfword ;
  c : quarterword ;
  i : fourquarters ;
  shiftup , shiftdown : scaled ;
Begin
  If ( mem [ q ] . hh . b1 = 0 ) And ( curstyle < 2 ) Then mem [ q ] . hh . b1 := 1 ;
  If mem [ q + 1 ] . hh . rh = 1 Then
    Begin
      fetch ( q + 1 ) ;
      If ( curstyle < 2 ) And ( ( ( curi . b2 - 0 ) Mod 4 ) = 2 ) Then
        Begin
          c := curi . b3 ;
          i := fontinfo [ charbase [ curf ] + c ] . qqqq ;
          If ( i . b0 > 0 ) Then
            Begin
              curc := c ;
              curi := i ;
              mem [ q + 1 ] . hh . b1 := c ;
            End ;
        End ;
      delta := fontinfo [ italicbase [ curf ] + ( curi . b2 - 0 ) Div 4 ] . int ;
      x := cleanbox ( q + 1 , curstyle ) ;
      If ( mem [ q + 3 ] . hh . rh <> 0 ) And ( mem [ q ] . hh . b1 <> 1 ) Then mem [ x + 1 ] . int := mem [ x + 1 ] . int - delta ;
      mem [ x + 4 ] . int := half ( mem [ x + 3 ] . int - mem [ x + 2 ] . int ) - fontinfo [ 22 + parambase [ eqtb [ 3937 + cursize ] . hh . rh ] ] . int ;
      mem [ q + 1 ] . hh . rh := 2 ;
      mem [ q + 1 ] . hh . lh := x ;
    End
  Else delta := 0 ;
  If mem [ q ] . hh . b1 = 1 Then
    Begin
      x := cleanbox ( q + 2 , 2 * ( curstyle Div 4 ) + 4 + ( curstyle Mod 2 ) ) ;
      y := cleanbox ( q + 1 , curstyle ) ;
      z := cleanbox ( q + 3 , 2 * ( curstyle Div 4 ) + 5 ) ;
      v := newnullbox ;
      mem [ v ] . hh . b0 := 1 ;
      mem [ v + 1 ] . int := mem [ y + 1 ] . int ;
      If mem [ x + 1 ] . int > mem [ v + 1 ] . int Then mem [ v + 1 ] . int := mem [ x + 1 ] . int ;
      If mem [ z + 1 ] . int > mem [ v + 1 ] . int Then mem [ v + 1 ] . int := mem [ z + 1 ] . int ;
      x := rebox ( x , mem [ v + 1 ] . int ) ;
      y := rebox ( y , mem [ v + 1 ] . int ) ;
      z := rebox ( z , mem [ v + 1 ] . int ) ;
      mem [ x + 4 ] . int := half ( delta ) ;
      mem [ z + 4 ] . int := - mem [ x + 4 ] . int ;
      mem [ v + 3 ] . int := mem [ y + 3 ] . int ;
      mem [ v + 2 ] . int := mem [ y + 2 ] . int ;
      If mem [ q + 2 ] . hh . rh = 0 Then
        Begin
          freenode ( x , 7 ) ;
          mem [ v + 5 ] . hh . rh := y ;
        End
      Else
        Begin
          shiftup := fontinfo [ 11 + parambase [ eqtb [ 3938 + cursize ] . hh . rh ] ] . int - mem [ x + 2 ] . int ;
          If shiftup < fontinfo [ 9 + parambase [ eqtb [ 3938 + cursize ] . hh . rh ] ] . int Then shiftup := fontinfo [ 9 + parambase [ eqtb [ 3938 + cursize ] . hh . rh ] ] . int ;
          p := newkern ( shiftup ) ;
          mem [ p ] . hh . rh := y ;
          mem [ x ] . hh . rh := p ;
          p := newkern ( fontinfo [ 13 + parambase [ eqtb [ 3938 + cursize ] . hh . rh ] ] . int ) ;
          mem [ p ] . hh . rh := x ;
          mem [ v + 5 ] . hh . rh := p ;
          mem [ v + 3 ] . int := mem [ v + 3 ] . int + fontinfo [ 13 + parambase [ eqtb [ 3938 + cursize ] . hh . rh ] ] . int + mem [ x + 3 ] . int + mem [ x + 2 ] . int + shiftup ;
        End ;
      If mem [ q + 3 ] . hh . rh = 0 Then freenode ( z , 7 )
      Else
        Begin
          shiftdown := fontinfo [ 12 + parambase [ eqtb [ 3938 + cursize ] . hh . rh ] ] . int - mem [ z + 3 ] . int ;
          If shiftdown < fontinfo [ 10 + parambase [ eqtb [ 3938 + cursize ] . hh . rh ] ] . int Then shiftdown := fontinfo [ 10 + parambase [ eqtb [ 3938 + cursize ] . hh . rh ] ] . int ;
          p := newkern ( shiftdown ) ;
          mem [ y ] . hh . rh := p ;
          mem [ p ] . hh . rh := z ;
          p := newkern ( fontinfo [ 13 + parambase [ eqtb [ 3938 + cursize ] . hh . rh ] ] . int ) ;
          mem [ z ] . hh . rh := p ;
          mem [ v + 2 ] . int := mem [ v + 2 ] . int + fontinfo [ 13 + parambase [ eqtb [ 3938 + cursize ] . hh . rh ] ] . int + mem [ z + 3 ] . int + mem [ z + 2 ] . int + shiftdown ;
        End ;
      mem [ q + 1 ] . int := v ;
    End ;
  makeop := delta ;
End ;
Procedure makeord ( q : halfword ) ;

Label 20 , 10 ;

Var a : integer ;
  p , r : halfword ;
Begin
  20 : If mem [ q + 3 ] . hh . rh = 0 Then If mem [ q + 2 ] . hh . rh = 0 Then If mem [ q + 1 ] . hh . rh = 1 Then
                                                                                 Begin
                                                                                   p := mem [ q ] . hh . rh ;
                                                                                   If p <> 0 Then If ( mem [ p ] . hh . b0 >= 16 ) And ( mem [ p ] . hh . b0 <= 22 ) Then If mem [ p + 1 ] . hh . rh = 1 Then If mem [ p + 1 ] . hh . b0 = mem [ q + 1 ] . hh . b0 Then
                                                                                                                                                                                                                Begin
                                                                                                                                                                                                                  mem [ q + 1 ] . hh . rh := 4 ;
                                                                                                                                                                                                                  fetch ( q + 1 ) ;
                                                                                                                                                                                                                  If ( ( curi . b2 - 0 ) Mod 4 ) = 1 Then
                                                                                                                                                                                                                    Begin
                                                                                                                                                                                                                      a := ligkernbase [ curf ] + curi . b3 ;
                                                                                                                                                                                                                      curc := mem [ p + 1 ] . hh . b1 ;
                                                                                                                                                                                                                      curi := fontinfo [ a ] . qqqq ;
                                                                                                                                                                                                                      If curi . b0 > 128 Then
                                                                                                                                                                                                                        Begin
                                                                                                                                                                                                                          a := ligkernbase [ curf ] + 256 * curi . b2 + curi . b3 + 32768 - 256 * ( 128 ) ;
                                                                                                                                                                                                                          curi := fontinfo [ a ] . qqqq ;
                                                                                                                                                                                                                        End ;
                                                                                                                                                                                                                      While true Do
                                                                                                                                                                                                                        Begin
                                                                                                                                                                                                                          If curi . b1 = curc Then If curi . b0 <= 128 Then If curi . b2 >= 128 Then
                                                                                                                                                                                                                                                                              Begin
                                                                                                                                                                                                                                                                                p := newkern ( fontinfo [ kernbase [ curf ] + 256 * curi . b2 + curi . b3 ] . int ) ;
                                                                                                                                                                                                                                                                                mem [ p ] . hh . rh := mem [ q ] . hh . rh ;
                                                                                                                                                                                                                                                                                mem [ q ] . hh . rh := p ;
                                                                                                                                                                                                                                                                                goto 10 ;
                                                                                                                                                                                                                                                                              End
                                                                                                                                                                                                                          Else
                                                                                                                                                                                                                            Begin
                                                                                                                                                                                                                              Begin
                                                                                                                                                                                                                                If interrupt <> 0 Then pauseforinstructions ;
                                                                                                                                                                                                                              End ;
                                                                                                                                                                                                                              Case curi . b2 Of 
                                                                                                                                                                                                                                1 , 5 : mem [ q + 1 ] . hh . b1 := curi . b3 ;
                                                                                                                                                                                                                                2 , 6 : mem [ p + 1 ] . hh . b1 := curi . b3 ;
                                                                                                                                                                                                                                3 , 7 , 11 :
                                                                                                                                                                                                                                             Begin
                                                                                                                                                                                                                                               r := newnoad ;
                                                                                                                                                                                                                                               mem [ r + 1 ] . hh . b1 := curi . b3 ;
                                                                                                                                                                                                                                               mem [ r + 1 ] . hh . b0 := mem [ q + 1 ] . hh . b0 ;
                                                                                                                                                                                                                                               mem [ q ] . hh . rh := r ;
                                                                                                                                                                                                                                               mem [ r ] . hh . rh := p ;
                                                                                                                                                                                                                                               If curi . b2 < 11 Then mem [ r + 1 ] . hh . rh := 1
                                                                                                                                                                                                                                               Else mem [ r + 1 ] . hh . rh := 4 ;
                                                                                                                                                                                                                                             End ;
                                                                                                                                                                                                                                others :
                                                                                                                                                                                                                                         Begin
                                                                                                                                                                                                                                           mem [ q ] . hh . rh := mem [ p ] . hh . rh ;
                                                                                                                                                                                                                                           mem [ q + 1 ] . hh . b1 := curi . b3 ;
                                                                                                                                                                                                                                           mem [ q + 3 ] := mem [ p + 3 ] ;
                                                                                                                                                                                                                                           mem [ q + 2 ] := mem [ p + 2 ] ;
                                                                                                                                                                                                                                           freenode ( p , 4 ) ;
                                                                                                                                                                                                                                         End
                                                                                                                                                                                                                              End ;
                                                                                                                                                                                                                              If curi . b2 > 3 Then goto 10 ;
                                                                                                                                                                                                                              mem [ q + 1 ] . hh . rh := 1 ;
                                                                                                                                                                                                                              goto 20 ;
                                                                                                                                                                                                                            End ;
                                                                                                                                                                                                                          If curi . b0 >= 128 Then goto 10 ;
                                                                                                                                                                                                                          a := a + curi . b0 + 1 ;
                                                                                                                                                                                                                          curi := fontinfo [ a ] . qqqq ;
                                                                                                                                                                                                                        End ;
                                                                                                                                                                                                                    End ;
                                                                                                                                                                                                                End ;
                                                                                 End ;
  10 :
End ;
Procedure makescripts ( q : halfword ; delta : scaled ) ;

Var p , x , y , z : halfword ;
  shiftup , shiftdown , clr : scaled ;
  t : smallnumber ;
Begin
  p := mem [ q + 1 ] . int ;
  If ( p >= himemmin ) Then
    Begin
      shiftup := 0 ;
      shiftdown := 0 ;
    End
  Else
    Begin
      z := hpack ( p , 0 , 1 ) ;
      If curstyle < 4 Then t := 16
      Else t := 32 ;
      shiftup := mem [ z + 3 ] . int - fontinfo [ 18 + parambase [ eqtb [ 3937 + t ] . hh . rh ] ] . int ;
      shiftdown := mem [ z + 2 ] . int + fontinfo [ 19 + parambase [ eqtb [ 3937 + t ] . hh . rh ] ] . int ;
      freenode ( z , 7 ) ;
    End ;
  If mem [ q + 2 ] . hh . rh = 0 Then
    Begin
      x := cleanbox ( q + 3 , 2 * ( curstyle Div 4 ) + 5 ) ;
      mem [ x + 1 ] . int := mem [ x + 1 ] . int + eqtb [ 5842 ] . int ;
      If shiftdown < fontinfo [ 16 + parambase [ eqtb [ 3937 + cursize ] . hh . rh ] ] . int Then shiftdown := fontinfo [ 16 + parambase [ eqtb [ 3937 + cursize ] . hh . rh ] ] . int ;
      clr := mem [ x + 3 ] . int - ( abs ( fontinfo [ 5 + parambase [ eqtb [ 3937 + cursize ] . hh . rh ] ] . int * 4 ) Div 5 ) ;
      If shiftdown < clr Then shiftdown := clr ;
      mem [ x + 4 ] . int := shiftdown ;
    End
  Else
    Begin
      Begin
        x := cleanbox ( q + 2 , 2 * ( curstyle Div 4 ) + 4 + ( curstyle Mod 2 ) ) ;
        mem [ x + 1 ] . int := mem [ x + 1 ] . int + eqtb [ 5842 ] . int ;
        If odd ( curstyle ) Then clr := fontinfo [ 15 + parambase [ eqtb [ 3937 + cursize ] . hh . rh ] ] . int
        Else If curstyle < 2 Then clr := fontinfo [ 13 + parambase [ eqtb [ 3937 + cursize ] . hh . rh ] ] . int
        Else clr := fontinfo [ 14 + parambase [ eqtb [ 3937 + cursize ] . hh . rh ] ] . int ;
        If shiftup < clr Then shiftup := clr ;
        clr := mem [ x + 2 ] . int + ( abs ( fontinfo [ 5 + parambase [ eqtb [ 3937 + cursize ] . hh . rh ] ] . int ) Div 4 ) ;
        If shiftup < clr Then shiftup := clr ;
      End ;
      If mem [ q + 3 ] . hh . rh = 0 Then mem [ x + 4 ] . int := - shiftup
      Else
        Begin
          y := cleanbox ( q + 3 , 2 * ( curstyle Div 4 ) + 5 ) ;
          mem [ y + 1 ] . int := mem [ y + 1 ] . int + eqtb [ 5842 ] . int ;
          If shiftdown < fontinfo [ 17 + parambase [ eqtb [ 3937 + cursize ] . hh . rh ] ] . int Then shiftdown := fontinfo [ 17 + parambase [ eqtb [ 3937 + cursize ] . hh . rh ] ] . int ;
          clr := 4 * fontinfo [ 8 + parambase [ eqtb [ 3938 + cursize ] . hh . rh ] ] . int - ( ( shiftup - mem [ x + 2 ] . int ) - ( mem [ y + 3 ] . int - shiftdown ) ) ;
          If clr > 0 Then
            Begin
              shiftdown := shiftdown + clr ;
              clr := ( abs ( fontinfo [ 5 + parambase [ eqtb [ 3937 + cursize ] . hh . rh ] ] . int * 4 ) Div 5 ) - ( shiftup - mem [ x + 2 ] . int ) ;
              If clr > 0 Then
                Begin
                  shiftup := shiftup + clr ;
                  shiftdown := shiftdown - clr ;
                End ;
            End ;
          mem [ x + 4 ] . int := delta ;
          p := newkern ( ( shiftup - mem [ x + 2 ] . int ) - ( mem [ y + 3 ] . int - shiftdown ) ) ;
          mem [ x ] . hh . rh := p ;
          mem [ p ] . hh . rh := y ;
          x := vpackage ( x , 0 , 1 , 1073741823 ) ;
          mem [ x + 4 ] . int := shiftdown ;
        End ;
    End ;
  If mem [ q + 1 ] . int = 0 Then mem [ q + 1 ] . int := x
  Else
    Begin
      p := mem [ q + 1 ] . int ;
      While mem [ p ] . hh . rh <> 0 Do
        p := mem [ p ] . hh . rh ;
      mem [ p ] . hh . rh := x ;
    End ;
End ;
Function makeleftright ( q : halfword ; style : smallnumber ; maxd , maxh : scaled ) : smallnumber ;

Var delta , delta1 , delta2 : scaled ;
Begin
  If style < 4 Then cursize := 0
  Else cursize := 16 * ( ( style - 2 ) Div 2 ) ;
  delta2 := maxd + fontinfo [ 22 + parambase [ eqtb [ 3937 + cursize ] . hh . rh ] ] . int ;
  delta1 := maxh + maxd - delta2 ;
  If delta2 > delta1 Then delta1 := delta2 ;
  delta := ( delta1 Div 500 ) * eqtb [ 5281 ] . int ;
  delta2 := delta1 + delta1 - eqtb [ 5840 ] . int ;
  If delta < delta2 Then delta := delta2 ;
  mem [ q + 1 ] . int := vardelimiter ( q + 1 , cursize , delta ) ;
  makeleftright := mem [ q ] . hh . b0 - ( 10 ) ;
End ;
Procedure mlisttohlist ;

Label 21 , 82 , 80 , 81 , 83 , 30 ;

Var mlist : halfword ;
  penalties : boolean ;
  style : smallnumber ;
  savestyle : smallnumber ;
  q : halfword ;
  r : halfword ;
  rtype : smallnumber ;
  t : smallnumber ;
  p , x , y , z : halfword ;
  pen : integer ;
  s : smallnumber ;
  maxh , maxd : scaled ;
  delta : scaled ;
Begin
  mlist := curmlist ;
  penalties := mlistpenalties ;
  style := curstyle ;
  q := mlist ;
  r := 0 ;
  rtype := 17 ;
  maxh := 0 ;
  maxd := 0 ;
  Begin
    If curstyle < 4 Then cursize := 0
    Else cursize := 16 * ( ( curstyle - 2 ) Div 2 ) ;
    curmu := xovern ( fontinfo [ 6 + parambase [ eqtb [ 3937 + cursize ] . hh . rh ] ] . int , 18 ) ;
  End ;
  While q <> 0 Do
    Begin
      21 : delta := 0 ;
      Case mem [ q ] . hh . b0 Of 
        18 : Case rtype Of 
               18 , 17 , 19 , 20 , 22 , 30 :
                                             Begin
                                               mem [ q ] . hh . b0 := 16 ;
                                               goto 21 ;
                                             End ;
               others :
             End ;
        19 , 21 , 22 , 31 :
                            Begin
                              If rtype = 18 Then mem [ r ] . hh . b0 := 16 ;
                              If mem [ q ] . hh . b0 = 31 Then goto 80 ;
                            End ;
        30 : goto 80 ;
        25 :
             Begin
               makefraction ( q ) ;
               goto 82 ;
             End ;
        17 :
             Begin
               delta := makeop ( q ) ;
               If mem [ q ] . hh . b1 = 1 Then goto 82 ;
             End ;
        16 : makeord ( q ) ;
        20 , 23 : ;
        24 : makeradical ( q ) ;
        27 : makeover ( q ) ;
        26 : makeunder ( q ) ;
        28 : makemathaccent ( q ) ;
        29 : makevcenter ( q ) ;
        14 :
             Begin
               curstyle := mem [ q ] . hh . b1 ;
               Begin
                 If curstyle < 4 Then cursize := 0
                 Else cursize := 16 * ( ( curstyle - 2 ) Div 2 ) ;
                 curmu := xovern ( fontinfo [ 6 + parambase [ eqtb [ 3937 + cursize ] . hh . rh ] ] . int , 18 ) ;
               End ;
               goto 81 ;
             End ;
        15 :
             Begin
               Case curstyle Div 2 Of 
                 0 :
                     Begin
                       p := mem [ q + 1 ] . hh . lh ;
                       mem [ q + 1 ] . hh . lh := 0 ;
                     End ;
                 1 :
                     Begin
                       p := mem [ q + 1 ] . hh . rh ;
                       mem [ q + 1 ] . hh . rh := 0 ;
                     End ;
                 2 :
                     Begin
                       p := mem [ q + 2 ] . hh . lh ;
                       mem [ q + 2 ] . hh . lh := 0 ;
                     End ;
                 3 :
                     Begin
                       p := mem [ q + 2 ] . hh . rh ;
                       mem [ q + 2 ] . hh . rh := 0 ;
                     End ;
               End ;
               flushnodelist ( mem [ q + 1 ] . hh . lh ) ;
               flushnodelist ( mem [ q + 1 ] . hh . rh ) ;
               flushnodelist ( mem [ q + 2 ] . hh . lh ) ;
               flushnodelist ( mem [ q + 2 ] . hh . rh ) ;
               mem [ q ] . hh . b0 := 14 ;
               mem [ q ] . hh . b1 := curstyle ;
               mem [ q + 1 ] . int := 0 ;
               mem [ q + 2 ] . int := 0 ;
               If p <> 0 Then
                 Begin
                   z := mem [ q ] . hh . rh ;
                   mem [ q ] . hh . rh := p ;
                   While mem [ p ] . hh . rh <> 0 Do
                     p := mem [ p ] . hh . rh ;
                   mem [ p ] . hh . rh := z ;
                 End ;
               goto 81 ;
             End ;
        3 , 4 , 5 , 8 , 12 , 7 : goto 81 ;
        2 :
            Begin
              If mem [ q + 3 ] . int > maxh Then maxh := mem [ q + 3 ] . int ;
              If mem [ q + 2 ] . int > maxd Then maxd := mem [ q + 2 ] . int ;
              goto 81 ;
            End ;
        10 :
             Begin
               If mem [ q ] . hh . b1 = 99 Then
                 Begin
                   x := mem [ q + 1 ] . hh . lh ;
                   y := mathglue ( x , curmu ) ;
                   deleteglueref ( x ) ;
                   mem [ q + 1 ] . hh . lh := y ;
                   mem [ q ] . hh . b1 := 0 ;
                 End
               Else If ( cursize <> 0 ) And ( mem [ q ] . hh . b1 = 98 ) Then
                      Begin
                        p := mem [ q ] . hh . rh ;
                        If p <> 0 Then If ( mem [ p ] . hh . b0 = 10 ) Or ( mem [ p ] . hh . b0 = 11 ) Then
                                         Begin
                                           mem [ q ] . hh . rh := mem [ p ] . hh . rh ;
                                           mem [ p ] . hh . rh := 0 ;
                                           flushnodelist ( p ) ;
                                         End ;
                      End ;
               goto 81 ;
             End ;
        11 :
             Begin
               mathkern ( q , curmu ) ;
               goto 81 ;
             End ;
        others : confusion ( 888 )
      End ;
      Case mem [ q + 1 ] . hh . rh Of 
        1 , 4 :
                Begin
                  fetch ( q + 1 ) ;
                  If ( curi . b0 > 0 ) Then
                    Begin
                      delta := fontinfo [ italicbase [ curf ] + ( curi . b2 - 0 ) Div 4 ] . int ;
                      p := newcharacter ( curf , curc - 0 ) ;
                      If ( mem [ q + 1 ] . hh . rh = 4 ) And ( fontinfo [ 2 + parambase [ curf ] ] . int <> 0 ) Then delta := 0 ;
                      If ( mem [ q + 3 ] . hh . rh = 0 ) And ( delta <> 0 ) Then
                        Begin
                          mem [ p ] . hh . rh := newkern ( delta ) ;
                          delta := 0 ;
                        End ;
                    End
                  Else p := 0 ;
                End ;
        0 : p := 0 ;
        2 : p := mem [ q + 1 ] . hh . lh ;
        3 :
            Begin
              curmlist := mem [ q + 1 ] . hh . lh ;
              savestyle := curstyle ;
              mlistpenalties := false ;
              mlisttohlist ;
              curstyle := savestyle ;
              Begin
                If curstyle < 4 Then cursize := 0
                Else cursize := 16 * ( ( curstyle - 2 ) Div 2 ) ;
                curmu := xovern ( fontinfo [ 6 + parambase [ eqtb [ 3937 + cursize ] . hh . rh ] ] . int , 18 ) ;
              End ;
              p := hpack ( mem [ 29997 ] . hh . rh , 0 , 1 ) ;
            End ;
        others : confusion ( 889 )
      End ;
      mem [ q + 1 ] . int := p ;
      If ( mem [ q + 3 ] . hh . rh = 0 ) And ( mem [ q + 2 ] . hh . rh = 0 ) Then goto 82 ;
      makescripts ( q , delta ) ;
      82 : z := hpack ( mem [ q + 1 ] . int , 0 , 1 ) ;
      If mem [ z + 3 ] . int > maxh Then maxh := mem [ z + 3 ] . int ;
      If mem [ z + 2 ] . int > maxd Then maxd := mem [ z + 2 ] . int ;
      freenode ( z , 7 ) ;
      80 : r := q ;
      rtype := mem [ r ] . hh . b0 ;
      81 : q := mem [ q ] . hh . rh ;
    End ;
  If rtype = 18 Then mem [ r ] . hh . b0 := 16 ;
  p := 29997 ;
  mem [ p ] . hh . rh := 0 ;
  q := mlist ;
  rtype := 0 ;
  curstyle := style ;
  Begin
    If curstyle < 4 Then cursize := 0
    Else cursize := 16 * ( ( curstyle - 2 ) Div 2 ) ;
    curmu := xovern ( fontinfo [ 6 + parambase [ eqtb [ 3937 + cursize ] . hh . rh ] ] . int , 18 ) ;
  End ;
  While q <> 0 Do
    Begin
      t := 16 ;
      s := 4 ;
      pen := 10000 ;
      Case mem [ q ] . hh . b0 Of 
        17 , 20 , 21 , 22 , 23 : t := mem [ q ] . hh . b0 ;
        18 :
             Begin
               t := 18 ;
               pen := eqtb [ 5272 ] . int ;
             End ;
        19 :
             Begin
               t := 19 ;
               pen := eqtb [ 5273 ] . int ;
             End ;
        16 , 29 , 27 , 26 : ;
        24 : s := 5 ;
        28 : s := 5 ;
        25 :
             Begin
               t := 23 ;
               s := 6 ;
             End ;
        30 , 31 : t := makeleftright ( q , style , maxd , maxh ) ;
        14 :
             Begin
               curstyle := mem [ q ] . hh . b1 ;
               s := 3 ;
               Begin
                 If curstyle < 4 Then cursize := 0
                 Else cursize := 16 * ( ( curstyle - 2 ) Div 2 ) ;
                 curmu := xovern ( fontinfo [ 6 + parambase [ eqtb [ 3937 + cursize ] . hh . rh ] ] . int , 18 ) ;
               End ;
               goto 83 ;
             End ;
        8 , 12 , 2 , 7 , 5 , 3 , 4 , 10 , 11 :
                                               Begin
                                                 mem [ p ] . hh . rh := q ;
                                                 p := q ;
                                                 q := mem [ q ] . hh . rh ;
                                                 mem [ p ] . hh . rh := 0 ;
                                                 goto 30 ;
                                               End ;
        others : confusion ( 890 )
      End ;
      If rtype > 0 Then
        Begin
          Case strpool [ rtype * 8 + t + magicoffset ] Of 
            48 : x := 0 ;
            49 : If curstyle < 4 Then x := 15
                 Else x := 0 ;
            50 : x := 15 ;
            51 : If curstyle < 4 Then x := 16
                 Else x := 0 ;
            52 : If curstyle < 4 Then x := 17
                 Else x := 0 ;
            others : confusion ( 892 )
          End ;
          If x <> 0 Then
            Begin
              y := mathglue ( eqtb [ 2882 + x ] . hh . rh , curmu ) ;
              z := newglue ( y ) ;
              mem [ y ] . hh . rh := 0 ;
              mem [ p ] . hh . rh := z ;
              p := z ;
              mem [ z ] . hh . b1 := x + 1 ;
            End ;
        End ;
      If mem [ q + 1 ] . int <> 0 Then
        Begin
          mem [ p ] . hh . rh := mem [ q + 1 ] . int ;
          Repeat
            p := mem [ p ] . hh . rh ;
          Until mem [ p ] . hh . rh = 0 ;
        End ;
      If penalties Then If mem [ q ] . hh . rh <> 0 Then If pen < 10000 Then
                                                           Begin
                                                             rtype := mem [ mem [ q ] . hh . rh ] . hh . b0 ;
                                                             If rtype <> 12 Then If rtype <> 19 Then
                                                                                   Begin
                                                                                     z := newpenalty ( pen ) ;
                                                                                     mem [ p ] . hh . rh := z ;
                                                                                     p := z ;
                                                                                   End ;
                                                           End ;
      rtype := t ;
      83 : r := q ;
      q := mem [ q ] . hh . rh ;
      freenode ( r , s ) ;
      30 :
    End ;
End ;
Procedure pushalignment ;

Var p : halfword ;
Begin
  p := getnode ( 5 ) ;
  mem [ p ] . hh . rh := alignptr ;
  mem [ p ] . hh . lh := curalign ;
  mem [ p + 1 ] . hh . lh := mem [ 29992 ] . hh . rh ;
  mem [ p + 1 ] . hh . rh := curspan ;
  mem [ p + 2 ] . int := curloop ;
  mem [ p + 3 ] . int := alignstate ;
  mem [ p + 4 ] . hh . lh := curhead ;
  mem [ p + 4 ] . hh . rh := curtail ;
  alignptr := p ;
  curhead := getavail ;
End ;
Procedure popalignment ;

Var p : halfword ;
Begin
  Begin
    mem [ curhead ] . hh . rh := avail ;
    avail := curhead ;
  End ;
  p := alignptr ;
  curtail := mem [ p + 4 ] . hh . rh ;
  curhead := mem [ p + 4 ] . hh . lh ;
  alignstate := mem [ p + 3 ] . int ;
  curloop := mem [ p + 2 ] . int ;
  curspan := mem [ p + 1 ] . hh . rh ;
  mem [ 29992 ] . hh . rh := mem [ p + 1 ] . hh . lh ;
  curalign := mem [ p ] . hh . lh ;
  alignptr := mem [ p ] . hh . rh ;
  freenode ( p , 5 ) ;
End ;
Procedure getpreambletoken ;

Label 20 ;
Begin
  20 : gettoken ;
  While ( curchr = 256 ) And ( curcmd = 4 ) Do
    Begin
      gettoken ;
      If curcmd > 100 Then
        Begin
          expand ;
          gettoken ;
        End ;
    End ;
  If curcmd = 9 Then fatalerror ( 595 ) ;
  If ( curcmd = 75 ) And ( curchr = 2893 ) Then
    Begin
      scanoptionalequals ;
      scanglue ( 2 ) ;
      If eqtb [ 5306 ] . int > 0 Then geqdefine ( 2893 , 117 , curval )
      Else eqdefine ( 2893 , 117 , curval ) ;
      goto 20 ;
    End ;
End ;
Procedure alignpeek ;
forward ;
Procedure normalparagraph ;
forward ;
Procedure initalign ;

Label 30 , 31 , 32 , 22 ;

Var savecsptr : halfword ;
  p : halfword ;
Begin
  savecsptr := curcs ;
  pushalignment ;
  alignstate := - 1000000 ;
  If ( curlist . modefield = 203 ) And ( ( curlist . tailfield <> curlist . headfield ) Or ( curlist . auxfield . int <> 0 ) ) Then
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 680 ) ;
      End ;
      printesc ( 520 ) ;
      print ( 893 ) ;
      Begin
        helpptr := 3 ;
        helpline [ 2 ] := 894 ;
        helpline [ 1 ] := 895 ;
        helpline [ 0 ] := 896 ;
      End ;
      error ;
      flushmath ;
    End ;
  pushnest ;
  If curlist . modefield = 203 Then
    Begin
      curlist . modefield := - 1 ;
      curlist . auxfield . int := nest [ nestptr - 2 ] . auxfield . int ;
    End
  Else If curlist . modefield > 0 Then curlist . modefield := - curlist . modefield ;
  scanspec ( 6 , false ) ;
  mem [ 29992 ] . hh . rh := 0 ;
  curalign := 29992 ;
  curloop := 0 ;
  scannerstatus := 4 ;
  warningindex := savecsptr ;
  alignstate := - 1000000 ;
  While true Do
    Begin
      mem [ curalign ] . hh . rh := newparamglue ( 11 ) ;
      curalign := mem [ curalign ] . hh . rh ;
      If curcmd = 5 Then goto 30 ;
      p := 29996 ;
      mem [ p ] . hh . rh := 0 ;
      While true Do
        Begin
          getpreambletoken ;
          If curcmd = 6 Then goto 31 ;
          If ( curcmd <= 5 ) And ( curcmd >= 4 ) And ( alignstate = - 1000000 ) Then If ( p = 29996 ) And ( curloop = 0 ) And ( curcmd = 4 ) Then curloop := curalign
          Else
            Begin
              Begin
                If interaction = 3 Then ;
                printnl ( 262 ) ;
                print ( 902 ) ;
              End ;
              Begin
                helpptr := 3 ;
                helpline [ 2 ] := 903 ;
                helpline [ 1 ] := 904 ;
                helpline [ 0 ] := 905 ;
              End ;
              backerror ;
              goto 31 ;
            End
          Else If ( curcmd <> 10 ) Or ( p <> 29996 ) Then
                 Begin
                   mem [ p ] . hh . rh := getavail ;
                   p := mem [ p ] . hh . rh ;
                   mem [ p ] . hh . lh := curtok ;
                 End ;
        End ;
      31 : ;
      mem [ curalign ] . hh . rh := newnullbox ;
      curalign := mem [ curalign ] . hh . rh ;
      mem [ curalign ] . hh . lh := 29991 ;
      mem [ curalign + 1 ] . int := - 1073741824 ;
      mem [ curalign + 3 ] . int := mem [ 29996 ] . hh . rh ;
      p := 29996 ;
      mem [ p ] . hh . rh := 0 ;
      While true Do
        Begin
          22 : getpreambletoken ;
          If ( curcmd <= 5 ) And ( curcmd >= 4 ) And ( alignstate = - 1000000 ) Then goto 32 ;
          If curcmd = 6 Then
            Begin
              Begin
                If interaction = 3 Then ;
                printnl ( 262 ) ;
                print ( 906 ) ;
              End ;
              Begin
                helpptr := 3 ;
                helpline [ 2 ] := 903 ;
                helpline [ 1 ] := 904 ;
                helpline [ 0 ] := 907 ;
              End ;
              error ;
              goto 22 ;
            End ;
          mem [ p ] . hh . rh := getavail ;
          p := mem [ p ] . hh . rh ;
          mem [ p ] . hh . lh := curtok ;
        End ;
      32 : mem [ p ] . hh . rh := getavail ;
      p := mem [ p ] . hh . rh ;
      mem [ p ] . hh . lh := 6714 ;
      mem [ curalign + 2 ] . int := mem [ 29996 ] . hh . rh ;
    End ;
  30 : scannerstatus := 0 ;
  newsavelevel ( 6 ) ;
  If eqtb [ 3420 ] . hh . rh <> 0 Then begintokenlist ( eqtb [ 3420 ] . hh . rh , 13 ) ;
  alignpeek ;
End ;
Procedure initspan ( p : halfword ) ;
Begin
  pushnest ;
  If curlist . modefield = - 102 Then curlist . auxfield . hh . lh := 1000
  Else
    Begin
      curlist . auxfield . int := - 65536000 ;
      normalparagraph ;
    End ;
  curspan := p ;
End ;
Procedure initrow ;
Begin
  pushnest ;
  curlist . modefield := ( - 103 ) - curlist . modefield ;
  If curlist . modefield = - 102 Then curlist . auxfield . hh . lh := 0
  Else curlist . auxfield . int := 0 ;
  Begin
    mem [ curlist . tailfield ] . hh . rh := newglue ( mem [ mem [ 29992 ] . hh . rh + 1 ] . hh . lh ) ;
    curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
  End ;
  mem [ curlist . tailfield ] . hh . b1 := 12 ;
  curalign := mem [ mem [ 29992 ] . hh . rh ] . hh . rh ;
  curtail := curhead ;
  initspan ( curalign ) ;
End ;
Procedure initcol ;
Begin
  mem [ curalign + 5 ] . hh . lh := curcmd ;
  If curcmd = 63 Then alignstate := 0
  Else
    Begin
      backinput ;
      begintokenlist ( mem [ curalign + 3 ] . int , 1 ) ;
    End ;
End ;
Function fincol : boolean ;

Label 10 ;

Var p : halfword ;
  q , r : halfword ;
  s : halfword ;
  u : halfword ;
  w : scaled ;
  o : glueord ;
  n : halfword ;
Begin
  If curalign = 0 Then confusion ( 908 ) ;
  q := mem [ curalign ] . hh . rh ;
  If q = 0 Then confusion ( 908 ) ;
  If alignstate < 500000 Then fatalerror ( 595 ) ;
  p := mem [ q ] . hh . rh ;
  If ( p = 0 ) And ( mem [ curalign + 5 ] . hh . lh < 257 ) Then If curloop <> 0 Then
                                                                   Begin
                                                                     mem [ q ] . hh . rh := newnullbox ;
                                                                     p := mem [ q ] . hh . rh ;
                                                                     mem [ p ] . hh . lh := 29991 ;
                                                                     mem [ p + 1 ] . int := - 1073741824 ;
                                                                     curloop := mem [ curloop ] . hh . rh ;
                                                                     q := 29996 ;
                                                                     r := mem [ curloop + 3 ] . int ;
                                                                     While r <> 0 Do
                                                                       Begin
                                                                         mem [ q ] . hh . rh := getavail ;
                                                                         q := mem [ q ] . hh . rh ;
                                                                         mem [ q ] . hh . lh := mem [ r ] . hh . lh ;
                                                                         r := mem [ r ] . hh . rh ;
                                                                       End ;
                                                                     mem [ q ] . hh . rh := 0 ;
                                                                     mem [ p + 3 ] . int := mem [ 29996 ] . hh . rh ;
                                                                     q := 29996 ;
                                                                     r := mem [ curloop + 2 ] . int ;
                                                                     While r <> 0 Do
                                                                       Begin
                                                                         mem [ q ] . hh . rh := getavail ;
                                                                         q := mem [ q ] . hh . rh ;
                                                                         mem [ q ] . hh . lh := mem [ r ] . hh . lh ;
                                                                         r := mem [ r ] . hh . rh ;
                                                                       End ;
                                                                     mem [ q ] . hh . rh := 0 ;
                                                                     mem [ p + 2 ] . int := mem [ 29996 ] . hh . rh ;
                                                                     curloop := mem [ curloop ] . hh . rh ;
                                                                     mem [ p ] . hh . rh := newglue ( mem [ curloop + 1 ] . hh . lh ) ;
                                                                   End
  Else
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 909 ) ;
      End ;
      printesc ( 898 ) ;
      Begin
        helpptr := 3 ;
        helpline [ 2 ] := 910 ;
        helpline [ 1 ] := 911 ;
        helpline [ 0 ] := 912 ;
      End ;
      mem [ curalign + 5 ] . hh . lh := 257 ;
      error ;
    End ;
  If mem [ curalign + 5 ] . hh . lh <> 256 Then
    Begin
      unsave ;
      newsavelevel ( 6 ) ;
      Begin
        If curlist . modefield = - 102 Then
          Begin
            adjusttail := curtail ;
            u := hpack ( mem [ curlist . headfield ] . hh . rh , 0 , 1 ) ;
            w := mem [ u + 1 ] . int ;
            curtail := adjusttail ;
            adjusttail := 0 ;
          End
        Else
          Begin
            u := vpackage ( mem [ curlist . headfield ] . hh . rh , 0 , 1 , 0 ) ;
            w := mem [ u + 3 ] . int ;
          End ;
        n := 0 ;
        If curspan <> curalign Then
          Begin
            q := curspan ;
            Repeat
              n := n + 1 ;
              q := mem [ mem [ q ] . hh . rh ] . hh . rh ;
            Until q = curalign ;
            If n > 255 Then confusion ( 913 ) ;
            q := curspan ;
            While mem [ mem [ q ] . hh . lh ] . hh . rh < n Do
              q := mem [ q ] . hh . lh ;
            If mem [ mem [ q ] . hh . lh ] . hh . rh > n Then
              Begin
                s := getnode ( 2 ) ;
                mem [ s ] . hh . lh := mem [ q ] . hh . lh ;
                mem [ s ] . hh . rh := n ;
                mem [ q ] . hh . lh := s ;
                mem [ s + 1 ] . int := w ;
              End
            Else If mem [ mem [ q ] . hh . lh + 1 ] . int < w Then mem [ mem [ q ] . hh . lh + 1 ] . int := w ;
          End
        Else If w > mem [ curalign + 1 ] . int Then mem [ curalign + 1 ] . int := w ;
        mem [ u ] . hh . b0 := 13 ;
        mem [ u ] . hh . b1 := n ;
        If totalstretch [ 3 ] <> 0 Then o := 3
        Else If totalstretch [ 2 ] <> 0 Then o := 2
        Else If totalstretch [ 1 ] <> 0 Then o := 1
        Else o := 0 ;
        mem [ u + 5 ] . hh . b1 := o ;
        mem [ u + 6 ] . int := totalstretch [ o ] ;
        If totalshrink [ 3 ] <> 0 Then o := 3
        Else If totalshrink [ 2 ] <> 0 Then o := 2
        Else If totalshrink [ 1 ] <> 0 Then o := 1
        Else o := 0 ;
        mem [ u + 5 ] . hh . b0 := o ;
        mem [ u + 4 ] . int := totalshrink [ o ] ;
        popnest ;
        mem [ curlist . tailfield ] . hh . rh := u ;
        curlist . tailfield := u ;
      End ;
      Begin
        mem [ curlist . tailfield ] . hh . rh := newglue ( mem [ mem [ curalign ] . hh . rh + 1 ] . hh . lh ) ;
        curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
      End ;
      mem [ curlist . tailfield ] . hh . b1 := 12 ;
      If mem [ curalign + 5 ] . hh . lh >= 257 Then
        Begin
          fincol := true ;
          goto 10 ;
        End ;
      initspan ( p ) ;
    End ;
  alignstate := 1000000 ;
  Repeat
    getxtoken ;
  Until curcmd <> 10 ;
  curalign := p ;
  initcol ;
  fincol := false ;
  10 :
End ;
Procedure finrow ;

Var p : halfword ;
Begin
  If curlist . modefield = - 102 Then
    Begin
      p := hpack ( mem [ curlist . headfield ] . hh . rh , 0 , 1 ) ;
      popnest ;
      appendtovlist ( p ) ;
      If curhead <> curtail Then
        Begin
          mem [ curlist . tailfield ] . hh . rh := mem [ curhead ] . hh . rh ;
          curlist . tailfield := curtail ;
        End ;
    End
  Else
    Begin
      p := vpackage ( mem [ curlist . headfield ] . hh . rh , 0 , 1 , 1073741823 ) ;
      popnest ;
      mem [ curlist . tailfield ] . hh . rh := p ;
      curlist . tailfield := p ;
      curlist . auxfield . hh . lh := 1000 ;
    End ;
  mem [ p ] . hh . b0 := 13 ;
  mem [ p + 6 ] . int := 0 ;
  If eqtb [ 3420 ] . hh . rh <> 0 Then begintokenlist ( eqtb [ 3420 ] . hh . rh , 13 ) ;
  alignpeek ;
End ;
Procedure doassignments ;
forward ;
Procedure resumeafterdisplay ;
forward ;
Procedure buildpage ;
forward ;
Procedure finalign ;

Var p , q , r , s , u , v : halfword ;
  t , w : scaled ;
  o : scaled ;
  n : halfword ;
  rulesave : scaled ;
  auxsave : memoryword ;
Begin
  If curgroup <> 6 Then confusion ( 914 ) ;
  unsave ;
  If curgroup <> 6 Then confusion ( 915 ) ;
  unsave ;
  If nest [ nestptr - 1 ] . modefield = 203 Then o := eqtb [ 5845 ] . int
  Else o := 0 ;
  q := mem [ mem [ 29992 ] . hh . rh ] . hh . rh ;
  Repeat
    flushlist ( mem [ q + 3 ] . int ) ;
    flushlist ( mem [ q + 2 ] . int ) ;
    p := mem [ mem [ q ] . hh . rh ] . hh . rh ;
    If mem [ q + 1 ] . int = - 1073741824 Then
      Begin
        mem [ q + 1 ] . int := 0 ;
        r := mem [ q ] . hh . rh ;
        s := mem [ r + 1 ] . hh . lh ;
        If s <> 0 Then
          Begin
            mem [ 0 ] . hh . rh := mem [ 0 ] . hh . rh + 1 ;
            deleteglueref ( s ) ;
            mem [ r + 1 ] . hh . lh := 0 ;
          End ;
      End ;
    If mem [ q ] . hh . lh <> 29991 Then
      Begin
        t := mem [ q + 1 ] . int + mem [ mem [ mem [ q ] . hh . rh + 1 ] . hh . lh + 1 ] . int ;
        r := mem [ q ] . hh . lh ;
        s := 29991 ;
        mem [ s ] . hh . lh := p ;
        n := 1 ;
        Repeat
          mem [ r + 1 ] . int := mem [ r + 1 ] . int - t ;
          u := mem [ r ] . hh . lh ;
          While mem [ r ] . hh . rh > n Do
            Begin
              s := mem [ s ] . hh . lh ;
              n := mem [ mem [ s ] . hh . lh ] . hh . rh + 1 ;
            End ;
          If mem [ r ] . hh . rh < n Then
            Begin
              mem [ r ] . hh . lh := mem [ s ] . hh . lh ;
              mem [ s ] . hh . lh := r ;
              mem [ r ] . hh . rh := mem [ r ] . hh . rh - 1 ;
              s := r ;
            End
          Else
            Begin
              If mem [ r + 1 ] . int > mem [ mem [ s ] . hh . lh + 1 ] . int Then mem [ mem [ s ] . hh . lh + 1 ] . int := mem [ r + 1 ] . int ;
              freenode ( r , 2 ) ;
            End ;
          r := u ;
        Until r = 29991 ;
      End ;
    mem [ q ] . hh . b0 := 13 ;
    mem [ q ] . hh . b1 := 0 ;
    mem [ q + 3 ] . int := 0 ;
    mem [ q + 2 ] . int := 0 ;
    mem [ q + 5 ] . hh . b1 := 0 ;
    mem [ q + 5 ] . hh . b0 := 0 ;
    mem [ q + 6 ] . int := 0 ;
    mem [ q + 4 ] . int := 0 ;
    q := p ;
  Until q = 0 ;
  saveptr := saveptr - 2 ;
  packbeginline := - curlist . mlfield ;
  If curlist . modefield = - 1 Then
    Begin
      rulesave := eqtb [ 5846 ] . int ;
      eqtb [ 5846 ] . int := 0 ;
      p := hpack ( mem [ 29992 ] . hh . rh , savestack [ saveptr + 1 ] . int , savestack [ saveptr + 0 ] . int ) ;
      eqtb [ 5846 ] . int := rulesave ;
    End
  Else
    Begin
      q := mem [ mem [ 29992 ] . hh . rh ] . hh . rh ;
      Repeat
        mem [ q + 3 ] . int := mem [ q + 1 ] . int ;
        mem [ q + 1 ] . int := 0 ;
        q := mem [ mem [ q ] . hh . rh ] . hh . rh ;
      Until q = 0 ;
      p := vpackage ( mem [ 29992 ] . hh . rh , savestack [ saveptr + 1 ] . int , savestack [ saveptr + 0 ] . int , 1073741823 ) ;
      q := mem [ mem [ 29992 ] . hh . rh ] . hh . rh ;
      Repeat
        mem [ q + 1 ] . int := mem [ q + 3 ] . int ;
        mem [ q + 3 ] . int := 0 ;
        q := mem [ mem [ q ] . hh . rh ] . hh . rh ;
      Until q = 0 ;
    End ;
  packbeginline := 0 ;
  q := mem [ curlist . headfield ] . hh . rh ;
  s := curlist . headfield ;
  While q <> 0 Do
    Begin
      If Not ( q >= himemmin ) Then If mem [ q ] . hh . b0 = 13 Then
                                      Begin
                                        If curlist . modefield = - 1 Then
                                          Begin
                                            mem [ q ] . hh . b0 := 0 ;
                                            mem [ q + 1 ] . int := mem [ p + 1 ] . int ;
                                          End
                                        Else
                                          Begin
                                            mem [ q ] . hh . b0 := 1 ;
                                            mem [ q + 3 ] . int := mem [ p + 3 ] . int ;
                                          End ;
                                        mem [ q + 5 ] . hh . b1 := mem [ p + 5 ] . hh . b1 ;
                                        mem [ q + 5 ] . hh . b0 := mem [ p + 5 ] . hh . b0 ;
                                        mem [ q + 6 ] . gr := mem [ p + 6 ] . gr ;
                                        mem [ q + 4 ] . int := o ;
                                        r := mem [ mem [ q + 5 ] . hh . rh ] . hh . rh ;
                                        s := mem [ mem [ p + 5 ] . hh . rh ] . hh . rh ;
                                        Repeat
                                          n := mem [ r ] . hh . b1 ;
                                          t := mem [ s + 1 ] . int ;
                                          w := t ;
                                          u := 29996 ;
                                          While n > 0 Do
                                            Begin
                                              n := n - 1 ;
                                              s := mem [ s ] . hh . rh ;
                                              v := mem [ s + 1 ] . hh . lh ;
                                              mem [ u ] . hh . rh := newglue ( v ) ;
                                              u := mem [ u ] . hh . rh ;
                                              mem [ u ] . hh . b1 := 12 ;
                                              t := t + mem [ v + 1 ] . int ;
                                              If mem [ p + 5 ] . hh . b0 = 1 Then
                                                Begin
                                                  If mem [ v ] . hh . b0 = mem [ p + 5 ] . hh . b1 Then t := t + round ( mem [ p + 6 ] . gr * mem [ v + 2 ] . int ) ;
                                                End
                                              Else If mem [ p + 5 ] . hh . b0 = 2 Then
                                                     Begin
                                                       If mem [ v ] . hh . b1 = mem [ p + 5 ] . hh . b1 Then t := t - round ( mem [ p + 6 ] . gr * mem [ v + 3 ] . int ) ;
                                                     End ;
                                              s := mem [ s ] . hh . rh ;
                                              mem [ u ] . hh . rh := newnullbox ;
                                              u := mem [ u ] . hh . rh ;
                                              t := t + mem [ s + 1 ] . int ;
                                              If curlist . modefield = - 1 Then mem [ u + 1 ] . int := mem [ s + 1 ] . int
                                              Else
                                                Begin
                                                  mem [ u ] . hh . b0 := 1 ;
                                                  mem [ u + 3 ] . int := mem [ s + 1 ] . int ;
                                                End ;
                                            End ;
                                          If curlist . modefield = - 1 Then
                                            Begin
                                              mem [ r + 3 ] . int := mem [ q + 3 ] . int ;
                                              mem [ r + 2 ] . int := mem [ q + 2 ] . int ;
                                              If t = mem [ r + 1 ] . int Then
                                                Begin
                                                  mem [ r + 5 ] . hh . b0 := 0 ;
                                                  mem [ r + 5 ] . hh . b1 := 0 ;
                                                  mem [ r + 6 ] . gr := 0.0 ;
                                                End
                                              Else If t > mem [ r + 1 ] . int Then
                                                     Begin
                                                       mem [ r + 5 ] . hh . b0 := 1 ;
                                                       If mem [ r + 6 ] . int = 0 Then mem [ r + 6 ] . gr := 0.0
                                                       Else mem [ r + 6 ] . gr := ( t - mem [ r + 1 ] . int ) / mem [ r + 6 ] . int ;
                                                     End
                                              Else
                                                Begin
                                                  mem [ r + 5 ] . hh . b1 := mem [ r + 5 ] . hh . b0 ;
                                                  mem [ r + 5 ] . hh . b0 := 2 ;
                                                  If mem [ r + 4 ] . int = 0 Then mem [ r + 6 ] . gr := 0.0
                                                  Else If ( mem [ r + 5 ] . hh . b1 = 0 ) And ( mem [ r + 1 ] . int - t > mem [ r + 4 ] . int ) Then mem [ r + 6 ] . gr := 1.0
                                                  Else mem [ r + 6 ] . gr := ( mem [ r + 1 ] . int - t ) / mem [ r + 4 ] . int ;
                                                End ;
                                              mem [ r + 1 ] . int := w ;
                                              mem [ r ] . hh . b0 := 0 ;
                                            End
                                          Else
                                            Begin
                                              mem [ r + 1 ] . int := mem [ q + 1 ] . int ;
                                              If t = mem [ r + 3 ] . int Then
                                                Begin
                                                  mem [ r + 5 ] . hh . b0 := 0 ;
                                                  mem [ r + 5 ] . hh . b1 := 0 ;
                                                  mem [ r + 6 ] . gr := 0.0 ;
                                                End
                                              Else If t > mem [ r + 3 ] . int Then
                                                     Begin
                                                       mem [ r + 5 ] . hh . b0 := 1 ;
                                                       If mem [ r + 6 ] . int = 0 Then mem [ r + 6 ] . gr := 0.0
                                                       Else mem [ r + 6 ] . gr := ( t - mem [ r + 3 ] . int ) / mem [ r + 6 ] . int ;
                                                     End
                                              Else
                                                Begin
                                                  mem [ r + 5 ] . hh . b1 := mem [ r + 5 ] . hh . b0 ;
                                                  mem [ r + 5 ] . hh . b0 := 2 ;
                                                  If mem [ r + 4 ] . int = 0 Then mem [ r + 6 ] . gr := 0.0
                                                  Else If ( mem [ r + 5 ] . hh . b1 = 0 ) And ( mem [ r + 3 ] . int - t > mem [ r + 4 ] . int ) Then mem [ r + 6 ] . gr := 1.0
                                                  Else mem [ r + 6 ] . gr := ( mem [ r + 3 ] . int - t ) / mem [ r + 4 ] . int ;
                                                End ;
                                              mem [ r + 3 ] . int := w ;
                                              mem [ r ] . hh . b0 := 1 ;
                                            End ;
                                          mem [ r + 4 ] . int := 0 ;
                                          If u <> 29996 Then
                                            Begin
                                              mem [ u ] . hh . rh := mem [ r ] . hh . rh ;
                                              mem [ r ] . hh . rh := mem [ 29996 ] . hh . rh ;
                                              r := u ;
                                            End ;
                                          r := mem [ mem [ r ] . hh . rh ] . hh . rh ;
                                          s := mem [ mem [ s ] . hh . rh ] . hh . rh ;
                                        Until r = 0 ;
                                      End
      Else If mem [ q ] . hh . b0 = 2 Then
             Begin
               If ( mem [ q + 1 ] . int = - 1073741824 ) Then mem [ q + 1 ] . int := mem [ p + 1 ] . int ;
               If ( mem [ q + 3 ] . int = - 1073741824 ) Then mem [ q + 3 ] . int := mem [ p + 3 ] . int ;
               If ( mem [ q + 2 ] . int = - 1073741824 ) Then mem [ q + 2 ] . int := mem [ p + 2 ] . int ;
               If o <> 0 Then
                 Begin
                   r := mem [ q ] . hh . rh ;
                   mem [ q ] . hh . rh := 0 ;
                   q := hpack ( q , 0 , 1 ) ;
                   mem [ q + 4 ] . int := o ;
                   mem [ q ] . hh . rh := r ;
                   mem [ s ] . hh . rh := q ;
                 End ;
             End ;
      s := q ;
      q := mem [ q ] . hh . rh ;
    End ;
  flushnodelist ( p ) ;
  popalignment ;
  auxsave := curlist . auxfield ;
  p := mem [ curlist . headfield ] . hh . rh ;
  q := curlist . tailfield ;
  popnest ;
  If curlist . modefield = 203 Then
    Begin
      doassignments ;
      If curcmd <> 3 Then
        Begin
          Begin
            If interaction = 3 Then ;
            printnl ( 262 ) ;
            print ( 1169 ) ;
          End ;
          Begin
            helpptr := 2 ;
            helpline [ 1 ] := 894 ;
            helpline [ 0 ] := 895 ;
          End ;
          backerror ;
        End
      Else
        Begin
          getxtoken ;
          If curcmd <> 3 Then
            Begin
              Begin
                If interaction = 3 Then ;
                printnl ( 262 ) ;
                print ( 1165 ) ;
              End ;
              Begin
                helpptr := 2 ;
                helpline [ 1 ] := 1166 ;
                helpline [ 0 ] := 1167 ;
              End ;
              backerror ;
            End ;
        End ;
      popnest ;
      Begin
        mem [ curlist . tailfield ] . hh . rh := newpenalty ( eqtb [ 5274 ] . int ) ;
        curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
      End ;
      Begin
        mem [ curlist . tailfield ] . hh . rh := newparamglue ( 3 ) ;
        curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
      End ;
      mem [ curlist . tailfield ] . hh . rh := p ;
      If p <> 0 Then curlist . tailfield := q ;
      Begin
        mem [ curlist . tailfield ] . hh . rh := newpenalty ( eqtb [ 5275 ] . int ) ;
        curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
      End ;
      Begin
        mem [ curlist . tailfield ] . hh . rh := newparamglue ( 4 ) ;
        curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
      End ;
      curlist . auxfield . int := auxsave . int ;
      resumeafterdisplay ;
    End
  Else
    Begin
      curlist . auxfield := auxsave ;
      mem [ curlist . tailfield ] . hh . rh := p ;
      If p <> 0 Then curlist . tailfield := q ;
      If curlist . modefield = 1 Then buildpage ;
    End ;
End ;
Procedure alignpeek ;

Label 20 ;
Begin
  20 : alignstate := 1000000 ;
  Repeat
    getxtoken ;
  Until curcmd <> 10 ;
  If curcmd = 34 Then
    Begin
      scanleftbrace ;
      newsavelevel ( 7 ) ;
      If curlist . modefield = - 1 Then normalparagraph ;
    End
  Else If curcmd = 2 Then finalign
  Else If ( curcmd = 5 ) And ( curchr = 258 ) Then goto 20
  Else
    Begin
      initrow ;
      initcol ;
    End ;
End ;
Function finiteshrink ( p : halfword ) : halfword ;

Var q : halfword ;
Begin
  If noshrinkerroryet Then
    Begin
      noshrinkerroryet := false ;
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 916 ) ;
      End ;
      Begin
        helpptr := 5 ;
        helpline [ 4 ] := 917 ;
        helpline [ 3 ] := 918 ;
        helpline [ 2 ] := 919 ;
        helpline [ 1 ] := 920 ;
        helpline [ 0 ] := 921 ;
      End ;
      error ;
    End ;
  q := newspec ( p ) ;
  mem [ q ] . hh . b1 := 0 ;
  deleteglueref ( p ) ;
  finiteshrink := q ;
End ;
Procedure trybreak ( pi : integer ; breaktype : smallnumber ) ;

Label 10 , 30 , 31 , 22 , 60 ;

Var r : halfword ;
  prevr : halfword ;
  oldl : halfword ;
  nobreakyet : boolean ;
  prevprevr : halfword ;
  s : halfword ;
  q : halfword ;
  v : halfword ;
  t : integer ;
  f : internalfontnumber ;
  l : halfword ;
  noderstaysactive : boolean ;
  linewidth : scaled ;
  fitclass : 0 .. 3 ;
  b : halfword ;
  d : integer ;
  artificialdemerits : boolean ;
  savelink : halfword ;
  shortfall : scaled ;
Begin
  If abs ( pi ) >= 10000 Then If pi > 0 Then goto 10
  Else pi := - 10000 ;
  nobreakyet := true ;
  prevr := 29993 ;
  oldl := 0 ;
  curactivewidth [ 1 ] := activewidth [ 1 ] ;
  curactivewidth [ 2 ] := activewidth [ 2 ] ;
  curactivewidth [ 3 ] := activewidth [ 3 ] ;
  curactivewidth [ 4 ] := activewidth [ 4 ] ;
  curactivewidth [ 5 ] := activewidth [ 5 ] ;
  curactivewidth [ 6 ] := activewidth [ 6 ] ;
  While true Do
    Begin
      22 : r := mem [ prevr ] . hh . rh ;
      If mem [ r ] . hh . b0 = 2 Then
        Begin
          curactivewidth [ 1 ] := curactivewidth [ 1 ] + mem [ r + 1 ] . int ;
          curactivewidth [ 2 ] := curactivewidth [ 2 ] + mem [ r + 2 ] . int ;
          curactivewidth [ 3 ] := curactivewidth [ 3 ] + mem [ r + 3 ] . int ;
          curactivewidth [ 4 ] := curactivewidth [ 4 ] + mem [ r + 4 ] . int ;
          curactivewidth [ 5 ] := curactivewidth [ 5 ] + mem [ r + 5 ] . int ;
          curactivewidth [ 6 ] := curactivewidth [ 6 ] + mem [ r + 6 ] . int ;
          prevprevr := prevr ;
          prevr := r ;
          goto 22 ;
        End ;
      Begin
        l := mem [ r + 1 ] . hh . lh ;
        If l > oldl Then
          Begin
            If ( minimumdemerits < 1073741823 ) And ( ( oldl <> easyline ) Or ( r = 29993 ) ) Then
              Begin
                If nobreakyet Then
                  Begin
                    nobreakyet := false ;
                    breakwidth [ 1 ] := background [ 1 ] ;
                    breakwidth [ 2 ] := background [ 2 ] ;
                    breakwidth [ 3 ] := background [ 3 ] ;
                    breakwidth [ 4 ] := background [ 4 ] ;
                    breakwidth [ 5 ] := background [ 5 ] ;
                    breakwidth [ 6 ] := background [ 6 ] ;
                    s := curp ;
                    If breaktype > 0 Then If curp <> 0 Then
                                            Begin
                                              t := mem [ curp ] . hh . b1 ;
                                              v := curp ;
                                              s := mem [ curp + 1 ] . hh . rh ;
                                              While t > 0 Do
                                                Begin
                                                  t := t - 1 ;
                                                  v := mem [ v ] . hh . rh ;
                                                  If ( v >= himemmin ) Then
                                                    Begin
                                                      f := mem [ v ] . hh . b0 ;
                                                      breakwidth [ 1 ] := breakwidth [ 1 ] - fontinfo [ widthbase [ f ] + fontinfo [ charbase [ f ] + mem [ v ] . hh . b1 ] . qqqq . b0 ] . int ;
                                                    End
                                                  Else Case mem [ v ] . hh . b0 Of 
                                                         6 :
                                                             Begin
                                                               f := mem [ v + 1 ] . hh . b0 ;
                                                               breakwidth [ 1 ] := breakwidth [ 1 ] - fontinfo [ widthbase [ f ] + fontinfo [ charbase [ f ] + mem [ v + 1 ] . hh . b1 ] . qqqq . b0 ] . int ;
                                                             End ;
                                                         0 , 1 , 2 , 11 : breakwidth [ 1 ] := breakwidth [ 1 ] - mem [ v + 1 ] . int ;
                                                         others : confusion ( 922 )
                                                    End ;
                                                End ;
                                              While s <> 0 Do
                                                Begin
                                                  If ( s >= himemmin ) Then
                                                    Begin
                                                      f := mem [ s ] . hh . b0 ;
                                                      breakwidth [ 1 ] := breakwidth [ 1 ] + fontinfo [ widthbase [ f ] + fontinfo [ charbase [ f ] + mem [ s ] . hh . b1 ] . qqqq . b0 ] . int ;
                                                    End
                                                  Else Case mem [ s ] . hh . b0 Of 
                                                         6 :
                                                             Begin
                                                               f := mem [ s + 1 ] . hh . b0 ;
                                                               breakwidth [ 1 ] := breakwidth [ 1 ] + fontinfo [ widthbase [ f ] + fontinfo [ charbase [ f ] + mem [ s + 1 ] . hh . b1 ] . qqqq . b0 ] . int ;
                                                             End ;
                                                         0 , 1 , 2 , 11 : breakwidth [ 1 ] := breakwidth [ 1 ] + mem [ s + 1 ] . int ;
                                                         others : confusion ( 923 )
                                                    End ;
                                                  s := mem [ s ] . hh . rh ;
                                                End ;
                                              breakwidth [ 1 ] := breakwidth [ 1 ] + discwidth ;
                                              If mem [ curp + 1 ] . hh . rh = 0 Then s := mem [ v ] . hh . rh ;
                                            End ;
                    While s <> 0 Do
                      Begin
                        If ( s >= himemmin ) Then goto 30 ;
                        Case mem [ s ] . hh . b0 Of 
                          10 :
                               Begin
                                 v := mem [ s + 1 ] . hh . lh ;
                                 breakwidth [ 1 ] := breakwidth [ 1 ] - mem [ v + 1 ] . int ;
                                 breakwidth [ 2 + mem [ v ] . hh . b0 ] := breakwidth [ 2 + mem [ v ] . hh . b0 ] - mem [ v + 2 ] . int ;
                                 breakwidth [ 6 ] := breakwidth [ 6 ] - mem [ v + 3 ] . int ;
                               End ;
                          12 : ;
                          9 : breakwidth [ 1 ] := breakwidth [ 1 ] - mem [ s + 1 ] . int ;
                          11 : If mem [ s ] . hh . b1 <> 1 Then goto 30
                               Else breakwidth [ 1 ] := breakwidth [ 1 ] - mem [ s + 1 ] . int ;
                          others : goto 30
                        End ;
                        s := mem [ s ] . hh . rh ;
                      End ;
                    30 :
                  End ;
                If mem [ prevr ] . hh . b0 = 2 Then
                  Begin
                    mem [ prevr + 1 ] . int := mem [ prevr + 1 ] . int - curactivewidth [ 1 ] + breakwidth [ 1 ] ;
                    mem [ prevr + 2 ] . int := mem [ prevr + 2 ] . int - curactivewidth [ 2 ] + breakwidth [ 2 ] ;
                    mem [ prevr + 3 ] . int := mem [ prevr + 3 ] . int - curactivewidth [ 3 ] + breakwidth [ 3 ] ;
                    mem [ prevr + 4 ] . int := mem [ prevr + 4 ] . int - curactivewidth [ 4 ] + breakwidth [ 4 ] ;
                    mem [ prevr + 5 ] . int := mem [ prevr + 5 ] . int - curactivewidth [ 5 ] + breakwidth [ 5 ] ;
                    mem [ prevr + 6 ] . int := mem [ prevr + 6 ] . int - curactivewidth [ 6 ] + breakwidth [ 6 ] ;
                  End
                Else If prevr = 29993 Then
                       Begin
                         activewidth [ 1 ] := breakwidth [ 1 ] ;
                         activewidth [ 2 ] := breakwidth [ 2 ] ;
                         activewidth [ 3 ] := breakwidth [ 3 ] ;
                         activewidth [ 4 ] := breakwidth [ 4 ] ;
                         activewidth [ 5 ] := breakwidth [ 5 ] ;
                         activewidth [ 6 ] := breakwidth [ 6 ] ;
                       End
                Else
                  Begin
                    q := getnode ( 7 ) ;
                    mem [ q ] . hh . rh := r ;
                    mem [ q ] . hh . b0 := 2 ;
                    mem [ q ] . hh . b1 := 0 ;
                    mem [ q + 1 ] . int := breakwidth [ 1 ] - curactivewidth [ 1 ] ;
                    mem [ q + 2 ] . int := breakwidth [ 2 ] - curactivewidth [ 2 ] ;
                    mem [ q + 3 ] . int := breakwidth [ 3 ] - curactivewidth [ 3 ] ;
                    mem [ q + 4 ] . int := breakwidth [ 4 ] - curactivewidth [ 4 ] ;
                    mem [ q + 5 ] . int := breakwidth [ 5 ] - curactivewidth [ 5 ] ;
                    mem [ q + 6 ] . int := breakwidth [ 6 ] - curactivewidth [ 6 ] ;
                    mem [ prevr ] . hh . rh := q ;
                    prevprevr := prevr ;
                    prevr := q ;
                  End ;
                If abs ( eqtb [ 5279 ] . int ) >= 1073741823 - minimumdemerits Then minimumdemerits := 1073741822
                Else minimumdemerits := minimumdemerits + abs ( eqtb [ 5279 ] . int ) ;
                For fitclass := 0 To 3 Do
                  Begin
                    If minimaldemerits [ fitclass ] <= minimumdemerits Then
                      Begin
                        q := getnode ( 2 ) ;
                        mem [ q ] . hh . rh := passive ;
                        passive := q ;
                        mem [ q + 1 ] . hh . rh := curp ;
                        mem [ q + 1 ] . hh . lh := bestplace [ fitclass ] ;
                        q := getnode ( 3 ) ;
                        mem [ q + 1 ] . hh . rh := passive ;
                        mem [ q + 1 ] . hh . lh := bestplline [ fitclass ] + 1 ;
                        mem [ q ] . hh . b1 := fitclass ;
                        mem [ q ] . hh . b0 := breaktype ;
                        mem [ q + 2 ] . int := minimaldemerits [ fitclass ] ;
                        mem [ q ] . hh . rh := r ;
                        mem [ prevr ] . hh . rh := q ;
                        prevr := q ;
                      End ;
                    minimaldemerits [ fitclass ] := 1073741823 ;
                  End ;
                minimumdemerits := 1073741823 ;
                If r <> 29993 Then
                  Begin
                    q := getnode ( 7 ) ;
                    mem [ q ] . hh . rh := r ;
                    mem [ q ] . hh . b0 := 2 ;
                    mem [ q ] . hh . b1 := 0 ;
                    mem [ q + 1 ] . int := curactivewidth [ 1 ] - breakwidth [ 1 ] ;
                    mem [ q + 2 ] . int := curactivewidth [ 2 ] - breakwidth [ 2 ] ;
                    mem [ q + 3 ] . int := curactivewidth [ 3 ] - breakwidth [ 3 ] ;
                    mem [ q + 4 ] . int := curactivewidth [ 4 ] - breakwidth [ 4 ] ;
                    mem [ q + 5 ] . int := curactivewidth [ 5 ] - breakwidth [ 5 ] ;
                    mem [ q + 6 ] . int := curactivewidth [ 6 ] - breakwidth [ 6 ] ;
                    mem [ prevr ] . hh . rh := q ;
                    prevprevr := prevr ;
                    prevr := q ;
                  End ;
              End ;
            If r = 29993 Then goto 10 ;
            If l > easyline Then
              Begin
                linewidth := secondwidth ;
                oldl := 65534 ;
              End
            Else
              Begin
                oldl := l ;
                If l > lastspecialline Then linewidth := secondwidth
                Else If eqtb [ 3412 ] . hh . rh = 0 Then linewidth := firstwidth
                Else linewidth := mem [ eqtb [ 3412 ] . hh . rh + 2 * l ] . int ;
              End ;
          End ;
      End ;
      Begin
        artificialdemerits := false ;
        shortfall := linewidth - curactivewidth [ 1 ] ;
        If shortfall > 0 Then If ( curactivewidth [ 3 ] <> 0 ) Or ( curactivewidth [ 4 ] <> 0 ) Or ( curactivewidth [ 5 ] <> 0 ) Then
                                Begin
                                  b := 0 ;
                                  fitclass := 2 ;
                                End
        Else
          Begin
            If shortfall > 7230584 Then If curactivewidth [ 2 ] < 1663497 Then
                                          Begin
                                            b := 10000 ;
                                            fitclass := 0 ;
                                            goto 31 ;
                                          End ;
            b := badness ( shortfall , curactivewidth [ 2 ] ) ;
            If b > 12 Then If b > 99 Then fitclass := 0
            Else fitclass := 1
            Else fitclass := 2 ;
            31 :
          End
        Else
          Begin
            If - shortfall > curactivewidth [ 6 ] Then b := 10001
            Else b := badness ( - shortfall , curactivewidth [ 6 ] ) ;
            If b > 12 Then fitclass := 3
            Else fitclass := 2 ;
          End ;
        If ( b > 10000 ) Or ( pi = - 10000 ) Then
          Begin
            If finalpass And ( minimumdemerits = 1073741823 ) And ( mem [ r ] . hh . rh = 29993 ) And ( prevr = 29993 ) Then artificialdemerits := true
            Else If b > threshold Then goto 60 ;
            noderstaysactive := false ;
          End
        Else
          Begin
            prevr := r ;
            If b > threshold Then goto 22 ;
            noderstaysactive := true ;
          End ;
        If artificialdemerits Then d := 0
        Else
          Begin
            d := eqtb [ 5265 ] . int + b ;
            If abs ( d ) >= 10000 Then d := 100000000
            Else d := d * d ;
            If pi <> 0 Then If pi > 0 Then d := d + pi * pi
            Else If pi > - 10000 Then d := d - pi * pi ;
            If ( breaktype = 1 ) And ( mem [ r ] . hh . b0 = 1 ) Then If curp <> 0 Then d := d + eqtb [ 5277 ] . int
            Else d := d + eqtb [ 5278 ] . int ;
            If abs ( fitclass - mem [ r ] . hh . b1 ) > 1 Then d := d + eqtb [ 5279 ] . int ;
          End ;
        d := d + mem [ r + 2 ] . int ;
        If d <= minimaldemerits [ fitclass ] Then
          Begin
            minimaldemerits [ fitclass ] := d ;
            bestplace [ fitclass ] := mem [ r + 1 ] . hh . rh ;
            bestplline [ fitclass ] := l ;
            If d < minimumdemerits Then minimumdemerits := d ;
          End ;
        If noderstaysactive Then goto 22 ;
        60 : mem [ prevr ] . hh . rh := mem [ r ] . hh . rh ;
        freenode ( r , 3 ) ;
        If prevr = 29993 Then
          Begin
            r := mem [ 29993 ] . hh . rh ;
            If mem [ r ] . hh . b0 = 2 Then
              Begin
                activewidth [ 1 ] := activewidth [ 1 ] + mem [ r + 1 ] . int ;
                activewidth [ 2 ] := activewidth [ 2 ] + mem [ r + 2 ] . int ;
                activewidth [ 3 ] := activewidth [ 3 ] + mem [ r + 3 ] . int ;
                activewidth [ 4 ] := activewidth [ 4 ] + mem [ r + 4 ] . int ;
                activewidth [ 5 ] := activewidth [ 5 ] + mem [ r + 5 ] . int ;
                activewidth [ 6 ] := activewidth [ 6 ] + mem [ r + 6 ] . int ;
                curactivewidth [ 1 ] := activewidth [ 1 ] ;
                curactivewidth [ 2 ] := activewidth [ 2 ] ;
                curactivewidth [ 3 ] := activewidth [ 3 ] ;
                curactivewidth [ 4 ] := activewidth [ 4 ] ;
                curactivewidth [ 5 ] := activewidth [ 5 ] ;
                curactivewidth [ 6 ] := activewidth [ 6 ] ;
                mem [ 29993 ] . hh . rh := mem [ r ] . hh . rh ;
                freenode ( r , 7 ) ;
              End ;
          End
        Else If mem [ prevr ] . hh . b0 = 2 Then
               Begin
                 r := mem [ prevr ] . hh . rh ;
                 If r = 29993 Then
                   Begin
                     curactivewidth [ 1 ] := curactivewidth [ 1 ] - mem [ prevr + 1 ] . int ;
                     curactivewidth [ 2 ] := curactivewidth [ 2 ] - mem [ prevr + 2 ] . int ;
                     curactivewidth [ 3 ] := curactivewidth [ 3 ] - mem [ prevr + 3 ] . int ;
                     curactivewidth [ 4 ] := curactivewidth [ 4 ] - mem [ prevr + 4 ] . int ;
                     curactivewidth [ 5 ] := curactivewidth [ 5 ] - mem [ prevr + 5 ] . int ;
                     curactivewidth [ 6 ] := curactivewidth [ 6 ] - mem [ prevr + 6 ] . int ;
                     mem [ prevprevr ] . hh . rh := 29993 ;
                     freenode ( prevr , 7 ) ;
                     prevr := prevprevr ;
                   End
                 Else If mem [ r ] . hh . b0 = 2 Then
                        Begin
                          curactivewidth [ 1 ] := curactivewidth [ 1 ] + mem [ r + 1 ] . int ;
                          curactivewidth [ 2 ] := curactivewidth [ 2 ] + mem [ r + 2 ] . int ;
                          curactivewidth [ 3 ] := curactivewidth [ 3 ] + mem [ r + 3 ] . int ;
                          curactivewidth [ 4 ] := curactivewidth [ 4 ] + mem [ r + 4 ] . int ;
                          curactivewidth [ 5 ] := curactivewidth [ 5 ] + mem [ r + 5 ] . int ;
                          curactivewidth [ 6 ] := curactivewidth [ 6 ] + mem [ r + 6 ] . int ;
                          mem [ prevr + 1 ] . int := mem [ prevr + 1 ] . int + mem [ r + 1 ] . int ;
                          mem [ prevr + 2 ] . int := mem [ prevr + 2 ] . int + mem [ r + 2 ] . int ;
                          mem [ prevr + 3 ] . int := mem [ prevr + 3 ] . int + mem [ r + 3 ] . int ;
                          mem [ prevr + 4 ] . int := mem [ prevr + 4 ] . int + mem [ r + 4 ] . int ;
                          mem [ prevr + 5 ] . int := mem [ prevr + 5 ] . int + mem [ r + 5 ] . int ;
                          mem [ prevr + 6 ] . int := mem [ prevr + 6 ] . int + mem [ r + 6 ] . int ;
                          mem [ prevr ] . hh . rh := mem [ r ] . hh . rh ;
                          freenode ( r , 7 ) ;
                        End ;
               End ;
      End ;
    End ;
  10 :
End ;
Procedure postlinebreak ( finalwidowpenalty : integer ) ;

Label 30 , 31 ;

Var q , r , s : halfword ;
  discbreak : boolean ;
  postdiscbreak : boolean ;
  curwidth : scaled ;
  curindent : scaled ;
  t : quarterword ;
  pen : integer ;
  curline : halfword ;
Begin
  q := mem [ bestbet + 1 ] . hh . rh ;
  curp := 0 ;
  Repeat
    r := q ;
    q := mem [ q + 1 ] . hh . lh ;
    mem [ r + 1 ] . hh . lh := curp ;
    curp := r ;
  Until q = 0 ;
  curline := curlist . pgfield + 1 ;
  Repeat
    q := mem [ curp + 1 ] . hh . rh ;
    discbreak := false ;
    postdiscbreak := false ;
    If q <> 0 Then If mem [ q ] . hh . b0 = 10 Then
                     Begin
                       deleteglueref ( mem [ q + 1 ] . hh . lh ) ;
                       mem [ q + 1 ] . hh . lh := eqtb [ 2890 ] . hh . rh ;
                       mem [ q ] . hh . b1 := 9 ;
                       mem [ eqtb [ 2890 ] . hh . rh ] . hh . rh := mem [ eqtb [ 2890 ] . hh . rh ] . hh . rh + 1 ;
                       goto 30 ;
                     End
    Else
      Begin
        If mem [ q ] . hh . b0 = 7 Then
          Begin
            t := mem [ q ] . hh . b1 ;
            If t = 0 Then r := mem [ q ] . hh . rh
            Else
              Begin
                r := q ;
                While t > 1 Do
                  Begin
                    r := mem [ r ] . hh . rh ;
                    t := t - 1 ;
                  End ;
                s := mem [ r ] . hh . rh ;
                r := mem [ s ] . hh . rh ;
                mem [ s ] . hh . rh := 0 ;
                flushnodelist ( mem [ q ] . hh . rh ) ;
                mem [ q ] . hh . b1 := 0 ;
              End ;
            If mem [ q + 1 ] . hh . rh <> 0 Then
              Begin
                s := mem [ q + 1 ] . hh . rh ;
                While mem [ s ] . hh . rh <> 0 Do
                  s := mem [ s ] . hh . rh ;
                mem [ s ] . hh . rh := r ;
                r := mem [ q + 1 ] . hh . rh ;
                mem [ q + 1 ] . hh . rh := 0 ;
                postdiscbreak := true ;
              End ;
            If mem [ q + 1 ] . hh . lh <> 0 Then
              Begin
                s := mem [ q + 1 ] . hh . lh ;
                mem [ q ] . hh . rh := s ;
                While mem [ s ] . hh . rh <> 0 Do
                  s := mem [ s ] . hh . rh ;
                mem [ q + 1 ] . hh . lh := 0 ;
                q := s ;
              End ;
            mem [ q ] . hh . rh := r ;
            discbreak := true ;
          End
        Else If ( mem [ q ] . hh . b0 = 9 ) Or ( mem [ q ] . hh . b0 = 11 ) Then mem [ q + 1 ] . int := 0 ;
      End
    Else
      Begin
        q := 29997 ;
        While mem [ q ] . hh . rh <> 0 Do
          q := mem [ q ] . hh . rh ;
      End ;
    r := newparamglue ( 8 ) ;
    mem [ r ] . hh . rh := mem [ q ] . hh . rh ;
    mem [ q ] . hh . rh := r ;
    q := r ;
    30 : ;
    r := mem [ q ] . hh . rh ;
    mem [ q ] . hh . rh := 0 ;
    q := mem [ 29997 ] . hh . rh ;
    mem [ 29997 ] . hh . rh := r ;
    If eqtb [ 2889 ] . hh . rh <> 0 Then
      Begin
        r := newparamglue ( 7 ) ;
        mem [ r ] . hh . rh := q ;
        q := r ;
      End ;
    If curline > lastspecialline Then
      Begin
        curwidth := secondwidth ;
        curindent := secondindent ;
      End
    Else If eqtb [ 3412 ] . hh . rh = 0 Then
           Begin
             curwidth := firstwidth ;
             curindent := firstindent ;
           End
    Else
      Begin
        curwidth := mem [ eqtb [ 3412 ] . hh . rh + 2 * curline ] . int ;
        curindent := mem [ eqtb [ 3412 ] . hh . rh + 2 * curline - 1 ] . int ;
      End ;
    adjusttail := 29995 ;
    justbox := hpack ( q , curwidth , 0 ) ;
    mem [ justbox + 4 ] . int := curindent ;
    appendtovlist ( justbox ) ;
    If 29995 <> adjusttail Then
      Begin
        mem [ curlist . tailfield ] . hh . rh := mem [ 29995 ] . hh . rh ;
        curlist . tailfield := adjusttail ;
      End ;
    adjusttail := 0 ;
    If curline + 1 <> bestline Then
      Begin
        pen := eqtb [ 5276 ] . int ;
        If curline = curlist . pgfield + 1 Then pen := pen + eqtb [ 5268 ] . int ;
        If curline + 2 = bestline Then pen := pen + finalwidowpenalty ;
        If discbreak Then pen := pen + eqtb [ 5271 ] . int ;
        If pen <> 0 Then
          Begin
            r := newpenalty ( pen ) ;
            mem [ curlist . tailfield ] . hh . rh := r ;
            curlist . tailfield := r ;
          End ;
      End ;
    curline := curline + 1 ;
    curp := mem [ curp + 1 ] . hh . lh ;
    If curp <> 0 Then If Not postdiscbreak Then
                        Begin
                          r := 29997 ;
                          While true Do
                            Begin
                              q := mem [ r ] . hh . rh ;
                              If q = mem [ curp + 1 ] . hh . rh Then goto 31 ;
                              If ( q >= himemmin ) Then goto 31 ;
                              If ( mem [ q ] . hh . b0 < 9 ) Then goto 31 ;
                              If mem [ q ] . hh . b0 = 11 Then If mem [ q ] . hh . b1 <> 1 Then goto 31 ;
                              r := q ;
                            End ;
                          31 : If r <> 29997 Then
                                 Begin
                                   mem [ r ] . hh . rh := 0 ;
                                   flushnodelist ( mem [ 29997 ] . hh . rh ) ;
                                   mem [ 29997 ] . hh . rh := q ;
                                 End ;
                        End ;
  Until curp = 0 ;
  If ( curline <> bestline ) Or ( mem [ 29997 ] . hh . rh <> 0 ) Then confusion ( 938 ) ;
  curlist . pgfield := bestline - 1 ;
End ;
Function reconstitute ( j , n : smallnumber ; bchar , hchar : halfword ) : smallnumber ;

Label 22 , 30 ;

Var p : halfword ;
  t : halfword ;
  q : fourquarters ;
  currh : halfword ;
  testchar : halfword ;
  w : scaled ;
  k : fontindex ;
Begin
  hyphenpassed := 0 ;
  t := 29996 ;
  w := 0 ;
  mem [ 29996 ] . hh . rh := 0 ;
  curl := hu [ j ] + 0 ;
  curq := t ;
  If j = 0 Then
    Begin
      ligaturepresent := initlig ;
      p := initlist ;
      If ligaturepresent Then lfthit := initlft ;
      While p > 0 Do
        Begin
          Begin
            mem [ t ] . hh . rh := getavail ;
            t := mem [ t ] . hh . rh ;
            mem [ t ] . hh . b0 := hf ;
            mem [ t ] . hh . b1 := mem [ p ] . hh . b1 ;
          End ;
          p := mem [ p ] . hh . rh ;
        End ;
    End
  Else If curl < 256 Then
         Begin
           mem [ t ] . hh . rh := getavail ;
           t := mem [ t ] . hh . rh ;
           mem [ t ] . hh . b0 := hf ;
           mem [ t ] . hh . b1 := curl ;
         End ;
  ligstack := 0 ;
  Begin
    If j < n Then curr := hu [ j + 1 ] + 0
    Else curr := bchar ;
    If odd ( hyf [ j ] ) Then currh := hchar
    Else currh := 256 ;
  End ;
  22 : If curl = 256 Then
         Begin
           k := bcharlabel [ hf ] ;
           If k = 0 Then goto 30
           Else q := fontinfo [ k ] . qqqq ;
         End
       Else
         Begin
           q := fontinfo [ charbase [ hf ] + curl ] . qqqq ;
           If ( ( q . b2 - 0 ) Mod 4 ) <> 1 Then goto 30 ;
           k := ligkernbase [ hf ] + q . b3 ;
           q := fontinfo [ k ] . qqqq ;
           If q . b0 > 128 Then
             Begin
               k := ligkernbase [ hf ] + 256 * q . b2 + q . b3 + 32768 - 256 * ( 128 ) ;
               q := fontinfo [ k ] . qqqq ;
             End ;
         End ;
  If currh < 256 Then testchar := currh
  Else testchar := curr ;
  While true Do
    Begin
      If q . b1 = testchar Then If q . b0 <= 128 Then If currh < 256 Then
                                                        Begin
                                                          hyphenpassed := j ;
                                                          hchar := 256 ;
                                                          currh := 256 ;
                                                          goto 22 ;
                                                        End
      Else
        Begin
          If hchar < 256 Then If odd ( hyf [ j ] ) Then
                                Begin
                                  hyphenpassed := j ;
                                  hchar := 256 ;
                                End ;
          If q . b2 < 128 Then
            Begin
              If curl = 256 Then lfthit := true ;
              If j = n Then If ligstack = 0 Then rthit := true ;
              Begin
                If interrupt <> 0 Then pauseforinstructions ;
              End ;
              Case q . b2 Of 
                1 , 5 :
                        Begin
                          curl := q . b3 ;
                          ligaturepresent := true ;
                        End ;
                2 , 6 :
                        Begin
                          curr := q . b3 ;
                          If ligstack > 0 Then mem [ ligstack ] . hh . b1 := curr
                          Else
                            Begin
                              ligstack := newligitem ( curr ) ;
                              If j = n Then bchar := 256
                              Else
                                Begin
                                  p := getavail ;
                                  mem [ ligstack + 1 ] . hh . rh := p ;
                                  mem [ p ] . hh . b1 := hu [ j + 1 ] + 0 ;
                                  mem [ p ] . hh . b0 := hf ;
                                End ;
                            End ;
                        End ;
                3 :
                    Begin
                      curr := q . b3 ;
                      p := ligstack ;
                      ligstack := newligitem ( curr ) ;
                      mem [ ligstack ] . hh . rh := p ;
                    End ;
                7 , 11 :
                         Begin
                           If ligaturepresent Then
                             Begin
                               p := newligature ( hf , curl , mem [ curq ] . hh . rh ) ;
                               If lfthit Then
                                 Begin
                                   mem [ p ] . hh . b1 := 2 ;
                                   lfthit := false ;
                                 End ;
                               If false Then If ligstack = 0 Then
                                               Begin
                                                 mem [ p ] . hh . b1 := mem [ p ] . hh . b1 + 1 ;
                                                 rthit := false ;
                                               End ;
                               mem [ curq ] . hh . rh := p ;
                               t := p ;
                               ligaturepresent := false ;
                             End ;
                           curq := t ;
                           curl := q . b3 ;
                           ligaturepresent := true ;
                         End ;
                others :
                         Begin
                           curl := q . b3 ;
                           ligaturepresent := true ;
                           If ligstack > 0 Then
                             Begin
                               If mem [ ligstack + 1 ] . hh . rh > 0 Then
                                 Begin
                                   mem [ t ] . hh . rh := mem [ ligstack + 1 ] . hh . rh ;
                                   t := mem [ t ] . hh . rh ;
                                   j := j + 1 ;
                                 End ;
                               p := ligstack ;
                               ligstack := mem [ p ] . hh . rh ;
                               freenode ( p , 2 ) ;
                               If ligstack = 0 Then
                                 Begin
                                   If j < n Then curr := hu [ j + 1 ] + 0
                                   Else curr := bchar ;
                                   If odd ( hyf [ j ] ) Then currh := hchar
                                   Else currh := 256 ;
                                 End
                               Else curr := mem [ ligstack ] . hh . b1 ;
                             End
                           Else If j = n Then goto 30
                           Else
                             Begin
                               Begin
                                 mem [ t ] . hh . rh := getavail ;
                                 t := mem [ t ] . hh . rh ;
                                 mem [ t ] . hh . b0 := hf ;
                                 mem [ t ] . hh . b1 := curr ;
                               End ;
                               j := j + 1 ;
                               Begin
                                 If j < n Then curr := hu [ j + 1 ] + 0
                                 Else curr := bchar ;
                                 If odd ( hyf [ j ] ) Then currh := hchar
                                 Else currh := 256 ;
                               End ;
                             End ;
                         End
              End ;
              If q . b2 > 4 Then If q . b2 <> 7 Then goto 30 ;
              goto 22 ;
            End ;
          w := fontinfo [ kernbase [ hf ] + 256 * q . b2 + q . b3 ] . int ;
          goto 30 ;
        End ;
      If q . b0 >= 128 Then If currh = 256 Then goto 30
      Else
        Begin
          currh := 256 ;
          goto 22 ;
        End ;
      k := k + q . b0 + 1 ;
      q := fontinfo [ k ] . qqqq ;
    End ;
  30 : ;
  If ligaturepresent Then
    Begin
      p := newligature ( hf , curl , mem [ curq ] . hh . rh ) ;
      If lfthit Then
        Begin
          mem [ p ] . hh . b1 := 2 ;
          lfthit := false ;
        End ;
      If rthit Then If ligstack = 0 Then
                      Begin
                        mem [ p ] . hh . b1 := mem [ p ] . hh . b1 + 1 ;
                        rthit := false ;
                      End ;
      mem [ curq ] . hh . rh := p ;
      t := p ;
      ligaturepresent := false ;
    End ;
  If w <> 0 Then
    Begin
      mem [ t ] . hh . rh := newkern ( w ) ;
      t := mem [ t ] . hh . rh ;
      w := 0 ;
    End ;
  If ligstack > 0 Then
    Begin
      curq := t ;
      curl := mem [ ligstack ] . hh . b1 ;
      ligaturepresent := true ;
      Begin
        If mem [ ligstack + 1 ] . hh . rh > 0 Then
          Begin
            mem [ t ] . hh . rh := mem [ ligstack + 1 ] . hh . rh ;
            t := mem [ t ] . hh . rh ;
            j := j + 1 ;
          End ;
        p := ligstack ;
        ligstack := mem [ p ] . hh . rh ;
        freenode ( p , 2 ) ;
        If ligstack = 0 Then
          Begin
            If j < n Then curr := hu [ j + 1 ] + 0
            Else curr := bchar ;
            If odd ( hyf [ j ] ) Then currh := hchar
            Else currh := 256 ;
          End
        Else curr := mem [ ligstack ] . hh . b1 ;
      End ;
      goto 22 ;
    End ;
  reconstitute := j ;
End ;
Procedure hyphenate ;

Label 50 , 30 , 40 , 41 , 42 , 45 , 10 ;

Var i , j , l : 0 .. 65 ;
  q , r , s : halfword ;
  bchar : halfword ;
  majortail , minortail : halfword ;
  c : ASCIIcode ;
  cloc : 0 .. 63 ;
  rcount : integer ;
  hyfnode : halfword ;
  z : triepointer ;
  v : integer ;
  h : hyphpointer ;
  k : strnumber ;
  u : poolpointer ;
Begin
  For j := 0 To hn Do
    hyf [ j ] := 0 ;
  h := hc [ 1 ] ;
  hn := hn + 1 ;
  hc [ hn ] := curlang ;
  For j := 2 To hn Do
    h := ( h + h + hc [ j ] ) Mod 307 ;
  While true Do
    Begin
      k := hyphword [ h ] ;
      If k = 0 Then goto 45 ;
      If ( strstart [ k + 1 ] - strstart [ k ] ) < hn Then goto 45 ;
      If ( strstart [ k + 1 ] - strstart [ k ] ) = hn Then
        Begin
          j := 1 ;
          u := strstart [ k ] ;
          Repeat
            If strpool [ u ] < hc [ j ] Then goto 45 ;
            If strpool [ u ] > hc [ j ] Then goto 30 ;
            j := j + 1 ;
            u := u + 1 ;
          Until j > hn ;
          s := hyphlist [ h ] ;
          While s <> 0 Do
            Begin
              hyf [ mem [ s ] . hh . lh ] := 1 ;
              s := mem [ s ] . hh . rh ;
            End ;
          hn := hn - 1 ;
          goto 40 ;
        End ;
      30 : ;
      If h > 0 Then h := h - 1
      Else h := 307 ;
    End ;
  45 : hn := hn - 1 ;
  If trie [ curlang + 1 ] . b1 <> curlang + 0 Then goto 10 ;
  hc [ 0 ] := 0 ;
  hc [ hn + 1 ] := 0 ;
  hc [ hn + 2 ] := 256 ;
  For j := 0 To hn - rhyf + 1 Do
    Begin
      z := trie [ curlang + 1 ] . rh + hc [ j ] ;
      l := j ;
      While hc [ l ] = trie [ z ] . b1 - 0 Do
        Begin
          If trie [ z ] . b0 <> 0 Then
            Begin
              v := trie [ z ] . b0 ;
              Repeat
                v := v + opstart [ curlang ] ;
                i := l - hyfdistance [ v ] ;
                If hyfnum [ v ] > hyf [ i ] Then hyf [ i ] := hyfnum [ v ] ;
                v := hyfnext [ v ] ;
              Until v = 0 ;
            End ;
          l := l + 1 ;
          z := trie [ z ] . rh + hc [ l ] ;
        End ;
    End ;
  40 : For j := 0 To lhyf - 1 Do
         hyf [ j ] := 0 ;
  For j := 0 To rhyf - 1 Do
    hyf [ hn - j ] := 0 ;
  For j := lhyf To hn - rhyf Do
    If odd ( hyf [ j ] ) Then goto 41 ;
  goto 10 ;
  41 : ;
  q := mem [ hb ] . hh . rh ;
  mem [ hb ] . hh . rh := 0 ;
  r := mem [ ha ] . hh . rh ;
  mem [ ha ] . hh . rh := 0 ;
  bchar := hyfbchar ;
  If ( ha >= himemmin ) Then If mem [ ha ] . hh . b0 <> hf Then goto 42
  Else
    Begin
      initlist := ha ;
      initlig := false ;
      hu [ 0 ] := mem [ ha ] . hh . b1 - 0 ;
    End
  Else If mem [ ha ] . hh . b0 = 6 Then If mem [ ha + 1 ] . hh . b0 <> hf Then goto 42
  Else
    Begin
      initlist := mem [ ha + 1 ] . hh . rh ;
      initlig := true ;
      initlft := ( mem [ ha ] . hh . b1 > 1 ) ;
      hu [ 0 ] := mem [ ha + 1 ] . hh . b1 - 0 ;
      If initlist = 0 Then If initlft Then
                             Begin
                               hu [ 0 ] := 256 ;
                               initlig := false ;
                             End ;
      freenode ( ha , 2 ) ;
    End
  Else
    Begin
      If Not ( r >= himemmin ) Then If mem [ r ] . hh . b0 = 6 Then If mem [ r ] . hh . b1 > 1 Then goto 42 ;
      j := 1 ;
      s := ha ;
      initlist := 0 ;
      goto 50 ;
    End ;
  s := curp ;
  While mem [ s ] . hh . rh <> ha Do
    s := mem [ s ] . hh . rh ;
  j := 0 ;
  goto 50 ;
  42 : s := ha ;
  j := 0 ;
  hu [ 0 ] := 256 ;
  initlig := false ;
  initlist := 0 ;
  50 : flushnodelist ( r ) ;
  Repeat
    l := j ;
    j := reconstitute ( j , hn , bchar , hyfchar + 0 ) + 1 ;
    If hyphenpassed = 0 Then
      Begin
        mem [ s ] . hh . rh := mem [ 29996 ] . hh . rh ;
        While mem [ s ] . hh . rh > 0 Do
          s := mem [ s ] . hh . rh ;
        If odd ( hyf [ j - 1 ] ) Then
          Begin
            l := j ;
            hyphenpassed := j - 1 ;
            mem [ 29996 ] . hh . rh := 0 ;
          End ;
      End ;
    If hyphenpassed > 0 Then Repeat
                               r := getnode ( 2 ) ;
                               mem [ r ] . hh . rh := mem [ 29996 ] . hh . rh ;
                               mem [ r ] . hh . b0 := 7 ;
                               majortail := r ;
                               rcount := 0 ;
                               While mem [ majortail ] . hh . rh > 0 Do
                                 Begin
                                   majortail := mem [ majortail ] . hh . rh ;
                                   rcount := rcount + 1 ;
                                 End ;
                               i := hyphenpassed ;
                               hyf [ i ] := 0 ;
                               minortail := 0 ;
                               mem [ r + 1 ] . hh . lh := 0 ;
                               hyfnode := newcharacter ( hf , hyfchar ) ;
                               If hyfnode <> 0 Then
                                 Begin
                                   i := i + 1 ;
                                   c := hu [ i ] ;
                                   hu [ i ] := hyfchar ;
                                   Begin
                                     mem [ hyfnode ] . hh . rh := avail ;
                                     avail := hyfnode ;
                                   End ;
                                 End ;
                               While l <= i Do
                                 Begin
                                   l := reconstitute ( l , i , fontbchar [ hf ] , 256 ) + 1 ;
                                   If mem [ 29996 ] . hh . rh > 0 Then
                                     Begin
                                       If minortail = 0 Then mem [ r + 1 ] . hh . lh := mem [ 29996 ] . hh . rh
                                       Else mem [ minortail ] . hh . rh := mem [ 29996 ] . hh . rh ;
                                       minortail := mem [ 29996 ] . hh . rh ;
                                       While mem [ minortail ] . hh . rh > 0 Do
                                         minortail := mem [ minortail ] . hh . rh ;
                                     End ;
                                 End ;
                               If hyfnode <> 0 Then
                                 Begin
                                   hu [ i ] := c ;
                                   l := i ;
                                   i := i - 1 ;
                                 End ;
                               minortail := 0 ;
                               mem [ r + 1 ] . hh . rh := 0 ;
                               cloc := 0 ;
                               If bcharlabel [ hf ] <> 0 Then
                                 Begin
                                   l := l - 1 ;
                                   c := hu [ l ] ;
                                   cloc := l ;
                                   hu [ l ] := 256 ;
                                 End ;
                               While l < j Do
                                 Begin
                                   Repeat
                                     l := reconstitute ( l , hn , bchar , 256 ) + 1 ;
                                     If cloc > 0 Then
                                       Begin
                                         hu [ cloc ] := c ;
                                         cloc := 0 ;
                                       End ;
                                     If mem [ 29996 ] . hh . rh > 0 Then
                                       Begin
                                         If minortail = 0 Then mem [ r + 1 ] . hh . rh := mem [ 29996 ] . hh . rh
                                         Else mem [ minortail ] . hh . rh := mem [ 29996 ] . hh . rh ;
                                         minortail := mem [ 29996 ] . hh . rh ;
                                         While mem [ minortail ] . hh . rh > 0 Do
                                           minortail := mem [ minortail ] . hh . rh ;
                                       End ;
                                   Until l >= j ;
                                   While l > j Do
                                     Begin
                                       j := reconstitute ( j , hn , bchar , 256 ) + 1 ;
                                       mem [ majortail ] . hh . rh := mem [ 29996 ] . hh . rh ;
                                       While mem [ majortail ] . hh . rh > 0 Do
                                         Begin
                                           majortail := mem [ majortail ] . hh . rh ;
                                           rcount := rcount + 1 ;
                                         End ;
                                     End ;
                                 End ;
                               If rcount > 127 Then
                                 Begin
                                   mem [ s ] . hh . rh := mem [ r ] . hh . rh ;
                                   mem [ r ] . hh . rh := 0 ;
                                   flushnodelist ( r ) ;
                                 End
                               Else
                                 Begin
                                   mem [ s ] . hh . rh := r ;
                                   mem [ r ] . hh . b1 := rcount ;
                                 End ;
                               s := majortail ;
                               hyphenpassed := j - 1 ;
                               mem [ 29996 ] . hh . rh := 0 ;
      Until Not odd ( hyf [ j - 1 ] ) ;
  Until j > hn ;
  mem [ s ] . hh . rh := q ;
  flushlist ( initlist ) ;
  10 :
End ;
Function newtrieop ( d , n : smallnumber ; v : quarterword ) : quarterword ;

Label 10 ;

Var h : - trieopsize .. trieopsize ;
  u : quarterword ;
  l : 0 .. trieopsize ;
Begin
  h := abs ( n + 313 * d + 361 * v + 1009 * curlang ) Mod ( trieopsize + trieopsize ) - trieopsize ;
  While true Do
    Begin
      l := trieophash [ h ] ;
      If l = 0 Then
        Begin
          If trieopptr = trieopsize Then overflow ( 948 , trieopsize ) ;
          u := trieused [ curlang ] ;
          If u = 255 Then overflow ( 949 , 255 ) ;
          trieopptr := trieopptr + 1 ;
          u := u + 1 ;
          trieused [ curlang ] := u ;
          hyfdistance [ trieopptr ] := d ;
          hyfnum [ trieopptr ] := n ;
          hyfnext [ trieopptr ] := v ;
          trieoplang [ trieopptr ] := curlang ;
          trieophash [ h ] := trieopptr ;
          trieopval [ trieopptr ] := u ;
          newtrieop := u ;
          goto 10 ;
        End ;
      If ( hyfdistance [ l ] = d ) And ( hyfnum [ l ] = n ) And ( hyfnext [ l ] = v ) And ( trieoplang [ l ] = curlang ) Then
        Begin
          newtrieop := trieopval [ l ] ;
          goto 10 ;
        End ;
      If h > - trieopsize Then h := h - 1
      Else h := trieopsize ;
    End ;
  10 :
End ;
Function trienode ( p : triepointer ) : triepointer ;

Label 10 ;

Var h : triepointer ;
  q : triepointer ;
Begin
  h := abs ( triec [ p ] + 1009 * trieo [ p ] + 2718 * triel [ p ] + 3142 * trier [ p ] ) Mod triesize ;
  While true Do
    Begin
      q := triehash [ h ] ;
      If q = 0 Then
        Begin
          triehash [ h ] := p ;
          trienode := p ;
          goto 10 ;
        End ;
      If ( triec [ q ] = triec [ p ] ) And ( trieo [ q ] = trieo [ p ] ) And ( triel [ q ] = triel [ p ] ) And ( trier [ q ] = trier [ p ] ) Then
        Begin
          trienode := q ;
          goto 10 ;
        End ;
      If h > 0 Then h := h - 1
      Else h := triesize ;
    End ;
  10 :
End ;
Function compresstrie ( p : triepointer ) : triepointer ;
Begin
  If p = 0 Then compresstrie := 0
  Else
    Begin
      triel [ p ] := compresstrie ( triel [ p ] ) ;
      trier [ p ] := compresstrie ( trier [ p ] ) ;
      compresstrie := trienode ( p ) ;
    End ;
End ;
Procedure firstfit ( p : triepointer ) ;

Label 45 , 40 ;

Var h : triepointer ;
  z : triepointer ;
  q : triepointer ;
  c : ASCIIcode ;
  l , r : triepointer ;
  ll : 1 .. 256 ;
Begin
  c := triec [ p ] ;
  z := triemin [ c ] ;
  While true Do
    Begin
      h := z - c ;
      If triemax < h + 256 Then
        Begin
          If triesize <= h + 256 Then overflow ( 950 , triesize ) ;
          Repeat
            triemax := triemax + 1 ;
            trietaken [ triemax ] := false ;
            trie [ triemax ] . rh := triemax + 1 ;
            trie [ triemax ] . lh := triemax - 1 ;
          Until triemax = h + 256 ;
        End ;
      If trietaken [ h ] Then goto 45 ;
      q := trier [ p ] ;
      While q > 0 Do
        Begin
          If trie [ h + triec [ q ] ] . rh = 0 Then goto 45 ;
          q := trier [ q ] ;
        End ;
      goto 40 ;
      45 : z := trie [ z ] . rh ;
    End ;
  40 : trietaken [ h ] := true ;
  triehash [ p ] := h ;
  q := p ;
  Repeat
    z := h + triec [ q ] ;
    l := trie [ z ] . lh ;
    r := trie [ z ] . rh ;
    trie [ r ] . lh := l ;
    trie [ l ] . rh := r ;
    trie [ z ] . rh := 0 ;
    If l < 256 Then
      Begin
        If z < 256 Then ll := z
        Else ll := 256 ;
        Repeat
          triemin [ l ] := r ;
          l := l + 1 ;
        Until l = ll ;
      End ;
    q := trier [ q ] ;
  Until q = 0 ;
End ;
Procedure triepack ( p : triepointer ) ;

Var q : triepointer ;
Begin
  Repeat
    q := triel [ p ] ;
    If ( q > 0 ) And ( triehash [ q ] = 0 ) Then
      Begin
        firstfit ( q ) ;
        triepack ( q ) ;
      End ;
    p := trier [ p ] ;
  Until p = 0 ;
End ;
Procedure triefix ( p : triepointer ) ;

Var q : triepointer ;
  c : ASCIIcode ;
  z : triepointer ;
Begin
  z := triehash [ p ] ;
  Repeat
    q := triel [ p ] ;
    c := triec [ p ] ;
    trie [ z + c ] . rh := triehash [ q ] ;
    trie [ z + c ] . b1 := c + 0 ;
    trie [ z + c ] . b0 := trieo [ p ] ;
    If q > 0 Then triefix ( q ) ;
    p := trier [ p ] ;
  Until p = 0 ;
End ;
Procedure newpatterns ;

Label 30 , 31 ;

Var k , l : 0 .. 64 ;
  digitsensed : boolean ;
  v : quarterword ;
  p , q : triepointer ;
  firstchild : boolean ;
  c : ASCIIcode ;
Begin
  If trienotready Then
    Begin
      If eqtb [ 5313 ] . int <= 0 Then curlang := 0
      Else If eqtb [ 5313 ] . int > 255 Then curlang := 0
      Else curlang := eqtb [ 5313 ] . int ;
      scanleftbrace ;
      k := 0 ;
      hyf [ 0 ] := 0 ;
      digitsensed := false ;
      While true Do
        Begin
          getxtoken ;
          Case curcmd Of 
            11 , 12 : If digitsensed Or ( curchr < 48 ) Or ( curchr > 57 ) Then
                        Begin
                          If curchr = 46 Then curchr := 0
                          Else
                            Begin
                              curchr := eqtb [ 4239 + curchr ] . hh . rh ;
                              If curchr = 0 Then
                                Begin
                                  Begin
                                    If interaction = 3 Then ;
                                    printnl ( 262 ) ;
                                    print ( 956 ) ;
                                  End ;
                                  Begin
                                    helpptr := 1 ;
                                    helpline [ 0 ] := 955 ;
                                  End ;
                                  error ;
                                End ;
                            End ;
                          If k < 63 Then
                            Begin
                              k := k + 1 ;
                              hc [ k ] := curchr ;
                              hyf [ k ] := 0 ;
                              digitsensed := false ;
                            End ;
                        End
                      Else If k < 63 Then
                             Begin
                               hyf [ k ] := curchr - 48 ;
                               digitsensed := true ;
                             End ;
            10 , 2 :
                     Begin
                       If k > 0 Then
                         Begin
                           If hc [ 1 ] = 0 Then hyf [ 0 ] := 0 ;
                           If hc [ k ] = 0 Then hyf [ k ] := 0 ;
                           l := k ;
                           v := 0 ;
                           While true Do
                             Begin
                               If hyf [ l ] <> 0 Then v := newtrieop ( k - l , hyf [ l ] , v ) ;
                               If l > 0 Then l := l - 1
                               Else goto 31 ;
                             End ;
                           31 : ;
                           q := 0 ;
                           hc [ 0 ] := curlang ;
                           While l <= k Do
                             Begin
                               c := hc [ l ] ;
                               l := l + 1 ;
                               p := triel [ q ] ;
                               firstchild := true ;
                               While ( p > 0 ) And ( c > triec [ p ] ) Do
                                 Begin
                                   q := p ;
                                   p := trier [ q ] ;
                                   firstchild := false ;
                                 End ;
                               If ( p = 0 ) Or ( c < triec [ p ] ) Then
                                 Begin
                                   If trieptr = triesize Then overflow ( 950 , triesize ) ;
                                   trieptr := trieptr + 1 ;
                                   trier [ trieptr ] := p ;
                                   p := trieptr ;
                                   triel [ p ] := 0 ;
                                   If firstchild Then triel [ q ] := p
                                   Else trier [ q ] := p ;
                                   triec [ p ] := c ;
                                   trieo [ p ] := 0 ;
                                 End ;
                               q := p ;
                             End ;
                           If trieo [ q ] <> 0 Then
                             Begin
                               Begin
                                 If interaction = 3 Then ;
                                 printnl ( 262 ) ;
                                 print ( 957 ) ;
                               End ;
                               Begin
                                 helpptr := 1 ;
                                 helpline [ 0 ] := 955 ;
                               End ;
                               error ;
                             End ;
                           trieo [ q ] := v ;
                         End ;
                       If curcmd = 2 Then goto 30 ;
                       k := 0 ;
                       hyf [ 0 ] := 0 ;
                       digitsensed := false ;
                     End ;
            others :
                     Begin
                       Begin
                         If interaction = 3 Then ;
                         printnl ( 262 ) ;
                         print ( 954 ) ;
                       End ;
                       printesc ( 952 ) ;
                       Begin
                         helpptr := 1 ;
                         helpline [ 0 ] := 955 ;
                       End ;
                       error ;
                     End
          End ;
        End ;
      30 : ;
    End
  Else
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 951 ) ;
      End ;
      printesc ( 952 ) ;
      Begin
        helpptr := 1 ;
        helpline [ 0 ] := 953 ;
      End ;
      error ;
      mem [ 29988 ] . hh . rh := scantoks ( false , false ) ;
      flushlist ( defref ) ;
    End ;
End ;
Procedure inittrie ;

Var p : triepointer ;
  j , k , t : integer ;
  r , s : triepointer ;
  h : twohalves ;
Begin
  opstart [ 0 ] := - 0 ;
  For j := 1 To 255 Do
    opstart [ j ] := opstart [ j - 1 ] + trieused [ j - 1 ] - 0 ;
  For j := 1 To trieopptr Do
    trieophash [ j ] := opstart [ trieoplang [ j ] ] + trieopval [ j ] ;
  For j := 1 To trieopptr Do
    While trieophash [ j ] > j Do
      Begin
        k := trieophash [ j ] ;
        t := hyfdistance [ k ] ;
        hyfdistance [ k ] := hyfdistance [ j ] ;
        hyfdistance [ j ] := t ;
        t := hyfnum [ k ] ;
        hyfnum [ k ] := hyfnum [ j ] ;
        hyfnum [ j ] := t ;
        t := hyfnext [ k ] ;
        hyfnext [ k ] := hyfnext [ j ] ;
        hyfnext [ j ] := t ;
        trieophash [ j ] := trieophash [ k ] ;
        trieophash [ k ] := k ;
      End ;
  For p := 0 To triesize Do
    triehash [ p ] := 0 ;
  triel [ 0 ] := compresstrie ( triel [ 0 ] ) ;
  For p := 0 To trieptr Do
    triehash [ p ] := 0 ;
  For p := 0 To 255 Do
    triemin [ p ] := p + 1 ;
  trie [ 0 ] . rh := 1 ;
  triemax := 0 ;
  If triel [ 0 ] <> 0 Then
    Begin
      firstfit ( triel [ 0 ] ) ;
      triepack ( triel [ 0 ] ) ;
    End ;
  h . rh := 0 ;
  h . b0 := 0 ;
  h . b1 := 0 ;
  If triel [ 0 ] = 0 Then
    Begin
      For r := 0 To 256 Do
        trie [ r ] := h ;
      triemax := 256 ;
    End
  Else
    Begin
      triefix ( triel [ 0 ] ) ;
      r := 0 ;
      Repeat
        s := trie [ r ] . rh ;
        trie [ r ] := h ;
        r := s ;
      Until r > triemax ;
    End ;
  trie [ 0 ] . b1 := 63 ; ;
  trienotready := false ;
End ;
Procedure linebreak ( finalwidowpenalty : integer ) ;

Label 30 , 31 , 32 , 33 , 34 , 35 , 22 ;

Var autobreaking : boolean ;
  prevp : halfword ;
  q , r , s , prevs : halfword ;
  f : internalfontnumber ;
  j : smallnumber ;
  c : 0 .. 255 ;
Begin
  packbeginline := curlist . mlfield ;
  mem [ 29997 ] . hh . rh := mem [ curlist . headfield ] . hh . rh ;
  If ( curlist . tailfield >= himemmin ) Then
    Begin
      mem [ curlist . tailfield ] . hh . rh := newpenalty ( 10000 ) ;
      curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
    End
  Else If mem [ curlist . tailfield ] . hh . b0 <> 10 Then
         Begin
           mem [ curlist . tailfield ] . hh . rh := newpenalty ( 10000 ) ;
           curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
         End
  Else
    Begin
      mem [ curlist . tailfield ] . hh . b0 := 12 ;
      deleteglueref ( mem [ curlist . tailfield + 1 ] . hh . lh ) ;
      flushnodelist ( mem [ curlist . tailfield + 1 ] . hh . rh ) ;
      mem [ curlist . tailfield + 1 ] . int := 10000 ;
    End ;
  mem [ curlist . tailfield ] . hh . rh := newparamglue ( 14 ) ;
  initcurlang := curlist . pgfield Mod 65536 ;
  initlhyf := curlist . pgfield Div 4194304 ;
  initrhyf := ( curlist . pgfield Div 65536 ) Mod 64 ;
  popnest ;
  noshrinkerroryet := true ;
  If ( mem [ eqtb [ 2889 ] . hh . rh ] . hh . b1 <> 0 ) And ( mem [ eqtb [ 2889 ] . hh . rh + 3 ] . int <> 0 ) Then
    Begin
      eqtb [ 2889 ] . hh . rh := finiteshrink ( eqtb [ 2889 ] . hh . rh ) ;
    End ;
  If ( mem [ eqtb [ 2890 ] . hh . rh ] . hh . b1 <> 0 ) And ( mem [ eqtb [ 2890 ] . hh . rh + 3 ] . int <> 0 ) Then
    Begin
      eqtb [ 2890 ] . hh . rh := finiteshrink ( eqtb [ 2890 ] . hh . rh ) ;
    End ;
  q := eqtb [ 2889 ] . hh . rh ;
  r := eqtb [ 2890 ] . hh . rh ;
  background [ 1 ] := mem [ q + 1 ] . int + mem [ r + 1 ] . int ;
  background [ 2 ] := 0 ;
  background [ 3 ] := 0 ;
  background [ 4 ] := 0 ;
  background [ 5 ] := 0 ;
  background [ 2 + mem [ q ] . hh . b0 ] := mem [ q + 2 ] . int ;
  background [ 2 + mem [ r ] . hh . b0 ] := background [ 2 + mem [ r ] . hh . b0 ] + mem [ r + 2 ] . int ;
  background [ 6 ] := mem [ q + 3 ] . int + mem [ r + 3 ] . int ;
  minimumdemerits := 1073741823 ;
  minimaldemerits [ 3 ] := 1073741823 ;
  minimaldemerits [ 2 ] := 1073741823 ;
  minimaldemerits [ 1 ] := 1073741823 ;
  minimaldemerits [ 0 ] := 1073741823 ;
  If eqtb [ 3412 ] . hh . rh = 0 Then If eqtb [ 5847 ] . int = 0 Then
                                        Begin
                                          lastspecialline := 0 ;
                                          secondwidth := eqtb [ 5833 ] . int ;
                                          secondindent := 0 ;
                                        End
  Else
    Begin
      lastspecialline := abs ( eqtb [ 5304 ] . int ) ;
      If eqtb [ 5304 ] . int < 0 Then
        Begin
          firstwidth := eqtb [ 5833 ] . int - abs ( eqtb [ 5847 ] . int ) ;
          If eqtb [ 5847 ] . int >= 0 Then firstindent := eqtb [ 5847 ] . int
          Else firstindent := 0 ;
          secondwidth := eqtb [ 5833 ] . int ;
          secondindent := 0 ;
        End
      Else
        Begin
          firstwidth := eqtb [ 5833 ] . int ;
          firstindent := 0 ;
          secondwidth := eqtb [ 5833 ] . int - abs ( eqtb [ 5847 ] . int ) ;
          If eqtb [ 5847 ] . int >= 0 Then secondindent := eqtb [ 5847 ] . int
          Else secondindent := 0 ;
        End ;
    End
  Else
    Begin
      lastspecialline := mem [ eqtb [ 3412 ] . hh . rh ] . hh . lh - 1 ;
      secondwidth := mem [ eqtb [ 3412 ] . hh . rh + 2 * ( lastspecialline + 1 ) ] . int ;
      secondindent := mem [ eqtb [ 3412 ] . hh . rh + 2 * lastspecialline + 1 ] . int ;
    End ;
  If eqtb [ 5282 ] . int = 0 Then easyline := lastspecialline
  Else easyline := 65535 ;
  threshold := eqtb [ 5263 ] . int ;
  If threshold >= 0 Then
    Begin
      secondpass := false ;
      finalpass := false ;
    End
  Else
    Begin
      threshold := eqtb [ 5264 ] . int ;
      secondpass := true ;
      finalpass := ( eqtb [ 5850 ] . int <= 0 ) ;
    End ;
  While true Do
    Begin
      If threshold > 10000 Then threshold := 10000 ;
      If secondpass Then
        Begin
          If trienotready Then inittrie ;
          curlang := initcurlang ;
          lhyf := initlhyf ;
          rhyf := initrhyf ;
        End ;
      q := getnode ( 3 ) ;
      mem [ q ] . hh . b0 := 0 ;
      mem [ q ] . hh . b1 := 2 ;
      mem [ q ] . hh . rh := 29993 ;
      mem [ q + 1 ] . hh . rh := 0 ;
      mem [ q + 1 ] . hh . lh := curlist . pgfield + 1 ;
      mem [ q + 2 ] . int := 0 ;
      mem [ 29993 ] . hh . rh := q ;
      activewidth [ 1 ] := background [ 1 ] ;
      activewidth [ 2 ] := background [ 2 ] ;
      activewidth [ 3 ] := background [ 3 ] ;
      activewidth [ 4 ] := background [ 4 ] ;
      activewidth [ 5 ] := background [ 5 ] ;
      activewidth [ 6 ] := background [ 6 ] ;
      passive := 0 ;
      printednode := 29997 ;
      passnumber := 0 ;
      fontinshortdisplay := 0 ;
      curp := mem [ 29997 ] . hh . rh ;
      autobreaking := true ;
      prevp := curp ;
      While ( curp <> 0 ) And ( mem [ 29993 ] . hh . rh <> 29993 ) Do
        Begin
          If ( curp >= himemmin ) Then
            Begin
              prevp := curp ;
              Repeat
                f := mem [ curp ] . hh . b0 ;
                activewidth [ 1 ] := activewidth [ 1 ] + fontinfo [ widthbase [ f ] + fontinfo [ charbase [ f ] + mem [ curp ] . hh . b1 ] . qqqq . b0 ] . int ;
                curp := mem [ curp ] . hh . rh ;
              Until Not ( curp >= himemmin ) ;
            End ;
          Case mem [ curp ] . hh . b0 Of 
            0 , 1 , 2 : activewidth [ 1 ] := activewidth [ 1 ] + mem [ curp + 1 ] . int ;
            8 : If mem [ curp ] . hh . b1 = 4 Then
                  Begin
                    curlang := mem [ curp + 1 ] . hh . rh ;
                    lhyf := mem [ curp + 1 ] . hh . b0 ;
                    rhyf := mem [ curp + 1 ] . hh . b1 ;
                  End ;
            10 :
                 Begin
                   If autobreaking Then
                     Begin
                       If ( prevp >= himemmin ) Then trybreak ( 0 , 0 )
                       Else If ( mem [ prevp ] . hh . b0 < 9 ) Then trybreak ( 0 , 0 )
                       Else If ( mem [ prevp ] . hh . b0 = 11 ) And ( mem [ prevp ] . hh . b1 <> 1 ) Then trybreak ( 0 , 0 ) ;
                     End ;
                   If ( mem [ mem [ curp + 1 ] . hh . lh ] . hh . b1 <> 0 ) And ( mem [ mem [ curp + 1 ] . hh . lh + 3 ] . int <> 0 ) Then
                     Begin
                       mem [ curp + 1 ] . hh . lh := finiteshrink ( mem [ curp + 1 ] . hh . lh ) ;
                     End ;
                   q := mem [ curp + 1 ] . hh . lh ;
                   activewidth [ 1 ] := activewidth [ 1 ] + mem [ q + 1 ] . int ;
                   activewidth [ 2 + mem [ q ] . hh . b0 ] := activewidth [ 2 + mem [ q ] . hh . b0 ] + mem [ q + 2 ] . int ;
                   activewidth [ 6 ] := activewidth [ 6 ] + mem [ q + 3 ] . int ;
                   If secondpass And autobreaking Then
                     Begin
                       prevs := curp ;
                       s := mem [ prevs ] . hh . rh ;
                       If s <> 0 Then
                         Begin
                           While true Do
                             Begin
                               If ( s >= himemmin ) Then
                                 Begin
                                   c := mem [ s ] . hh . b1 - 0 ;
                                   hf := mem [ s ] . hh . b0 ;
                                 End
                               Else If mem [ s ] . hh . b0 = 6 Then If mem [ s + 1 ] . hh . rh = 0 Then goto 22
                               Else
                                 Begin
                                   q := mem [ s + 1 ] . hh . rh ;
                                   c := mem [ q ] . hh . b1 - 0 ;
                                   hf := mem [ q ] . hh . b0 ;
                                 End
                               Else If ( mem [ s ] . hh . b0 = 11 ) And ( mem [ s ] . hh . b1 = 0 ) Then goto 22
                               Else If mem [ s ] . hh . b0 = 8 Then
                                      Begin
                                        If mem [ s ] . hh . b1 = 4 Then
                                          Begin
                                            curlang := mem [ s + 1 ] . hh . rh ;
                                            lhyf := mem [ s + 1 ] . hh . b0 ;
                                            rhyf := mem [ s + 1 ] . hh . b1 ;
                                          End ;
                                        goto 22 ;
                                      End
                               Else goto 31 ;
                               If eqtb [ 4239 + c ] . hh . rh <> 0 Then If ( eqtb [ 4239 + c ] . hh . rh = c ) Or ( eqtb [ 5301 ] . int > 0 ) Then goto 32
                               Else goto 31 ;
                               22 : prevs := s ;
                               s := mem [ prevs ] . hh . rh ;
                             End ;
                           32 : hyfchar := hyphenchar [ hf ] ;
                           If hyfchar < 0 Then goto 31 ;
                           If hyfchar > 255 Then goto 31 ;
                           ha := prevs ;
                           If lhyf + rhyf > 63 Then goto 31 ;
                           hn := 0 ;
                           While true Do
                             Begin
                               If ( s >= himemmin ) Then
                                 Begin
                                   If mem [ s ] . hh . b0 <> hf Then goto 33 ;
                                   hyfbchar := mem [ s ] . hh . b1 ;
                                   c := hyfbchar - 0 ;
                                   If eqtb [ 4239 + c ] . hh . rh = 0 Then goto 33 ;
                                   If hn = 63 Then goto 33 ;
                                   hb := s ;
                                   hn := hn + 1 ;
                                   hu [ hn ] := c ;
                                   hc [ hn ] := eqtb [ 4239 + c ] . hh . rh ;
                                   hyfbchar := 256 ;
                                 End
                               Else If mem [ s ] . hh . b0 = 6 Then
                                      Begin
                                        If mem [ s + 1 ] . hh . b0 <> hf Then goto 33 ;
                                        j := hn ;
                                        q := mem [ s + 1 ] . hh . rh ;
                                        If q > 0 Then hyfbchar := mem [ q ] . hh . b1 ;
                                        While q > 0 Do
                                          Begin
                                            c := mem [ q ] . hh . b1 - 0 ;
                                            If eqtb [ 4239 + c ] . hh . rh = 0 Then goto 33 ;
                                            If j = 63 Then goto 33 ;
                                            j := j + 1 ;
                                            hu [ j ] := c ;
                                            hc [ j ] := eqtb [ 4239 + c ] . hh . rh ;
                                            q := mem [ q ] . hh . rh ;
                                          End ;
                                        hb := s ;
                                        hn := j ;
                                        If odd ( mem [ s ] . hh . b1 ) Then hyfbchar := fontbchar [ hf ]
                                        Else hyfbchar := 256 ;
                                      End
                               Else If ( mem [ s ] . hh . b0 = 11 ) And ( mem [ s ] . hh . b1 = 0 ) Then
                                      Begin
                                        hb := s ;
                                        hyfbchar := fontbchar [ hf ] ;
                                      End
                               Else goto 33 ;
                               s := mem [ s ] . hh . rh ;
                             End ;
                           33 : ;
                           If hn < lhyf + rhyf Then goto 31 ;
                           While true Do
                             Begin
                               If Not ( ( s >= himemmin ) ) Then Case mem [ s ] . hh . b0 Of 
                                                                   6 : ;
                                                                   11 : If mem [ s ] . hh . b1 <> 0 Then goto 34 ;
                                                                   8 , 10 , 12 , 3 , 5 , 4 : goto 34 ;
                                                                   others : goto 31
                                 End ;
                               s := mem [ s ] . hh . rh ;
                             End ;
                           34 : ;
                           hyphenate ;
                         End ;
                       31 :
                     End ;
                 End ;
            11 : If mem [ curp ] . hh . b1 = 1 Then
                   Begin
                     If Not ( mem [ curp ] . hh . rh >= himemmin ) And autobreaking Then If mem [ mem [ curp ] . hh . rh ] . hh . b0 = 10 Then trybreak ( 0 , 0 ) ;
                     activewidth [ 1 ] := activewidth [ 1 ] + mem [ curp + 1 ] . int ;
                   End
                 Else activewidth [ 1 ] := activewidth [ 1 ] + mem [ curp + 1 ] . int ;
            6 :
                Begin
                  f := mem [ curp + 1 ] . hh . b0 ;
                  activewidth [ 1 ] := activewidth [ 1 ] + fontinfo [ widthbase [ f ] + fontinfo [ charbase [ f ] + mem [ curp + 1 ] . hh . b1 ] . qqqq . b0 ] . int ;
                End ;
            7 :
                Begin
                  s := mem [ curp + 1 ] . hh . lh ;
                  discwidth := 0 ;
                  If s = 0 Then trybreak ( eqtb [ 5267 ] . int , 1 )
                  Else
                    Begin
                      Repeat
                        If ( s >= himemmin ) Then
                          Begin
                            f := mem [ s ] . hh . b0 ;
                            discwidth := discwidth + fontinfo [ widthbase [ f ] + fontinfo [ charbase [ f ] + mem [ s ] . hh . b1 ] . qqqq . b0 ] . int ;
                          End
                        Else Case mem [ s ] . hh . b0 Of 
                               6 :
                                   Begin
                                     f := mem [ s + 1 ] . hh . b0 ;
                                     discwidth := discwidth + fontinfo [ widthbase [ f ] + fontinfo [ charbase [ f ] + mem [ s + 1 ] . hh . b1 ] . qqqq . b0 ] . int ;
                                   End ;
                               0 , 1 , 2 , 11 : discwidth := discwidth + mem [ s + 1 ] . int ;
                               others : confusion ( 936 )
                          End ;
                        s := mem [ s ] . hh . rh ;
                      Until s = 0 ;
                      activewidth [ 1 ] := activewidth [ 1 ] + discwidth ;
                      trybreak ( eqtb [ 5266 ] . int , 1 ) ;
                      activewidth [ 1 ] := activewidth [ 1 ] - discwidth ;
                    End ;
                  r := mem [ curp ] . hh . b1 ;
                  s := mem [ curp ] . hh . rh ;
                  While r > 0 Do
                    Begin
                      If ( s >= himemmin ) Then
                        Begin
                          f := mem [ s ] . hh . b0 ;
                          activewidth [ 1 ] := activewidth [ 1 ] + fontinfo [ widthbase [ f ] + fontinfo [ charbase [ f ] + mem [ s ] . hh . b1 ] . qqqq . b0 ] . int ;
                        End
                      Else Case mem [ s ] . hh . b0 Of 
                             6 :
                                 Begin
                                   f := mem [ s + 1 ] . hh . b0 ;
                                   activewidth [ 1 ] := activewidth [ 1 ] + fontinfo [ widthbase [ f ] + fontinfo [ charbase [ f ] + mem [ s + 1 ] . hh . b1 ] . qqqq . b0 ] . int ;
                                 End ;
                             0 , 1 , 2 , 11 : activewidth [ 1 ] := activewidth [ 1 ] + mem [ s + 1 ] . int ;
                             others : confusion ( 937 )
                        End ;
                      r := r - 1 ;
                      s := mem [ s ] . hh . rh ;
                    End ;
                  prevp := curp ;
                  curp := s ;
                  goto 35 ;
                End ;
            9 :
                Begin
                  autobreaking := ( mem [ curp ] . hh . b1 = 1 ) ;
                  Begin
                    If Not ( mem [ curp ] . hh . rh >= himemmin ) And autobreaking Then If mem [ mem [ curp ] . hh . rh ] . hh . b0 = 10 Then trybreak ( 0 , 0 ) ;
                    activewidth [ 1 ] := activewidth [ 1 ] + mem [ curp + 1 ] . int ;
                  End ;
                End ;
            12 : trybreak ( mem [ curp + 1 ] . int , 0 ) ;
            4 , 3 , 5 : ;
            others : confusion ( 935 )
          End ;
          prevp := curp ;
          curp := mem [ curp ] . hh . rh ;
          35 :
        End ;
      If curp = 0 Then
        Begin
          trybreak ( - 10000 , 1 ) ;
          If mem [ 29993 ] . hh . rh <> 29993 Then
            Begin
              r := mem [ 29993 ] . hh . rh ;
              fewestdemerits := 1073741823 ;
              Repeat
                If mem [ r ] . hh . b0 <> 2 Then If mem [ r + 2 ] . int < fewestdemerits Then
                                                   Begin
                                                     fewestdemerits := mem [ r + 2 ] . int ;
                                                     bestbet := r ;
                                                   End ;
                r := mem [ r ] . hh . rh ;
              Until r = 29993 ;
              bestline := mem [ bestbet + 1 ] . hh . lh ;
              If eqtb [ 5282 ] . int = 0 Then goto 30 ;
              Begin
                r := mem [ 29993 ] . hh . rh ;
                actuallooseness := 0 ;
                Repeat
                  If mem [ r ] . hh . b0 <> 2 Then
                    Begin
                      linediff := mem [ r + 1 ] . hh . lh - bestline ;
                      If ( ( linediff < actuallooseness ) And ( eqtb [ 5282 ] . int <= linediff ) ) Or ( ( linediff > actuallooseness ) And ( eqtb [ 5282 ] . int >= linediff ) ) Then
                        Begin
                          bestbet := r ;
                          actuallooseness := linediff ;
                          fewestdemerits := mem [ r + 2 ] . int ;
                        End
                      Else If ( linediff = actuallooseness ) And ( mem [ r + 2 ] . int < fewestdemerits ) Then
                             Begin
                               bestbet := r ;
                               fewestdemerits := mem [ r + 2 ] . int ;
                             End ;
                    End ;
                  r := mem [ r ] . hh . rh ;
                Until r = 29993 ;
                bestline := mem [ bestbet + 1 ] . hh . lh ;
              End ;
              If ( actuallooseness = eqtb [ 5282 ] . int ) Or finalpass Then goto 30 ;
            End ;
        End ;
      q := mem [ 29993 ] . hh . rh ;
      While q <> 29993 Do
        Begin
          curp := mem [ q ] . hh . rh ;
          If mem [ q ] . hh . b0 = 2 Then freenode ( q , 7 )
          Else freenode ( q , 3 ) ;
          q := curp ;
        End ;
      q := passive ;
      While q <> 0 Do
        Begin
          curp := mem [ q ] . hh . rh ;
          freenode ( q , 2 ) ;
          q := curp ;
        End ;
      If Not secondpass Then
        Begin
          threshold := eqtb [ 5264 ] . int ;
          secondpass := true ;
          finalpass := ( eqtb [ 5850 ] . int <= 0 ) ;
        End
      Else
        Begin
          background [ 2 ] := background [ 2 ] + eqtb [ 5850 ] . int ;
          finalpass := true ;
        End ;
    End ;
  30 : ;
  postlinebreak ( finalwidowpenalty ) ;
  q := mem [ 29993 ] . hh . rh ;
  While q <> 29993 Do
    Begin
      curp := mem [ q ] . hh . rh ;
      If mem [ q ] . hh . b0 = 2 Then freenode ( q , 7 )
      Else freenode ( q , 3 ) ;
      q := curp ;
    End ;
  q := passive ;
  While q <> 0 Do
    Begin
      curp := mem [ q ] . hh . rh ;
      freenode ( q , 2 ) ;
      q := curp ;
    End ;
  packbeginline := 0 ;
End ;
Procedure newhyphexceptions ;

Label 21 , 10 , 40 , 45 ;

Var n : 0 .. 64 ;
  j : 0 .. 64 ;
  h : hyphpointer ;
  k : strnumber ;
  p : halfword ;
  q : halfword ;
  s , t : strnumber ;
  u , v : poolpointer ;
Begin
  scanleftbrace ;
  If eqtb [ 5313 ] . int <= 0 Then curlang := 0
  Else If eqtb [ 5313 ] . int > 255 Then curlang := 0
  Else curlang := eqtb [ 5313 ] . int ;
  n := 0 ;
  p := 0 ;
  While true Do
    Begin
      getxtoken ;
      21 : Case curcmd Of 
             11 , 12 , 68 : If curchr = 45 Then
                              Begin
                                If n < 63 Then
                                  Begin
                                    q := getavail ;
                                    mem [ q ] . hh . rh := p ;
                                    mem [ q ] . hh . lh := n ;
                                    p := q ;
                                  End ;
                              End
                            Else
                              Begin
                                If eqtb [ 4239 + curchr ] . hh . rh = 0 Then
                                  Begin
                                    Begin
                                      If interaction = 3 Then ;
                                      printnl ( 262 ) ;
                                      print ( 944 ) ;
                                    End ;
                                    Begin
                                      helpptr := 2 ;
                                      helpline [ 1 ] := 945 ;
                                      helpline [ 0 ] := 946 ;
                                    End ;
                                    error ;
                                  End
                                Else If n < 63 Then
                                       Begin
                                         n := n + 1 ;
                                         hc [ n ] := eqtb [ 4239 + curchr ] . hh . rh ;
                                       End ;
                              End ;
             16 :
                  Begin
                    scancharnum ;
                    curchr := curval ;
                    curcmd := 68 ;
                    goto 21 ;
                  End ;
             10 , 2 :
                      Begin
                        If n > 1 Then
                          Begin
                            n := n + 1 ;
                            hc [ n ] := curlang ;
                            Begin
                              If poolptr + n > poolsize Then overflow ( 257 , poolsize - initpoolptr ) ;
                            End ;
                            h := 0 ;
                            For j := 1 To n Do
                              Begin
                                h := ( h + h + hc [ j ] ) Mod 307 ;
                                Begin
                                  strpool [ poolptr ] := hc [ j ] ;
                                  poolptr := poolptr + 1 ;
                                End ;
                              End ;
                            s := makestring ;
                            If hyphcount = 307 Then overflow ( 947 , 307 ) ;
                            hyphcount := hyphcount + 1 ;
                            While hyphword [ h ] <> 0 Do
                              Begin
                                k := hyphword [ h ] ;
                                If ( strstart [ k + 1 ] - strstart [ k ] ) < ( strstart [ s + 1 ] - strstart [ s ] ) Then goto 40 ;
                                If ( strstart [ k + 1 ] - strstart [ k ] ) > ( strstart [ s + 1 ] - strstart [ s ] ) Then goto 45 ;
                                u := strstart [ k ] ;
                                v := strstart [ s ] ;
                                Repeat
                                  If strpool [ u ] < strpool [ v ] Then goto 40 ;
                                  If strpool [ u ] > strpool [ v ] Then goto 45 ;
                                  u := u + 1 ;
                                  v := v + 1 ;
                                Until u = strstart [ k + 1 ] ;
                                40 : q := hyphlist [ h ] ;
                                hyphlist [ h ] := p ;
                                p := q ;
                                t := hyphword [ h ] ;
                                hyphword [ h ] := s ;
                                s := t ;
                                45 : ;
                                If h > 0 Then h := h - 1
                                Else h := 307 ;
                              End ;
                            hyphword [ h ] := s ;
                            hyphlist [ h ] := p ;
                          End ;
                        If curcmd = 2 Then goto 10 ;
                        n := 0 ;
                        p := 0 ;
                      End ;
             others :
                      Begin
                        Begin
                          If interaction = 3 Then ;
                          printnl ( 262 ) ;
                          print ( 680 ) ;
                        End ;
                        printesc ( 940 ) ;
                        print ( 941 ) ;
                        Begin
                          helpptr := 2 ;
                          helpline [ 1 ] := 942 ;
                          helpline [ 0 ] := 943 ;
                        End ;
                        error ;
                      End
           End ;
    End ;
  10 :
End ;
Function prunepagetop ( p : halfword ) : halfword ;

Var prevp : halfword ;
  q : halfword ;
Begin
  prevp := 29997 ;
  mem [ 29997 ] . hh . rh := p ;
  While p <> 0 Do
    Case mem [ p ] . hh . b0 Of 
      0 , 1 , 2 :
                  Begin
                    q := newskipparam ( 10 ) ;
                    mem [ prevp ] . hh . rh := q ;
                    mem [ q ] . hh . rh := p ;
                    If mem [ tempptr + 1 ] . int > mem [ p + 3 ] . int Then mem [ tempptr + 1 ] . int := mem [ tempptr + 1 ] . int - mem [ p + 3 ] . int
                    Else mem [ tempptr + 1 ] . int := 0 ;
                    p := 0 ;
                  End ;
      8 , 4 , 3 :
                  Begin
                    prevp := p ;
                    p := mem [ prevp ] . hh . rh ;
                  End ;
      10 , 11 , 12 :
                     Begin
                       q := p ;
                       p := mem [ q ] . hh . rh ;
                       mem [ q ] . hh . rh := 0 ;
                       mem [ prevp ] . hh . rh := p ;
                       flushnodelist ( q ) ;
                     End ;
      others : confusion ( 958 )
    End ;
  prunepagetop := mem [ 29997 ] . hh . rh ;
End ;
Function vertbreak ( p : halfword ; h , d : scaled ) : halfword ;

Label 30 , 45 , 90 ;

Var prevp : halfword ;
  q , r : halfword ;
  pi : integer ;
  b : integer ;
  leastcost : integer ;
  bestplace : halfword ;
  prevdp : scaled ;
  t : smallnumber ;
Begin
  prevp := p ;
  leastcost := 1073741823 ;
  activewidth [ 1 ] := 0 ;
  activewidth [ 2 ] := 0 ;
  activewidth [ 3 ] := 0 ;
  activewidth [ 4 ] := 0 ;
  activewidth [ 5 ] := 0 ;
  activewidth [ 6 ] := 0 ;
  prevdp := 0 ;
  While true Do
    Begin
      If p = 0 Then pi := - 10000
      Else Case mem [ p ] . hh . b0 Of 
             0 , 1 , 2 :
                         Begin
                           activewidth [ 1 ] := activewidth [ 1 ] + prevdp + mem [ p + 3 ] . int ;
                           prevdp := mem [ p + 2 ] . int ;
                           goto 45 ;
                         End ;
             8 : goto 45 ;
             10 : If ( mem [ prevp ] . hh . b0 < 9 ) Then pi := 0
                  Else goto 90 ;
             11 :
                  Begin
                    If mem [ p ] . hh . rh = 0 Then t := 12
                    Else t := mem [ mem [ p ] . hh . rh ] . hh . b0 ;
                    If t = 10 Then pi := 0
                    Else goto 90 ;
                  End ;
             12 : pi := mem [ p + 1 ] . int ;
             4 , 3 : goto 45 ;
             others : confusion ( 959 )
        End ;
      If pi < 10000 Then
        Begin
          If activewidth [ 1 ] < h Then If ( activewidth [ 3 ] <> 0 ) Or ( activewidth [ 4 ] <> 0 ) Or ( activewidth [ 5 ] <> 0 ) Then b := 0
          Else b := badness ( h - activewidth [ 1 ] , activewidth [ 2 ] )
          Else If activewidth [ 1 ] - h > activewidth [ 6 ] Then b := 1073741823
          Else b := badness ( activewidth [ 1 ] - h , activewidth [ 6 ] ) ;
          If b < 1073741823 Then If pi <= - 10000 Then b := pi
          Else If b < 10000 Then b := b + pi
          Else b := 100000 ;
          If b <= leastcost Then
            Begin
              bestplace := p ;
              leastcost := b ;
              bestheightplusdepth := activewidth [ 1 ] + prevdp ;
            End ;
          If ( b = 1073741823 ) Or ( pi <= - 10000 ) Then goto 30 ;
        End ;
      If ( mem [ p ] . hh . b0 < 10 ) Or ( mem [ p ] . hh . b0 > 11 ) Then goto 45 ;
      90 : If mem [ p ] . hh . b0 = 11 Then q := p
           Else
             Begin
               q := mem [ p + 1 ] . hh . lh ;
               activewidth [ 2 + mem [ q ] . hh . b0 ] := activewidth [ 2 + mem [ q ] . hh . b0 ] + mem [ q + 2 ] . int ;
               activewidth [ 6 ] := activewidth [ 6 ] + mem [ q + 3 ] . int ;
               If ( mem [ q ] . hh . b1 <> 0 ) And ( mem [ q + 3 ] . int <> 0 ) Then
                 Begin
                   Begin
                     If interaction = 3 Then ;
                     printnl ( 262 ) ;
                     print ( 960 ) ;
                   End ;
                   Begin
                     helpptr := 4 ;
                     helpline [ 3 ] := 961 ;
                     helpline [ 2 ] := 962 ;
                     helpline [ 1 ] := 963 ;
                     helpline [ 0 ] := 921 ;
                   End ;
                   error ;
                   r := newspec ( q ) ;
                   mem [ r ] . hh . b1 := 0 ;
                   deleteglueref ( q ) ;
                   mem [ p + 1 ] . hh . lh := r ;
                   q := r ;
                 End ;
             End ;
      activewidth [ 1 ] := activewidth [ 1 ] + prevdp + mem [ q + 1 ] . int ;
      prevdp := 0 ;
      45 : If prevdp > d Then
             Begin
               activewidth [ 1 ] := activewidth [ 1 ] + prevdp - d ;
               prevdp := d ;
             End ; ;
      prevp := p ;
      p := mem [ prevp ] . hh . rh ;
    End ;
  30 : vertbreak := bestplace ;
End ;
Function vsplit ( n : eightbits ; h : scaled ) : halfword ;

Label 10 , 30 ;

Var v : halfword ;
  p : halfword ;
  q : halfword ;
Begin
  v := eqtb [ 3678 + n ] . hh . rh ;
  If curmark [ 3 ] <> 0 Then
    Begin
      deletetokenref ( curmark [ 3 ] ) ;
      curmark [ 3 ] := 0 ;
      deletetokenref ( curmark [ 4 ] ) ;
      curmark [ 4 ] := 0 ;
    End ;
  If v = 0 Then
    Begin
      vsplit := 0 ;
      goto 10 ;
    End ;
  If mem [ v ] . hh . b0 <> 1 Then
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 338 ) ;
      End ;
      printesc ( 964 ) ;
      print ( 965 ) ;
      printesc ( 966 ) ;
      Begin
        helpptr := 2 ;
        helpline [ 1 ] := 967 ;
        helpline [ 0 ] := 968 ;
      End ;
      error ;
      vsplit := 0 ;
      goto 10 ;
    End ;
  q := vertbreak ( mem [ v + 5 ] . hh . rh , h , eqtb [ 5836 ] . int ) ;
  p := mem [ v + 5 ] . hh . rh ;
  If p = q Then mem [ v + 5 ] . hh . rh := 0
  Else While true Do
         Begin
           If mem [ p ] . hh . b0 = 4 Then If curmark [ 3 ] = 0 Then
                                             Begin
                                               curmark [ 3 ] := mem [ p + 1 ] . int ;
                                               curmark [ 4 ] := curmark [ 3 ] ;
                                               mem [ curmark [ 3 ] ] . hh . lh := mem [ curmark [ 3 ] ] . hh . lh + 2 ;
                                             End
           Else
             Begin
               deletetokenref ( curmark [ 4 ] ) ;
               curmark [ 4 ] := mem [ p + 1 ] . int ;
               mem [ curmark [ 4 ] ] . hh . lh := mem [ curmark [ 4 ] ] . hh . lh + 1 ;
             End ;
           If mem [ p ] . hh . rh = q Then
             Begin
               mem [ p ] . hh . rh := 0 ;
               goto 30 ;
             End ;
           p := mem [ p ] . hh . rh ;
         End ;
  30 : ;
  q := prunepagetop ( q ) ;
  p := mem [ v + 5 ] . hh . rh ;
  freenode ( v , 7 ) ;
  If q = 0 Then eqtb [ 3678 + n ] . hh . rh := 0
  Else eqtb [ 3678 + n ] . hh . rh := vpackage ( q , 0 , 1 , 1073741823 ) ;
  vsplit := vpackage ( p , h , 0 , eqtb [ 5836 ] . int ) ;
  10 :
End ;
Procedure printtotals ;
Begin
  printscaled ( pagesofar [ 1 ] ) ;
  If pagesofar [ 2 ] <> 0 Then
    Begin
      print ( 312 ) ;
      printscaled ( pagesofar [ 2 ] ) ;
      print ( 338 ) ;
    End ;
  If pagesofar [ 3 ] <> 0 Then
    Begin
      print ( 312 ) ;
      printscaled ( pagesofar [ 3 ] ) ;
      print ( 311 ) ;
    End ;
  If pagesofar [ 4 ] <> 0 Then
    Begin
      print ( 312 ) ;
      printscaled ( pagesofar [ 4 ] ) ;
      print ( 977 ) ;
    End ;
  If pagesofar [ 5 ] <> 0 Then
    Begin
      print ( 312 ) ;
      printscaled ( pagesofar [ 5 ] ) ;
      print ( 978 ) ;
    End ;
  If pagesofar [ 6 ] <> 0 Then
    Begin
      print ( 313 ) ;
      printscaled ( pagesofar [ 6 ] ) ;
    End ;
End ;
Procedure freezepagespecs ( s : smallnumber ) ;
Begin
  pagecontents := s ;
  pagesofar [ 0 ] := eqtb [ 5834 ] . int ;
  pagemaxdepth := eqtb [ 5835 ] . int ;
  pagesofar [ 7 ] := 0 ;
  pagesofar [ 1 ] := 0 ;
  pagesofar [ 2 ] := 0 ;
  pagesofar [ 3 ] := 0 ;
  pagesofar [ 4 ] := 0 ;
  pagesofar [ 5 ] := 0 ;
  pagesofar [ 6 ] := 0 ;
  leastpagecost := 1073741823 ;
End ;
Procedure boxerror ( n : eightbits ) ;
Begin
  error ;
  begindiagnostic ;
  printnl ( 835 ) ;
  showbox ( eqtb [ 3678 + n ] . hh . rh ) ;
  enddiagnostic ( true ) ;
  flushnodelist ( eqtb [ 3678 + n ] . hh . rh ) ;
  eqtb [ 3678 + n ] . hh . rh := 0 ;
End ;
Procedure ensurevbox ( n : eightbits ) ;

Var p : halfword ;
Begin
  p := eqtb [ 3678 + n ] . hh . rh ;
  If p <> 0 Then If mem [ p ] . hh . b0 = 0 Then
                   Begin
                     Begin
                       If interaction = 3 Then ;
                       printnl ( 262 ) ;
                       print ( 988 ) ;
                     End ;
                     Begin
                       helpptr := 3 ;
                       helpline [ 2 ] := 989 ;
                       helpline [ 1 ] := 990 ;
                       helpline [ 0 ] := 991 ;
                     End ;
                     boxerror ( n ) ;
                   End ;
End ;
Procedure fireup ( c : halfword ) ;

Label 10 ;

Var p , q , r , s : halfword ;
  prevp : halfword ;
  n : 0 .. 255 ;
  wait : boolean ;
  savevbadness : integer ;
  savevfuzz : scaled ;
  savesplittopskip : halfword ;
Begin
  If mem [ bestpagebreak ] . hh . b0 = 12 Then
    Begin
      geqworddefine ( 5302 , mem [ bestpagebreak + 1 ] . int ) ;
      mem [ bestpagebreak + 1 ] . int := 10000 ;
    End
  Else geqworddefine ( 5302 , 10000 ) ;
  If curmark [ 2 ] <> 0 Then
    Begin
      If curmark [ 0 ] <> 0 Then deletetokenref ( curmark [ 0 ] ) ;
      curmark [ 0 ] := curmark [ 2 ] ;
      mem [ curmark [ 0 ] ] . hh . lh := mem [ curmark [ 0 ] ] . hh . lh + 1 ;
      deletetokenref ( curmark [ 1 ] ) ;
      curmark [ 1 ] := 0 ;
    End ;
  If c = bestpagebreak Then bestpagebreak := 0 ;
  If eqtb [ 3933 ] . hh . rh <> 0 Then
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 338 ) ;
      End ;
      printesc ( 409 ) ;
      print ( 1002 ) ;
      Begin
        helpptr := 2 ;
        helpline [ 1 ] := 1003 ;
        helpline [ 0 ] := 991 ;
      End ;
      boxerror ( 255 ) ;
    End ;
  insertpenalties := 0 ;
  savesplittopskip := eqtb [ 2892 ] . hh . rh ;
  If eqtb [ 5316 ] . int <= 0 Then
    Begin
      r := mem [ 30000 ] . hh . rh ;
      While r <> 30000 Do
        Begin
          If mem [ r + 2 ] . hh . lh <> 0 Then
            Begin
              n := mem [ r ] . hh . b1 - 0 ;
              ensurevbox ( n ) ;
              If eqtb [ 3678 + n ] . hh . rh = 0 Then eqtb [ 3678 + n ] . hh . rh := newnullbox ;
              p := eqtb [ 3678 + n ] . hh . rh + 5 ;
              While mem [ p ] . hh . rh <> 0 Do
                p := mem [ p ] . hh . rh ;
              mem [ r + 2 ] . hh . rh := p ;
            End ;
          r := mem [ r ] . hh . rh ;
        End ;
    End ;
  q := 29996 ;
  mem [ q ] . hh . rh := 0 ;
  prevp := 29998 ;
  p := mem [ prevp ] . hh . rh ;
  While p <> bestpagebreak Do
    Begin
      If mem [ p ] . hh . b0 = 3 Then
        Begin
          If eqtb [ 5316 ] . int <= 0 Then
            Begin
              r := mem [ 30000 ] . hh . rh ;
              While mem [ r ] . hh . b1 <> mem [ p ] . hh . b1 Do
                r := mem [ r ] . hh . rh ;
              If mem [ r + 2 ] . hh . lh = 0 Then wait := true
              Else
                Begin
                  wait := false ;
                  s := mem [ r + 2 ] . hh . rh ;
                  mem [ s ] . hh . rh := mem [ p + 4 ] . hh . lh ;
                  If mem [ r + 2 ] . hh . lh = p Then
                    Begin
                      If mem [ r ] . hh . b0 = 1 Then If ( mem [ r + 1 ] . hh . lh = p ) And ( mem [ r + 1 ] . hh . rh <> 0 ) Then
                                                        Begin
                                                          While mem [ s ] . hh . rh <> mem [ r + 1 ] . hh . rh Do
                                                            s := mem [ s ] . hh . rh ;
                                                          mem [ s ] . hh . rh := 0 ;
                                                          eqtb [ 2892 ] . hh . rh := mem [ p + 4 ] . hh . rh ;
                                                          mem [ p + 4 ] . hh . lh := prunepagetop ( mem [ r + 1 ] . hh . rh ) ;
                                                          If mem [ p + 4 ] . hh . lh <> 0 Then
                                                            Begin
                                                              tempptr := vpackage ( mem [ p + 4 ] . hh . lh , 0 , 1 , 1073741823 ) ;
                                                              mem [ p + 3 ] . int := mem [ tempptr + 3 ] . int + mem [ tempptr + 2 ] . int ;
                                                              freenode ( tempptr , 7 ) ;
                                                              wait := true ;
                                                            End ;
                                                        End ;
                      mem [ r + 2 ] . hh . lh := 0 ;
                      n := mem [ r ] . hh . b1 - 0 ;
                      tempptr := mem [ eqtb [ 3678 + n ] . hh . rh + 5 ] . hh . rh ;
                      freenode ( eqtb [ 3678 + n ] . hh . rh , 7 ) ;
                      eqtb [ 3678 + n ] . hh . rh := vpackage ( tempptr , 0 , 1 , 1073741823 ) ;
                    End
                  Else
                    Begin
                      While mem [ s ] . hh . rh <> 0 Do
                        s := mem [ s ] . hh . rh ;
                      mem [ r + 2 ] . hh . rh := s ;
                    End ;
                End ;
              mem [ prevp ] . hh . rh := mem [ p ] . hh . rh ;
              mem [ p ] . hh . rh := 0 ;
              If wait Then
                Begin
                  mem [ q ] . hh . rh := p ;
                  q := p ;
                  insertpenalties := insertpenalties + 1 ;
                End
              Else
                Begin
                  deleteglueref ( mem [ p + 4 ] . hh . rh ) ;
                  freenode ( p , 5 ) ;
                End ;
              p := prevp ;
            End ;
        End
      Else If mem [ p ] . hh . b0 = 4 Then
             Begin
               If curmark [ 1 ] = 0 Then
                 Begin
                   curmark [ 1 ] := mem [ p + 1 ] . int ;
                   mem [ curmark [ 1 ] ] . hh . lh := mem [ curmark [ 1 ] ] . hh . lh + 1 ;
                 End ;
               If curmark [ 2 ] <> 0 Then deletetokenref ( curmark [ 2 ] ) ;
               curmark [ 2 ] := mem [ p + 1 ] . int ;
               mem [ curmark [ 2 ] ] . hh . lh := mem [ curmark [ 2 ] ] . hh . lh + 1 ;
             End ;
      prevp := p ;
      p := mem [ prevp ] . hh . rh ;
    End ;
  eqtb [ 2892 ] . hh . rh := savesplittopskip ;
  If p <> 0 Then
    Begin
      If mem [ 29999 ] . hh . rh = 0 Then If nestptr = 0 Then curlist . tailfield := pagetail
      Else nest [ 0 ] . tailfield := pagetail ;
      mem [ pagetail ] . hh . rh := mem [ 29999 ] . hh . rh ;
      mem [ 29999 ] . hh . rh := p ;
      mem [ prevp ] . hh . rh := 0 ;
    End ;
  savevbadness := eqtb [ 5290 ] . int ;
  eqtb [ 5290 ] . int := 10000 ;
  savevfuzz := eqtb [ 5839 ] . int ;
  eqtb [ 5839 ] . int := 1073741823 ;
  eqtb [ 3933 ] . hh . rh := vpackage ( mem [ 29998 ] . hh . rh , bestsize , 0 , pagemaxdepth ) ;
  eqtb [ 5290 ] . int := savevbadness ;
  eqtb [ 5839 ] . int := savevfuzz ;
  If lastglue <> 65535 Then deleteglueref ( lastglue ) ;
  pagecontents := 0 ;
  pagetail := 29998 ;
  mem [ 29998 ] . hh . rh := 0 ;
  lastglue := 65535 ;
  lastpenalty := 0 ;
  lastkern := 0 ;
  pagesofar [ 7 ] := 0 ;
  pagemaxdepth := 0 ;
  If q <> 29996 Then
    Begin
      mem [ 29998 ] . hh . rh := mem [ 29996 ] . hh . rh ;
      pagetail := q ;
    End ;
  r := mem [ 30000 ] . hh . rh ;
  While r <> 30000 Do
    Begin
      q := mem [ r ] . hh . rh ;
      freenode ( r , 4 ) ;
      r := q ;
    End ;
  mem [ 30000 ] . hh . rh := 30000 ;
  If ( curmark [ 0 ] <> 0 ) And ( curmark [ 1 ] = 0 ) Then
    Begin
      curmark [ 1 ] := curmark [ 0 ] ;
      mem [ curmark [ 0 ] ] . hh . lh := mem [ curmark [ 0 ] ] . hh . lh + 1 ;
    End ;
  If eqtb [ 3413 ] . hh . rh <> 0 Then If deadcycles >= eqtb [ 5303 ] . int Then
                                         Begin
                                           Begin
                                             If interaction = 3 Then ;
                                             printnl ( 262 ) ;
                                             print ( 1004 ) ;
                                           End ;
                                           printint ( deadcycles ) ;
                                           print ( 1005 ) ;
                                           Begin
                                             helpptr := 3 ;
                                             helpline [ 2 ] := 1006 ;
                                             helpline [ 1 ] := 1007 ;
                                             helpline [ 0 ] := 1008 ;
                                           End ;
                                           error ;
                                         End
  Else
    Begin
      outputactive := true ;
      deadcycles := deadcycles + 1 ;
      pushnest ;
      curlist . modefield := - 1 ;
      curlist . auxfield . int := - 65536000 ;
      curlist . mlfield := - line ;
      begintokenlist ( eqtb [ 3413 ] . hh . rh , 6 ) ;
      newsavelevel ( 8 ) ;
      normalparagraph ;
      scanleftbrace ;
      goto 10 ;
    End ;
  Begin
    If mem [ 29998 ] . hh . rh <> 0 Then
      Begin
        If mem [ 29999 ] . hh . rh = 0 Then If nestptr = 0 Then curlist . tailfield := pagetail
        Else nest [ 0 ] . tailfield := pagetail
        Else mem [ pagetail ] . hh . rh := mem [ 29999 ] . hh . rh ;
        mem [ 29999 ] . hh . rh := mem [ 29998 ] . hh . rh ;
        mem [ 29998 ] . hh . rh := 0 ;
        pagetail := 29998 ;
      End ;
    shipout ( eqtb [ 3933 ] . hh . rh ) ;
    eqtb [ 3933 ] . hh . rh := 0 ;
  End ;
  10 :
End ;
Procedure buildpage ;

Label 10 , 30 , 31 , 22 , 80 , 90 ;

Var p : halfword ;
  q , r : halfword ;
  b , c : integer ;
  pi : integer ;
  n : 0 .. 255 ;
  delta , h , w : scaled ;
Begin
  If ( mem [ 29999 ] . hh . rh = 0 ) Or outputactive Then goto 10 ;
  Repeat
    22 : p := mem [ 29999 ] . hh . rh ;
    If lastglue <> 65535 Then deleteglueref ( lastglue ) ;
    lastpenalty := 0 ;
    lastkern := 0 ;
    If mem [ p ] . hh . b0 = 10 Then
      Begin
        lastglue := mem [ p + 1 ] . hh . lh ;
        mem [ lastglue ] . hh . rh := mem [ lastglue ] . hh . rh + 1 ;
      End
    Else
      Begin
        lastglue := 65535 ;
        If mem [ p ] . hh . b0 = 12 Then lastpenalty := mem [ p + 1 ] . int
        Else If mem [ p ] . hh . b0 = 11 Then lastkern := mem [ p + 1 ] . int ;
      End ;
    Case mem [ p ] . hh . b0 Of 
      0 , 1 , 2 : If pagecontents < 2 Then
                    Begin
                      If pagecontents = 0 Then freezepagespecs ( 2 )
                      Else pagecontents := 2 ;
                      q := newskipparam ( 9 ) ;
                      If mem [ tempptr + 1 ] . int > mem [ p + 3 ] . int Then mem [ tempptr + 1 ] . int := mem [ tempptr + 1 ] . int - mem [ p + 3 ] . int
                      Else mem [ tempptr + 1 ] . int := 0 ;
                      mem [ q ] . hh . rh := p ;
                      mem [ 29999 ] . hh . rh := q ;
                      goto 22 ;
                    End
                  Else
                    Begin
                      pagesofar [ 1 ] := pagesofar [ 1 ] + pagesofar [ 7 ] + mem [ p + 3 ] . int ;
                      pagesofar [ 7 ] := mem [ p + 2 ] . int ;
                      goto 80 ;
                    End ;
      8 : goto 80 ;
      10 : If pagecontents < 2 Then goto 31
           Else If ( mem [ pagetail ] . hh . b0 < 9 ) Then pi := 0
           Else goto 90 ;
      11 : If pagecontents < 2 Then goto 31
           Else If mem [ p ] . hh . rh = 0 Then goto 10
           Else If mem [ mem [ p ] . hh . rh ] . hh . b0 = 10 Then pi := 0
           Else goto 90 ;
      12 : If pagecontents < 2 Then goto 31
           Else pi := mem [ p + 1 ] . int ;
      4 : goto 80 ;
      3 :
          Begin
            If pagecontents = 0 Then freezepagespecs ( 1 ) ;
            n := mem [ p ] . hh . b1 ;
            r := 30000 ;
            While n >= mem [ mem [ r ] . hh . rh ] . hh . b1 Do
              r := mem [ r ] . hh . rh ;
            n := n - 0 ;
            If mem [ r ] . hh . b1 <> n + 0 Then
              Begin
                q := getnode ( 4 ) ;
                mem [ q ] . hh . rh := mem [ r ] . hh . rh ;
                mem [ r ] . hh . rh := q ;
                r := q ;
                mem [ r ] . hh . b1 := n + 0 ;
                mem [ r ] . hh . b0 := 0 ;
                ensurevbox ( n ) ;
                If eqtb [ 3678 + n ] . hh . rh = 0 Then mem [ r + 3 ] . int := 0
                Else mem [ r + 3 ] . int := mem [ eqtb [ 3678 + n ] . hh . rh + 3 ] . int + mem [ eqtb [ 3678 + n ] . hh . rh + 2 ] . int ;
                mem [ r + 2 ] . hh . lh := 0 ;
                q := eqtb [ 2900 + n ] . hh . rh ;
                If eqtb [ 5318 + n ] . int = 1000 Then h := mem [ r + 3 ] . int
                Else h := xovern ( mem [ r + 3 ] . int , 1000 ) * eqtb [ 5318 + n ] . int ;
                pagesofar [ 0 ] := pagesofar [ 0 ] - h - mem [ q + 1 ] . int ;
                pagesofar [ 2 + mem [ q ] . hh . b0 ] := pagesofar [ 2 + mem [ q ] . hh . b0 ] + mem [ q + 2 ] . int ;
                pagesofar [ 6 ] := pagesofar [ 6 ] + mem [ q + 3 ] . int ;
                If ( mem [ q ] . hh . b1 <> 0 ) And ( mem [ q + 3 ] . int <> 0 ) Then
                  Begin
                    Begin
                      If interaction = 3 Then ;
                      printnl ( 262 ) ;
                      print ( 997 ) ;
                    End ;
                    printesc ( 395 ) ;
                    printint ( n ) ;
                    Begin
                      helpptr := 3 ;
                      helpline [ 2 ] := 998 ;
                      helpline [ 1 ] := 999 ;
                      helpline [ 0 ] := 921 ;
                    End ;
                    error ;
                  End ;
              End ;
            If mem [ r ] . hh . b0 = 1 Then insertpenalties := insertpenalties + mem [ p + 1 ] . int
            Else
              Begin
                mem [ r + 2 ] . hh . rh := p ;
                delta := pagesofar [ 0 ] - pagesofar [ 1 ] - pagesofar [ 7 ] + pagesofar [ 6 ] ;
                If eqtb [ 5318 + n ] . int = 1000 Then h := mem [ p + 3 ] . int
                Else h := xovern ( mem [ p + 3 ] . int , 1000 ) * eqtb [ 5318 + n ] . int ;
                If ( ( h <= 0 ) Or ( h <= delta ) ) And ( mem [ p + 3 ] . int + mem [ r + 3 ] . int <= eqtb [ 5851 + n ] . int ) Then
                  Begin
                    pagesofar [ 0 ] := pagesofar [ 0 ] - h ;
                    mem [ r + 3 ] . int := mem [ r + 3 ] . int + mem [ p + 3 ] . int ;
                  End
                Else
                  Begin
                    If eqtb [ 5318 + n ] . int <= 0 Then w := 1073741823
                    Else
                      Begin
                        w := pagesofar [ 0 ] - pagesofar [ 1 ] - pagesofar [ 7 ] ;
                        If eqtb [ 5318 + n ] . int <> 1000 Then w := xovern ( w , eqtb [ 5318 + n ] . int ) * 1000 ;
                      End ;
                    If w > eqtb [ 5851 + n ] . int - mem [ r + 3 ] . int Then w := eqtb [ 5851 + n ] . int - mem [ r + 3 ] . int ;
                    q := vertbreak ( mem [ p + 4 ] . hh . lh , w , mem [ p + 2 ] . int ) ;
                    mem [ r + 3 ] . int := mem [ r + 3 ] . int + bestheightplusdepth ;
                    If eqtb [ 5318 + n ] . int <> 1000 Then bestheightplusdepth := xovern ( bestheightplusdepth , 1000 ) * eqtb [ 5318 + n ] . int ;
                    pagesofar [ 0 ] := pagesofar [ 0 ] - bestheightplusdepth ;
                    mem [ r ] . hh . b0 := 1 ;
                    mem [ r + 1 ] . hh . rh := q ;
                    mem [ r + 1 ] . hh . lh := p ;
                    If q = 0 Then insertpenalties := insertpenalties - 10000
                    Else If mem [ q ] . hh . b0 = 12 Then insertpenalties := insertpenalties + mem [ q + 1 ] . int ;
                  End ;
              End ;
            goto 80 ;
          End ;
      others : confusion ( 992 )
    End ;
    If pi < 10000 Then
      Begin
        If pagesofar [ 1 ] < pagesofar [ 0 ] Then If ( pagesofar [ 3 ] <> 0 ) Or ( pagesofar [ 4 ] <> 0 ) Or ( pagesofar [ 5 ] <> 0 ) Then b := 0
        Else b := badness ( pagesofar [ 0 ] - pagesofar [ 1 ] , pagesofar [ 2 ] )
        Else If pagesofar [ 1 ] - pagesofar [ 0 ] > pagesofar [ 6 ] Then b := 1073741823
        Else b := badness ( pagesofar [ 1 ] - pagesofar [ 0 ] , pagesofar [ 6 ] ) ;
        If b < 1073741823 Then If pi <= - 10000 Then c := pi
        Else If b < 10000 Then c := b + pi + insertpenalties
        Else c := 100000
        Else c := b ;
        If insertpenalties >= 10000 Then c := 1073741823 ;
        If c <= leastpagecost Then
          Begin
            bestpagebreak := p ;
            bestsize := pagesofar [ 0 ] ;
            leastpagecost := c ;
            r := mem [ 30000 ] . hh . rh ;
            While r <> 30000 Do
              Begin
                mem [ r + 2 ] . hh . lh := mem [ r + 2 ] . hh . rh ;
                r := mem [ r ] . hh . rh ;
              End ;
          End ;
        If ( c = 1073741823 ) Or ( pi <= - 10000 ) Then
          Begin
            fireup ( p ) ;
            If outputactive Then goto 10 ;
            goto 30 ;
          End ;
      End ;
    If ( mem [ p ] . hh . b0 < 10 ) Or ( mem [ p ] . hh . b0 > 11 ) Then goto 80 ;
    90 : If mem [ p ] . hh . b0 = 11 Then q := p
         Else
           Begin
             q := mem [ p + 1 ] . hh . lh ;
             pagesofar [ 2 + mem [ q ] . hh . b0 ] := pagesofar [ 2 + mem [ q ] . hh . b0 ] + mem [ q + 2 ] . int ;
             pagesofar [ 6 ] := pagesofar [ 6 ] + mem [ q + 3 ] . int ;
             If ( mem [ q ] . hh . b1 <> 0 ) And ( mem [ q + 3 ] . int <> 0 ) Then
               Begin
                 Begin
                   If interaction = 3 Then ;
                   printnl ( 262 ) ;
                   print ( 993 ) ;
                 End ;
                 Begin
                   helpptr := 4 ;
                   helpline [ 3 ] := 994 ;
                   helpline [ 2 ] := 962 ;
                   helpline [ 1 ] := 963 ;
                   helpline [ 0 ] := 921 ;
                 End ;
                 error ;
                 r := newspec ( q ) ;
                 mem [ r ] . hh . b1 := 0 ;
                 deleteglueref ( q ) ;
                 mem [ p + 1 ] . hh . lh := r ;
                 q := r ;
               End ;
           End ;
    pagesofar [ 1 ] := pagesofar [ 1 ] + pagesofar [ 7 ] + mem [ q + 1 ] . int ;
    pagesofar [ 7 ] := 0 ;
    80 : If pagesofar [ 7 ] > pagemaxdepth Then
           Begin
             pagesofar [ 1 ] := pagesofar [ 1 ] + pagesofar [ 7 ] - pagemaxdepth ;
             pagesofar [ 7 ] := pagemaxdepth ;
           End ; ;
    mem [ pagetail ] . hh . rh := p ;
    pagetail := p ;
    mem [ 29999 ] . hh . rh := mem [ p ] . hh . rh ;
    mem [ p ] . hh . rh := 0 ;
    goto 30 ;
    31 : mem [ 29999 ] . hh . rh := mem [ p ] . hh . rh ;
    mem [ p ] . hh . rh := 0 ;
    flushnodelist ( p ) ;
    30 : ;
  Until mem [ 29999 ] . hh . rh = 0 ;
  If nestptr = 0 Then curlist . tailfield := 29999
  Else nest [ 0 ] . tailfield := 29999 ;
  10 :
End ;
Procedure appspace ;

Var q : halfword ;
Begin
  If ( curlist . auxfield . hh . lh >= 2000 ) And ( eqtb [ 2895 ] . hh . rh <> 0 ) Then q := newparamglue ( 13 )
  Else
    Begin
      If eqtb [ 2894 ] . hh . rh <> 0 Then mainp := eqtb [ 2894 ] . hh . rh
      Else
        Begin
          mainp := fontglue [ eqtb [ 3934 ] . hh . rh ] ;
          If mainp = 0 Then
            Begin
              mainp := newspec ( 0 ) ;
              maink := parambase [ eqtb [ 3934 ] . hh . rh ] + 2 ;
              mem [ mainp + 1 ] . int := fontinfo [ maink ] . int ;
              mem [ mainp + 2 ] . int := fontinfo [ maink + 1 ] . int ;
              mem [ mainp + 3 ] . int := fontinfo [ maink + 2 ] . int ;
              fontglue [ eqtb [ 3934 ] . hh . rh ] := mainp ;
            End ;
        End ;
      mainp := newspec ( mainp ) ;
      If curlist . auxfield . hh . lh >= 2000 Then mem [ mainp + 1 ] . int := mem [ mainp + 1 ] . int + fontinfo [ 7 + parambase [ eqtb [ 3934 ] . hh . rh ] ] . int ;
      mem [ mainp + 2 ] . int := xnoverd ( mem [ mainp + 2 ] . int , curlist . auxfield . hh . lh , 1000 ) ;
      mem [ mainp + 3 ] . int := xnoverd ( mem [ mainp + 3 ] . int , 1000 , curlist . auxfield . hh . lh ) ;
      q := newglue ( mainp ) ;
      mem [ mainp ] . hh . rh := 0 ;
    End ;
  mem [ curlist . tailfield ] . hh . rh := q ;
  curlist . tailfield := q ;
End ;
Procedure insertdollarsign ;
Begin
  backinput ;
  curtok := 804 ;
  Begin
    If interaction = 3 Then ;
    printnl ( 262 ) ;
    print ( 1016 ) ;
  End ;
  Begin
    helpptr := 2 ;
    helpline [ 1 ] := 1017 ;
    helpline [ 0 ] := 1018 ;
  End ;
  inserror ;
End ;
Procedure youcant ;
Begin
  Begin
    If interaction = 3 Then ;
    printnl ( 262 ) ;
    print ( 685 ) ;
  End ;
  printcmdchr ( curcmd , curchr ) ;
  print ( 1019 ) ;
  printmode ( curlist . modefield ) ;
End ;
Procedure reportillegalcase ;
Begin
  youcant ;
  Begin
    helpptr := 4 ;
    helpline [ 3 ] := 1020 ;
    helpline [ 2 ] := 1021 ;
    helpline [ 1 ] := 1022 ;
    helpline [ 0 ] := 1023 ;
  End ;
  error ;
End ;
Function privileged : boolean ;
Begin
  If curlist . modefield > 0 Then privileged := true
  Else
    Begin
      reportillegalcase ;
      privileged := false ;
    End ;
End ;
Function itsallover : boolean ;

Label 10 ;
Begin
  If privileged Then
    Begin
      If ( 29998 = pagetail ) And ( curlist . headfield = curlist . tailfield ) And ( deadcycles = 0 ) Then
        Begin
          itsallover := true ;
          goto 10 ;
        End ;
      backinput ;
      Begin
        mem [ curlist . tailfield ] . hh . rh := newnullbox ;
        curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
      End ;
      mem [ curlist . tailfield + 1 ] . int := eqtb [ 5833 ] . int ;
      Begin
        mem [ curlist . tailfield ] . hh . rh := newglue ( 8 ) ;
        curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
      End ;
      Begin
        mem [ curlist . tailfield ] . hh . rh := newpenalty ( - 1073741824 ) ;
        curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
      End ;
      buildpage ;
    End ;
  itsallover := false ;
  10 :
End ;
Procedure appendglue ;

Var s : smallnumber ;
Begin
  s := curchr ;
  Case s Of 
    0 : curval := 4 ;
    1 : curval := 8 ;
    2 : curval := 12 ;
    3 : curval := 16 ;
    4 : scanglue ( 2 ) ;
    5 : scanglue ( 3 ) ;
  End ;
  Begin
    mem [ curlist . tailfield ] . hh . rh := newglue ( curval ) ;
    curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
  End ;
  If s >= 4 Then
    Begin
      mem [ curval ] . hh . rh := mem [ curval ] . hh . rh - 1 ;
      If s > 4 Then mem [ curlist . tailfield ] . hh . b1 := 99 ;
    End ;
End ;
Procedure appendkern ;

Var s : quarterword ;
Begin
  s := curchr ;
  scandimen ( s = 99 , false , false ) ;
  Begin
    mem [ curlist . tailfield ] . hh . rh := newkern ( curval ) ;
    curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
  End ;
  mem [ curlist . tailfield ] . hh . b1 := s ;
End ;
Procedure offsave ;

Var p : halfword ;
Begin
  If curgroup = 0 Then
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 776 ) ;
      End ;
      printcmdchr ( curcmd , curchr ) ;
      Begin
        helpptr := 1 ;
        helpline [ 0 ] := 1042 ;
      End ;
      error ;
    End
  Else
    Begin
      backinput ;
      p := getavail ;
      mem [ 29997 ] . hh . rh := p ;
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 625 ) ;
      End ;
      Case curgroup Of 
        14 :
             Begin
               mem [ p ] . hh . lh := 6711 ;
               printesc ( 516 ) ;
             End ;
        15 :
             Begin
               mem [ p ] . hh . lh := 804 ;
               printchar ( 36 ) ;
             End ;
        16 :
             Begin
               mem [ p ] . hh . lh := 6712 ;
               mem [ p ] . hh . rh := getavail ;
               p := mem [ p ] . hh . rh ;
               mem [ p ] . hh . lh := 3118 ;
               printesc ( 1041 ) ;
             End ;
        others :
                 Begin
                   mem [ p ] . hh . lh := 637 ;
                   printchar ( 125 ) ;
                 End
      End ;
      print ( 626 ) ;
      begintokenlist ( mem [ 29997 ] . hh . rh , 4 ) ;
      Begin
        helpptr := 5 ;
        helpline [ 4 ] := 1036 ;
        helpline [ 3 ] := 1037 ;
        helpline [ 2 ] := 1038 ;
        helpline [ 1 ] := 1039 ;
        helpline [ 0 ] := 1040 ;
      End ;
      error ;
    End ;
End ;
Procedure extrarightbrace ;
Begin
  Begin
    If interaction = 3 Then ;
    printnl ( 262 ) ;
    print ( 1047 ) ;
  End ;
  Case curgroup Of 
    14 : printesc ( 516 ) ;
    15 : printchar ( 36 ) ;
    16 : printesc ( 876 ) ;
  End ;
  Begin
    helpptr := 5 ;
    helpline [ 4 ] := 1048 ;
    helpline [ 3 ] := 1049 ;
    helpline [ 2 ] := 1050 ;
    helpline [ 1 ] := 1051 ;
    helpline [ 0 ] := 1052 ;
  End ;
  error ;
  alignstate := alignstate + 1 ;
End ;
Procedure normalparagraph ;
Begin
  If eqtb [ 5282 ] . int <> 0 Then eqworddefine ( 5282 , 0 ) ;
  If eqtb [ 5847 ] . int <> 0 Then eqworddefine ( 5847 , 0 ) ;
  If eqtb [ 5304 ] . int <> 1 Then eqworddefine ( 5304 , 1 ) ;
  If eqtb [ 3412 ] . hh . rh <> 0 Then eqdefine ( 3412 , 118 , 0 ) ;
End ;
Procedure boxend ( boxcontext : integer ) ;

Var p : halfword ;
Begin
  If boxcontext < 1073741824 Then
    Begin
      If curbox <> 0 Then
        Begin
          mem [ curbox + 4 ] . int := boxcontext ;
          If abs ( curlist . modefield ) = 1 Then
            Begin
              appendtovlist ( curbox ) ;
              If adjusttail <> 0 Then
                Begin
                  If 29995 <> adjusttail Then
                    Begin
                      mem [ curlist . tailfield ] . hh . rh := mem [ 29995 ] . hh . rh ;
                      curlist . tailfield := adjusttail ;
                    End ;
                  adjusttail := 0 ;
                End ;
              If curlist . modefield > 0 Then buildpage ;
            End
          Else
            Begin
              If abs ( curlist . modefield ) = 102 Then curlist . auxfield . hh . lh := 1000
              Else
                Begin
                  p := newnoad ;
                  mem [ p + 1 ] . hh . rh := 2 ;
                  mem [ p + 1 ] . hh . lh := curbox ;
                  curbox := p ;
                End ;
              mem [ curlist . tailfield ] . hh . rh := curbox ;
              curlist . tailfield := curbox ;
            End ;
        End ;
    End
  Else If boxcontext < 1073742336 Then If boxcontext < 1073742080 Then eqdefine ( - 1073738146 + boxcontext , 119 , curbox )
  Else geqdefine ( - 1073738402 + boxcontext , 119 , curbox )
  Else If curbox <> 0 Then If boxcontext > 1073742336 Then
                             Begin
                               Repeat
                                 getxtoken ;
                               Until ( curcmd <> 10 ) And ( curcmd <> 0 ) ;
                               If ( ( curcmd = 26 ) And ( abs ( curlist . modefield ) <> 1 ) ) Or ( ( curcmd = 27 ) And ( abs ( curlist . modefield ) = 1 ) ) Then
                                 Begin
                                   appendglue ;
                                   mem [ curlist . tailfield ] . hh . b1 := boxcontext - ( 1073742237 ) ;
                                   mem [ curlist . tailfield + 1 ] . hh . rh := curbox ;
                                 End
                               Else
                                 Begin
                                   Begin
                                     If interaction = 3 Then ;
                                     printnl ( 262 ) ;
                                     print ( 1065 ) ;
                                   End ;
                                   Begin
                                     helpptr := 3 ;
                                     helpline [ 2 ] := 1066 ;
                                     helpline [ 1 ] := 1067 ;
                                     helpline [ 0 ] := 1068 ;
                                   End ;
                                   backerror ;
                                   flushnodelist ( curbox ) ;
                                 End ;
                             End
  Else shipout ( curbox ) ;
End ;
Procedure beginbox ( boxcontext : integer ) ;

Label 10 , 30 ;

Var p , q : halfword ;
  m : quarterword ;
  k : halfword ;
  n : eightbits ;
Begin
  Case curchr Of 
    0 :
        Begin
          scaneightbitint ;
          curbox := eqtb [ 3678 + curval ] . hh . rh ;
          eqtb [ 3678 + curval ] . hh . rh := 0 ;
        End ;
    1 :
        Begin
          scaneightbitint ;
          curbox := copynodelist ( eqtb [ 3678 + curval ] . hh . rh ) ;
        End ;
    2 :
        Begin
          curbox := 0 ;
          If abs ( curlist . modefield ) = 203 Then
            Begin
              youcant ;
              Begin
                helpptr := 1 ;
                helpline [ 0 ] := 1069 ;
              End ;
              error ;
            End
          Else If ( curlist . modefield = 1 ) And ( curlist . headfield = curlist . tailfield ) Then
                 Begin
                   youcant ;
                   Begin
                     helpptr := 2 ;
                     helpline [ 1 ] := 1070 ;
                     helpline [ 0 ] := 1071 ;
                   End ;
                   error ;
                 End
          Else
            Begin
              If Not ( curlist . tailfield >= himemmin ) Then If ( mem [ curlist . tailfield ] . hh . b0 = 0 ) Or ( mem [ curlist . tailfield ] . hh . b0 = 1 ) Then
                                                                Begin
                                                                  q := curlist . headfield ;
                                                                  Repeat
                                                                    p := q ;
                                                                    If Not ( q >= himemmin ) Then If mem [ q ] . hh . b0 = 7 Then
                                                                                                    Begin
                                                                                                      For m := 1 To mem [ q ] . hh . b1 Do
                                                                                                        p := mem [ p ] . hh . rh ;
                                                                                                      If p = curlist . tailfield Then goto 30 ;
                                                                                                    End ;
                                                                    q := mem [ p ] . hh . rh ;
                                                                  Until q = curlist . tailfield ;
                                                                  curbox := curlist . tailfield ;
                                                                  mem [ curbox + 4 ] . int := 0 ;
                                                                  curlist . tailfield := p ;
                                                                  mem [ p ] . hh . rh := 0 ;
                                                                  30 :
                                                                End ;
            End ;
        End ;
    3 :
        Begin
          scaneightbitint ;
          n := curval ;
          If Not scankeyword ( 841 ) Then
            Begin
              Begin
                If interaction = 3 Then ;
                printnl ( 262 ) ;
                print ( 1072 ) ;
              End ;
              Begin
                helpptr := 2 ;
                helpline [ 1 ] := 1073 ;
                helpline [ 0 ] := 1074 ;
              End ;
              error ;
            End ;
          scandimen ( false , false , false ) ;
          curbox := vsplit ( n , curval ) ;
        End ;
    others :
             Begin
               k := curchr - 4 ;
               savestack [ saveptr + 0 ] . int := boxcontext ;
               If k = 102 Then If ( boxcontext < 1073741824 ) And ( abs ( curlist . modefield ) = 1 ) Then scanspec ( 3 , true )
               Else scanspec ( 2 , true )
               Else
                 Begin
                   If k = 1 Then scanspec ( 4 , true )
                   Else
                     Begin
                       scanspec ( 5 , true ) ;
                       k := 1 ;
                     End ;
                   normalparagraph ;
                 End ;
               pushnest ;
               curlist . modefield := - k ;
               If k = 1 Then
                 Begin
                   curlist . auxfield . int := - 65536000 ;
                   If eqtb [ 3418 ] . hh . rh <> 0 Then begintokenlist ( eqtb [ 3418 ] . hh . rh , 11 ) ;
                 End
               Else
                 Begin
                   curlist . auxfield . hh . lh := 1000 ;
                   If eqtb [ 3417 ] . hh . rh <> 0 Then begintokenlist ( eqtb [ 3417 ] . hh . rh , 10 ) ;
                 End ;
               goto 10 ;
             End
  End ;
  boxend ( boxcontext ) ;
  10 :
End ;
Procedure scanbox ( boxcontext : integer ) ;
Begin
  Repeat
    getxtoken ;
  Until ( curcmd <> 10 ) And ( curcmd <> 0 ) ;
  If curcmd = 20 Then beginbox ( boxcontext )
  Else If ( boxcontext >= 1073742337 ) And ( ( curcmd = 36 ) Or ( curcmd = 35 ) ) Then
         Begin
           curbox := scanrulespec ;
           boxend ( boxcontext ) ;
         End
  Else
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 1075 ) ;
      End ;
      Begin
        helpptr := 3 ;
        helpline [ 2 ] := 1076 ;
        helpline [ 1 ] := 1077 ;
        helpline [ 0 ] := 1078 ;
      End ;
      backerror ;
    End ;
End ;
Procedure package ( c : smallnumber ) ;

Var h : scaled ;
  p : halfword ;
  d : scaled ;
Begin
  d := eqtb [ 5837 ] . int ;
  unsave ;
  saveptr := saveptr - 3 ;
  If curlist . modefield = - 102 Then curbox := hpack ( mem [ curlist . headfield ] . hh . rh , savestack [ saveptr + 2 ] . int , savestack [ saveptr + 1 ] . int )
  Else
    Begin
      curbox := vpackage ( mem [ curlist . headfield ] . hh . rh , savestack [ saveptr + 2 ] . int , savestack [ saveptr + 1 ] . int , d ) ;
      If c = 4 Then
        Begin
          h := 0 ;
          p := mem [ curbox + 5 ] . hh . rh ;
          If p <> 0 Then If mem [ p ] . hh . b0 <= 2 Then h := mem [ p + 3 ] . int ;
          mem [ curbox + 2 ] . int := mem [ curbox + 2 ] . int - h + mem [ curbox + 3 ] . int ;
          mem [ curbox + 3 ] . int := h ;
        End ;
    End ;
  popnest ;
  boxend ( savestack [ saveptr + 0 ] . int ) ;
End ;
Function normmin ( h : integer ) : smallnumber ;
Begin
  If h <= 0 Then normmin := 1
  Else If h >= 63 Then normmin := 63
  Else normmin := h ;
End ;
Procedure newgraf ( indented : boolean ) ;
Begin
  curlist . pgfield := 0 ;
  If ( curlist . modefield = 1 ) Or ( curlist . headfield <> curlist . tailfield ) Then
    Begin
      mem [ curlist . tailfield ] . hh . rh := newparamglue ( 2 ) ;
      curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
    End ;
  pushnest ;
  curlist . modefield := 102 ;
  curlist . auxfield . hh . lh := 1000 ;
  If eqtb [ 5313 ] . int <= 0 Then curlang := 0
  Else If eqtb [ 5313 ] . int > 255 Then curlang := 0
  Else curlang := eqtb [ 5313 ] . int ;
  curlist . auxfield . hh . rh := curlang ;
  curlist . pgfield := ( normmin ( eqtb [ 5314 ] . int ) * 64 + normmin ( eqtb [ 5315 ] . int ) ) * 65536 + curlang ;
  If indented Then
    Begin
      curlist . tailfield := newnullbox ;
      mem [ curlist . headfield ] . hh . rh := curlist . tailfield ;
      mem [ curlist . tailfield + 1 ] . int := eqtb [ 5830 ] . int ;
    End ;
  If eqtb [ 3414 ] . hh . rh <> 0 Then begintokenlist ( eqtb [ 3414 ] . hh . rh , 7 ) ;
  If nestptr = 1 Then buildpage ;
End ;
Procedure indentinhmode ;

Var p , q : halfword ;
Begin
  If curchr > 0 Then
    Begin
      p := newnullbox ;
      mem [ p + 1 ] . int := eqtb [ 5830 ] . int ;
      If abs ( curlist . modefield ) = 102 Then curlist . auxfield . hh . lh := 1000
      Else
        Begin
          q := newnoad ;
          mem [ q + 1 ] . hh . rh := 2 ;
          mem [ q + 1 ] . hh . lh := p ;
          p := q ;
        End ;
      Begin
        mem [ curlist . tailfield ] . hh . rh := p ;
        curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
      End ;
    End ;
End ;
Procedure headforvmode ;
Begin
  If curlist . modefield < 0 Then If curcmd <> 36 Then offsave
  Else
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 685 ) ;
      End ;
      printesc ( 521 ) ;
      print ( 1081 ) ;
      Begin
        helpptr := 2 ;
        helpline [ 1 ] := 1082 ;
        helpline [ 0 ] := 1083 ;
      End ;
      error ;
    End
  Else
    Begin
      backinput ;
      curtok := partoken ;
      backinput ;
      curinput . indexfield := 4 ;
    End ;
End ;
Procedure endgraf ;
Begin
  If curlist . modefield = 102 Then
    Begin
      If curlist . headfield = curlist . tailfield Then popnest
      Else linebreak ( eqtb [ 5269 ] . int ) ;
      normalparagraph ;
      errorcount := 0 ;
    End ;
End ;
Procedure begininsertoradjust ;
Begin
  If curcmd = 38 Then curval := 255
  Else
    Begin
      scaneightbitint ;
      If curval = 255 Then
        Begin
          Begin
            If interaction = 3 Then ;
            printnl ( 262 ) ;
            print ( 1084 ) ;
          End ;
          printesc ( 330 ) ;
          printint ( 255 ) ;
          Begin
            helpptr := 1 ;
            helpline [ 0 ] := 1085 ;
          End ;
          error ;
          curval := 0 ;
        End ;
    End ;
  savestack [ saveptr + 0 ] . int := curval ;
  saveptr := saveptr + 1 ;
  newsavelevel ( 11 ) ;
  scanleftbrace ;
  normalparagraph ;
  pushnest ;
  curlist . modefield := - 1 ;
  curlist . auxfield . int := - 65536000 ;
End ;
Procedure makemark ;

Var p : halfword ;
Begin
  p := scantoks ( false , true ) ;
  p := getnode ( 2 ) ;
  mem [ p ] . hh . b0 := 4 ;
  mem [ p ] . hh . b1 := 0 ;
  mem [ p + 1 ] . int := defref ;
  mem [ curlist . tailfield ] . hh . rh := p ;
  curlist . tailfield := p ;
End ;
Procedure appendpenalty ;
Begin
  scanint ;
  Begin
    mem [ curlist . tailfield ] . hh . rh := newpenalty ( curval ) ;
    curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
  End ;
  If curlist . modefield = 1 Then buildpage ;
End ;
Procedure deletelast ;

Label 10 ;

Var p , q : halfword ;
  m : quarterword ;
Begin
  If ( curlist . modefield = 1 ) And ( curlist . tailfield = curlist . headfield ) Then
    Begin
      If ( curchr <> 10 ) Or ( lastglue <> 65535 ) Then
        Begin
          youcant ;
          Begin
            helpptr := 2 ;
            helpline [ 1 ] := 1070 ;
            helpline [ 0 ] := 1086 ;
          End ;
          If curchr = 11 Then helpline [ 0 ] := ( 1087 )
          Else If curchr <> 10 Then helpline [ 0 ] := ( 1088 ) ;
          error ;
        End ;
    End
  Else
    Begin
      If Not ( curlist . tailfield >= himemmin ) Then If mem [ curlist . tailfield ] . hh . b0 = curchr Then
                                                        Begin
                                                          q := curlist . headfield ;
                                                          Repeat
                                                            p := q ;
                                                            If Not ( q >= himemmin ) Then If mem [ q ] . hh . b0 = 7 Then
                                                                                            Begin
                                                                                              For m := 1 To mem [ q ] . hh . b1 Do
                                                                                                p := mem [ p ] . hh . rh ;
                                                                                              If p = curlist . tailfield Then goto 10 ;
                                                                                            End ;
                                                            q := mem [ p ] . hh . rh ;
                                                          Until q = curlist . tailfield ;
                                                          mem [ p ] . hh . rh := 0 ;
                                                          flushnodelist ( curlist . tailfield ) ;
                                                          curlist . tailfield := p ;
                                                        End ;
    End ;
  10 :
End ;
Procedure unpackage ;

Label 10 ;

Var p : halfword ;
  c : 0 .. 1 ;
Begin
  c := curchr ;
  scaneightbitint ;
  p := eqtb [ 3678 + curval ] . hh . rh ;
  If p = 0 Then goto 10 ;
  If ( abs ( curlist . modefield ) = 203 ) Or ( ( abs ( curlist . modefield ) = 1 ) And ( mem [ p ] . hh . b0 <> 1 ) ) Or ( ( abs ( curlist . modefield ) = 102 ) And ( mem [ p ] . hh . b0 <> 0 ) ) Then
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 1096 ) ;
      End ;
      Begin
        helpptr := 3 ;
        helpline [ 2 ] := 1097 ;
        helpline [ 1 ] := 1098 ;
        helpline [ 0 ] := 1099 ;
      End ;
      error ;
      goto 10 ;
    End ;
  If c = 1 Then mem [ curlist . tailfield ] . hh . rh := copynodelist ( mem [ p + 5 ] . hh . rh )
  Else
    Begin
      mem [ curlist . tailfield ] . hh . rh := mem [ p + 5 ] . hh . rh ;
      eqtb [ 3678 + curval ] . hh . rh := 0 ;
      freenode ( p , 7 ) ;
    End ;
  While mem [ curlist . tailfield ] . hh . rh <> 0 Do
    curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
  10 :
End ;
Procedure appenditaliccorrection ;

Label 10 ;

Var p : halfword ;
  f : internalfontnumber ;
Begin
  If curlist . tailfield <> curlist . headfield Then
    Begin
      If ( curlist . tailfield >= himemmin ) Then p := curlist . tailfield
      Else If mem [ curlist . tailfield ] . hh . b0 = 6 Then p := curlist . tailfield + 1
      Else goto 10 ;
      f := mem [ p ] . hh . b0 ;
      Begin
        mem [ curlist . tailfield ] . hh . rh := newkern ( fontinfo [ italicbase [ f ] + ( fontinfo [ charbase [ f ] + mem [ p ] . hh . b1 ] . qqqq . b2 - 0 ) Div 4 ] . int ) ;
        curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
      End ;
      mem [ curlist . tailfield ] . hh . b1 := 1 ;
    End ;
  10 :
End ;
Procedure appenddiscretionary ;

Var c : integer ;
Begin
  Begin
    mem [ curlist . tailfield ] . hh . rh := newdisc ;
    curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
  End ;
  If curchr = 1 Then
    Begin
      c := hyphenchar [ eqtb [ 3934 ] . hh . rh ] ;
      If c >= 0 Then If c < 256 Then mem [ curlist . tailfield + 1 ] . hh . lh := newcharacter ( eqtb [ 3934 ] . hh . rh , c ) ;
    End
  Else
    Begin
      saveptr := saveptr + 1 ;
      savestack [ saveptr - 1 ] . int := 0 ;
      newsavelevel ( 10 ) ;
      scanleftbrace ;
      pushnest ;
      curlist . modefield := - 102 ;
      curlist . auxfield . hh . lh := 1000 ;
    End ;
End ;
Procedure builddiscretionary ;

Label 30 , 10 ;

Var p , q : halfword ;
  n : integer ;
Begin
  unsave ;
  q := curlist . headfield ;
  p := mem [ q ] . hh . rh ;
  n := 0 ;
  While p <> 0 Do
    Begin
      If Not ( p >= himemmin ) Then If mem [ p ] . hh . b0 > 2 Then If mem [ p ] . hh . b0 <> 11 Then If mem [ p ] . hh . b0 <> 6 Then
                                                                                                        Begin
                                                                                                          Begin
                                                                                                            If interaction = 3 Then ;
                                                                                                            printnl ( 262 ) ;
                                                                                                            print ( 1106 ) ;
                                                                                                          End ;
                                                                                                          Begin
                                                                                                            helpptr := 1 ;
                                                                                                            helpline [ 0 ] := 1107 ;
                                                                                                          End ;
                                                                                                          error ;
                                                                                                          begindiagnostic ;
                                                                                                          printnl ( 1108 ) ;
                                                                                                          showbox ( p ) ;
                                                                                                          enddiagnostic ( true ) ;
                                                                                                          flushnodelist ( p ) ;
                                                                                                          mem [ q ] . hh . rh := 0 ;
                                                                                                          goto 30 ;
                                                                                                        End ;
      q := p ;
      p := mem [ q ] . hh . rh ;
      n := n + 1 ;
    End ;
  30 : ;
  p := mem [ curlist . headfield ] . hh . rh ;
  popnest ;
  Case savestack [ saveptr - 1 ] . int Of 
    0 : mem [ curlist . tailfield + 1 ] . hh . lh := p ;
    1 : mem [ curlist . tailfield + 1 ] . hh . rh := p ;
    2 :
        Begin
          If ( n > 0 ) And ( abs ( curlist . modefield ) = 203 ) Then
            Begin
              Begin
                If interaction = 3 Then ;
                printnl ( 262 ) ;
                print ( 1100 ) ;
              End ;
              printesc ( 349 ) ;
              Begin
                helpptr := 2 ;
                helpline [ 1 ] := 1101 ;
                helpline [ 0 ] := 1102 ;
              End ;
              flushnodelist ( p ) ;
              n := 0 ;
              error ;
            End
          Else mem [ curlist . tailfield ] . hh . rh := p ;
          If n <= 255 Then mem [ curlist . tailfield ] . hh . b1 := n
          Else
            Begin
              Begin
                If interaction = 3 Then ;
                printnl ( 262 ) ;
                print ( 1103 ) ;
              End ;
              Begin
                helpptr := 2 ;
                helpline [ 1 ] := 1104 ;
                helpline [ 0 ] := 1105 ;
              End ;
              error ;
            End ;
          If n > 0 Then curlist . tailfield := q ;
          saveptr := saveptr - 1 ;
          goto 10 ;
        End ;
  End ;
  savestack [ saveptr - 1 ] . int := savestack [ saveptr - 1 ] . int + 1 ;
  newsavelevel ( 10 ) ;
  scanleftbrace ;
  pushnest ;
  curlist . modefield := - 102 ;
  curlist . auxfield . hh . lh := 1000 ;
  10 :
End ;
Procedure makeaccent ;

Var s , t : real ;
  p , q , r : halfword ;
  f : internalfontnumber ;
  a , h , x , w , delta : scaled ;
  i : fourquarters ;
Begin
  scancharnum ;
  f := eqtb [ 3934 ] . hh . rh ;
  p := newcharacter ( f , curval ) ;
  If p <> 0 Then
    Begin
      x := fontinfo [ 5 + parambase [ f ] ] . int ;
      s := fontinfo [ 1 + parambase [ f ] ] . int / 65536.0 ;
      a := fontinfo [ widthbase [ f ] + fontinfo [ charbase [ f ] + mem [ p ] . hh . b1 ] . qqqq . b0 ] . int ;
      doassignments ;
      q := 0 ;
      f := eqtb [ 3934 ] . hh . rh ;
      If ( curcmd = 11 ) Or ( curcmd = 12 ) Or ( curcmd = 68 ) Then q := newcharacter ( f , curchr )
      Else If curcmd = 16 Then
             Begin
               scancharnum ;
               q := newcharacter ( f , curval ) ;
             End
      Else backinput ;
      If q <> 0 Then
        Begin
          t := fontinfo [ 1 + parambase [ f ] ] . int / 65536.0 ;
          i := fontinfo [ charbase [ f ] + mem [ q ] . hh . b1 ] . qqqq ;
          w := fontinfo [ widthbase [ f ] + i . b0 ] . int ;
          h := fontinfo [ heightbase [ f ] + ( i . b1 - 0 ) Div 16 ] . int ;
          If h <> x Then
            Begin
              p := hpack ( p , 0 , 1 ) ;
              mem [ p + 4 ] . int := x - h ;
            End ;
          delta := round ( ( w - a ) / 2.0 + h * t - x * s ) ;
          r := newkern ( delta ) ;
          mem [ r ] . hh . b1 := 2 ;
          mem [ curlist . tailfield ] . hh . rh := r ;
          mem [ r ] . hh . rh := p ;
          curlist . tailfield := newkern ( - a - delta ) ;
          mem [ curlist . tailfield ] . hh . b1 := 2 ;
          mem [ p ] . hh . rh := curlist . tailfield ;
          p := q ;
        End ;
      mem [ curlist . tailfield ] . hh . rh := p ;
      curlist . tailfield := p ;
      curlist . auxfield . hh . lh := 1000 ;
    End ;
End ;
Procedure alignerror ;
Begin
  If abs ( alignstate ) > 2 Then
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 1113 ) ;
      End ;
      printcmdchr ( curcmd , curchr ) ;
      If curtok = 1062 Then
        Begin
          Begin
            helpptr := 6 ;
            helpline [ 5 ] := 1114 ;
            helpline [ 4 ] := 1115 ;
            helpline [ 3 ] := 1116 ;
            helpline [ 2 ] := 1117 ;
            helpline [ 1 ] := 1118 ;
            helpline [ 0 ] := 1119 ;
          End ;
        End
      Else
        Begin
          Begin
            helpptr := 5 ;
            helpline [ 4 ] := 1114 ;
            helpline [ 3 ] := 1120 ;
            helpline [ 2 ] := 1117 ;
            helpline [ 1 ] := 1118 ;
            helpline [ 0 ] := 1119 ;
          End ;
        End ;
      error ;
    End
  Else
    Begin
      backinput ;
      If alignstate < 0 Then
        Begin
          Begin
            If interaction = 3 Then ;
            printnl ( 262 ) ;
            print ( 657 ) ;
          End ;
          alignstate := alignstate + 1 ;
          curtok := 379 ;
        End
      Else
        Begin
          Begin
            If interaction = 3 Then ;
            printnl ( 262 ) ;
            print ( 1109 ) ;
          End ;
          alignstate := alignstate - 1 ;
          curtok := 637 ;
        End ;
      Begin
        helpptr := 3 ;
        helpline [ 2 ] := 1110 ;
        helpline [ 1 ] := 1111 ;
        helpline [ 0 ] := 1112 ;
      End ;
      inserror ;
    End ;
End ;
Procedure noalignerror ;
Begin
  Begin
    If interaction = 3 Then ;
    printnl ( 262 ) ;
    print ( 1113 ) ;
  End ;
  printesc ( 527 ) ;
  Begin
    helpptr := 2 ;
    helpline [ 1 ] := 1121 ;
    helpline [ 0 ] := 1122 ;
  End ;
  error ;
End ;
Procedure omiterror ;
Begin
  Begin
    If interaction = 3 Then ;
    printnl ( 262 ) ;
    print ( 1113 ) ;
  End ;
  printesc ( 530 ) ;
  Begin
    helpptr := 2 ;
    helpline [ 1 ] := 1123 ;
    helpline [ 0 ] := 1122 ;
  End ;
  error ;
End ;
Procedure doendv ;
Begin
  baseptr := inputptr ;
  inputstack [ baseptr ] := curinput ;
  While ( inputstack [ baseptr ] . indexfield <> 2 ) And ( inputstack [ baseptr ] . locfield = 0 ) And ( inputstack [ baseptr ] . statefield = 0 ) Do
    baseptr := baseptr - 1 ;
  If ( inputstack [ baseptr ] . indexfield <> 2 ) Or ( inputstack [ baseptr ] . locfield <> 0 ) Or ( inputstack [ baseptr ] . statefield <> 0 ) Then fatalerror ( 595 ) ;
  If curgroup = 6 Then
    Begin
      endgraf ;
      If fincol Then finrow ;
    End
  Else offsave ;
End ;
Procedure cserror ;
Begin
  Begin
    If interaction = 3 Then ;
    printnl ( 262 ) ;
    print ( 776 ) ;
  End ;
  printesc ( 505 ) ;
  Begin
    helpptr := 1 ;
    helpline [ 0 ] := 1125 ;
  End ;
  error ;
End ;
Procedure pushmath ( c : groupcode ) ;
Begin
  pushnest ;
  curlist . modefield := - 203 ;
  curlist . auxfield . int := 0 ;
  newsavelevel ( c ) ;
End ;
Procedure initmath ;

Label 21 , 40 , 45 , 30 ;

Var w : scaled ;
  l : scaled ;
  s : scaled ;
  p : halfword ;
  q : halfword ;
  f : internalfontnumber ;
  n : integer ;
  v : scaled ;
  d : scaled ;
Begin
  gettoken ;
  If ( curcmd = 3 ) And ( curlist . modefield > 0 ) Then
    Begin
      If curlist . headfield = curlist . tailfield Then
        Begin
          popnest ;
          w := - 1073741823 ;
        End
      Else
        Begin
          linebreak ( eqtb [ 5270 ] . int ) ;
          v := mem [ justbox + 4 ] . int + 2 * fontinfo [ 6 + parambase [ eqtb [ 3934 ] . hh . rh ] ] . int ;
          w := - 1073741823 ;
          p := mem [ justbox + 5 ] . hh . rh ;
          While p <> 0 Do
            Begin
              21 : If ( p >= himemmin ) Then
                     Begin
                       f := mem [ p ] . hh . b0 ;
                       d := fontinfo [ widthbase [ f ] + fontinfo [ charbase [ f ] + mem [ p ] . hh . b1 ] . qqqq . b0 ] . int ;
                       goto 40 ;
                     End ;
              Case mem [ p ] . hh . b0 Of 
                0 , 1 , 2 :
                            Begin
                              d := mem [ p + 1 ] . int ;
                              goto 40 ;
                            End ;
                6 :
                    Begin
                      mem [ 29988 ] := mem [ p + 1 ] ;
                      mem [ 29988 ] . hh . rh := mem [ p ] . hh . rh ;
                      p := 29988 ;
                      goto 21 ;
                    End ;
                11 , 9 : d := mem [ p + 1 ] . int ;
                10 :
                     Begin
                       q := mem [ p + 1 ] . hh . lh ;
                       d := mem [ q + 1 ] . int ;
                       If mem [ justbox + 5 ] . hh . b0 = 1 Then
                         Begin
                           If ( mem [ justbox + 5 ] . hh . b1 = mem [ q ] . hh . b0 ) And ( mem [ q + 2 ] . int <> 0 ) Then v := 1073741823 ;
                         End
                       Else If mem [ justbox + 5 ] . hh . b0 = 2 Then
                              Begin
                                If ( mem [ justbox + 5 ] . hh . b1 = mem [ q ] . hh . b1 ) And ( mem [ q + 3 ] . int <> 0 ) Then v := 1073741823 ;
                              End ;
                       If mem [ p ] . hh . b1 >= 100 Then goto 40 ;
                     End ;
                8 : d := 0 ;
                others : d := 0
              End ;
              If v < 1073741823 Then v := v + d ;
              goto 45 ;
              40 : If v < 1073741823 Then
                     Begin
                       v := v + d ;
                       w := v ;
                     End
                   Else
                     Begin
                       w := 1073741823 ;
                       goto 30 ;
                     End ;
              45 : p := mem [ p ] . hh . rh ;
            End ;
          30 : ;
        End ;
      If eqtb [ 3412 ] . hh . rh = 0 Then If ( eqtb [ 5847 ] . int <> 0 ) And ( ( ( eqtb [ 5304 ] . int >= 0 ) And ( curlist . pgfield + 2 > eqtb [ 5304 ] . int ) ) Or ( curlist . pgfield + 1 < - eqtb [ 5304 ] . int ) ) Then
                                            Begin
                                              l := eqtb [ 5833 ] . int - abs ( eqtb [ 5847 ] . int ) ;
                                              If eqtb [ 5847 ] . int > 0 Then s := eqtb [ 5847 ] . int
                                              Else s := 0 ;
                                            End
      Else
        Begin
          l := eqtb [ 5833 ] . int ;
          s := 0 ;
        End
      Else
        Begin
          n := mem [ eqtb [ 3412 ] . hh . rh ] . hh . lh ;
          If curlist . pgfield + 2 >= n Then p := eqtb [ 3412 ] . hh . rh + 2 * n
          Else p := eqtb [ 3412 ] . hh . rh + 2 * ( curlist . pgfield + 2 ) ;
          s := mem [ p - 1 ] . int ;
          l := mem [ p ] . int ;
        End ;
      pushmath ( 15 ) ;
      curlist . modefield := 203 ;
      eqworddefine ( 5307 , - 1 ) ;
      eqworddefine ( 5843 , w ) ;
      eqworddefine ( 5844 , l ) ;
      eqworddefine ( 5845 , s ) ;
      If eqtb [ 3416 ] . hh . rh <> 0 Then begintokenlist ( eqtb [ 3416 ] . hh . rh , 9 ) ;
      If nestptr = 1 Then buildpage ;
    End
  Else
    Begin
      backinput ;
      Begin
        pushmath ( 15 ) ;
        eqworddefine ( 5307 , - 1 ) ;
        If eqtb [ 3415 ] . hh . rh <> 0 Then begintokenlist ( eqtb [ 3415 ] . hh . rh , 8 ) ;
      End ;
    End ;
End ;
Procedure starteqno ;
Begin
  savestack [ saveptr + 0 ] . int := curchr ;
  saveptr := saveptr + 1 ;
  Begin
    pushmath ( 15 ) ;
    eqworddefine ( 5307 , - 1 ) ;
    If eqtb [ 3415 ] . hh . rh <> 0 Then begintokenlist ( eqtb [ 3415 ] . hh . rh , 8 ) ;
  End ;
End ;
Procedure scanmath ( p : halfword ) ;

Label 20 , 21 , 10 ;

Var c : integer ;
Begin
  20 : Repeat
         getxtoken ;
       Until ( curcmd <> 10 ) And ( curcmd <> 0 ) ;
  21 : Case curcmd Of 
         11 , 12 , 68 :
                        Begin
                          c := eqtb [ 5007 + curchr ] . hh . rh - 0 ;
                          If c = 32768 Then
                            Begin
                              Begin
                                curcs := curchr + 1 ;
                                curcmd := eqtb [ curcs ] . hh . b0 ;
                                curchr := eqtb [ curcs ] . hh . rh ;
                                xtoken ;
                                backinput ;
                              End ;
                              goto 20 ;
                            End ;
                        End ;
         16 :
              Begin
                scancharnum ;
                curchr := curval ;
                curcmd := 68 ;
                goto 21 ;
              End ;
         17 :
              Begin
                scanfifteenbitint ;
                c := curval ;
              End ;
         69 : c := curchr ;
         15 :
              Begin
                scantwentysevenbitint ;
                c := curval Div 4096 ;
              End ;
         others :
                  Begin
                    backinput ;
                    scanleftbrace ;
                    savestack [ saveptr + 0 ] . int := p ;
                    saveptr := saveptr + 1 ;
                    pushmath ( 9 ) ;
                    goto 10 ;
                  End
       End ;
  mem [ p ] . hh . rh := 1 ;
  mem [ p ] . hh . b1 := c Mod 256 + 0 ;
  If ( c >= 28672 ) And ( ( eqtb [ 5307 ] . int >= 0 ) And ( eqtb [ 5307 ] . int < 16 ) ) Then mem [ p ] . hh . b0 := eqtb [ 5307 ] . int
  Else mem [ p ] . hh . b0 := ( c Div 256 ) Mod 16 ;
  10 :
End ;
Procedure setmathchar ( c : integer ) ;

Var p : halfword ;
Begin
  If c >= 32768 Then
    Begin
      curcs := curchr + 1 ;
      curcmd := eqtb [ curcs ] . hh . b0 ;
      curchr := eqtb [ curcs ] . hh . rh ;
      xtoken ;
      backinput ;
    End
  Else
    Begin
      p := newnoad ;
      mem [ p + 1 ] . hh . rh := 1 ;
      mem [ p + 1 ] . hh . b1 := c Mod 256 + 0 ;
      mem [ p + 1 ] . hh . b0 := ( c Div 256 ) Mod 16 ;
      If c >= 28672 Then
        Begin
          If ( ( eqtb [ 5307 ] . int >= 0 ) And ( eqtb [ 5307 ] . int < 16 ) ) Then mem [ p + 1 ] . hh . b0 := eqtb [ 5307 ] . int ;
          mem [ p ] . hh . b0 := 16 ;
        End
      Else mem [ p ] . hh . b0 := 16 + ( c Div 4096 ) ;
      mem [ curlist . tailfield ] . hh . rh := p ;
      curlist . tailfield := p ;
    End ;
End ;
Procedure mathlimitswitch ;

Label 10 ;
Begin
  If curlist . headfield <> curlist . tailfield Then If mem [ curlist . tailfield ] . hh . b0 = 17 Then
                                                       Begin
                                                         mem [ curlist . tailfield ] . hh . b1 := curchr ;
                                                         goto 10 ;
                                                       End ;
  Begin
    If interaction = 3 Then ;
    printnl ( 262 ) ;
    print ( 1129 ) ;
  End ;
  Begin
    helpptr := 1 ;
    helpline [ 0 ] := 1130 ;
  End ;
  error ;
  10 :
End ;
Procedure scandelimiter ( p : halfword ; r : boolean ) ;
Begin
  If r Then scantwentysevenbitint
  Else
    Begin
      Repeat
        getxtoken ;
      Until ( curcmd <> 10 ) And ( curcmd <> 0 ) ;
      Case curcmd Of 
        11 , 12 : curval := eqtb [ 5574 + curchr ] . int ;
        15 : scantwentysevenbitint ;
        others : curval := - 1
      End ;
    End ;
  If curval < 0 Then
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 1131 ) ;
      End ;
      Begin
        helpptr := 6 ;
        helpline [ 5 ] := 1132 ;
        helpline [ 4 ] := 1133 ;
        helpline [ 3 ] := 1134 ;
        helpline [ 2 ] := 1135 ;
        helpline [ 1 ] := 1136 ;
        helpline [ 0 ] := 1137 ;
      End ;
      backerror ;
      curval := 0 ;
    End ;
  mem [ p ] . qqqq . b0 := ( curval Div 1048576 ) Mod 16 ;
  mem [ p ] . qqqq . b1 := ( curval Div 4096 ) Mod 256 + 0 ;
  mem [ p ] . qqqq . b2 := ( curval Div 256 ) Mod 16 ;
  mem [ p ] . qqqq . b3 := curval Mod 256 + 0 ;
End ;
Procedure mathradical ;
Begin
  Begin
    mem [ curlist . tailfield ] . hh . rh := getnode ( 5 ) ;
    curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
  End ;
  mem [ curlist . tailfield ] . hh . b0 := 24 ;
  mem [ curlist . tailfield ] . hh . b1 := 0 ;
  mem [ curlist . tailfield + 1 ] . hh := emptyfield ;
  mem [ curlist . tailfield + 3 ] . hh := emptyfield ;
  mem [ curlist . tailfield + 2 ] . hh := emptyfield ;
  scandelimiter ( curlist . tailfield + 4 , true ) ;
  scanmath ( curlist . tailfield + 1 ) ;
End ;
Procedure mathac ;
Begin
  If curcmd = 45 Then
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 1138 ) ;
      End ;
      printesc ( 523 ) ;
      print ( 1139 ) ;
      Begin
        helpptr := 2 ;
        helpline [ 1 ] := 1140 ;
        helpline [ 0 ] := 1141 ;
      End ;
      error ;
    End ;
  Begin
    mem [ curlist . tailfield ] . hh . rh := getnode ( 5 ) ;
    curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
  End ;
  mem [ curlist . tailfield ] . hh . b0 := 28 ;
  mem [ curlist . tailfield ] . hh . b1 := 0 ;
  mem [ curlist . tailfield + 1 ] . hh := emptyfield ;
  mem [ curlist . tailfield + 3 ] . hh := emptyfield ;
  mem [ curlist . tailfield + 2 ] . hh := emptyfield ;
  mem [ curlist . tailfield + 4 ] . hh . rh := 1 ;
  scanfifteenbitint ;
  mem [ curlist . tailfield + 4 ] . hh . b1 := curval Mod 256 + 0 ;
  If ( curval >= 28672 ) And ( ( eqtb [ 5307 ] . int >= 0 ) And ( eqtb [ 5307 ] . int < 16 ) ) Then mem [ curlist . tailfield + 4 ] . hh . b0 := eqtb [ 5307 ] . int
  Else mem [ curlist . tailfield + 4 ] . hh . b0 := ( curval Div 256 ) Mod 16 ;
  scanmath ( curlist . tailfield + 1 ) ;
End ;
Procedure appendchoices ;
Begin
  Begin
    mem [ curlist . tailfield ] . hh . rh := newchoice ;
    curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
  End ;
  saveptr := saveptr + 1 ;
  savestack [ saveptr - 1 ] . int := 0 ;
  pushmath ( 13 ) ;
  scanleftbrace ;
End ;
Function finmlist ( p : halfword ) : halfword ;

Var q : halfword ;
Begin
  If curlist . auxfield . int <> 0 Then
    Begin
      mem [ curlist . auxfield . int + 3 ] . hh . rh := 3 ;
      mem [ curlist . auxfield . int + 3 ] . hh . lh := mem [ curlist . headfield ] . hh . rh ;
      If p = 0 Then q := curlist . auxfield . int
      Else
        Begin
          q := mem [ curlist . auxfield . int + 2 ] . hh . lh ;
          If mem [ q ] . hh . b0 <> 30 Then confusion ( 876 ) ;
          mem [ curlist . auxfield . int + 2 ] . hh . lh := mem [ q ] . hh . rh ;
          mem [ q ] . hh . rh := curlist . auxfield . int ;
          mem [ curlist . auxfield . int ] . hh . rh := p ;
        End ;
    End
  Else
    Begin
      mem [ curlist . tailfield ] . hh . rh := p ;
      q := mem [ curlist . headfield ] . hh . rh ;
    End ;
  popnest ;
  finmlist := q ;
End ;
Procedure buildchoices ;

Label 10 ;

Var p : halfword ;
Begin
  unsave ;
  p := finmlist ( 0 ) ;
  Case savestack [ saveptr - 1 ] . int Of 
    0 : mem [ curlist . tailfield + 1 ] . hh . lh := p ;
    1 : mem [ curlist . tailfield + 1 ] . hh . rh := p ;
    2 : mem [ curlist . tailfield + 2 ] . hh . lh := p ;
    3 :
        Begin
          mem [ curlist . tailfield + 2 ] . hh . rh := p ;
          saveptr := saveptr - 1 ;
          goto 10 ;
        End ;
  End ;
  savestack [ saveptr - 1 ] . int := savestack [ saveptr - 1 ] . int + 1 ;
  pushmath ( 13 ) ;
  scanleftbrace ;
  10 :
End ;
Procedure subsup ;

Var t : smallnumber ;
  p : halfword ;
Begin
  t := 0 ;
  p := 0 ;
  If curlist . tailfield <> curlist . headfield Then If ( mem [ curlist . tailfield ] . hh . b0 >= 16 ) And ( mem [ curlist . tailfield ] . hh . b0 < 30 ) Then
                                                       Begin
                                                         p := curlist . tailfield + 2 + curcmd - 7 ;
                                                         t := mem [ p ] . hh . rh ;
                                                       End ;
  If ( p = 0 ) Or ( t <> 0 ) Then
    Begin
      Begin
        mem [ curlist . tailfield ] . hh . rh := newnoad ;
        curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
      End ;
      p := curlist . tailfield + 2 + curcmd - 7 ;
      If t <> 0 Then
        Begin
          If curcmd = 7 Then
            Begin
              Begin
                If interaction = 3 Then ;
                printnl ( 262 ) ;
                print ( 1142 ) ;
              End ;
              Begin
                helpptr := 1 ;
                helpline [ 0 ] := 1143 ;
              End ;
            End
          Else
            Begin
              Begin
                If interaction = 3 Then ;
                printnl ( 262 ) ;
                print ( 1144 ) ;
              End ;
              Begin
                helpptr := 1 ;
                helpline [ 0 ] := 1145 ;
              End ;
            End ;
          error ;
        End ;
    End ;
  scanmath ( p ) ;
End ;
Procedure mathfraction ;

Var c : smallnumber ;
Begin
  c := curchr ;
  If curlist . auxfield . int <> 0 Then
    Begin
      If c >= 3 Then
        Begin
          scandelimiter ( 29988 , false ) ;
          scandelimiter ( 29988 , false ) ;
        End ;
      If c Mod 3 = 0 Then scandimen ( false , false , false ) ;
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 1152 ) ;
      End ;
      Begin
        helpptr := 3 ;
        helpline [ 2 ] := 1153 ;
        helpline [ 1 ] := 1154 ;
        helpline [ 0 ] := 1155 ;
      End ;
      error ;
    End
  Else
    Begin
      curlist . auxfield . int := getnode ( 6 ) ;
      mem [ curlist . auxfield . int ] . hh . b0 := 25 ;
      mem [ curlist . auxfield . int ] . hh . b1 := 0 ;
      mem [ curlist . auxfield . int + 2 ] . hh . rh := 3 ;
      mem [ curlist . auxfield . int + 2 ] . hh . lh := mem [ curlist . headfield ] . hh . rh ;
      mem [ curlist . auxfield . int + 3 ] . hh := emptyfield ;
      mem [ curlist . auxfield . int + 4 ] . qqqq := nulldelimiter ;
      mem [ curlist . auxfield . int + 5 ] . qqqq := nulldelimiter ;
      mem [ curlist . headfield ] . hh . rh := 0 ;
      curlist . tailfield := curlist . headfield ;
      If c >= 3 Then
        Begin
          scandelimiter ( curlist . auxfield . int + 4 , false ) ;
          scandelimiter ( curlist . auxfield . int + 5 , false ) ;
        End ;
      Case c Mod 3 Of 
        0 :
            Begin
              scandimen ( false , false , false ) ;
              mem [ curlist . auxfield . int + 1 ] . int := curval ;
            End ;
        1 : mem [ curlist . auxfield . int + 1 ] . int := 1073741824 ;
        2 : mem [ curlist . auxfield . int + 1 ] . int := 0 ;
      End ;
    End ;
End ;
Procedure mathleftright ;

Var t : smallnumber ;
  p : halfword ;
Begin
  t := curchr ;
  If ( t = 31 ) And ( curgroup <> 16 ) Then
    Begin
      If curgroup = 15 Then
        Begin
          scandelimiter ( 29988 , false ) ;
          Begin
            If interaction = 3 Then ;
            printnl ( 262 ) ;
            print ( 776 ) ;
          End ;
          printesc ( 876 ) ;
          Begin
            helpptr := 1 ;
            helpline [ 0 ] := 1156 ;
          End ;
          error ;
        End
      Else offsave ;
    End
  Else
    Begin
      p := newnoad ;
      mem [ p ] . hh . b0 := t ;
      scandelimiter ( p + 1 , false ) ;
      If t = 30 Then
        Begin
          pushmath ( 16 ) ;
          mem [ curlist . headfield ] . hh . rh := p ;
          curlist . tailfield := p ;
        End
      Else
        Begin
          p := finmlist ( p ) ;
          unsave ;
          Begin
            mem [ curlist . tailfield ] . hh . rh := newnoad ;
            curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
          End ;
          mem [ curlist . tailfield ] . hh . b0 := 23 ;
          mem [ curlist . tailfield + 1 ] . hh . rh := 3 ;
          mem [ curlist . tailfield + 1 ] . hh . lh := p ;
        End ;
    End ;
End ;
Procedure aftermath ;

Var l : boolean ;
  danger : boolean ;
  m : integer ;
  p : halfword ;
  a : halfword ;
  b : halfword ;
  w : scaled ;
  z : scaled ;
  e : scaled ;
  q : scaled ;
  d : scaled ;
  s : scaled ;
  g1 , g2 : smallnumber ;
  r : halfword ;
  t : halfword ;
Begin
  danger := false ;
  If ( fontparams [ eqtb [ 3937 ] . hh . rh ] < 22 ) Or ( fontparams [ eqtb [ 3953 ] . hh . rh ] < 22 ) Or ( fontparams [ eqtb [ 3969 ] . hh . rh ] < 22 ) Then
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 1157 ) ;
      End ;
      Begin
        helpptr := 3 ;
        helpline [ 2 ] := 1158 ;
        helpline [ 1 ] := 1159 ;
        helpline [ 0 ] := 1160 ;
      End ;
      error ;
      flushmath ;
      danger := true ;
    End
  Else If ( fontparams [ eqtb [ 3938 ] . hh . rh ] < 13 ) Or ( fontparams [ eqtb [ 3954 ] . hh . rh ] < 13 ) Or ( fontparams [ eqtb [ 3970 ] . hh . rh ] < 13 ) Then
         Begin
           Begin
             If interaction = 3 Then ;
             printnl ( 262 ) ;
             print ( 1161 ) ;
           End ;
           Begin
             helpptr := 3 ;
             helpline [ 2 ] := 1162 ;
             helpline [ 1 ] := 1163 ;
             helpline [ 0 ] := 1164 ;
           End ;
           error ;
           flushmath ;
           danger := true ;
         End ;
  m := curlist . modefield ;
  l := false ;
  p := finmlist ( 0 ) ;
  If curlist . modefield = - m Then
    Begin
      Begin
        getxtoken ;
        If curcmd <> 3 Then
          Begin
            Begin
              If interaction = 3 Then ;
              printnl ( 262 ) ;
              print ( 1165 ) ;
            End ;
            Begin
              helpptr := 2 ;
              helpline [ 1 ] := 1166 ;
              helpline [ 0 ] := 1167 ;
            End ;
            backerror ;
          End ;
      End ;
      curmlist := p ;
      curstyle := 2 ;
      mlistpenalties := false ;
      mlisttohlist ;
      a := hpack ( mem [ 29997 ] . hh . rh , 0 , 1 ) ;
      unsave ;
      saveptr := saveptr - 1 ;
      If savestack [ saveptr + 0 ] . int = 1 Then l := true ;
      danger := false ;
      If ( fontparams [ eqtb [ 3937 ] . hh . rh ] < 22 ) Or ( fontparams [ eqtb [ 3953 ] . hh . rh ] < 22 ) Or ( fontparams [ eqtb [ 3969 ] . hh . rh ] < 22 ) Then
        Begin
          Begin
            If interaction = 3 Then ;
            printnl ( 262 ) ;
            print ( 1157 ) ;
          End ;
          Begin
            helpptr := 3 ;
            helpline [ 2 ] := 1158 ;
            helpline [ 1 ] := 1159 ;
            helpline [ 0 ] := 1160 ;
          End ;
          error ;
          flushmath ;
          danger := true ;
        End
      Else If ( fontparams [ eqtb [ 3938 ] . hh . rh ] < 13 ) Or ( fontparams [ eqtb [ 3954 ] . hh . rh ] < 13 ) Or ( fontparams [ eqtb [ 3970 ] . hh . rh ] < 13 ) Then
             Begin
               Begin
                 If interaction = 3 Then ;
                 printnl ( 262 ) ;
                 print ( 1161 ) ;
               End ;
               Begin
                 helpptr := 3 ;
                 helpline [ 2 ] := 1162 ;
                 helpline [ 1 ] := 1163 ;
                 helpline [ 0 ] := 1164 ;
               End ;
               error ;
               flushmath ;
               danger := true ;
             End ;
      m := curlist . modefield ;
      p := finmlist ( 0 ) ;
    End
  Else a := 0 ;
  If m < 0 Then
    Begin
      Begin
        mem [ curlist . tailfield ] . hh . rh := newmath ( eqtb [ 5831 ] . int , 0 ) ;
        curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
      End ;
      curmlist := p ;
      curstyle := 2 ;
      mlistpenalties := ( curlist . modefield > 0 ) ;
      mlisttohlist ;
      mem [ curlist . tailfield ] . hh . rh := mem [ 29997 ] . hh . rh ;
      While mem [ curlist . tailfield ] . hh . rh <> 0 Do
        curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
      Begin
        mem [ curlist . tailfield ] . hh . rh := newmath ( eqtb [ 5831 ] . int , 1 ) ;
        curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
      End ;
      curlist . auxfield . hh . lh := 1000 ;
      unsave ;
    End
  Else
    Begin
      If a = 0 Then
        Begin
          getxtoken ;
          If curcmd <> 3 Then
            Begin
              Begin
                If interaction = 3 Then ;
                printnl ( 262 ) ;
                print ( 1165 ) ;
              End ;
              Begin
                helpptr := 2 ;
                helpline [ 1 ] := 1166 ;
                helpline [ 0 ] := 1167 ;
              End ;
              backerror ;
            End ;
        End ;
      curmlist := p ;
      curstyle := 0 ;
      mlistpenalties := false ;
      mlisttohlist ;
      p := mem [ 29997 ] . hh . rh ;
      adjusttail := 29995 ;
      b := hpack ( p , 0 , 1 ) ;
      p := mem [ b + 5 ] . hh . rh ;
      t := adjusttail ;
      adjusttail := 0 ;
      w := mem [ b + 1 ] . int ;
      z := eqtb [ 5844 ] . int ;
      s := eqtb [ 5845 ] . int ;
      If ( a = 0 ) Or danger Then
        Begin
          e := 0 ;
          q := 0 ;
        End
      Else
        Begin
          e := mem [ a + 1 ] . int ;
          q := e + fontinfo [ 6 + parambase [ eqtb [ 3937 ] . hh . rh ] ] . int ;
        End ;
      If w + q > z Then
        Begin
          If ( e <> 0 ) And ( ( w - totalshrink [ 0 ] + q <= z ) Or ( totalshrink [ 1 ] <> 0 ) Or ( totalshrink [ 2 ] <> 0 ) Or ( totalshrink [ 3 ] <> 0 ) ) Then
            Begin
              freenode ( b , 7 ) ;
              b := hpack ( p , z - q , 0 ) ;
            End
          Else
            Begin
              e := 0 ;
              If w > z Then
                Begin
                  freenode ( b , 7 ) ;
                  b := hpack ( p , z , 0 ) ;
                End ;
            End ;
          w := mem [ b + 1 ] . int ;
        End ;
      d := half ( z - w ) ;
      If ( e > 0 ) And ( d < 2 * e ) Then
        Begin
          d := half ( z - w - e ) ;
          If p <> 0 Then If Not ( p >= himemmin ) Then If mem [ p ] . hh . b0 = 10 Then d := 0 ;
        End ;
      Begin
        mem [ curlist . tailfield ] . hh . rh := newpenalty ( eqtb [ 5274 ] . int ) ;
        curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
      End ;
      If ( d + s <= eqtb [ 5843 ] . int ) Or l Then
        Begin
          g1 := 3 ;
          g2 := 4 ;
        End
      Else
        Begin
          g1 := 5 ;
          g2 := 6 ;
        End ;
      If l And ( e = 0 ) Then
        Begin
          mem [ a + 4 ] . int := s ;
          appendtovlist ( a ) ;
          Begin
            mem [ curlist . tailfield ] . hh . rh := newpenalty ( 10000 ) ;
            curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
          End ;
        End
      Else
        Begin
          mem [ curlist . tailfield ] . hh . rh := newparamglue ( g1 ) ;
          curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
        End ;
      If e <> 0 Then
        Begin
          r := newkern ( z - w - e - d ) ;
          If l Then
            Begin
              mem [ a ] . hh . rh := r ;
              mem [ r ] . hh . rh := b ;
              b := a ;
              d := 0 ;
            End
          Else
            Begin
              mem [ b ] . hh . rh := r ;
              mem [ r ] . hh . rh := a ;
            End ;
          b := hpack ( b , 0 , 1 ) ;
        End ;
      mem [ b + 4 ] . int := s + d ;
      appendtovlist ( b ) ;
      If ( a <> 0 ) And ( e = 0 ) And Not l Then
        Begin
          Begin
            mem [ curlist . tailfield ] . hh . rh := newpenalty ( 10000 ) ;
            curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
          End ;
          mem [ a + 4 ] . int := s + z - mem [ a + 1 ] . int ;
          appendtovlist ( a ) ;
          g2 := 0 ;
        End ;
      If t <> 29995 Then
        Begin
          mem [ curlist . tailfield ] . hh . rh := mem [ 29995 ] . hh . rh ;
          curlist . tailfield := t ;
        End ;
      Begin
        mem [ curlist . tailfield ] . hh . rh := newpenalty ( eqtb [ 5275 ] . int ) ;
        curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
      End ;
      If g2 > 0 Then
        Begin
          mem [ curlist . tailfield ] . hh . rh := newparamglue ( g2 ) ;
          curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
        End ;
      resumeafterdisplay ;
    End ;
End ;
Procedure resumeafterdisplay ;
Begin
  If curgroup <> 15 Then confusion ( 1168 ) ;
  unsave ;
  curlist . pgfield := curlist . pgfield + 3 ;
  pushnest ;
  curlist . modefield := 102 ;
  curlist . auxfield . hh . lh := 1000 ;
  If eqtb [ 5313 ] . int <= 0 Then curlang := 0
  Else If eqtb [ 5313 ] . int > 255 Then curlang := 0
  Else curlang := eqtb [ 5313 ] . int ;
  curlist . auxfield . hh . rh := curlang ;
  curlist . pgfield := ( normmin ( eqtb [ 5314 ] . int ) * 64 + normmin ( eqtb [ 5315 ] . int ) ) * 65536 + curlang ;
  Begin
    getxtoken ;
    If curcmd <> 10 Then backinput ;
  End ;
  If nestptr = 1 Then buildpage ;
End ;
Procedure getrtoken ;

Label 20 ;
Begin
  20 : Repeat
         gettoken ;
       Until curtok <> 2592 ;
  If ( curcs = 0 ) Or ( curcs > 2614 ) Then
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 1183 ) ;
      End ;
      Begin
        helpptr := 5 ;
        helpline [ 4 ] := 1184 ;
        helpline [ 3 ] := 1185 ;
        helpline [ 2 ] := 1186 ;
        helpline [ 1 ] := 1187 ;
        helpline [ 0 ] := 1188 ;
      End ;
      If curcs = 0 Then backinput ;
      curtok := 6709 ;
      inserror ;
      goto 20 ;
    End ;
End ;
Procedure trapzeroglue ;
Begin
  If ( mem [ curval + 1 ] . int = 0 ) And ( mem [ curval + 2 ] . int = 0 ) And ( mem [ curval + 3 ] . int = 0 ) Then
    Begin
      mem [ 0 ] . hh . rh := mem [ 0 ] . hh . rh + 1 ;
      deleteglueref ( curval ) ;
      curval := 0 ;
    End ;
End ;
Procedure doregistercommand ( a : smallnumber ) ;

Label 40 , 10 ;

Var l , q , r , s : halfword ;
  p : 0 .. 3 ;
Begin
  q := curcmd ;
  Begin
    If q <> 89 Then
      Begin
        getxtoken ;
        If ( curcmd >= 73 ) And ( curcmd <= 76 ) Then
          Begin
            l := curchr ;
            p := curcmd - 73 ;
            goto 40 ;
          End ;
        If curcmd <> 89 Then
          Begin
            Begin
              If interaction = 3 Then ;
              printnl ( 262 ) ;
              print ( 685 ) ;
            End ;
            printcmdchr ( curcmd , curchr ) ;
            print ( 686 ) ;
            printcmdchr ( q , 0 ) ;
            Begin
              helpptr := 1 ;
              helpline [ 0 ] := 1209 ;
            End ;
            error ;
            goto 10 ;
          End ;
      End ;
    p := curchr ;
    scaneightbitint ;
    Case p Of 
      0 : l := curval + 5318 ;
      1 : l := curval + 5851 ;
      2 : l := curval + 2900 ;
      3 : l := curval + 3156 ;
    End ;
  End ;
  40 : ;
  If q = 89 Then scanoptionalequals
  Else If scankeyword ( 1205 ) Then ;
  aritherror := false ;
  If q < 91 Then If p < 2 Then
                   Begin
                     If p = 0 Then scanint
                     Else scandimen ( false , false , false ) ;
                     If q = 90 Then curval := curval + eqtb [ l ] . int ;
                   End
  Else
    Begin
      scanglue ( p ) ;
      If q = 90 Then
        Begin
          q := newspec ( curval ) ;
          r := eqtb [ l ] . hh . rh ;
          deleteglueref ( curval ) ;
          mem [ q + 1 ] . int := mem [ q + 1 ] . int + mem [ r + 1 ] . int ;
          If mem [ q + 2 ] . int = 0 Then mem [ q ] . hh . b0 := 0 ;
          If mem [ q ] . hh . b0 = mem [ r ] . hh . b0 Then mem [ q + 2 ] . int := mem [ q + 2 ] . int + mem [ r + 2 ] . int
          Else If ( mem [ q ] . hh . b0 < mem [ r ] . hh . b0 ) And ( mem [ r + 2 ] . int <> 0 ) Then
                 Begin
                   mem [ q + 2 ] . int := mem [ r + 2 ] . int ;
                   mem [ q ] . hh . b0 := mem [ r ] . hh . b0 ;
                 End ;
          If mem [ q + 3 ] . int = 0 Then mem [ q ] . hh . b1 := 0 ;
          If mem [ q ] . hh . b1 = mem [ r ] . hh . b1 Then mem [ q + 3 ] . int := mem [ q + 3 ] . int + mem [ r + 3 ] . int
          Else If ( mem [ q ] . hh . b1 < mem [ r ] . hh . b1 ) And ( mem [ r + 3 ] . int <> 0 ) Then
                 Begin
                   mem [ q + 3 ] . int := mem [ r + 3 ] . int ;
                   mem [ q ] . hh . b1 := mem [ r ] . hh . b1 ;
                 End ;
          curval := q ;
        End ;
    End
  Else
    Begin
      scanint ;
      If p < 2 Then If q = 91 Then If p = 0 Then curval := multandadd ( eqtb [ l ] . int , curval , 0 , 2147483647 )
      Else curval := multandadd ( eqtb [ l ] . int , curval , 0 , 1073741823 )
      Else curval := xovern ( eqtb [ l ] . int , curval )
      Else
        Begin
          s := eqtb [ l ] . hh . rh ;
          r := newspec ( s ) ;
          If q = 91 Then
            Begin
              mem [ r + 1 ] . int := multandadd ( mem [ s + 1 ] . int , curval , 0 , 1073741823 ) ;
              mem [ r + 2 ] . int := multandadd ( mem [ s + 2 ] . int , curval , 0 , 1073741823 ) ;
              mem [ r + 3 ] . int := multandadd ( mem [ s + 3 ] . int , curval , 0 , 1073741823 ) ;
            End
          Else
            Begin
              mem [ r + 1 ] . int := xovern ( mem [ s + 1 ] . int , curval ) ;
              mem [ r + 2 ] . int := xovern ( mem [ s + 2 ] . int , curval ) ;
              mem [ r + 3 ] . int := xovern ( mem [ s + 3 ] . int , curval ) ;
            End ;
          curval := r ;
        End ;
    End ;
  If aritherror Then
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 1206 ) ;
      End ;
      Begin
        helpptr := 2 ;
        helpline [ 1 ] := 1207 ;
        helpline [ 0 ] := 1208 ;
      End ;
      If p >= 2 Then deleteglueref ( curval ) ;
      error ;
      goto 10 ;
    End ;
  If p < 2 Then If ( a >= 4 ) Then geqworddefine ( l , curval )
  Else eqworddefine ( l , curval )
  Else
    Begin
      trapzeroglue ;
      If ( a >= 4 ) Then geqdefine ( l , 117 , curval )
      Else eqdefine ( l , 117 , curval ) ;
    End ;
  10 :
End ;
Procedure alteraux ;

Var c : halfword ;
Begin
  If curchr <> abs ( curlist . modefield ) Then reportillegalcase
  Else
    Begin
      c := curchr ;
      scanoptionalequals ;
      If c = 1 Then
        Begin
          scandimen ( false , false , false ) ;
          curlist . auxfield . int := curval ;
        End
      Else
        Begin
          scanint ;
          If ( curval <= 0 ) Or ( curval > 32767 ) Then
            Begin
              Begin
                If interaction = 3 Then ;
                printnl ( 262 ) ;
                print ( 1212 ) ;
              End ;
              Begin
                helpptr := 1 ;
                helpline [ 0 ] := 1213 ;
              End ;
              interror ( curval ) ;
            End
          Else curlist . auxfield . hh . lh := curval ;
        End ;
    End ;
End ;
Procedure alterprevgraf ;

Var p : 0 .. nestsize ;
Begin
  nest [ nestptr ] := curlist ;
  p := nestptr ;
  While abs ( nest [ p ] . modefield ) <> 1 Do
    p := p - 1 ;
  scanoptionalequals ;
  scanint ;
  If curval < 0 Then
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 954 ) ;
      End ;
      printesc ( 532 ) ;
      Begin
        helpptr := 1 ;
        helpline [ 0 ] := 1214 ;
      End ;
      interror ( curval ) ;
    End
  Else
    Begin
      nest [ p ] . pgfield := curval ;
      curlist := nest [ nestptr ] ;
    End ;
End ;
Procedure alterpagesofar ;

Var c : 0 .. 7 ;
Begin
  c := curchr ;
  scanoptionalequals ;
  scandimen ( false , false , false ) ;
  pagesofar [ c ] := curval ;
End ;
Procedure alterinteger ;

Var c : 0 .. 1 ;
Begin
  c := curchr ;
  scanoptionalequals ;
  scanint ;
  If c = 0 Then deadcycles := curval
  Else insertpenalties := curval ;
End ;
Procedure alterboxdimen ;

Var c : smallnumber ;
  b : eightbits ;
Begin
  c := curchr ;
  scaneightbitint ;
  b := curval ;
  scanoptionalequals ;
  scandimen ( false , false , false ) ;
  If eqtb [ 3678 + b ] . hh . rh <> 0 Then mem [ eqtb [ 3678 + b ] . hh . rh + c ] . int := curval ;
End ;
Procedure newfont ( a : smallnumber ) ;

Label 50 ;

Var u : halfword ;
  s : scaled ;
  f : internalfontnumber ;
  t : strnumber ;
  oldsetting : 0 .. 21 ;
  flushablestring : strnumber ;
Begin
  If jobname = 0 Then openlogfile ;
  getrtoken ;
  u := curcs ;
  If u >= 514 Then t := hash [ u ] . rh
  Else If u >= 257 Then If u = 513 Then t := 1218
  Else t := u - 257
  Else
    Begin
      oldsetting := selector ;
      selector := 21 ;
      print ( 1218 ) ;
      print ( u - 1 ) ;
      selector := oldsetting ;
      Begin
        If poolptr + 1 > poolsize Then overflow ( 257 , poolsize - initpoolptr ) ;
      End ;
      t := makestring ;
    End ;
  If ( a >= 4 ) Then geqdefine ( u , 87 , 0 )
  Else eqdefine ( u , 87 , 0 ) ;
  scanoptionalequals ;
  scanfilename ;
  nameinprogress := true ;
  If scankeyword ( 1219 ) Then
    Begin
      scandimen ( false , false , false ) ;
      s := curval ;
      If ( s <= 0 ) Or ( s >= 134217728 ) Then
        Begin
          Begin
            If interaction = 3 Then ;
            printnl ( 262 ) ;
            print ( 1221 ) ;
          End ;
          printscaled ( s ) ;
          print ( 1222 ) ;
          Begin
            helpptr := 2 ;
            helpline [ 1 ] := 1223 ;
            helpline [ 0 ] := 1224 ;
          End ;
          error ;
          s := 10 * 65536 ;
        End ;
    End
  Else If scankeyword ( 1220 ) Then
         Begin
           scanint ;
           s := - curval ;
           If ( curval <= 0 ) Or ( curval > 32768 ) Then
             Begin
               Begin
                 If interaction = 3 Then ;
                 printnl ( 262 ) ;
                 print ( 552 ) ;
               End ;
               Begin
                 helpptr := 1 ;
                 helpline [ 0 ] := 553 ;
               End ;
               interror ( curval ) ;
               s := - 1000 ;
             End ;
         End
  Else s := - 1000 ;
  nameinprogress := false ;
  flushablestring := strptr - 1 ;
  For f := 1 To fontptr Do
    If streqstr ( fontname [ f ] , curname ) And streqstr ( fontarea [ f ] , curarea ) Then
      Begin
        If curname = flushablestring Then
          Begin
            Begin
              strptr := strptr - 1 ;
              poolptr := strstart [ strptr ] ;
            End ;
            curname := fontname [ f ] ;
          End ;
        If s > 0 Then
          Begin
            If s = fontsize [ f ] Then goto 50 ;
          End
        Else If fontsize [ f ] = xnoverd ( fontdsize [ f ] , - s , 1000 ) Then goto 50 ;
      End ;
  f := readfontinfo ( u , curname , curarea , s ) ;
  50 : eqtb [ u ] . hh . rh := f ;
  eqtb [ 2624 + f ] := eqtb [ u ] ;
  hash [ 2624 + f ] . rh := t ;
End ;
Procedure newinteraction ;
Begin
  println ;
  interaction := curchr ;
  If interaction = 0 Then selector := 16
  Else selector := 17 ;
  If logopened Then selector := selector + 2 ;
End ;
Procedure prefixedcommand ;

Label 30 , 10 ;

Var a : smallnumber ;
  f : internalfontnumber ;
  j : halfword ;
  k : fontindex ;
  p , q : halfword ;
  n : integer ;
  e : boolean ;
Begin
  a := 0 ;
  While curcmd = 93 Do
    Begin
      If Not odd ( a Div curchr ) Then a := a + curchr ;
      Repeat
        getxtoken ;
      Until ( curcmd <> 10 ) And ( curcmd <> 0 ) ;
      If curcmd <= 70 Then
        Begin
          Begin
            If interaction = 3 Then ;
            printnl ( 262 ) ;
            print ( 1178 ) ;
          End ;
          printcmdchr ( curcmd , curchr ) ;
          printchar ( 39 ) ;
          Begin
            helpptr := 1 ;
            helpline [ 0 ] := 1179 ;
          End ;
          backerror ;
          goto 10 ;
        End ;
    End ;
  If ( curcmd <> 97 ) And ( a Mod 4 <> 0 ) Then
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 685 ) ;
      End ;
      printesc ( 1170 ) ;
      print ( 1180 ) ;
      printesc ( 1171 ) ;
      print ( 1181 ) ;
      printcmdchr ( curcmd , curchr ) ;
      printchar ( 39 ) ;
      Begin
        helpptr := 1 ;
        helpline [ 0 ] := 1182 ;
      End ;
      error ;
    End ;
  If eqtb [ 5306 ] . int <> 0 Then If eqtb [ 5306 ] . int < 0 Then
                                     Begin
                                       If ( a >= 4 ) Then a := a - 4 ;
                                     End
  Else
    Begin
      If Not ( a >= 4 ) Then a := a + 4 ;
    End ;
  Case curcmd Of 
    87 : If ( a >= 4 ) Then geqdefine ( 3934 , 120 , curchr )
         Else eqdefine ( 3934 , 120 , curchr ) ;
    97 :
         Begin
           If odd ( curchr ) And Not ( a >= 4 ) And ( eqtb [ 5306 ] . int >= 0 ) Then a := a + 4 ;
           e := ( curchr >= 2 ) ;
           getrtoken ;
           p := curcs ;
           q := scantoks ( true , e ) ;
           If ( a >= 4 ) Then geqdefine ( p , 111 + ( a Mod 4 ) , defref )
           Else eqdefine ( p , 111 + ( a Mod 4 ) , defref ) ;
         End ;
    94 :
         Begin
           n := curchr ;
           getrtoken ;
           p := curcs ;
           If n = 0 Then
             Begin
               Repeat
                 gettoken ;
               Until curcmd <> 10 ;
               If curtok = 3133 Then
                 Begin
                   gettoken ;
                   If curcmd = 10 Then gettoken ;
                 End ;
             End
           Else
             Begin
               gettoken ;
               q := curtok ;
               gettoken ;
               backinput ;
               curtok := q ;
               backinput ;
             End ;
           If curcmd >= 111 Then mem [ curchr ] . hh . lh := mem [ curchr ] . hh . lh + 1 ;
           If ( a >= 4 ) Then geqdefine ( p , curcmd , curchr )
           Else eqdefine ( p , curcmd , curchr ) ;
         End ;
    95 :
         Begin
           n := curchr ;
           getrtoken ;
           p := curcs ;
           If ( a >= 4 ) Then geqdefine ( p , 0 , 256 )
           Else eqdefine ( p , 0 , 256 ) ;
           scanoptionalequals ;
           Case n Of 
             0 :
                 Begin
                   scancharnum ;
                   If ( a >= 4 ) Then geqdefine ( p , 68 , curval )
                   Else eqdefine ( p , 68 , curval ) ;
                 End ;
             1 :
                 Begin
                   scanfifteenbitint ;
                   If ( a >= 4 ) Then geqdefine ( p , 69 , curval )
                   Else eqdefine ( p , 69 , curval ) ;
                 End ;
             others :
                      Begin
                        scaneightbitint ;
                        Case n Of 
                          2 : If ( a >= 4 ) Then geqdefine ( p , 73 , 5318 + curval )
                              Else eqdefine ( p , 73 , 5318 + curval ) ;
                          3 : If ( a >= 4 ) Then geqdefine ( p , 74 , 5851 + curval )
                              Else eqdefine ( p , 74 , 5851 + curval ) ;
                          4 : If ( a >= 4 ) Then geqdefine ( p , 75 , 2900 + curval )
                              Else eqdefine ( p , 75 , 2900 + curval ) ;
                          5 : If ( a >= 4 ) Then geqdefine ( p , 76 , 3156 + curval )
                              Else eqdefine ( p , 76 , 3156 + curval ) ;
                          6 : If ( a >= 4 ) Then geqdefine ( p , 72 , 3422 + curval )
                              Else eqdefine ( p , 72 , 3422 + curval ) ;
                        End ;
                      End
           End ;
         End ;
    96 :
         Begin
           scanint ;
           n := curval ;
           If Not scankeyword ( 841 ) Then
             Begin
               Begin
                 If interaction = 3 Then ;
                 printnl ( 262 ) ;
                 print ( 1072 ) ;
               End ;
               Begin
                 helpptr := 2 ;
                 helpline [ 1 ] := 1199 ;
                 helpline [ 0 ] := 1200 ;
               End ;
               error ;
             End ;
           getrtoken ;
           p := curcs ;
           readtoks ( n , p ) ;
           If ( a >= 4 ) Then geqdefine ( p , 111 , curval )
           Else eqdefine ( p , 111 , curval ) ;
         End ;
    71 , 72 :
              Begin
                q := curcs ;
                If curcmd = 71 Then
                  Begin
                    scaneightbitint ;
                    p := 3422 + curval ;
                  End
                Else p := curchr ;
                scanoptionalequals ;
                Repeat
                  getxtoken ;
                Until ( curcmd <> 10 ) And ( curcmd <> 0 ) ;
                If curcmd <> 1 Then
                  Begin
                    If curcmd = 71 Then
                      Begin
                        scaneightbitint ;
                        curcmd := 72 ;
                        curchr := 3422 + curval ;
                      End ;
                    If curcmd = 72 Then
                      Begin
                        q := eqtb [ curchr ] . hh . rh ;
                        If q = 0 Then If ( a >= 4 ) Then geqdefine ( p , 101 , 0 )
                        Else eqdefine ( p , 101 , 0 )
                        Else
                          Begin
                            mem [ q ] . hh . lh := mem [ q ] . hh . lh + 1 ;
                            If ( a >= 4 ) Then geqdefine ( p , 111 , q )
                            Else eqdefine ( p , 111 , q ) ;
                          End ;
                        goto 30 ;
                      End ;
                  End ;
                backinput ;
                curcs := q ;
                q := scantoks ( false , false ) ;
                If mem [ defref ] . hh . rh = 0 Then
                  Begin
                    If ( a >= 4 ) Then geqdefine ( p , 101 , 0 )
                    Else eqdefine ( p , 101 , 0 ) ;
                    Begin
                      mem [ defref ] . hh . rh := avail ;
                      avail := defref ;
                    End ;
                  End
                Else
                  Begin
                    If p = 3413 Then
                      Begin
                        mem [ q ] . hh . rh := getavail ;
                        q := mem [ q ] . hh . rh ;
                        mem [ q ] . hh . lh := 637 ;
                        q := getavail ;
                        mem [ q ] . hh . lh := 379 ;
                        mem [ q ] . hh . rh := mem [ defref ] . hh . rh ;
                        mem [ defref ] . hh . rh := q ;
                      End ;
                    If ( a >= 4 ) Then geqdefine ( p , 111 , defref )
                    Else eqdefine ( p , 111 , defref ) ;
                  End ;
              End ;
    73 :
         Begin
           p := curchr ;
           scanoptionalequals ;
           scanint ;
           If ( a >= 4 ) Then geqworddefine ( p , curval )
           Else eqworddefine ( p , curval ) ;
         End ;
    74 :
         Begin
           p := curchr ;
           scanoptionalequals ;
           scandimen ( false , false , false ) ;
           If ( a >= 4 ) Then geqworddefine ( p , curval )
           Else eqworddefine ( p , curval ) ;
         End ;
    75 , 76 :
              Begin
                p := curchr ;
                n := curcmd ;
                scanoptionalequals ;
                If n = 76 Then scanglue ( 3 )
                Else scanglue ( 2 ) ;
                trapzeroglue ;
                If ( a >= 4 ) Then geqdefine ( p , 117 , curval )
                Else eqdefine ( p , 117 , curval ) ;
              End ;
    85 :
         Begin
           If curchr = 3983 Then n := 15
           Else If curchr = 5007 Then n := 32768
           Else If curchr = 4751 Then n := 32767
           Else If curchr = 5574 Then n := 16777215
           Else n := 255 ;
           p := curchr ;
           scancharnum ;
           p := p + curval ;
           scanoptionalequals ;
           scanint ;
           If ( ( curval < 0 ) And ( p < 5574 ) ) Or ( curval > n ) Then
             Begin
               Begin
                 If interaction = 3 Then ;
                 printnl ( 262 ) ;
                 print ( 1201 ) ;
               End ;
               printint ( curval ) ;
               If p < 5574 Then print ( 1202 )
               Else print ( 1203 ) ;
               printint ( n ) ;
               Begin
                 helpptr := 1 ;
                 helpline [ 0 ] := 1204 ;
               End ;
               error ;
               curval := 0 ;
             End ;
           If p < 5007 Then If ( a >= 4 ) Then geqdefine ( p , 120 , curval )
           Else eqdefine ( p , 120 , curval )
           Else If p < 5574 Then If ( a >= 4 ) Then geqdefine ( p , 120 , curval + 0 )
           Else eqdefine ( p , 120 , curval + 0 )
           Else If ( a >= 4 ) Then geqworddefine ( p , curval )
           Else eqworddefine ( p , curval ) ;
         End ;
    86 :
         Begin
           p := curchr ;
           scanfourbitint ;
           p := p + curval ;
           scanoptionalequals ;
           scanfontident ;
           If ( a >= 4 ) Then geqdefine ( p , 120 , curval )
           Else eqdefine ( p , 120 , curval ) ;
         End ;
    89 , 90 , 91 , 92 : doregistercommand ( a ) ;
    98 :
         Begin
           scaneightbitint ;
           If ( a >= 4 ) Then n := 256 + curval
           Else n := curval ;
           scanoptionalequals ;
           If setboxallowed Then scanbox ( 1073741824 + n )
           Else
             Begin
               Begin
                 If interaction = 3 Then ;
                 printnl ( 262 ) ;
                 print ( 680 ) ;
               End ;
               printesc ( 536 ) ;
               Begin
                 helpptr := 2 ;
                 helpline [ 1 ] := 1210 ;
                 helpline [ 0 ] := 1211 ;
               End ;
               error ;
             End ;
         End ;
    79 : alteraux ;
    80 : alterprevgraf ;
    81 : alterpagesofar ;
    82 : alterinteger ;
    83 : alterboxdimen ;
    84 :
         Begin
           scanoptionalequals ;
           scanint ;
           n := curval ;
           If n <= 0 Then p := 0
           Else
             Begin
               p := getnode ( 2 * n + 1 ) ;
               mem [ p ] . hh . lh := n ;
               For j := 1 To n Do
                 Begin
                   scandimen ( false , false , false ) ;
                   mem [ p + 2 * j - 1 ] . int := curval ;
                   scandimen ( false , false , false ) ;
                   mem [ p + 2 * j ] . int := curval ;
                 End ;
             End ;
           If ( a >= 4 ) Then geqdefine ( 3412 , 118 , p )
           Else eqdefine ( 3412 , 118 , p ) ;
         End ;
    99 : If curchr = 1 Then
           Begin
             newpatterns ;
             goto 30 ;
             Begin
               If interaction = 3 Then ;
               printnl ( 262 ) ;
               print ( 1215 ) ;
             End ;
             helpptr := 0 ;
             error ;
             Repeat
               gettoken ;
             Until curcmd = 2 ;
             goto 10 ;
           End
         Else
           Begin
             newhyphexceptions ;
             goto 30 ;
           End ;
    77 :
         Begin
           findfontdimen ( true ) ;
           k := curval ;
           scanoptionalequals ;
           scandimen ( false , false , false ) ;
           fontinfo [ k ] . int := curval ;
         End ;
    78 :
         Begin
           n := curchr ;
           scanfontident ;
           f := curval ;
           scanoptionalequals ;
           scanint ;
           If n = 0 Then hyphenchar [ f ] := curval
           Else skewchar [ f ] := curval ;
         End ;
    88 : newfont ( a ) ;
    100 : newinteraction ;
    others : confusion ( 1177 )
  End ;
  30 : If aftertoken <> 0 Then
         Begin
           curtok := aftertoken ;
           backinput ;
           aftertoken := 0 ;
         End ;
  10 :
End ;
Procedure doassignments ;

Label 10 ;
Begin
  While true Do
    Begin
      Repeat
        getxtoken ;
      Until ( curcmd <> 10 ) And ( curcmd <> 0 ) ;
      If curcmd <= 70 Then goto 10 ;
      setboxallowed := false ;
      prefixedcommand ;
      setboxallowed := true ;
    End ;
  10 :
End ;
Procedure openorclosein ;

Var c : 0 .. 1 ;
  n : 0 .. 15 ;
Begin
  c := curchr ;
  scanfourbitint ;
  n := curval ;
  If readopen [ n ] <> 2 Then
    Begin
      aclose ( readfile [ n ] ) ;
      readopen [ n ] := 2 ;
    End ;
  If c <> 0 Then
    Begin
      scanoptionalequals ;
      scanfilename ;
      If curext = 338 Then curext := 790 ;
      packfilename ( curname , curarea , curext ) ;
      If aopenin ( readfile [ n ] ) Then readopen [ n ] := 1 ;
    End ;
End ;
Procedure issuemessage ;

Var oldsetting : 0 .. 21 ;
  c : 0 .. 1 ;
  s : strnumber ;
Begin
  c := curchr ;
  mem [ 29988 ] . hh . rh := scantoks ( false , true ) ;
  oldsetting := selector ;
  selector := 21 ;
  tokenshow ( defref ) ;
  selector := oldsetting ;
  flushlist ( defref ) ;
  Begin
    If poolptr + 1 > poolsize Then overflow ( 257 , poolsize - initpoolptr ) ;
  End ;
  s := makestring ;
  If c = 0 Then
    Begin
      If termoffset + ( strstart [ s + 1 ] - strstart [ s ] ) > maxprintline - 2 Then println
      Else If ( termoffset > 0 ) Or ( fileoffset > 0 ) Then printchar ( 32 ) ;
      slowprint ( s ) ;
      break ( termout ) ;
    End
  Else
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 338 ) ;
      End ;
      slowprint ( s ) ;
      If eqtb [ 3421 ] . hh . rh <> 0 Then useerrhelp := true
      Else If longhelpseen Then
             Begin
               helpptr := 1 ;
               helpline [ 0 ] := 1231 ;
             End
      Else
        Begin
          If interaction < 3 Then longhelpseen := true ;
          Begin
            helpptr := 4 ;
            helpline [ 3 ] := 1232 ;
            helpline [ 2 ] := 1233 ;
            helpline [ 1 ] := 1234 ;
            helpline [ 0 ] := 1235 ;
          End ;
        End ;
      error ;
      useerrhelp := false ;
    End ;
  Begin
    strptr := strptr - 1 ;
    poolptr := strstart [ strptr ] ;
  End ;
End ;
Procedure shiftcase ;

Var b : halfword ;
  p : halfword ;
  t : halfword ;
  c : eightbits ;
Begin
  b := curchr ;
  p := scantoks ( false , false ) ;
  p := mem [ defref ] . hh . rh ;
  While p <> 0 Do
    Begin
      t := mem [ p ] . hh . lh ;
      If t < 4352 Then
        Begin
          c := t Mod 256 ;
          If eqtb [ b + c ] . hh . rh <> 0 Then mem [ p ] . hh . lh := t - c + eqtb [ b + c ] . hh . rh ;
        End ;
      p := mem [ p ] . hh . rh ;
    End ;
  begintokenlist ( mem [ defref ] . hh . rh , 3 ) ;
  Begin
    mem [ defref ] . hh . rh := avail ;
    avail := defref ;
  End ;
End ;
Procedure showwhatever ;

Label 50 ;

Var p : halfword ;
Begin
  Case curchr Of 
    3 :
        Begin
          begindiagnostic ;
          showactivities ;
        End ;
    1 :
        Begin
          scaneightbitint ;
          begindiagnostic ;
          printnl ( 1253 ) ;
          printint ( curval ) ;
          printchar ( 61 ) ;
          If eqtb [ 3678 + curval ] . hh . rh = 0 Then print ( 410 )
          Else showbox ( eqtb [ 3678 + curval ] . hh . rh ) ;
        End ;
    0 :
        Begin
          gettoken ;
          If interaction = 3 Then ;
          printnl ( 1247 ) ;
          If curcs <> 0 Then
            Begin
              sprintcs ( curcs ) ;
              printchar ( 61 ) ;
            End ;
          printmeaning ;
          goto 50 ;
        End ;
    others :
             Begin
               p := thetoks ;
               If interaction = 3 Then ;
               printnl ( 1247 ) ;
               tokenshow ( 29997 ) ;
               flushlist ( mem [ 29997 ] . hh . rh ) ;
               goto 50 ;
             End
  End ;
  enddiagnostic ( true ) ;
  Begin
    If interaction = 3 Then ;
    printnl ( 262 ) ;
    print ( 1254 ) ;
  End ;
  If selector = 19 Then If eqtb [ 5292 ] . int <= 0 Then
                          Begin
                            selector := 17 ;
                            print ( 1255 ) ;
                            selector := 19 ;
                          End ;
  50 : If interaction < 3 Then
         Begin
           helpptr := 0 ;
           errorcount := errorcount - 1 ;
         End
       Else If eqtb [ 5292 ] . int > 0 Then
              Begin
                Begin
                  helpptr := 3 ;
                  helpline [ 2 ] := 1242 ;
                  helpline [ 1 ] := 1243 ;
                  helpline [ 0 ] := 1244 ;
                End ;
              End
       Else
         Begin
           Begin
             helpptr := 5 ;
             helpline [ 4 ] := 1242 ;
             helpline [ 3 ] := 1243 ;
             helpline [ 2 ] := 1244 ;
             helpline [ 1 ] := 1245 ;
             helpline [ 0 ] := 1246 ;
           End ;
         End ;
  error ;
End ;
Procedure storefmtfile ;

Label 41 , 42 , 31 , 32 ;

Var j , k , l : integer ;
  p , q : halfword ;
  x : integer ;
  w : fourquarters ;
Begin
  If saveptr <> 0 Then
    Begin
      Begin
        If interaction = 3 Then ;
        printnl ( 262 ) ;
        print ( 1257 ) ;
      End ;
      Begin
        helpptr := 1 ;
        helpline [ 0 ] := 1258 ;
      End ;
      Begin
        If interaction = 3 Then interaction := 2 ;
        If logopened Then error ;
        history := 3 ;
        jumpout ;
      End ;
    End ;
  selector := 21 ;
  print ( 1271 ) ;
  print ( jobname ) ;
  printchar ( 32 ) ;
  printint ( eqtb [ 5286 ] . int ) ;
  printchar ( 46 ) ;
  printint ( eqtb [ 5285 ] . int ) ;
  printchar ( 46 ) ;
  printint ( eqtb [ 5284 ] . int ) ;
  printchar ( 41 ) ;
  If interaction = 0 Then selector := 18
  Else selector := 19 ;
  Begin
    If poolptr + 1 > poolsize Then overflow ( 257 , poolsize - initpoolptr ) ;
  End ;
  formatident := makestring ;
  packjobname ( 785 ) ;
  While Not wopenout ( fmtfile ) Do
    promptfilename ( 1272 , 785 ) ;
  printnl ( 1273 ) ;
  slowprint ( wmakenamestring ( fmtfile ) ) ;
  Begin
    strptr := strptr - 1 ;
    poolptr := strstart [ strptr ] ;
  End ;
  printnl ( 338 ) ;
  slowprint ( formatident ) ;
  Begin
    fmtfile ^ . int := 117275187 ;
    put ( fmtfile ) ;
  End ;
  Begin
    fmtfile ^ . int := 0 ;
    put ( fmtfile ) ;
  End ;
  Begin
    fmtfile ^ . int := 30000 ;
    put ( fmtfile ) ;
  End ;
  Begin
    fmtfile ^ . int := 6106 ;
    put ( fmtfile ) ;
  End ;
  Begin
    fmtfile ^ . int := 1777 ;
    put ( fmtfile ) ;
  End ;
  Begin
    fmtfile ^ . int := 307 ;
    put ( fmtfile ) ;
  End ;
  Begin
    fmtfile ^ . int := poolptr ;
    put ( fmtfile ) ;
  End ;
  Begin
    fmtfile ^ . int := strptr ;
    put ( fmtfile ) ;
  End ;
  For k := 0 To strptr Do
    Begin
      fmtfile ^ . int := strstart [ k ] ;
      put ( fmtfile ) ;
    End ;
  k := 0 ;
  While k + 4 < poolptr Do
    Begin
      w . b0 := strpool [ k ] + 0 ;
      w . b1 := strpool [ k + 1 ] + 0 ;
      w . b2 := strpool [ k + 2 ] + 0 ;
      w . b3 := strpool [ k + 3 ] + 0 ;
      Begin
        fmtfile ^ . qqqq := w ;
        put ( fmtfile ) ;
      End ;
      k := k + 4 ;
    End ;
  k := poolptr - 4 ;
  w . b0 := strpool [ k ] + 0 ;
  w . b1 := strpool [ k + 1 ] + 0 ;
  w . b2 := strpool [ k + 2 ] + 0 ;
  w . b3 := strpool [ k + 3 ] + 0 ;
  Begin
    fmtfile ^ . qqqq := w ;
    put ( fmtfile ) ;
  End ;
  println ;
  printint ( strptr ) ;
  print ( 1259 ) ;
  printint ( poolptr ) ;
  sortavail ;
  varused := 0 ;
  Begin
    fmtfile ^ . int := lomemmax ;
    put ( fmtfile ) ;
  End ;
  Begin
    fmtfile ^ . int := rover ;
    put ( fmtfile ) ;
  End ;
  p := 0 ;
  q := rover ;
  x := 0 ;
  Repeat
    For k := p To q + 1 Do
      Begin
        fmtfile ^ := mem [ k ] ;
        put ( fmtfile ) ;
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
      fmtfile ^ := mem [ k ] ;
      put ( fmtfile ) ;
    End ;
  x := x + lomemmax + 1 - p ;
  Begin
    fmtfile ^ . int := himemmin ;
    put ( fmtfile ) ;
  End ;
  Begin
    fmtfile ^ . int := avail ;
    put ( fmtfile ) ;
  End ;
  For k := himemmin To memend Do
    Begin
      fmtfile ^ := mem [ k ] ;
      put ( fmtfile ) ;
    End ;
  x := x + memend + 1 - himemmin ;
  p := avail ;
  While p <> 0 Do
    Begin
      dynused := dynused - 1 ;
      p := mem [ p ] . hh . rh ;
    End ;
  Begin
    fmtfile ^ . int := varused ;
    put ( fmtfile ) ;
  End ;
  Begin
    fmtfile ^ . int := dynused ;
    put ( fmtfile ) ;
  End ;
  println ;
  printint ( x ) ;
  print ( 1260 ) ;
  printint ( varused ) ;
  printchar ( 38 ) ;
  printint ( dynused ) ;
  k := 1 ;
  Repeat
    j := k ;
    While j < 5262 Do
      Begin
        If ( eqtb [ j ] . hh . rh = eqtb [ j + 1 ] . hh . rh ) And ( eqtb [ j ] . hh . b0 = eqtb [ j + 1 ] . hh . b0 ) And ( eqtb [ j ] . hh . b1 = eqtb [ j + 1 ] . hh . b1 ) Then goto 41 ;
        j := j + 1 ;
      End ;
    l := 5263 ;
    goto 31 ;
    41 : j := j + 1 ;
    l := j ;
    While j < 5262 Do
      Begin
        If ( eqtb [ j ] . hh . rh <> eqtb [ j + 1 ] . hh . rh ) Or ( eqtb [ j ] . hh . b0 <> eqtb [ j + 1 ] . hh . b0 ) Or ( eqtb [ j ] . hh . b1 <> eqtb [ j + 1 ] . hh . b1 ) Then goto 31 ;
        j := j + 1 ;
      End ;
    31 :
         Begin
           fmtfile ^ . int := l - k ;
           put ( fmtfile ) ;
         End ;
    While k < l Do
      Begin
        Begin
          fmtfile ^ := eqtb [ k ] ;
          put ( fmtfile ) ;
        End ;
        k := k + 1 ;
      End ;
    k := j + 1 ;
    Begin
      fmtfile ^ . int := k - l ;
      put ( fmtfile ) ;
    End ;
  Until k = 5263 ;
  Repeat
    j := k ;
    While j < 6106 Do
      Begin
        If eqtb [ j ] . int = eqtb [ j + 1 ] . int Then goto 42 ;
        j := j + 1 ;
      End ;
    l := 6107 ;
    goto 32 ;
    42 : j := j + 1 ;
    l := j ;
    While j < 6106 Do
      Begin
        If eqtb [ j ] . int <> eqtb [ j + 1 ] . int Then goto 32 ;
        j := j + 1 ;
      End ;
    32 :
         Begin
           fmtfile ^ . int := l - k ;
           put ( fmtfile ) ;
         End ;
    While k < l Do
      Begin
        Begin
          fmtfile ^ := eqtb [ k ] ;
          put ( fmtfile ) ;
        End ;
        k := k + 1 ;
      End ;
    k := j + 1 ;
    Begin
      fmtfile ^ . int := k - l ;
      put ( fmtfile ) ;
    End ;
  Until k > 6106 ;
  Begin
    fmtfile ^ . int := parloc ;
    put ( fmtfile ) ;
  End ;
  Begin
    fmtfile ^ . int := writeloc ;
    put ( fmtfile ) ;
  End ;
  Begin
    fmtfile ^ . int := hashused ;
    put ( fmtfile ) ;
  End ;
  cscount := 2613 - hashused ;
  For p := 514 To hashused Do
    If hash [ p ] . rh <> 0 Then
      Begin
        Begin
          fmtfile ^ . int := p ;
          put ( fmtfile ) ;
        End ;
        Begin
          fmtfile ^ . hh := hash [ p ] ;
          put ( fmtfile ) ;
        End ;
        cscount := cscount + 1 ;
      End ;
  For p := hashused + 1 To 2880 Do
    Begin
      fmtfile ^ . hh := hash [ p ] ;
      put ( fmtfile ) ;
    End ;
  Begin
    fmtfile ^ . int := cscount ;
    put ( fmtfile ) ;
  End ;
  println ;
  printint ( cscount ) ;
  print ( 1261 ) ;
  Begin
    fmtfile ^ . int := fmemptr ;
    put ( fmtfile ) ;
  End ;
  For k := 0 To fmemptr - 1 Do
    Begin
      fmtfile ^ := fontinfo [ k ] ;
      put ( fmtfile ) ;
    End ;
  Begin
    fmtfile ^ . int := fontptr ;
    put ( fmtfile ) ;
  End ;
  For k := 0 To fontptr Do
    Begin
      Begin
        fmtfile ^ . qqqq := fontcheck [ k ] ;
        put ( fmtfile ) ;
      End ;
      Begin
        fmtfile ^ . int := fontsize [ k ] ;
        put ( fmtfile ) ;
      End ;
      Begin
        fmtfile ^ . int := fontdsize [ k ] ;
        put ( fmtfile ) ;
      End ;
      Begin
        fmtfile ^ . int := fontparams [ k ] ;
        put ( fmtfile ) ;
      End ;
      Begin
        fmtfile ^ . int := hyphenchar [ k ] ;
        put ( fmtfile ) ;
      End ;
      Begin
        fmtfile ^ . int := skewchar [ k ] ;
        put ( fmtfile ) ;
      End ;
      Begin
        fmtfile ^ . int := fontname [ k ] ;
        put ( fmtfile ) ;
      End ;
      Begin
        fmtfile ^ . int := fontarea [ k ] ;
        put ( fmtfile ) ;
      End ;
      Begin
        fmtfile ^ . int := fontbc [ k ] ;
        put ( fmtfile ) ;
      End ;
      Begin
        fmtfile ^ . int := fontec [ k ] ;
        put ( fmtfile ) ;
      End ;
      Begin
        fmtfile ^ . int := charbase [ k ] ;
        put ( fmtfile ) ;
      End ;
      Begin
        fmtfile ^ . int := widthbase [ k ] ;
        put ( fmtfile ) ;
      End ;
      Begin
        fmtfile ^ . int := heightbase [ k ] ;
        put ( fmtfile ) ;
      End ;
      Begin
        fmtfile ^ . int := depthbase [ k ] ;
        put ( fmtfile ) ;
      End ;
      Begin
        fmtfile ^ . int := italicbase [ k ] ;
        put ( fmtfile ) ;
      End ;
      Begin
        fmtfile ^ . int := ligkernbase [ k ] ;
        put ( fmtfile ) ;
      End ;
      Begin
        fmtfile ^ . int := kernbase [ k ] ;
        put ( fmtfile ) ;
      End ;
      Begin
        fmtfile ^ . int := extenbase [ k ] ;
        put ( fmtfile ) ;
      End ;
      Begin
        fmtfile ^ . int := parambase [ k ] ;
        put ( fmtfile ) ;
      End ;
      Begin
        fmtfile ^ . int := fontglue [ k ] ;
        put ( fmtfile ) ;
      End ;
      Begin
        fmtfile ^ . int := bcharlabel [ k ] ;
        put ( fmtfile ) ;
      End ;
      Begin
        fmtfile ^ . int := fontbchar [ k ] ;
        put ( fmtfile ) ;
      End ;
      Begin
        fmtfile ^ . int := fontfalsebchar [ k ] ;
        put ( fmtfile ) ;
      End ;
      printnl ( 1264 ) ;
      printesc ( hash [ 2624 + k ] . rh ) ;
      printchar ( 61 ) ;
      printfilename ( fontname [ k ] , fontarea [ k ] , 338 ) ;
      If fontsize [ k ] <> fontdsize [ k ] Then
        Begin
          print ( 741 ) ;
          printscaled ( fontsize [ k ] ) ;
          print ( 397 ) ;
        End ;
    End ;
  println ;
  printint ( fmemptr - 7 ) ;
  print ( 1262 ) ;
  printint ( fontptr - 0 ) ;
  print ( 1263 ) ;
  If fontptr <> 1 Then printchar ( 115 ) ;
  Begin
    fmtfile ^ . int := hyphcount ;
    put ( fmtfile ) ;
  End ;
  For k := 0 To 307 Do
    If hyphword [ k ] <> 0 Then
      Begin
        Begin
          fmtfile ^ . int := k ;
          put ( fmtfile ) ;
        End ;
        Begin
          fmtfile ^ . int := hyphword [ k ] ;
          put ( fmtfile ) ;
        End ;
        Begin
          fmtfile ^ . int := hyphlist [ k ] ;
          put ( fmtfile ) ;
        End ;
      End ;
  println ;
  printint ( hyphcount ) ;
  print ( 1265 ) ;
  If hyphcount <> 1 Then printchar ( 115 ) ;
  If trienotready Then inittrie ;
  Begin
    fmtfile ^ . int := triemax ;
    put ( fmtfile ) ;
  End ;
  For k := 0 To triemax Do
    Begin
      fmtfile ^ . hh := trie [ k ] ;
      put ( fmtfile ) ;
    End ;
  Begin
    fmtfile ^ . int := trieopptr ;
    put ( fmtfile ) ;
  End ;
  For k := 1 To trieopptr Do
    Begin
      Begin
        fmtfile ^ . int := hyfdistance [ k ] ;
        put ( fmtfile ) ;
      End ;
      Begin
        fmtfile ^ . int := hyfnum [ k ] ;
        put ( fmtfile ) ;
      End ;
      Begin
        fmtfile ^ . int := hyfnext [ k ] ;
        put ( fmtfile ) ;
      End ;
    End ;
  printnl ( 1266 ) ;
  printint ( triemax ) ;
  print ( 1267 ) ;
  printint ( trieopptr ) ;
  print ( 1268 ) ;
  If trieopptr <> 1 Then printchar ( 115 ) ;
  print ( 1269 ) ;
  printint ( trieopsize ) ;
  For k := 255 Downto 0 Do
    If trieused [ k ] > 0 Then
      Begin
        printnl ( 799 ) ;
        printint ( trieused [ k ] - 0 ) ;
        print ( 1270 ) ;
        printint ( k ) ;
        Begin
          fmtfile ^ . int := k ;
          put ( fmtfile ) ;
        End ;
        Begin
          fmtfile ^ . int := trieused [ k ] - 0 ;
          put ( fmtfile ) ;
        End ;
      End ;
  Begin
    fmtfile ^ . int := interaction ;
    put ( fmtfile ) ;
  End ;
  Begin
    fmtfile ^ . int := formatident ;
    put ( fmtfile ) ;
  End ;
  Begin
    fmtfile ^ . int := 69069 ;
    put ( fmtfile ) ;
  End ;
  eqtb [ 5294 ] . int := 0 ;
  wclose ( fmtfile ) ;
End ;
Procedure newwhatsit ( s : smallnumber ; w : smallnumber ) ;

Var p : halfword ;
Begin
  p := getnode ( w ) ;
  mem [ p ] . hh . b0 := 8 ;
  mem [ p ] . hh . b1 := s ;
  mem [ curlist . tailfield ] . hh . rh := p ;
  curlist . tailfield := p ;
End ;
Procedure newwritewhatsit ( w : smallnumber ) ;
Begin
  newwhatsit ( curchr , w ) ;
  If w <> 2 Then scanfourbitint
  Else
    Begin
      scanint ;
      If curval < 0 Then curval := 17
      Else If curval > 15 Then curval := 16 ;
    End ;
  mem [ curlist . tailfield + 1 ] . hh . lh := curval ;
End ;
Procedure doextension ;

Var i , j , k : integer ;
  p , q , r : halfword ;
Begin
  Case curchr Of 
    0 :
        Begin
          newwritewhatsit ( 3 ) ;
          scanoptionalequals ;
          scanfilename ;
          mem [ curlist . tailfield + 1 ] . hh . rh := curname ;
          mem [ curlist . tailfield + 2 ] . hh . lh := curarea ;
          mem [ curlist . tailfield + 2 ] . hh . rh := curext ;
        End ;
    1 :
        Begin
          k := curcs ;
          newwritewhatsit ( 2 ) ;
          curcs := k ;
          p := scantoks ( false , false ) ;
          mem [ curlist . tailfield + 1 ] . hh . rh := defref ;
        End ;
    2 :
        Begin
          newwritewhatsit ( 2 ) ;
          mem [ curlist . tailfield + 1 ] . hh . rh := 0 ;
        End ;
    3 :
        Begin
          newwhatsit ( 3 , 2 ) ;
          mem [ curlist . tailfield + 1 ] . hh . lh := 0 ;
          p := scantoks ( false , true ) ;
          mem [ curlist . tailfield + 1 ] . hh . rh := defref ;
        End ;
    4 :
        Begin
          getxtoken ;
          If ( curcmd = 59 ) And ( curchr <= 2 ) Then
            Begin
              p := curlist . tailfield ;
              doextension ;
              outwhat ( curlist . tailfield ) ;
              flushnodelist ( curlist . tailfield ) ;
              curlist . tailfield := p ;
              mem [ p ] . hh . rh := 0 ;
            End
          Else backinput ;
        End ;
    5 : If abs ( curlist . modefield ) <> 102 Then reportillegalcase
        Else
          Begin
            newwhatsit ( 4 , 2 ) ;
            scanint ;
            If curval <= 0 Then curlist . auxfield . hh . rh := 0
            Else If curval > 255 Then curlist . auxfield . hh . rh := 0
            Else curlist . auxfield . hh . rh := curval ;
            mem [ curlist . tailfield + 1 ] . hh . rh := curlist . auxfield . hh . rh ;
            mem [ curlist . tailfield + 1 ] . hh . b0 := normmin ( eqtb [ 5314 ] . int ) ;
            mem [ curlist . tailfield + 1 ] . hh . b1 := normmin ( eqtb [ 5315 ] . int ) ;
          End ;
    others : confusion ( 1290 )
  End ;
End ;
Procedure fixlanguage ;

Var l : ASCIIcode ;
Begin
  If eqtb [ 5313 ] . int <= 0 Then l := 0
  Else If eqtb [ 5313 ] . int > 255 Then l := 0
  Else l := eqtb [ 5313 ] . int ;
  If l <> curlist . auxfield . hh . rh Then
    Begin
      newwhatsit ( 4 , 2 ) ;
      mem [ curlist . tailfield + 1 ] . hh . rh := l ;
      curlist . auxfield . hh . rh := l ;
      mem [ curlist . tailfield + 1 ] . hh . b0 := normmin ( eqtb [ 5314 ] . int ) ;
      mem [ curlist . tailfield + 1 ] . hh . b1 := normmin ( eqtb [ 5315 ] . int ) ;
    End ;
End ;
Procedure handlerightbrace ;

Var p , q : halfword ;
  d : scaled ;
  f : integer ;
Begin
  Case curgroup Of 
    1 : unsave ;
    0 :
        Begin
          Begin
            If interaction = 3 Then ;
            printnl ( 262 ) ;
            print ( 1043 ) ;
          End ;
          Begin
            helpptr := 2 ;
            helpline [ 1 ] := 1044 ;
            helpline [ 0 ] := 1045 ;
          End ;
          error ;
        End ;
    14 , 15 , 16 : extrarightbrace ;
    2 : package ( 0 ) ;
    3 :
        Begin
          adjusttail := 29995 ;
          package ( 0 ) ;
        End ;
    4 :
        Begin
          endgraf ;
          package ( 0 ) ;
        End ;
    5 :
        Begin
          endgraf ;
          package ( 4 ) ;
        End ;
    11 :
         Begin
           endgraf ;
           q := eqtb [ 2892 ] . hh . rh ;
           mem [ q ] . hh . rh := mem [ q ] . hh . rh + 1 ;
           d := eqtb [ 5836 ] . int ;
           f := eqtb [ 5305 ] . int ;
           unsave ;
           saveptr := saveptr - 1 ;
           p := vpackage ( mem [ curlist . headfield ] . hh . rh , 0 , 1 , 1073741823 ) ;
           popnest ;
           If savestack [ saveptr + 0 ] . int < 255 Then
             Begin
               Begin
                 mem [ curlist . tailfield ] . hh . rh := getnode ( 5 ) ;
                 curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
               End ;
               mem [ curlist . tailfield ] . hh . b0 := 3 ;
               mem [ curlist . tailfield ] . hh . b1 := savestack [ saveptr + 0 ] . int + 0 ;
               mem [ curlist . tailfield + 3 ] . int := mem [ p + 3 ] . int + mem [ p + 2 ] . int ;
               mem [ curlist . tailfield + 4 ] . hh . lh := mem [ p + 5 ] . hh . rh ;
               mem [ curlist . tailfield + 4 ] . hh . rh := q ;
               mem [ curlist . tailfield + 2 ] . int := d ;
               mem [ curlist . tailfield + 1 ] . int := f ;
             End
           Else
             Begin
               Begin
                 mem [ curlist . tailfield ] . hh . rh := getnode ( 2 ) ;
                 curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
               End ;
               mem [ curlist . tailfield ] . hh . b0 := 5 ;
               mem [ curlist . tailfield ] . hh . b1 := 0 ;
               mem [ curlist . tailfield + 1 ] . int := mem [ p + 5 ] . hh . rh ;
               deleteglueref ( q ) ;
             End ;
           freenode ( p , 7 ) ;
           If nestptr = 0 Then buildpage ;
         End ;
    8 :
        Begin
          If ( curinput . locfield <> 0 ) Or ( ( curinput . indexfield <> 6 ) And ( curinput . indexfield <> 3 ) ) Then
            Begin
              Begin
                If interaction = 3 Then ;
                printnl ( 262 ) ;
                print ( 1009 ) ;
              End ;
              Begin
                helpptr := 2 ;
                helpline [ 1 ] := 1010 ;
                helpline [ 0 ] := 1011 ;
              End ;
              error ;
              Repeat
                gettoken ;
              Until curinput . locfield = 0 ;
            End ;
          endtokenlist ;
          endgraf ;
          unsave ;
          outputactive := false ;
          insertpenalties := 0 ;
          If eqtb [ 3933 ] . hh . rh <> 0 Then
            Begin
              Begin
                If interaction = 3 Then ;
                printnl ( 262 ) ;
                print ( 1012 ) ;
              End ;
              printesc ( 409 ) ;
              printint ( 255 ) ;
              Begin
                helpptr := 3 ;
                helpline [ 2 ] := 1013 ;
                helpline [ 1 ] := 1014 ;
                helpline [ 0 ] := 1015 ;
              End ;
              boxerror ( 255 ) ;
            End ;
          If curlist . tailfield <> curlist . headfield Then
            Begin
              mem [ pagetail ] . hh . rh := mem [ curlist . headfield ] . hh . rh ;
              pagetail := curlist . tailfield ;
            End ;
          If mem [ 29998 ] . hh . rh <> 0 Then
            Begin
              If mem [ 29999 ] . hh . rh = 0 Then nest [ 0 ] . tailfield := pagetail ;
              mem [ pagetail ] . hh . rh := mem [ 29999 ] . hh . rh ;
              mem [ 29999 ] . hh . rh := mem [ 29998 ] . hh . rh ;
              mem [ 29998 ] . hh . rh := 0 ;
              pagetail := 29998 ;
            End ;
          popnest ;
          buildpage ;
        End ;
    10 : builddiscretionary ;
    6 :
        Begin
          backinput ;
          curtok := 6710 ;
          Begin
            If interaction = 3 Then ;
            printnl ( 262 ) ;
            print ( 625 ) ;
          End ;
          printesc ( 898 ) ;
          print ( 626 ) ;
          Begin
            helpptr := 1 ;
            helpline [ 0 ] := 1124 ;
          End ;
          inserror ;
        End ;
    7 :
        Begin
          endgraf ;
          unsave ;
          alignpeek ;
        End ;
    12 :
         Begin
           endgraf ;
           unsave ;
           saveptr := saveptr - 2 ;
           p := vpackage ( mem [ curlist . headfield ] . hh . rh , savestack [ saveptr + 1 ] . int , savestack [ saveptr + 0 ] . int , 1073741823 ) ;
           popnest ;
           Begin
             mem [ curlist . tailfield ] . hh . rh := newnoad ;
             curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
           End ;
           mem [ curlist . tailfield ] . hh . b0 := 29 ;
           mem [ curlist . tailfield + 1 ] . hh . rh := 2 ;
           mem [ curlist . tailfield + 1 ] . hh . lh := p ;
         End ;
    13 : buildchoices ;
    9 :
        Begin
          unsave ;
          saveptr := saveptr - 1 ;
          mem [ savestack [ saveptr + 0 ] . int ] . hh . rh := 3 ;
          p := finmlist ( 0 ) ;
          mem [ savestack [ saveptr + 0 ] . int ] . hh . lh := p ;
          If p <> 0 Then If mem [ p ] . hh . rh = 0 Then If mem [ p ] . hh . b0 = 16 Then
                                                           Begin
                                                             If mem [ p + 3 ] . hh . rh = 0 Then If mem [ p + 2 ] . hh . rh = 0 Then
                                                                                                   Begin
                                                                                                     mem [ savestack [ saveptr + 0 ] . int ] . hh := mem [ p + 1 ] . hh ;
                                                                                                     freenode ( p , 4 ) ;
                                                                                                   End ;
                                                           End
          Else If mem [ p ] . hh . b0 = 28 Then If savestack [ saveptr + 0 ] . int = curlist . tailfield + 1 Then If mem [ curlist . tailfield ] . hh . b0 = 16 Then
                                                                                                                    Begin
                                                                                                                      q := curlist . headfield ;
                                                                                                                      While mem [ q ] . hh . rh <> curlist . tailfield Do
                                                                                                                        q := mem [ q ] . hh . rh ;
                                                                                                                      mem [ q ] . hh . rh := p ;
                                                                                                                      freenode ( curlist . tailfield , 4 ) ;
                                                                                                                      curlist . tailfield := p ;
                                                                                                                    End ;
        End ;
    others : confusion ( 1046 )
  End ;
End ;
Procedure maincontrol ;

Label 60 , 21 , 70 , 80 , 90 , 91 , 92 , 95 , 100 , 101 , 110 , 111 , 112 , 120 , 10 ;

Var t : integer ;
Begin
  If eqtb [ 3419 ] . hh . rh <> 0 Then begintokenlist ( eqtb [ 3419 ] . hh . rh , 12 ) ;
  60 : getxtoken ;
  21 : If interrupt <> 0 Then If OKtointerrupt Then
                                Begin
                                  backinput ;
                                  Begin
                                    If interrupt <> 0 Then pauseforinstructions ;
                                  End ;
                                  goto 60 ;
                                End ;
  If eqtb [ 5299 ] . int > 0 Then showcurcmdchr ;
  Case abs ( curlist . modefield ) + curcmd Of 
    113 , 114 , 170 : goto 70 ;
    118 :
          Begin
            scancharnum ;
            curchr := curval ;
            goto 70 ;
          End ;
    167 :
          Begin
            getxtoken ;
            If ( curcmd = 11 ) Or ( curcmd = 12 ) Or ( curcmd = 68 ) Or ( curcmd = 16 ) Then cancelboundary := true ;
            goto 21 ;
          End ;
    112 : If curlist . auxfield . hh . lh = 1000 Then goto 120
          Else appspace ;
    166 , 267 : goto 120 ;
    1 , 102 , 203 , 11 , 213 , 268 : ;
    40 , 141 , 242 :
                     Begin
                       Repeat
                         getxtoken ;
                       Until curcmd <> 10 ;
                       goto 21 ;
                     End ;
    15 : If itsallover Then goto 10 ;
    23 , 123 , 224 , 71 , 172 , 273 , 39 , 45 , 49 , 150 , 7 , 108 , 209 : reportillegalcase ;
    8 , 109 , 9 , 110 , 18 , 119 , 70 , 171 , 51 , 152 , 16 , 117 , 50 , 151 , 53 , 154 , 67 , 168 , 54 , 155 , 55 , 156 , 57 , 158 , 56 , 157 , 31 , 132 , 52 , 153 , 29 , 130 , 47 , 148 , 212 , 216 , 217 , 230 , 227 , 236 , 239 : insertdollarsign ;
    37 , 137 , 238 :
                     Begin
                       Begin
                         mem [ curlist . tailfield ] . hh . rh := scanrulespec ;
                         curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
                       End ;
                       If abs ( curlist . modefield ) = 1 Then curlist . auxfield . int := - 65536000
                       Else If abs ( curlist . modefield ) = 102 Then curlist . auxfield . hh . lh := 1000 ;
                     End ;
    28 , 128 , 229 , 231 : appendglue ;
    30 , 131 , 232 , 233 : appendkern ;
    2 , 103 : newsavelevel ( 1 ) ;
    62 , 163 , 264 : newsavelevel ( 14 ) ;
    63 , 164 , 265 : If curgroup = 14 Then unsave
                     Else offsave ;
    3 , 104 , 205 : handlerightbrace ;
    22 , 124 , 225 :
                     Begin
                       t := curchr ;
                       scandimen ( false , false , false ) ;
                       If t = 0 Then scanbox ( curval )
                       Else scanbox ( - curval ) ;
                     End ;
    32 , 133 , 234 : scanbox ( 1073742237 + curchr ) ;
    21 , 122 , 223 : beginbox ( 0 ) ;
    44 : newgraf ( curchr > 0 ) ;
    12 , 13 , 17 , 69 , 4 , 24 , 36 , 46 , 48 , 27 , 34 , 65 , 66 :
                                                                    Begin
                                                                      backinput ;
                                                                      newgraf ( true ) ;
                                                                    End ;
    145 , 246 : indentinhmode ;
    14 :
         Begin
           normalparagraph ;
           If curlist . modefield > 0 Then buildpage ;
         End ;
    115 :
          Begin
            If alignstate < 0 Then offsave ;
            endgraf ;
            If curlist . modefield = 1 Then buildpage ;
          End ;
    116 , 129 , 138 , 126 , 134 : headforvmode ;
    38 , 139 , 240 , 140 , 241 : begininsertoradjust ;
    19 , 120 , 221 : makemark ;
    43 , 144 , 245 : appendpenalty ;
    26 , 127 , 228 : deletelast ;
    25 , 125 , 226 : unpackage ;
    146 : appenditaliccorrection ;
    247 :
          Begin
            mem [ curlist . tailfield ] . hh . rh := newkern ( 0 ) ;
            curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
          End ;
    149 , 250 : appenddiscretionary ;
    147 : makeaccent ;
    6 , 107 , 208 , 5 , 106 , 207 : alignerror ;
    35 , 136 , 237 : noalignerror ;
    64 , 165 , 266 : omiterror ;
    33 , 135 : initalign ;
    235 : If privileged Then If curgroup = 15 Then initalign
          Else offsave ;
    10 , 111 : doendv ;
    68 , 169 , 270 : cserror ;
    105 : initmath ;
    251 : If privileged Then If curgroup = 15 Then starteqno
          Else offsave ;
    204 :
          Begin
            Begin
              mem [ curlist . tailfield ] . hh . rh := newnoad ;
              curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
            End ;
            backinput ;
            scanmath ( curlist . tailfield + 1 ) ;
          End ;
    214 , 215 , 271 : setmathchar ( eqtb [ 5007 + curchr ] . hh . rh - 0 ) ;
    219 :
          Begin
            scancharnum ;
            curchr := curval ;
            setmathchar ( eqtb [ 5007 + curchr ] . hh . rh - 0 ) ;
          End ;
    220 :
          Begin
            scanfifteenbitint ;
            setmathchar ( curval ) ;
          End ;
    272 : setmathchar ( curchr ) ;
    218 :
          Begin
            scantwentysevenbitint ;
            setmathchar ( curval Div 4096 ) ;
          End ;
    253 :
          Begin
            Begin
              mem [ curlist . tailfield ] . hh . rh := newnoad ;
              curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
            End ;
            mem [ curlist . tailfield ] . hh . b0 := curchr ;
            scanmath ( curlist . tailfield + 1 ) ;
          End ;
    254 : mathlimitswitch ;
    269 : mathradical ;
    248 , 249 : mathac ;
    259 :
          Begin
            scanspec ( 12 , false ) ;
            normalparagraph ;
            pushnest ;
            curlist . modefield := - 1 ;
            curlist . auxfield . int := - 65536000 ;
            If eqtb [ 3418 ] . hh . rh <> 0 Then begintokenlist ( eqtb [ 3418 ] . hh . rh , 11 ) ;
          End ;
    256 :
          Begin
            mem [ curlist . tailfield ] . hh . rh := newstyle ( curchr ) ;
            curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
          End ;
    258 :
          Begin
            Begin
              mem [ curlist . tailfield ] . hh . rh := newglue ( 0 ) ;
              curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
            End ;
            mem [ curlist . tailfield ] . hh . b1 := 98 ;
          End ;
    257 : appendchoices ;
    211 , 210 : subsup ;
    255 : mathfraction ;
    252 : mathleftright ;
    206 : If curgroup = 15 Then aftermath
          Else offsave ;
    72 , 173 , 274 , 73 , 174 , 275 , 74 , 175 , 276 , 75 , 176 , 277 , 76 , 177 , 278 , 77 , 178 , 279 , 78 , 179 , 280 , 79 , 180 , 281 , 80 , 181 , 282 , 81 , 182 , 283 , 82 , 183 , 284 , 83 , 184 , 285 , 84 , 185 , 286 , 85 , 186 , 287 , 86 , 187 , 288 , 87 , 188 , 289 , 88 , 189 , 290 , 89 , 190 , 291 , 90 , 191 , 292 , 91 , 192 , 293 , 92 , 193 , 294 , 93 , 194 , 295 , 94 , 195 , 296 , 95 , 196 , 297 , 96 , 197 , 298 , 97 , 198 , 299 , 98 , 199 , 300 , 99 , 200 , 301 , 100 , 201 , 302 , 101 , 202 , 303 : prefixedcommand ;
    41 , 142 , 243 :
                     Begin
                       gettoken ;
                       aftertoken := curtok ;
                     End ;
    42 , 143 , 244 :
                     Begin
                       gettoken ;
                       saveforafter ( curtok ) ;
                     End ;
    61 , 162 , 263 : openorclosein ;
    59 , 160 , 261 : issuemessage ;
    58 , 159 , 260 : shiftcase ;
    20 , 121 , 222 : showwhatever ;
    60 , 161 , 262 : doextension ;
  End ;
  goto 60 ;
  70 : mains := eqtb [ 4751 + curchr ] . hh . rh ;
  If mains = 1000 Then curlist . auxfield . hh . lh := 1000
  Else If mains < 1000 Then
         Begin
           If mains > 0 Then curlist . auxfield . hh . lh := mains ;
         End
  Else If curlist . auxfield . hh . lh < 1000 Then curlist . auxfield . hh . lh := 1000
  Else curlist . auxfield . hh . lh := mains ;
  mainf := eqtb [ 3934 ] . hh . rh ;
  bchar := fontbchar [ mainf ] ;
  falsebchar := fontfalsebchar [ mainf ] ;
  If curlist . modefield > 0 Then If eqtb [ 5313 ] . int <> curlist . auxfield . hh . rh Then fixlanguage ;
  Begin
    ligstack := avail ;
    If ligstack = 0 Then ligstack := getavail
    Else
      Begin
        avail := mem [ ligstack ] . hh . rh ;
        mem [ ligstack ] . hh . rh := 0 ;
      End ;
  End ;
  mem [ ligstack ] . hh . b0 := mainf ;
  curl := curchr + 0 ;
  mem [ ligstack ] . hh . b1 := curl ;
  curq := curlist . tailfield ;
  If cancelboundary Then
    Begin
      cancelboundary := false ;
      maink := 0 ;
    End
  Else maink := bcharlabel [ mainf ] ;
  If maink = 0 Then goto 92 ;
  curr := curl ;
  curl := 256 ;
  goto 111 ;
  80 : If curl < 256 Then
         Begin
           If mem [ curq ] . hh . rh > 0 Then If mem [ curlist . tailfield ] . hh . b1 = hyphenchar [ mainf ] + 0 Then insdisc := true ;
           If ligaturepresent Then
             Begin
               mainp := newligature ( mainf , curl , mem [ curq ] . hh . rh ) ;
               If lfthit Then
                 Begin
                   mem [ mainp ] . hh . b1 := 2 ;
                   lfthit := false ;
                 End ;
               If rthit Then If ligstack = 0 Then
                               Begin
                                 mem [ mainp ] . hh . b1 := mem [ mainp ] . hh . b1 + 1 ;
                                 rthit := false ;
                               End ;
               mem [ curq ] . hh . rh := mainp ;
               curlist . tailfield := mainp ;
               ligaturepresent := false ;
             End ;
           If insdisc Then
             Begin
               insdisc := false ;
               If curlist . modefield > 0 Then
                 Begin
                   mem [ curlist . tailfield ] . hh . rh := newdisc ;
                   curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
                 End ;
             End ;
         End ;
  90 : If ligstack = 0 Then goto 21 ;
  curq := curlist . tailfield ;
  curl := mem [ ligstack ] . hh . b1 ;
  91 : If Not ( ligstack >= himemmin ) Then goto 95 ;
  92 : If ( curchr < fontbc [ mainf ] ) Or ( curchr > fontec [ mainf ] ) Then
         Begin
           charwarning ( mainf , curchr ) ;
           Begin
             mem [ ligstack ] . hh . rh := avail ;
             avail := ligstack ;
           End ;
           goto 60 ;
         End ;
  maini := fontinfo [ charbase [ mainf ] + curl ] . qqqq ;
  If Not ( maini . b0 > 0 ) Then
    Begin
      charwarning ( mainf , curchr ) ;
      Begin
        mem [ ligstack ] . hh . rh := avail ;
        avail := ligstack ;
      End ;
      goto 60 ;
    End ;
  mem [ curlist . tailfield ] . hh . rh := ligstack ;
  curlist . tailfield := ligstack ;
  100 : getnext ;
  If curcmd = 11 Then goto 101 ;
  If curcmd = 12 Then goto 101 ;
  If curcmd = 68 Then goto 101 ;
  xtoken ;
  If curcmd = 11 Then goto 101 ;
  If curcmd = 12 Then goto 101 ;
  If curcmd = 68 Then goto 101 ;
  If curcmd = 16 Then
    Begin
      scancharnum ;
      curchr := curval ;
      goto 101 ;
    End ;
  If curcmd = 65 Then bchar := 256 ;
  curr := bchar ;
  ligstack := 0 ;
  goto 110 ;
  101 : mains := eqtb [ 4751 + curchr ] . hh . rh ;
  If mains = 1000 Then curlist . auxfield . hh . lh := 1000
  Else If mains < 1000 Then
         Begin
           If mains > 0 Then curlist . auxfield . hh . lh := mains ;
         End
  Else If curlist . auxfield . hh . lh < 1000 Then curlist . auxfield . hh . lh := 1000
  Else curlist . auxfield . hh . lh := mains ;
  Begin
    ligstack := avail ;
    If ligstack = 0 Then ligstack := getavail
    Else
      Begin
        avail := mem [ ligstack ] . hh . rh ;
        mem [ ligstack ] . hh . rh := 0 ;
      End ;
  End ;
  mem [ ligstack ] . hh . b0 := mainf ;
  curr := curchr + 0 ;
  mem [ ligstack ] . hh . b1 := curr ;
  If curr = falsebchar Then curr := 256 ;
  110 : If ( ( maini . b2 - 0 ) Mod 4 ) <> 1 Then goto 80 ;
  If curr = 256 Then goto 80 ;
  maink := ligkernbase [ mainf ] + maini . b3 ;
  mainj := fontinfo [ maink ] . qqqq ;
  If mainj . b0 <= 128 Then goto 112 ;
  maink := ligkernbase [ mainf ] + 256 * mainj . b2 + mainj . b3 + 32768 - 256 * ( 128 ) ;
  111 : mainj := fontinfo [ maink ] . qqqq ;
  112 : If mainj . b1 = curr Then If mainj . b0 <= 128 Then
                                    Begin
                                      If mainj . b2 >= 128 Then
                                        Begin
                                          If curl < 256 Then
                                            Begin
                                              If mem [ curq ] . hh . rh > 0 Then If mem [ curlist . tailfield ] . hh . b1 = hyphenchar [ mainf ] + 0 Then insdisc := true ;
                                              If ligaturepresent Then
                                                Begin
                                                  mainp := newligature ( mainf , curl , mem [ curq ] . hh . rh ) ;
                                                  If lfthit Then
                                                    Begin
                                                      mem [ mainp ] . hh . b1 := 2 ;
                                                      lfthit := false ;
                                                    End ;
                                                  If rthit Then If ligstack = 0 Then
                                                                  Begin
                                                                    mem [ mainp ] . hh . b1 := mem [ mainp ] . hh . b1 + 1 ;
                                                                    rthit := false ;
                                                                  End ;
                                                  mem [ curq ] . hh . rh := mainp ;
                                                  curlist . tailfield := mainp ;
                                                  ligaturepresent := false ;
                                                End ;
                                              If insdisc Then
                                                Begin
                                                  insdisc := false ;
                                                  If curlist . modefield > 0 Then
                                                    Begin
                                                      mem [ curlist . tailfield ] . hh . rh := newdisc ;
                                                      curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
                                                    End ;
                                                End ;
                                            End ;
                                          Begin
                                            mem [ curlist . tailfield ] . hh . rh := newkern ( fontinfo [ kernbase [ mainf ] + 256 * mainj . b2 + mainj . b3 ] . int ) ;
                                            curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
                                          End ;
                                          goto 90 ;
                                        End ;
                                      If curl = 256 Then lfthit := true
                                      Else If ligstack = 0 Then rthit := true ;
                                      Begin
                                        If interrupt <> 0 Then pauseforinstructions ;
                                      End ;
                                      Case mainj . b2 Of 
                                        1 , 5 :
                                                Begin
                                                  curl := mainj . b3 ;
                                                  maini := fontinfo [ charbase [ mainf ] + curl ] . qqqq ;
                                                  ligaturepresent := true ;
                                                End ;
                                        2 , 6 :
                                                Begin
                                                  curr := mainj . b3 ;
                                                  If ligstack = 0 Then
                                                    Begin
                                                      ligstack := newligitem ( curr ) ;
                                                      bchar := 256 ;
                                                    End
                                                  Else If ( ligstack >= himemmin ) Then
                                                         Begin
                                                           mainp := ligstack ;
                                                           ligstack := newligitem ( curr ) ;
                                                           mem [ ligstack + 1 ] . hh . rh := mainp ;
                                                         End
                                                  Else mem [ ligstack ] . hh . b1 := curr ;
                                                End ;
                                        3 :
                                            Begin
                                              curr := mainj . b3 ;
                                              mainp := ligstack ;
                                              ligstack := newligitem ( curr ) ;
                                              mem [ ligstack ] . hh . rh := mainp ;
                                            End ;
                                        7 , 11 :
                                                 Begin
                                                   If curl < 256 Then
                                                     Begin
                                                       If mem [ curq ] . hh . rh > 0 Then If mem [ curlist . tailfield ] . hh . b1 = hyphenchar [ mainf ] + 0 Then insdisc := true ;
                                                       If ligaturepresent Then
                                                         Begin
                                                           mainp := newligature ( mainf , curl , mem [ curq ] . hh . rh ) ;
                                                           If lfthit Then
                                                             Begin
                                                               mem [ mainp ] . hh . b1 := 2 ;
                                                               lfthit := false ;
                                                             End ;
                                                           If false Then If ligstack = 0 Then
                                                                           Begin
                                                                             mem [ mainp ] . hh . b1 := mem [ mainp ] . hh . b1 + 1 ;
                                                                             rthit := false ;
                                                                           End ;
                                                           mem [ curq ] . hh . rh := mainp ;
                                                           curlist . tailfield := mainp ;
                                                           ligaturepresent := false ;
                                                         End ;
                                                       If insdisc Then
                                                         Begin
                                                           insdisc := false ;
                                                           If curlist . modefield > 0 Then
                                                             Begin
                                                               mem [ curlist . tailfield ] . hh . rh := newdisc ;
                                                               curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
                                                             End ;
                                                         End ;
                                                     End ;
                                                   curq := curlist . tailfield ;
                                                   curl := mainj . b3 ;
                                                   maini := fontinfo [ charbase [ mainf ] + curl ] . qqqq ;
                                                   ligaturepresent := true ;
                                                 End ;
                                        others :
                                                 Begin
                                                   curl := mainj . b3 ;
                                                   ligaturepresent := true ;
                                                   If ligstack = 0 Then goto 80
                                                   Else goto 91 ;
                                                 End
                                      End ;
                                      If mainj . b2 > 4 Then If mainj . b2 <> 7 Then goto 80 ;
                                      If curl < 256 Then goto 110 ;
                                      maink := bcharlabel [ mainf ] ;
                                      goto 111 ;
                                    End ;
  If mainj . b0 = 0 Then maink := maink + 1
  Else
    Begin
      If mainj . b0 >= 128 Then goto 80 ;
      maink := maink + mainj . b0 + 1 ;
    End ;
  goto 111 ;
  95 : mainp := mem [ ligstack + 1 ] . hh . rh ;
  If mainp > 0 Then
    Begin
      mem [ curlist . tailfield ] . hh . rh := mainp ;
      curlist . tailfield := mem [ curlist . tailfield ] . hh . rh ;
    End ;
  tempptr := ligstack ;
  ligstack := mem [ tempptr ] . hh . rh ;
  freenode ( tempptr , 2 ) ;
  maini := fontinfo [ charbase [ mainf ] + curl ] . qqqq ;
  ligaturepresent := true ;
  If ligstack = 0 Then If mainp > 0 Then goto 100
  Else curr := bchar
  Else curr := mem [ ligstack ] . hh . b1 ;
  goto 110 ;
  120 : If eqtb [ 2894 ] . hh . rh = 0 Then
          Begin
            Begin
              mainp := fontglue [ eqtb [ 3934 ] . hh . rh ] ;
              If mainp = 0 Then
                Begin
                  mainp := newspec ( 0 ) ;
                  maink := parambase [ eqtb [ 3934 ] . hh . rh ] + 2 ;
                  mem [ mainp + 1 ] . int := fontinfo [ maink ] . int ;
                  mem [ mainp + 2 ] . int := fontinfo [ maink + 1 ] . int ;
                  mem [ mainp + 3 ] . int := fontinfo [ maink + 2 ] . int ;
                  fontglue [ eqtb [ 3934 ] . hh . rh ] := mainp ;
                End ;
            End ;
            tempptr := newglue ( mainp ) ;
          End
        Else tempptr := newparamglue ( 12 ) ;
  mem [ curlist . tailfield ] . hh . rh := tempptr ;
  curlist . tailfield := tempptr ;
  goto 60 ;
  10 :
End ;
Procedure giveerrhelp ;
Begin
  tokenshow ( eqtb [ 3421 ] . hh . rh ) ;
End ;
Function openfmtfile : boolean ;

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
      If wopenin ( fmtfile ) Then goto 40 ;
      packbufferedname ( 11 , curinput . locfield , j - 1 ) ;
      If wopenin ( fmtfile ) Then goto 40 ; ;
      writeln ( termout , 'Sorry, I can''t find that format;' , ' will try PLAIN.' ) ;
      break ( termout ) ;
    End ;
  packbufferedname ( 16 , 1 , 0 ) ;
  If Not wopenin ( fmtfile ) Then
    Begin ;
      writeln ( termout , 'I can''t find the PLAIN format file!' ) ;
      openfmtfile := false ;
      goto 10 ;
    End ;
  40 : curinput . locfield := j ;
  openfmtfile := true ;
  10 :
End ;
Function loadfmtfile : boolean ;

Label 6666 , 10 ;

Var j , k : integer ;
  p , q : halfword ;
  x : integer ;
  w : fourquarters ;
Begin
  x := fmtfile ^ . int ;
  If x <> 117275187 Then goto 6666 ;
  Begin
    get ( fmtfile ) ;
    x := fmtfile ^ . int ;
  End ;
  If x <> 0 Then goto 6666 ;
  Begin
    get ( fmtfile ) ;
    x := fmtfile ^ . int ;
  End ;
  If x <> 30000 Then goto 6666 ;
  Begin
    get ( fmtfile ) ;
    x := fmtfile ^ . int ;
  End ;
  If x <> 6106 Then goto 6666 ;
  Begin
    get ( fmtfile ) ;
    x := fmtfile ^ . int ;
  End ;
  If x <> 1777 Then goto 6666 ;
  Begin
    get ( fmtfile ) ;
    x := fmtfile ^ . int ;
  End ;
  If x <> 307 Then goto 6666 ;
  Begin
    Begin
      get ( fmtfile ) ;
      x := fmtfile ^ . int ;
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
      get ( fmtfile ) ;
      x := fmtfile ^ . int ;
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
        get ( fmtfile ) ;
        x := fmtfile ^ . int ;
      End ;
      If ( x < 0 ) Or ( x > poolptr ) Then goto 6666
      Else strstart [ k ] := x ;
    End ;
  k := 0 ;
  While k + 4 < poolptr Do
    Begin
      Begin
        get ( fmtfile ) ;
        w := fmtfile ^ . qqqq ;
      End ;
      strpool [ k ] := w . b0 - 0 ;
      strpool [ k + 1 ] := w . b1 - 0 ;
      strpool [ k + 2 ] := w . b2 - 0 ;
      strpool [ k + 3 ] := w . b3 - 0 ;
      k := k + 4 ;
    End ;
  k := poolptr - 4 ;
  Begin
    get ( fmtfile ) ;
    w := fmtfile ^ . qqqq ;
  End ;
  strpool [ k ] := w . b0 - 0 ;
  strpool [ k + 1 ] := w . b1 - 0 ;
  strpool [ k + 2 ] := w . b2 - 0 ;
  strpool [ k + 3 ] := w . b3 - 0 ;
  initstrptr := strptr ;
  initpoolptr := poolptr ;
  Begin
    Begin
      get ( fmtfile ) ;
      x := fmtfile ^ . int ;
    End ;
    If ( x < 1019 ) Or ( x > 29986 ) Then goto 6666
    Else lomemmax := x ;
  End ;
  Begin
    Begin
      get ( fmtfile ) ;
      x := fmtfile ^ . int ;
    End ;
    If ( x < 20 ) Or ( x > lomemmax ) Then goto 6666
    Else rover := x ;
  End ;
  p := 0 ;
  q := rover ;
  Repeat
    For k := p To q + 1 Do
      Begin
        get ( fmtfile ) ;
        mem [ k ] := fmtfile ^ ;
      End ;
    p := q + mem [ q ] . hh . lh ;
    If ( p > lomemmax ) Or ( ( q >= mem [ q + 1 ] . hh . rh ) And ( mem [ q + 1 ] . hh . rh <> rover ) ) Then goto 6666 ;
    q := mem [ q + 1 ] . hh . rh ;
  Until q = rover ;
  For k := p To lomemmax Do
    Begin
      get ( fmtfile ) ;
      mem [ k ] := fmtfile ^ ;
    End ;
  If memmin < - 2 Then
    Begin
      p := mem [ rover + 1 ] . hh . lh ;
      q := memmin + 1 ;
      mem [ memmin ] . hh . rh := 0 ;
      mem [ memmin ] . hh . lh := 0 ;
      mem [ p + 1 ] . hh . rh := q ;
      mem [ rover + 1 ] . hh . lh := q ;
      mem [ q + 1 ] . hh . rh := rover ;
      mem [ q + 1 ] . hh . lh := p ;
      mem [ q ] . hh . rh := 65535 ;
      mem [ q ] . hh . lh := - 0 - q ;
    End ;
  Begin
    Begin
      get ( fmtfile ) ;
      x := fmtfile ^ . int ;
    End ;
    If ( x < lomemmax + 1 ) Or ( x > 29987 ) Then goto 6666
    Else himemmin := x ;
  End ;
  Begin
    Begin
      get ( fmtfile ) ;
      x := fmtfile ^ . int ;
    End ;
    If ( x < 0 ) Or ( x > 30000 ) Then goto 6666
    Else avail := x ;
  End ;
  memend := 30000 ;
  For k := himemmin To memend Do
    Begin
      get ( fmtfile ) ;
      mem [ k ] := fmtfile ^ ;
    End ;
  Begin
    get ( fmtfile ) ;
    varused := fmtfile ^ . int ;
  End ;
  Begin
    get ( fmtfile ) ;
    dynused := fmtfile ^ . int ;
  End ;
  k := 1 ;
  Repeat
    Begin
      get ( fmtfile ) ;
      x := fmtfile ^ . int ;
    End ;
    If ( x < 1 ) Or ( k + x > 6107 ) Then goto 6666 ;
    For j := k To k + x - 1 Do
      Begin
        get ( fmtfile ) ;
        eqtb [ j ] := fmtfile ^ ;
      End ;
    k := k + x ;
    Begin
      get ( fmtfile ) ;
      x := fmtfile ^ . int ;
    End ;
    If ( x < 0 ) Or ( k + x > 6107 ) Then goto 6666 ;
    For j := k To k + x - 1 Do
      eqtb [ j ] := eqtb [ k - 1 ] ;
    k := k + x ;
  Until k > 6106 ;
  Begin
    Begin
      get ( fmtfile ) ;
      x := fmtfile ^ . int ;
    End ;
    If ( x < 514 ) Or ( x > 2614 ) Then goto 6666
    Else parloc := x ;
  End ;
  partoken := 4095 + parloc ;
  Begin
    Begin
      get ( fmtfile ) ;
      x := fmtfile ^ . int ;
    End ;
    If ( x < 514 ) Or ( x > 2614 ) Then goto 6666
    Else writeloc := x ;
  End ;
  Begin
    Begin
      get ( fmtfile ) ;
      x := fmtfile ^ . int ;
    End ;
    If ( x < 514 ) Or ( x > 2614 ) Then goto 6666
    Else hashused := x ;
  End ;
  p := 513 ;
  Repeat
    Begin
      Begin
        get ( fmtfile ) ;
        x := fmtfile ^ . int ;
      End ;
      If ( x < p + 1 ) Or ( x > hashused ) Then goto 6666
      Else p := x ;
    End ;
    Begin
      get ( fmtfile ) ;
      hash [ p ] := fmtfile ^ . hh ;
    End ;
  Until p = hashused ;
  For p := hashused + 1 To 2880 Do
    Begin
      get ( fmtfile ) ;
      hash [ p ] := fmtfile ^ . hh ;
    End ;
  Begin
    get ( fmtfile ) ;
    cscount := fmtfile ^ . int ;
  End ;
  Begin
    Begin
      get ( fmtfile ) ;
      x := fmtfile ^ . int ;
    End ;
    If x < 7 Then goto 6666 ;
    If x > fontmemsize Then
      Begin ;
        writeln ( termout , '---! Must increase the ' , 'font mem size' ) ;
        goto 6666 ;
      End
    Else fmemptr := x ;
  End ;
  For k := 0 To fmemptr - 1 Do
    Begin
      get ( fmtfile ) ;
      fontinfo [ k ] := fmtfile ^ ;
    End ;
  Begin
    Begin
      get ( fmtfile ) ;
      x := fmtfile ^ . int ;
    End ;
    If x < 0 Then goto 6666 ;
    If x > fontmax Then
      Begin ;
        writeln ( termout , '---! Must increase the ' , 'font max' ) ;
        goto 6666 ;
      End
    Else fontptr := x ;
  End ;
  For k := 0 To fontptr Do
    Begin
      Begin
        get ( fmtfile ) ;
        fontcheck [ k ] := fmtfile ^ . qqqq ;
      End ;
      Begin
        get ( fmtfile ) ;
        fontsize [ k ] := fmtfile ^ . int ;
      End ;
      Begin
        get ( fmtfile ) ;
        fontdsize [ k ] := fmtfile ^ . int ;
      End ;
      Begin
        Begin
          get ( fmtfile ) ;
          x := fmtfile ^ . int ;
        End ;
        If ( x < 0 ) Or ( x > 65535 ) Then goto 6666
        Else fontparams [ k ] := x ;
      End ;
      Begin
        get ( fmtfile ) ;
        hyphenchar [ k ] := fmtfile ^ . int ;
      End ;
      Begin
        get ( fmtfile ) ;
        skewchar [ k ] := fmtfile ^ . int ;
      End ;
      Begin
        Begin
          get ( fmtfile ) ;
          x := fmtfile ^ . int ;
        End ;
        If ( x < 0 ) Or ( x > strptr ) Then goto 6666
        Else fontname [ k ] := x ;
      End ;
      Begin
        Begin
          get ( fmtfile ) ;
          x := fmtfile ^ . int ;
        End ;
        If ( x < 0 ) Or ( x > strptr ) Then goto 6666
        Else fontarea [ k ] := x ;
      End ;
      Begin
        Begin
          get ( fmtfile ) ;
          x := fmtfile ^ . int ;
        End ;
        If ( x < 0 ) Or ( x > 255 ) Then goto 6666
        Else fontbc [ k ] := x ;
      End ;
      Begin
        Begin
          get ( fmtfile ) ;
          x := fmtfile ^ . int ;
        End ;
        If ( x < 0 ) Or ( x > 255 ) Then goto 6666
        Else fontec [ k ] := x ;
      End ;
      Begin
        get ( fmtfile ) ;
        charbase [ k ] := fmtfile ^ . int ;
      End ;
      Begin
        get ( fmtfile ) ;
        widthbase [ k ] := fmtfile ^ . int ;
      End ;
      Begin
        get ( fmtfile ) ;
        heightbase [ k ] := fmtfile ^ . int ;
      End ;
      Begin
        get ( fmtfile ) ;
        depthbase [ k ] := fmtfile ^ . int ;
      End ;
      Begin
        get ( fmtfile ) ;
        italicbase [ k ] := fmtfile ^ . int ;
      End ;
      Begin
        get ( fmtfile ) ;
        ligkernbase [ k ] := fmtfile ^ . int ;
      End ;
      Begin
        get ( fmtfile ) ;
        kernbase [ k ] := fmtfile ^ . int ;
      End ;
      Begin
        get ( fmtfile ) ;
        extenbase [ k ] := fmtfile ^ . int ;
      End ;
      Begin
        get ( fmtfile ) ;
        parambase [ k ] := fmtfile ^ . int ;
      End ;
      Begin
        Begin
          get ( fmtfile ) ;
          x := fmtfile ^ . int ;
        End ;
        If ( x < 0 ) Or ( x > lomemmax ) Then goto 6666
        Else fontglue [ k ] := x ;
      End ;
      Begin
        Begin
          get ( fmtfile ) ;
          x := fmtfile ^ . int ;
        End ;
        If ( x < 0 ) Or ( x > fmemptr - 1 ) Then goto 6666
        Else bcharlabel [ k ] := x ;
      End ;
      Begin
        Begin
          get ( fmtfile ) ;
          x := fmtfile ^ . int ;
        End ;
        If ( x < 0 ) Or ( x > 256 ) Then goto 6666
        Else fontbchar [ k ] := x ;
      End ;
      Begin
        Begin
          get ( fmtfile ) ;
          x := fmtfile ^ . int ;
        End ;
        If ( x < 0 ) Or ( x > 256 ) Then goto 6666
        Else fontfalsebchar [ k ] := x ;
      End ;
    End ;
  Begin
    Begin
      get ( fmtfile ) ;
      x := fmtfile ^ . int ;
    End ;
    If ( x < 0 ) Or ( x > 307 ) Then goto 6666
    Else hyphcount := x ;
  End ;
  For k := 1 To hyphcount Do
    Begin
      Begin
        Begin
          get ( fmtfile ) ;
          x := fmtfile ^ . int ;
        End ;
        If ( x < 0 ) Or ( x > 307 ) Then goto 6666
        Else j := x ;
      End ;
      Begin
        Begin
          get ( fmtfile ) ;
          x := fmtfile ^ . int ;
        End ;
        If ( x < 0 ) Or ( x > strptr ) Then goto 6666
        Else hyphword [ j ] := x ;
      End ;
      Begin
        Begin
          get ( fmtfile ) ;
          x := fmtfile ^ . int ;
        End ;
        If ( x < 0 ) Or ( x > 65535 ) Then goto 6666
        Else hyphlist [ j ] := x ;
      End ;
    End ;
  Begin
    Begin
      get ( fmtfile ) ;
      x := fmtfile ^ . int ;
    End ;
    If x < 0 Then goto 6666 ;
    If x > triesize Then
      Begin ;
        writeln ( termout , '---! Must increase the ' , 'trie size' ) ;
        goto 6666 ;
      End
    Else j := x ;
  End ;
  triemax := j ;
  For k := 0 To j Do
    Begin
      get ( fmtfile ) ;
      trie [ k ] := fmtfile ^ . hh ;
    End ;
  Begin
    Begin
      get ( fmtfile ) ;
      x := fmtfile ^ . int ;
    End ;
    If x < 0 Then goto 6666 ;
    If x > trieopsize Then
      Begin ;
        writeln ( termout , '---! Must increase the ' , 'trie op size' ) ;
        goto 6666 ;
      End
    Else j := x ;
  End ;
  trieopptr := j ;
  For k := 1 To j Do
    Begin
      Begin
        Begin
          get ( fmtfile ) ;
          x := fmtfile ^ . int ;
        End ;
        If ( x < 0 ) Or ( x > 63 ) Then goto 6666
        Else hyfdistance [ k ] := x ;
      End ;
      Begin
        Begin
          get ( fmtfile ) ;
          x := fmtfile ^ . int ;
        End ;
        If ( x < 0 ) Or ( x > 63 ) Then goto 6666
        Else hyfnum [ k ] := x ;
      End ;
      Begin
        Begin
          get ( fmtfile ) ;
          x := fmtfile ^ . int ;
        End ;
        If ( x < 0 ) Or ( x > 255 ) Then goto 6666
        Else hyfnext [ k ] := x ;
      End ;
    End ;
  For k := 0 To 255 Do
    trieused [ k ] := 0 ;
  k := 256 ;
  While j > 0 Do
    Begin
      Begin
        Begin
          get ( fmtfile ) ;
          x := fmtfile ^ . int ;
        End ;
        If ( x < 0 ) Or ( x > k - 1 ) Then goto 6666
        Else k := x ;
      End ;
      Begin
        Begin
          get ( fmtfile ) ;
          x := fmtfile ^ . int ;
        End ;
        If ( x < 1 ) Or ( x > j ) Then goto 6666
        Else x := x ;
      End ;
      trieused [ k ] := x + 0 ;
      j := j - x ;
      opstart [ k ] := j - 0 ;
    End ;
  trienotready := false ;
  Begin
    Begin
      get ( fmtfile ) ;
      x := fmtfile ^ . int ;
    End ;
    If ( x < 0 ) Or ( x > 3 ) Then goto 6666
    Else interaction := x ;
  End ;
  Begin
    Begin
      get ( fmtfile ) ;
      x := fmtfile ^ . int ;
    End ;
    If ( x < 0 ) Or ( x > strptr ) Then goto 6666
    Else formatident := x ;
  End ;
  Begin
    get ( fmtfile ) ;
    x := fmtfile ^ . int ;
  End ;
  If ( x <> 69069 ) Or eof ( fmtfile ) Then goto 6666 ;
  loadfmtfile := true ;
  goto 10 ;
  6666 : ;
  writeln ( termout , '(Fatal format file error; I''m stymied)' ) ;
  loadfmtfile := false ;
  10 :
End ;
Procedure closefilesandterminate ;

Var k : integer ;
Begin
  For k := 0 To 15 Do
    If writeopen [ k ] Then aclose ( writefile [ k ] ) ; ;
  While curs > - 1 Do
    Begin
      If curs > 0 Then
        Begin
          dvibuf [ dviptr ] := 142 ;
          dviptr := dviptr + 1 ;
          If dviptr = dvilimit Then dviswap ;
        End
      Else
        Begin
          Begin
            dvibuf [ dviptr ] := 140 ;
            dviptr := dviptr + 1 ;
            If dviptr = dvilimit Then dviswap ;
          End ;
          totalpages := totalpages + 1 ;
        End ;
      curs := curs - 1 ;
    End ;
  If totalpages = 0 Then printnl ( 836 )
  Else
    Begin
      Begin
        dvibuf [ dviptr ] := 248 ;
        dviptr := dviptr + 1 ;
        If dviptr = dvilimit Then dviswap ;
      End ;
      dvifour ( lastbop ) ;
      lastbop := dvioffset + dviptr - 5 ;
      dvifour ( 25400000 ) ;
      dvifour ( 473628672 ) ;
      preparemag ;
      dvifour ( eqtb [ 5280 ] . int ) ;
      dvifour ( maxv ) ;
      dvifour ( maxh ) ;
      Begin
        dvibuf [ dviptr ] := maxpush Div 256 ;
        dviptr := dviptr + 1 ;
        If dviptr = dvilimit Then dviswap ;
      End ;
      Begin
        dvibuf [ dviptr ] := maxpush Mod 256 ;
        dviptr := dviptr + 1 ;
        If dviptr = dvilimit Then dviswap ;
      End ;
      Begin
        dvibuf [ dviptr ] := ( totalpages Div 256 ) Mod 256 ;
        dviptr := dviptr + 1 ;
        If dviptr = dvilimit Then dviswap ;
      End ;
      Begin
        dvibuf [ dviptr ] := totalpages Mod 256 ;
        dviptr := dviptr + 1 ;
        If dviptr = dvilimit Then dviswap ;
      End ;
      While fontptr > 0 Do
        Begin
          If fontused [ fontptr ] Then dvifontdef ( fontptr ) ;
          fontptr := fontptr - 1 ;
        End ;
      Begin
        dvibuf [ dviptr ] := 249 ;
        dviptr := dviptr + 1 ;
        If dviptr = dvilimit Then dviswap ;
      End ;
      dvifour ( lastbop ) ;
      Begin
        dvibuf [ dviptr ] := 2 ;
        dviptr := dviptr + 1 ;
        If dviptr = dvilimit Then dviswap ;
      End ;
      k := 4 + ( ( dvibufsize - dviptr ) Mod 4 ) ;
      While k > 0 Do
        Begin
          Begin
            dvibuf [ dviptr ] := 223 ;
            dviptr := dviptr + 1 ;
            If dviptr = dvilimit Then dviswap ;
          End ;
          k := k - 1 ;
        End ;
      If dvilimit = halfbuf Then writedvi ( halfbuf , dvibufsize - 1 ) ;
      If dviptr > 0 Then writedvi ( 0 , dviptr - 1 ) ;
      printnl ( 837 ) ;
      slowprint ( outputfilename ) ;
      print ( 286 ) ;
      printint ( totalpages ) ;
      print ( 838 ) ;
      If totalpages <> 1 Then printchar ( 115 ) ;
      print ( 839 ) ;
      printint ( dvioffset + dviptr ) ;
      print ( 840 ) ;
      bclose ( dvifile ) ;
    End ;
  If logopened Then
    Begin
      writeln ( logfile ) ;
      aclose ( logfile ) ;
      selector := selector - 2 ;
      If selector = 17 Then
        Begin
          printnl ( 1274 ) ;
          slowprint ( logname ) ;
          printchar ( 46 ) ;
        End ;
    End ;
End ;
Procedure finalcleanup ;

Label 10 ;

Var c : smallnumber ;
Begin
  c := curchr ;
  If jobname = 0 Then openlogfile ;
  While inputptr > 0 Do
    If curinput . statefield = 0 Then endtokenlist
    Else endfilereading ;
  While openparens > 0 Do
    Begin
      print ( 1275 ) ;
      openparens := openparens - 1 ;
    End ;
  If curlevel > 1 Then
    Begin
      printnl ( 40 ) ;
      printesc ( 1276 ) ;
      print ( 1277 ) ;
      printint ( curlevel - 1 ) ;
      printchar ( 41 ) ;
    End ;
  While condptr <> 0 Do
    Begin
      printnl ( 40 ) ;
      printesc ( 1276 ) ;
      print ( 1278 ) ;
      printcmdchr ( 105 , curif ) ;
      If ifline <> 0 Then
        Begin
          print ( 1279 ) ;
          printint ( ifline ) ;
        End ;
      print ( 1280 ) ;
      ifline := mem [ condptr + 1 ] . int ;
      curif := mem [ condptr ] . hh . b1 ;
      tempptr := condptr ;
      condptr := mem [ condptr ] . hh . rh ;
      freenode ( tempptr , 2 ) ;
    End ;
  If history <> 0 Then If ( ( history = 1 ) Or ( interaction < 3 ) ) Then If selector = 19 Then
                                                                            Begin
                                                                              selector := 17 ;
                                                                              printnl ( 1281 ) ;
                                                                              selector := 19 ;
                                                                            End ;
  If c = 1 Then
    Begin
      For c := 0 To 4 Do
        If curmark [ c ] <> 0 Then deletetokenref ( curmark [ c ] ) ;
      If lastglue <> 65535 Then deleteglueref ( lastglue ) ;
      storefmtfile ;
      goto 10 ;
      printnl ( 1282 ) ;
      goto 10 ;
    End ;
  10 :
End ;
Procedure initprim ;
Begin
  nonewcontrolsequence := false ;
  primitive ( 376 , 75 , 2882 ) ;
  primitive ( 377 , 75 , 2883 ) ;
  primitive ( 378 , 75 , 2884 ) ;
  primitive ( 379 , 75 , 2885 ) ;
  primitive ( 380 , 75 , 2886 ) ;
  primitive ( 381 , 75 , 2887 ) ;
  primitive ( 382 , 75 , 2888 ) ;
  primitive ( 383 , 75 , 2889 ) ;
  primitive ( 384 , 75 , 2890 ) ;
  primitive ( 385 , 75 , 2891 ) ;
  primitive ( 386 , 75 , 2892 ) ;
  primitive ( 387 , 75 , 2893 ) ;
  primitive ( 388 , 75 , 2894 ) ;
  primitive ( 389 , 75 , 2895 ) ;
  primitive ( 390 , 75 , 2896 ) ;
  primitive ( 391 , 76 , 2897 ) ;
  primitive ( 392 , 76 , 2898 ) ;
  primitive ( 393 , 76 , 2899 ) ;
  primitive ( 398 , 72 , 3413 ) ;
  primitive ( 399 , 72 , 3414 ) ;
  primitive ( 400 , 72 , 3415 ) ;
  primitive ( 401 , 72 , 3416 ) ;
  primitive ( 402 , 72 , 3417 ) ;
  primitive ( 403 , 72 , 3418 ) ;
  primitive ( 404 , 72 , 3419 ) ;
  primitive ( 405 , 72 , 3420 ) ;
  primitive ( 406 , 72 , 3421 ) ;
  primitive ( 420 , 73 , 5263 ) ;
  primitive ( 421 , 73 , 5264 ) ;
  primitive ( 422 , 73 , 5265 ) ;
  primitive ( 423 , 73 , 5266 ) ;
  primitive ( 424 , 73 , 5267 ) ;
  primitive ( 425 , 73 , 5268 ) ;
  primitive ( 426 , 73 , 5269 ) ;
  primitive ( 427 , 73 , 5270 ) ;
  primitive ( 428 , 73 , 5271 ) ;
  primitive ( 429 , 73 , 5272 ) ;
  primitive ( 430 , 73 , 5273 ) ;
  primitive ( 431 , 73 , 5274 ) ;
  primitive ( 432 , 73 , 5275 ) ;
  primitive ( 433 , 73 , 5276 ) ;
  primitive ( 434 , 73 , 5277 ) ;
  primitive ( 435 , 73 , 5278 ) ;
  primitive ( 436 , 73 , 5279 ) ;
  primitive ( 437 , 73 , 5280 ) ;
  primitive ( 438 , 73 , 5281 ) ;
  primitive ( 439 , 73 , 5282 ) ;
  primitive ( 440 , 73 , 5283 ) ;
  primitive ( 441 , 73 , 5284 ) ;
  primitive ( 442 , 73 , 5285 ) ;
  primitive ( 443 , 73 , 5286 ) ;
  primitive ( 444 , 73 , 5287 ) ;
  primitive ( 445 , 73 , 5288 ) ;
  primitive ( 446 , 73 , 5289 ) ;
  primitive ( 447 , 73 , 5290 ) ;
  primitive ( 448 , 73 , 5291 ) ;
  primitive ( 449 , 73 , 5292 ) ;
  primitive ( 450 , 73 , 5293 ) ;
  primitive ( 451 , 73 , 5294 ) ;
  primitive ( 452 , 73 , 5295 ) ;
  primitive ( 453 , 73 , 5296 ) ;
  primitive ( 454 , 73 , 5297 ) ;
  primitive ( 455 , 73 , 5298 ) ;
  primitive ( 456 , 73 , 5299 ) ;
  primitive ( 457 , 73 , 5300 ) ;
  primitive ( 458 , 73 , 5301 ) ;
  primitive ( 459 , 73 , 5302 ) ;
  primitive ( 460 , 73 , 5303 ) ;
  primitive ( 461 , 73 , 5304 ) ;
  primitive ( 462 , 73 , 5305 ) ;
  primitive ( 463 , 73 , 5306 ) ;
  primitive ( 464 , 73 , 5307 ) ;
  primitive ( 465 , 73 , 5308 ) ;
  primitive ( 466 , 73 , 5309 ) ;
  primitive ( 467 , 73 , 5310 ) ;
  primitive ( 468 , 73 , 5311 ) ;
  primitive ( 469 , 73 , 5312 ) ;
  primitive ( 470 , 73 , 5313 ) ;
  primitive ( 471 , 73 , 5314 ) ;
  primitive ( 472 , 73 , 5315 ) ;
  primitive ( 473 , 73 , 5316 ) ;
  primitive ( 474 , 73 , 5317 ) ;
  primitive ( 478 , 74 , 5830 ) ;
  primitive ( 479 , 74 , 5831 ) ;
  primitive ( 480 , 74 , 5832 ) ;
  primitive ( 481 , 74 , 5833 ) ;
  primitive ( 482 , 74 , 5834 ) ;
  primitive ( 483 , 74 , 5835 ) ;
  primitive ( 484 , 74 , 5836 ) ;
  primitive ( 485 , 74 , 5837 ) ;
  primitive ( 486 , 74 , 5838 ) ;
  primitive ( 487 , 74 , 5839 ) ;
  primitive ( 488 , 74 , 5840 ) ;
  primitive ( 489 , 74 , 5841 ) ;
  primitive ( 490 , 74 , 5842 ) ;
  primitive ( 491 , 74 , 5843 ) ;
  primitive ( 492 , 74 , 5844 ) ;
  primitive ( 493 , 74 , 5845 ) ;
  primitive ( 494 , 74 , 5846 ) ;
  primitive ( 495 , 74 , 5847 ) ;
  primitive ( 496 , 74 , 5848 ) ;
  primitive ( 497 , 74 , 5849 ) ;
  primitive ( 498 , 74 , 5850 ) ;
  primitive ( 32 , 64 , 0 ) ;
  primitive ( 47 , 44 , 0 ) ;
  primitive ( 508 , 45 , 0 ) ;
  primitive ( 509 , 90 , 0 ) ;
  primitive ( 510 , 40 , 0 ) ;
  primitive ( 511 , 41 , 0 ) ;
  primitive ( 512 , 61 , 0 ) ;
  primitive ( 513 , 16 , 0 ) ;
  primitive ( 504 , 107 , 0 ) ;
  primitive ( 514 , 15 , 0 ) ;
  primitive ( 515 , 92 , 0 ) ;
  primitive ( 505 , 67 , 0 ) ;
  primitive ( 516 , 62 , 0 ) ;
  hash [ 2616 ] . rh := 516 ;
  eqtb [ 2616 ] := eqtb [ curval ] ;
  primitive ( 517 , 102 , 0 ) ;
  primitive ( 518 , 88 , 0 ) ;
  primitive ( 519 , 77 , 0 ) ;
  primitive ( 520 , 32 , 0 ) ;
  primitive ( 521 , 36 , 0 ) ;
  primitive ( 522 , 39 , 0 ) ;
  primitive ( 330 , 37 , 0 ) ;
  primitive ( 351 , 18 , 0 ) ;
  primitive ( 523 , 46 , 0 ) ;
  primitive ( 524 , 17 , 0 ) ;
  primitive ( 525 , 54 , 0 ) ;
  primitive ( 526 , 91 , 0 ) ;
  primitive ( 527 , 34 , 0 ) ;
  primitive ( 528 , 65 , 0 ) ;
  primitive ( 529 , 103 , 0 ) ;
  primitive ( 335 , 55 , 0 ) ;
  primitive ( 530 , 63 , 0 ) ;
  primitive ( 408 , 84 , 0 ) ;
  primitive ( 531 , 42 , 0 ) ;
  primitive ( 532 , 80 , 0 ) ;
  primitive ( 533 , 66 , 0 ) ;
  primitive ( 534 , 96 , 0 ) ;
  primitive ( 535 , 0 , 256 ) ;
  hash [ 2621 ] . rh := 535 ;
  eqtb [ 2621 ] := eqtb [ curval ] ;
  primitive ( 536 , 98 , 0 ) ;
  primitive ( 537 , 109 , 0 ) ;
  primitive ( 407 , 71 , 0 ) ;
  primitive ( 352 , 38 , 0 ) ;
  primitive ( 538 , 33 , 0 ) ;
  primitive ( 539 , 56 , 0 ) ;
  primitive ( 540 , 35 , 0 ) ;
  primitive ( 597 , 13 , 256 ) ;
  parloc := curval ;
  partoken := 4095 + parloc ;
  primitive ( 629 , 104 , 0 ) ;
  primitive ( 630 , 104 , 1 ) ;
  primitive ( 631 , 110 , 0 ) ;
  primitive ( 632 , 110 , 1 ) ;
  primitive ( 633 , 110 , 2 ) ;
  primitive ( 634 , 110 , 3 ) ;
  primitive ( 635 , 110 , 4 ) ;
  primitive ( 476 , 89 , 0 ) ;
  primitive ( 500 , 89 , 1 ) ;
  primitive ( 395 , 89 , 2 ) ;
  primitive ( 396 , 89 , 3 ) ;
  primitive ( 668 , 79 , 102 ) ;
  primitive ( 669 , 79 , 1 ) ;
  primitive ( 670 , 82 , 0 ) ;
  primitive ( 671 , 82 , 1 ) ;
  primitive ( 672 , 83 , 1 ) ;
  primitive ( 673 , 83 , 3 ) ;
  primitive ( 674 , 83 , 2 ) ;
  primitive ( 675 , 70 , 0 ) ;
  primitive ( 676 , 70 , 1 ) ;
  primitive ( 677 , 70 , 2 ) ;
  primitive ( 678 , 70 , 3 ) ;
  primitive ( 679 , 70 , 4 ) ;
  primitive ( 735 , 108 , 0 ) ;
  primitive ( 736 , 108 , 1 ) ;
  primitive ( 737 , 108 , 2 ) ;
  primitive ( 738 , 108 , 3 ) ;
  primitive ( 739 , 108 , 4 ) ;
  primitive ( 740 , 108 , 5 ) ;
  primitive ( 756 , 105 , 0 ) ;
  primitive ( 757 , 105 , 1 ) ;
  primitive ( 758 , 105 , 2 ) ;
  primitive ( 759 , 105 , 3 ) ;
  primitive ( 760 , 105 , 4 ) ;
  primitive ( 761 , 105 , 5 ) ;
  primitive ( 762 , 105 , 6 ) ;
  primitive ( 763 , 105 , 7 ) ;
  primitive ( 764 , 105 , 8 ) ;
  primitive ( 765 , 105 , 9 ) ;
  primitive ( 766 , 105 , 10 ) ;
  primitive ( 767 , 105 , 11 ) ;
  primitive ( 768 , 105 , 12 ) ;
  primitive ( 769 , 105 , 13 ) ;
  primitive ( 770 , 105 , 14 ) ;
  primitive ( 771 , 105 , 15 ) ;
  primitive ( 772 , 105 , 16 ) ;
  primitive ( 773 , 106 , 2 ) ;
  hash [ 2618 ] . rh := 773 ;
  eqtb [ 2618 ] := eqtb [ curval ] ;
  primitive ( 774 , 106 , 4 ) ;
  primitive ( 775 , 106 , 3 ) ;
  primitive ( 800 , 87 , 0 ) ;
  hash [ 2624 ] . rh := 800 ;
  eqtb [ 2624 ] := eqtb [ curval ] ;
  primitive ( 897 , 4 , 256 ) ;
  primitive ( 898 , 5 , 257 ) ;
  hash [ 2615 ] . rh := 898 ;
  eqtb [ 2615 ] := eqtb [ curval ] ;
  primitive ( 899 , 5 , 258 ) ;
  hash [ 2619 ] . rh := 900 ;
  hash [ 2620 ] . rh := 900 ;
  eqtb [ 2620 ] . hh . b0 := 9 ;
  eqtb [ 2620 ] . hh . rh := 29989 ;
  eqtb [ 2620 ] . hh . b1 := 1 ;
  eqtb [ 2619 ] := eqtb [ 2620 ] ;
  eqtb [ 2619 ] . hh . b0 := 115 ;
  primitive ( 969 , 81 , 0 ) ;
  primitive ( 970 , 81 , 1 ) ;
  primitive ( 971 , 81 , 2 ) ;
  primitive ( 972 , 81 , 3 ) ;
  primitive ( 973 , 81 , 4 ) ;
  primitive ( 974 , 81 , 5 ) ;
  primitive ( 975 , 81 , 6 ) ;
  primitive ( 976 , 81 , 7 ) ;
  primitive ( 1024 , 14 , 0 ) ;
  primitive ( 1025 , 14 , 1 ) ;
  primitive ( 1026 , 26 , 4 ) ;
  primitive ( 1027 , 26 , 0 ) ;
  primitive ( 1028 , 26 , 1 ) ;
  primitive ( 1029 , 26 , 2 ) ;
  primitive ( 1030 , 26 , 3 ) ;
  primitive ( 1031 , 27 , 4 ) ;
  primitive ( 1032 , 27 , 0 ) ;
  primitive ( 1033 , 27 , 1 ) ;
  primitive ( 1034 , 27 , 2 ) ;
  primitive ( 1035 , 27 , 3 ) ;
  primitive ( 336 , 28 , 5 ) ;
  primitive ( 340 , 29 , 1 ) ;
  primitive ( 342 , 30 , 99 ) ;
  primitive ( 1053 , 21 , 1 ) ;
  primitive ( 1054 , 21 , 0 ) ;
  primitive ( 1055 , 22 , 1 ) ;
  primitive ( 1056 , 22 , 0 ) ;
  primitive ( 409 , 20 , 0 ) ;
  primitive ( 1057 , 20 , 1 ) ;
  primitive ( 1058 , 20 , 2 ) ;
  primitive ( 964 , 20 , 3 ) ;
  primitive ( 1059 , 20 , 4 ) ;
  primitive ( 966 , 20 , 5 ) ;
  primitive ( 1060 , 20 , 106 ) ;
  primitive ( 1061 , 31 , 99 ) ;
  primitive ( 1062 , 31 , 100 ) ;
  primitive ( 1063 , 31 , 101 ) ;
  primitive ( 1064 , 31 , 102 ) ;
  primitive ( 1079 , 43 , 1 ) ;
  primitive ( 1080 , 43 , 0 ) ;
  primitive ( 1089 , 25 , 12 ) ;
  primitive ( 1090 , 25 , 11 ) ;
  primitive ( 1091 , 25 , 10 ) ;
  primitive ( 1092 , 23 , 0 ) ;
  primitive ( 1093 , 23 , 1 ) ;
  primitive ( 1094 , 24 , 0 ) ;
  primitive ( 1095 , 24 , 1 ) ;
  primitive ( 45 , 47 , 1 ) ;
  primitive ( 349 , 47 , 0 ) ;
  primitive ( 1126 , 48 , 0 ) ;
  primitive ( 1127 , 48 , 1 ) ;
  primitive ( 865 , 50 , 16 ) ;
  primitive ( 866 , 50 , 17 ) ;
  primitive ( 867 , 50 , 18 ) ;
  primitive ( 868 , 50 , 19 ) ;
  primitive ( 869 , 50 , 20 ) ;
  primitive ( 870 , 50 , 21 ) ;
  primitive ( 871 , 50 , 22 ) ;
  primitive ( 872 , 50 , 23 ) ;
  primitive ( 874 , 50 , 26 ) ;
  primitive ( 873 , 50 , 27 ) ;
  primitive ( 1128 , 51 , 0 ) ;
  primitive ( 877 , 51 , 1 ) ;
  primitive ( 878 , 51 , 2 ) ;
  primitive ( 860 , 53 , 0 ) ;
  primitive ( 861 , 53 , 2 ) ;
  primitive ( 862 , 53 , 4 ) ;
  primitive ( 863 , 53 , 6 ) ;
  primitive ( 1146 , 52 , 0 ) ;
  primitive ( 1147 , 52 , 1 ) ;
  primitive ( 1148 , 52 , 2 ) ;
  primitive ( 1149 , 52 , 3 ) ;
  primitive ( 1150 , 52 , 4 ) ;
  primitive ( 1151 , 52 , 5 ) ;
  primitive ( 875 , 49 , 30 ) ;
  primitive ( 876 , 49 , 31 ) ;
  hash [ 2617 ] . rh := 876 ;
  eqtb [ 2617 ] := eqtb [ curval ] ;
  primitive ( 1170 , 93 , 1 ) ;
  primitive ( 1171 , 93 , 2 ) ;
  primitive ( 1172 , 93 , 4 ) ;
  primitive ( 1173 , 97 , 0 ) ;
  primitive ( 1174 , 97 , 1 ) ;
  primitive ( 1175 , 97 , 2 ) ;
  primitive ( 1176 , 97 , 3 ) ;
  primitive ( 1190 , 94 , 0 ) ;
  primitive ( 1191 , 94 , 1 ) ;
  primitive ( 1192 , 95 , 0 ) ;
  primitive ( 1193 , 95 , 1 ) ;
  primitive ( 1194 , 95 , 2 ) ;
  primitive ( 1195 , 95 , 3 ) ;
  primitive ( 1196 , 95 , 4 ) ;
  primitive ( 1197 , 95 , 5 ) ;
  primitive ( 1198 , 95 , 6 ) ;
  primitive ( 415 , 85 , 3983 ) ;
  primitive ( 419 , 85 , 5007 ) ;
  primitive ( 416 , 85 , 4239 ) ;
  primitive ( 417 , 85 , 4495 ) ;
  primitive ( 418 , 85 , 4751 ) ;
  primitive ( 477 , 85 , 5574 ) ;
  primitive ( 412 , 86 , 3935 ) ;
  primitive ( 413 , 86 , 3951 ) ;
  primitive ( 414 , 86 , 3967 ) ;
  primitive ( 940 , 99 , 0 ) ;
  primitive ( 952 , 99 , 1 ) ;
  primitive ( 1216 , 78 , 0 ) ;
  primitive ( 1217 , 78 , 1 ) ;
  primitive ( 274 , 100 , 0 ) ;
  primitive ( 275 , 100 , 1 ) ;
  primitive ( 276 , 100 , 2 ) ;
  primitive ( 1226 , 100 , 3 ) ;
  primitive ( 1227 , 60 , 1 ) ;
  primitive ( 1228 , 60 , 0 ) ;
  primitive ( 1229 , 58 , 0 ) ;
  primitive ( 1230 , 58 , 1 ) ;
  primitive ( 1236 , 57 , 4239 ) ;
  primitive ( 1237 , 57 , 4495 ) ;
  primitive ( 1238 , 19 , 0 ) ;
  primitive ( 1239 , 19 , 1 ) ;
  primitive ( 1240 , 19 , 2 ) ;
  primitive ( 1241 , 19 , 3 ) ;
  primitive ( 1284 , 59 , 0 ) ;
  primitive ( 594 , 59 , 1 ) ;
  writeloc := curval ;
  primitive ( 1285 , 59 , 2 ) ;
  primitive ( 1286 , 59 , 3 ) ;
  primitive ( 1287 , 59 , 4 ) ;
  primitive ( 1288 , 59 , 5 ) ; ;
  nonewcontrolsequence := true ;
End ;
Begin
  history := 3 ;
  rewrite ( termout , 'TTY:' , '/O' ) ;
  If readyalready = 314159 Then goto 1 ;
  bad := 0 ;
  If ( halferrorline < 30 ) Or ( halferrorline > errorline - 15 ) Then bad := 1 ;
  If maxprintline < 60 Then bad := 2 ;
  If dvibufsize Mod 8 <> 0 Then bad := 3 ;
  If 1100 > 30000 Then bad := 4 ;
  If 1777 > 2100 Then bad := 5 ;
  If maxinopen >= 128 Then bad := 6 ;
  If 30000 < 267 Then bad := 7 ;
  If ( memmin <> 0 ) Or ( memmax <> 30000 ) Then bad := 10 ;
  If ( memmin > 0 ) Or ( memmax < 30000 ) Then bad := 10 ;
  If ( 0 > 0 ) Or ( 255 < 127 ) Then bad := 11 ;
  If ( 0 > 0 ) Or ( 65535 < 32767 ) Then bad := 12 ;
  If ( 0 < 0 ) Or ( 255 > 65535 ) Then bad := 13 ;
  If ( memmin < 0 ) Or ( memmax >= 65535 ) Or ( - 0 - memmin > 65536 ) Then bad := 14 ;
  If ( 0 < 0 ) Or ( fontmax > 255 ) Then bad := 15 ;
  If fontmax > 256 Then bad := 16 ;
  If ( savesize > 65535 ) Or ( maxstrings > 65535 ) Then bad := 17 ;
  If bufsize > 65535 Then bad := 18 ;
  If 255 < 255 Then bad := 19 ;
  If 6976 > 65535 Then bad := 21 ;
  If 20 > filenamesize Then bad := 31 ;
  If 2 * 65535 < 30000 - memmin Then bad := 41 ;
  If bad > 0 Then
    Begin
      writeln ( termout , 'Ouch---my internal constants have been clobbered!' , '---case ' , bad : 1 ) ;
      goto 9999 ;
    End ;
  initialize ;
  If Not getstringsstarted Then goto 9999 ;
  initprim ;
  initstrptr := strptr ;
  initpoolptr := poolptr ;
  fixdateandtime ;
  readyalready := 314159 ;
  1 : selector := 17 ;
  tally := 0 ;
  termoffset := 0 ;
  fileoffset := 0 ;
  write ( termout , 'This is TeX, Version 3.14159265' ) ;
  If formatident = 0 Then writeln ( termout , ' (no format preloaded)' )
  Else
    Begin
      slowprint ( formatident ) ;
      println ;
    End ;
  break ( termout ) ;
  jobname := 0 ;
  nameinprogress := false ;
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
      first := bufsize ;
      Repeat
        buffer [ first ] := 0 ;
        first := first - 1 ;
      Until first = 0 ;
      scannerstatus := 0 ;
      warningindex := 0 ;
      first := 1 ;
      curinput . statefield := 33 ;
      curinput . startfield := 1 ;
      curinput . indexfield := 0 ;
      line := 0 ;
      curinput . namefield := 0 ;
      forceeof := false ;
      alignstate := 1000000 ;
      If Not initterminal Then goto 9999 ;
      curinput . limitfield := last ;
      first := last + 1 ;
    End ;
    If ( formatident = 0 ) Or ( buffer [ curinput . locfield ] = 38 ) Then
      Begin
        If formatident <> 0 Then initialize ;
        If Not openfmtfile Then goto 9999 ;
        If Not loadfmtfile Then
          Begin
            wclose ( fmtfile ) ;
            goto 9999 ;
          End ;
        wclose ( fmtfile ) ;
        While ( curinput . locfield < curinput . limitfield ) And ( buffer [ curinput . locfield ] = 32 ) Do
          curinput . locfield := curinput . locfield + 1 ;
      End ;
    If ( eqtb [ 5311 ] . int < 0 ) Or ( eqtb [ 5311 ] . int > 255 ) Then curinput . limitfield := curinput . limitfield - 1
    Else buffer [ curinput . limitfield ] := eqtb [ 5311 ] . int ;
    fixdateandtime ;
    magicoffset := strstart [ 891 ] - 9 * 16 ;
    If interaction = 0 Then selector := 16
    Else selector := 17 ;
    If ( curinput . locfield < curinput . limitfield ) And ( eqtb [ 3983 + buffer [ curinput . locfield ] ] . hh . rh <> 0 ) Then startinput ;
  End ;
  history := 0 ;
  maincontrol ;
  finalcleanup ;
  9998 : closefilesandterminate ;
  9999 : readyalready := 0 ;
End .
