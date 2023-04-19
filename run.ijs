require 'plot'
require 'tables/tara'

DEFDT=: 30
DHEATER=: 3
MINDT=: 20
TESTW=: 'data.xls'

rxl=: ''&readxlsheets
sht=: {.@:>@:}.@:{
parse=: 3 : 0
'tin tout q w'=. 4{.}.|:2}.y
tin=. ,tin
tout=. ,tout
q=. ,q
w=. ,w
hl=. tin i. 0
tk=. hl&{.
dp=. hl&}.
tHin=. tk tin
tHout=. tk tout
qH=. tk q
wH=. tk w
h=. tHout;tHin;qH;wH
ic=. 0~: dp tin
tCin=. ic # dp tin
tCout=. ic # dp tout
qC=. ic # dp q
wC=. ic # dp w
c=. tCin;tCout;qC;wC
h,:c
)

ex=: 4 : 0
parse x sht rxl y
)

addhc=: 4 : 0
'h c'=. y
'tHout tHin qH wH'=. h
'tCin tCout qC wC'=. c
if. 0=#x do.
  hdt=. DEFDT
  cdt=. DEFDT
elseif. 1=#x do.
  hdt=. x
  cdt=. x
else.
  'hdt cdt'=. x
end.
qd=. qC (-&:(+/)) qH
if. qd<0 do.
  d=. <./tCin-cdt
  tCin=. d,tCin
  tCout=. d,tCout
  qC=. qC,~-qd
  wC=. 0,wC
  (<"1 h),:tCin;tCout;qC;wC
else.
  d=. >./tHin+hdt
  tHin=. d,tHin
  tHout=. d,tHout
  qH=. qH,~qd
  wH=. 0,wH
  (tHout;tHin;qH;wH),:<"1 c
end.
)

NB. =========================================================
NB.*et v calculate equivalent temperature curves
NB.-syntax:
NB.+et Tin; Tout; q; W
NB.-example:
NB.+   et T0in;T0out;q0;W0
NB.+┌───┬───┐
NB.+│ q │ T │
NB.+└───┴───┘
et=: 3 : 0
'Ti To q W'=. y
T=. /:~Ti,To
b=. </\(=/&Ti*=/&To) 0 (I.2~:/\T)} }:T
ts=. (>/&Ti*</&To) 2-:@+/\T
T;~0,+/\(b+/ .*q)-(ts+/ .*W)*2-/\T
)

ins=: 4 : 0
y=. |: y
c=. ({.x) ((<:{:)*(>:{.)) {.y
a=. (-/@{:%-/@{.) y
b=. (({.y)-/ .*|.{:y)%-/{.y
if. c do.
  if. 0~:-/{:y do.
    ({:x)-(b+a*{.x)
  else.
    ({:x)->./{:y
  end.
else.
  __
end.
)

mdif=: 4 : 0
'qh th'=. x
'qc tc'=. y
>./,(,.&>/y) ins"1 2/ 2,.\,.&>/x
)

clc=: 4 : 0
'h c'=. y
'tHout tHin qH wH'=. h
'tCin tCout qC wC'=. c
ml=. (<./tHout)-<./tCin
mr=. (>./tHin)->./tCout
if. 0=#x do.
  hdt=. DEFDT
  cdt=. DEFDT
  i=.0
elseif. 1=#x do.
  hdt=. x
  cdt=. x
  i=.0
else.
  'hdt cdt i'=. x
end.
qd=. qC (-&:(+/)) qH
if. qd<0 do.
  d=. <./tCin-cdt
  tCin=. d,tCin
  tCout=. d,tCout
  qC=. qC,~-qd
  wC=. 0,wC
  cdt=. 0
elseif. qd>0 do.
  d=. >./tHin+hdt
  tHin=. d,tHin
  tHout=. d,tHout
  qH=. qd,qH
  wH=. 0,wH
  hdt=. 0
end.
r1=. et tHout;tHin;qH;wH
r2=. et tCin;tCout;qC;wC
d=. r1 mdif r2
NB. smoutput d
if. d>-MINDT do.
  if. i < 0 do.
  if. (hdt=0)*(ml<MINDT) do.
     cdt=. MINDT-ml
  elseif. (cdt=0)*(mr<MINDT) do.
     hdt=. MINDT-mr
  end.
  dc=. <./tCin-cdt
  if. cdt=0 do.
    cl=. {. qC
    qC=. (DHEATER+cl),}.qC
  else.
    tCin=. dc,tCin
    tCout=. dc,tCout
    qC=. DHEATER,qC
    wC=. 0,wC
  end.
  dh=. >./tHin+hdt
  tHin=. dh,tHin
  tHout=. dh,tHout
  qH=. DHEATER,qH
  wH=. 0,wH
  h=. tHout;tHin;qH;wH
  c=. tCin;tCout;qC;wC
  
  (0 0, i+1) clc h,:c
  else.
    |:r1,.r2
  end.
else.
  |:r1,.r2
end.
)

runex=: 4 : 0
pd 'reset'
pd 'color red,green'
pd 'ycaption T, K'
pd 'xcaption Q, MW'
pl=. '' clc x ex y
r1=. {. pl
r2=. {: pl
smoutput {:r2
pd r1
pd r2
pd 'show'
)

0 runex TESTW

