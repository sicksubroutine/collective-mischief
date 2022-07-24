pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
--tng music by phlox
--shmup tutorial by lazy devs
--star trek shmup by chaz(🐱)
-- testing git
--todo
-------------
-- nicer screens
-- enemy bull spreadshot
-- enemy spawn location
-- pickups

function _init()
	cls(0)
	startscreen()
	
	blinkt=1
	t=0
	lockout=0
end

function _update()
	t+=1
	blinkt+=1
	if mode=="game" then
		update_game()
	elseif mode=="start" then
		update_start()
	elseif mode=="over" then
		update_over()
	elseif mode=="cutscene1" then
		update_cut1()
	elseif mode=="wavetxt" then
		update_wavetxt()	
	elseif mode =="win" then
		update_win()		
	end		
end

function _draw()
	if mode=="game" then
		draw_game()
	elseif mode=="start" then
		draw_start()
	elseif mode=="over" then
		draw_over()
	elseif mode=="cutscene1" then
		draw_cut1()
	elseif mode=="wavetxt" then
		draw_wavetxt()	
	elseif mode =="win" then
		draw_win()			
	end
		
end

function startgame()
	
	
	mode="wavetxt"
	
	wave=0
	t=0
	nextwave()

	ship=makespr()
	ship.x=64
	ship.y=100
	ship.sx=1
	ship.sy=1
	ship.colh=6
	ship.colw=5
	ship.spr=18
	
	--starting game conditions
	shields=5
	bul2cnt=3
	--
	kills=0
	parttor=0
	muzzle=0
	muzzle2=0
	torspr=0
	invul=0
	btimer=0
	btimer2=0
	torout=0
	delay=120
	ded=0
	faceanim=224
	wavetime=80
	moartor=0
	atkfreq=60
	nextfire=0
	
	stars={}
	for i=1,100 do
		local newstar={}
		newstar.x=flr(rnd(128))
		newstar.y=flr(rnd(128))
		newstar.spd=rnd(3.75)+(0.15)
		add(stars,newstar)	
	end
	
	buls={}
	buls2={}	
	ebuls={}
	
	enemies={}
	
	explode={}
	
	parts={}
	parts2={}
	
	shwaves={}
end

function startcut1()
	mode="cutscene1"

	parts2={}
end

function startscreen()

	mode="start"
	music(16)
	--stars
	stars={}
	for i=1,100 do
		local newstar={}
		newstar.x=flr(rnd(129))
		newstar.y=flr(rnd(129))
		newstar.spd=rnd(3.75)+(0.15)
		add(stars,newstar)	
	end
end

function ftw()
--stars
	stars={}
	for i=1,100 do
		local newstar={}
		newstar.x=flr(rnd(128))
		newstar.y=flr(rnd(128))
		newstar.spd=rnd(3.75)+(0.15)
		add(stars,newstar)	
	end
end
-->8
--tools
-- baby's first function
function starfield()

	for i=1,#stars do
		local mystar=stars[i]
		local scol=5
		
	if mystar.spd<.17 then
		spr(44,mystar.x,mystar.y)
		scol=0
		elseif mystar.spd<1.25 then
			scol=1
		elseif mystar.spd<2.25 then
			scol=0	
			line(mystar.x,mystar.y,mystar.x,mystar.y+3,7)
	end
	
	pset(mystar.x,mystar.y,scol)
	end
end

function star_start()
	for i=1,#stars do
		local mystar=stars[i]
		local scol=5
	if mystar.spd<.21 then
		scol=0
		elseif mystar.spd<1.55 then
			scol=6
	end
	pset(mystar.x,mystar.y,scol)
	end
end
function star_cut1()
	for i=1,#stars do
			local mystar=stars[i]
			local scol=1	
			if mystar.spd<.21 then			
			elseif mystar.spd<.85 then
					scol=6
			end
		pset(mystar.x,mystar.y,scol)
	end
end
function animstars()
	for i=1,#stars do
		local mystar=stars[i]
		mystar.y=mystar.y+mystar.spd
		if mystar.y>120 then
			mystar.y-=120
		end	
	end
end
function drwmyspr(myspr)
	local sprx=myspr.x
	local spry=myspr.y
	
	if myspr.shake>=0 then
		myspr.shake-=1
		if t%4<2 then
			sprx+=1.25
		end
	end
	
	spr(myspr.spr,sprx,spry,myspr.sprw,myspr.sprh)
end
--blink and you're dead
function blink()
	local blanim={8,8,8,8,8,8,6,6,7,7,6,6,8,8}
	 
	if blinkt>#blanim then
		blinkt=5
	end
	return blanim[blinkt]
end

function col(a,b)

 local a_left=a.x
 local a_top=a.y
 local a_right=a.x+a.colw-1
 local a_bottom=a.y+a.colh-1
 
 local b_left=b.x
 local b_top=b.y
 local b_right=b.x+b.colw-1
 local b_bottom=b.y+b.colh-1
 
 if a_top >b_bottom then return false end
 if b_top >a_bottom then return false end
 if a_left>b_right then return false end
 if b_left>a_right then return false end
 
	return true
end

function sparks(expx,expy)
	for i=1,3 do
		local myp={}
		myp.x=expx+4
		myp.y=expy+4
		myp.sx=(rnd()-1)*10
		myp.sy=(rnd()-1)*10
		myp.age=rnd(2)
		myp.maxage=7+rnd(10)--sizeofex
		myp.size=1
		add(parts2,myp)
	end
end

function explodes(expx,expy,isblue)

	local myp={}
	myp.x=expx+4--xpos
	myp.y=expy+4--ypos
	
	myp.sx=0
	myp.sy=0
	
	myp.age=rnd(2)
	myp.maxage=8--sizeofex
	myp.size=10
	myp.blue=isblue
	add(parts,myp)
	
	--clouds n shiz
	for i=1,15 do
		local myp={}
		myp.x=expx+4
		myp.y=expy+4
		myp.sx=(rnd()-0.5)*7--partspd
		myp.sy=(rnd()-0.5)*7--partspd
		myp.age=rnd(2)
		myp.maxage=7+rnd(7)
		myp.size=0.75+rnd(3)
		myp.blue=isblue
		add(parts,myp)
	end
	
	--sparks
	for i=1,3 do
		local myp={}
		myp.x=expx+4
		myp.y=expy+4
		myp.sx=(rnd()-0.5)*17--partspd
		myp.sy=(rnd()-0.5)*15--partspd
		myp.age=3
		myp.maxage=10+rnd(7)
		myp.size=1
		myp.blue=false
		add(parts,myp)
	end
big_shwave(expx,expy)
end
function page_red(page)
	local col=7
	if page>3 then
		col=10
	end	
	if page>5 then
		col=9
	end
	if page>10 then
		col=8
	end		
	if page>12 then
		col=2
	end
	if page>15 then
		col=5
	end
	
	return col	
end

function page_blue(page)
	local col=6
	if page>3 then
		col=12
	end	
	if page>5 then
		col=13
	end
	if page>10 then
		col=13
	end		
	if page>12 then
		col=1
	end
	if page>15 then
		col=1
	end
	
	return col	
end

function smol_shwave(shx,shy)
	local mysw={}
	mysw.x=shx+3
	mysw.y=shy+3
	mysw.r=3
	mysw.tr=4.25
	mysw.col=9
	mysw.speed=1
	add(shwaves,mysw)
end

function big_shwave(shx,shy)
	local mysw={}
	mysw.x=shx+3
	mysw.y=shy+3
	mysw.r=3
	mysw.tr=30
	mysw.col=7
	mysw.speed=3.2
	add(shwaves,mysw)
end

function dis_spr(mynum,loc)
	local pos=5			
	local z=0
	--tor,toplowleft
	if loc==3 then locx=21 locy=119 end
	--kills,botlowleft
	if loc==4 then locx=46 locy=0 end	
	if mynum<=9 then
		digit=sub(mynum,1,1)
		spr(z+digit,locx,locy)
	end
	if mynum>=10 and mynum<=99 then
		digit=sub(mynum,1,1)
		digit2=sub(mynum,2,2)
		spr(z+digit,locx,locy)
		spr(z+digit2,locx+pos,locy)
	end
	if mynum>=100	then
		digit=sub(mynum,1,1)
		digit2=sub(mynum,2,2)
		digit3=sub(mynum,3,3)
		spr(z+digit,locx,locy)
		spr(z+digit2,locx+pos,locy)
		spr(z+digit3,locx+pos*2,locy)
	end	
end

function makespr()
	local myspr={}
	myspr.shake=0
	myspr.x=0
	myspr.y=0
	myspr.sx=0
	myspr.sy=0
	myspr.flash=0
	myspr.flash1=0
	myspr.aniframe=1
	myspr.age=0
	myspr.spr=0
	myspr.sprw=1
	myspr.sprh=1
	myspr.colw=8
	myspr.colh=8
	return myspr
end


-->8
-- update functions
function update_game()
	
	torout-=1
	--reset speed
	ship.sx=0
	ship.sy=0
	ship.spr=18
	muzzle=0
	muzzle2=0
	
	--left
	if btn(0) and ded<=0 then
		ship.sx=-2
		ship.spr=17
	end
	--right
	if btn(1) and  ded<=0 then
		ship.sx=2
		ship.spr=19
	end
	--up
	if btn(2) and ded<=0 then
		ship.sy=-2
	end
	--down
	if btn(3) and ded<=0 then
		ship.sy=2
	end	
	--controls phasers o
	if btn(5) and ded<=0 then
		if btimer<=0 then
			local newbul=makespr()
			newbul.x=ship.x+1
			newbul.y=ship.y-1
			newbul.spr=16
			newbul.colw=4
			newbul.sx=0
			newbul.sy=-4
			muzzle2=2
			add(buls,newbul)
			sfx(0)
			btimer=3.5
		end
	end	
	--controls torpedoes x
	if btn(4) and ded==0 then
		if 	btimer2<=0 and torout<0 and bul2cnt<=0.99 then
			torout=50
			sfx(4)
		end	
		if btimer2<=0 and bul2cnt>=0.24 and torout<0 then
			local newbul=makespr()
			newbul.x=ship.x-1
			newbul.y=ship.y-3
			newbul.spr=36
			newbul.colw=7
			newbul.sx=0
			newbul.sy=-6
			add(buls2,newbul)
			sfx(1)
			muzzle=4
			bul2cnt-=1
			btimer2=20
		end
	end
	btimer-=1	
	btimer2-=1
	--movement speed
	ship.x+=ship.sx
	ship.y+=ship.sy
	--checking if we hit the edge
	-- far right
	if ship.x>120 then
		ship.x=120
	end
	-- far left
	if ship.x<0 then
		ship.x=0
	end
	-- bottom
	if ship.y>103 then
		ship.y=103
	end
	-- top
	if ship.y<8 then
		ship.y=8
	end

	--pulse phasers movement
	for mybul in all(buls) do
		move(mybul)
		
		if mybul.y<-8 then
			del(buls,mybul)
		end
	end
	--torpedo movement
	for mybul in all(buls2) do
		move(mybul)
		
		mybul.spr+=0.25
		if mybul.spr>=40 then
			mybul.spr=36
		end	

		if mybul.y<-8 then
			del(buls2,mybul)
		end
	end
	
	--move the ebuls
	for myebul in all(ebuls) do
		move(myebul)
		animate(myebul)

		if myebul.y>128 or myebul.y<-8 or myebul.x<-8 or myebul.x>128 then
			del(ebuls,myebul)
		end
		myebul.age+=1
		if myebul.age>200 then
			del(ebuls,myebul)
		end
		if delbul==1 and myebul.age==nil then return
		elseif delbul==1 and myebul.age>=200 then	
			delbul=0 del(ebuls,myebul)
		end	
	end
	
	-- move borg
	for myen in all(enemies) do
	--enemy mission
		doenemy(myen)
		animate(myen)
		--enemy leaving screen
		if myen.mission!="flyin" then
			if myen.y>128 or myen.x<-8 or myen.x>128 then
				del(enemies,myen)
				if myen==nil then return end	
			end
		end
	end
	-- collision borg x torpedoes
	for myen in all(enemies) do
		for mybul in all(buls2) do
			if col(myen,mybul) and ded<=0 then
				del(buls2,mybul)
				sfx(3)
				myen.y=myen.y-0.3
				myen.hp-=5
				myen.flash=2
				sparks(myen.x,myen.y)
				smol_shwave(mybul.x,mybul.y)
				if myen.hp<=0 then
					killen(myen)
				end
			end	
		end		
	end
	
	-- collision borg x phasers
	for myen in all(enemies) do
		for mybul in all(buls) do
			if col(myen,mybul) and ded<=0 then
				del(buls,mybul)
				smol_shwave(mybul.x,mybul.y)
				sfx(3)
				myen.y=myen.y-0.1
				myen.hp-=1.05
				myen.flash=2
				sparks(myen.x,myen.y)
				smol_shwave(mybul.x,mybul.y)
				if myen.hp<=0 then
					killen(myen)
				end
			end
		end		
	end
	
	-- collision ship x enemies
	if invul<=0 then
		for myen in all(enemies) do
			if col(myen,ship) and ded<=0 then
				sfx(2)
				myen.hp-=3
				myen.flash=2
				shields-=1
				invul=45
				sparks(ship.x,ship.y)
				sparks(myen.x,myen.y)
				explodes(ship.x,ship.y,true)
			if myen.hp<=0 then	
				killen(myen)	
			end
		end		
	end
	else 
		invul-=1		
	end
	-- coll x ebuls
	if invul<=0 then
		for myebul in all(ebuls) do
			if col(myebul,ship) and ded<=0 then
				sfx(2)
				shields-=1
				invul=45
				sparks(ship.x,ship.y)
				explodes(ship.x,ship.y,true)
			end		
		end
	end
	-- number of kills
	-- to get free torp
	if parttor>=5 then
		parttor=0
		bul2cnt+=1
		moartor=60
	end
	moartor-=1
	--u ded
	if shields<=0 then
		
		invul=10000
		delay-=0.5
		ded=1
	end
	if shields<=0 and ded==1 and delay>119 then
		explodes(ship.x,ship.y)
		music(6)
	end
	if delay==0 then
		mode="over"
		lockout=t+50
		return
	end
	
	--enemy picking function
	picktimer()
	
	--animate muzzle flash
	if muzzle>2 then
		muzzle-=1
	end
	
	if muzzle2>2 then
		muzzle2-=2
	end
	animstars()

	if mode=="game" and #enemies==0 and ded<=0 then
		nextwave()
	end
end

-- start screen check for x/o
function update_start()
	
	animstars()
	
	if btn(4)==false and btn(5)==false then
		btnreleased=true
	end
	if btnreleased then
		if btnp(5) or btnp(4) then
			startcut1()
			
			btnreleased=false
		end
	end
end
 -- cutscene handoff
function update_cut1()
	if btn(4)==false and btn(5)==false then
		btnreleased=true
	end
	if btnreleased then
		if btnp(5) or btnp(4) then
			startgame()
			
			btnreleased=false
		end
	end
end

-- game over

function update_over()
	
	if t<lockout then
		return
	end
	
	if btn(4)==false and btn(5)==false then
		btnreleased=true
	end
	if btnreleased then
		if btnp(5) or btnp(4) then
			mode="start"
			music(0)
			btnreleased=false
		end
	end
end

function update_win()
	lockout=t+30
	if t<lockout then
		return
	end
animstars()
	if btn(4)==false and btn(5)==false then
		btnreleased=true
	end
	if btnreleased then
		if btnp(5) or btnp(4) then
			startscreen()
			
			btnreleased=false
		end
	end
end

function update_wavetxt()
	update_game()
	wavetime-=1
	
	if wavetime<=0 then
			
		mode="game"
		
		spawnwave1()
	end	
	
end
-->8
-- draw functions
function draw_game()
	--clear screen
	cls(0)
	-- draw dem stars
	star_start()	
	-- draw player ship
	if invul<=0 then
		drwmyspr(ship)	
		else
			if invul<=0 and ded==1 then
			
			elseif invul>0 and ded<=0 then
				if sin(t/5)<0 then
				spr(34,ship.x,ship.y)
			end
		end
	end
	--phasers
	for mybul in all(buls) do
		drwmyspr(mybul)
	end	
	--torpedoes
	for mybul in all(buls2) do
		drwmyspr(mybul)
	end
	--drawing enemies
	for myen in all(enemies) do
		if myen.flash>0 then
			myen.flash-=1
			for i=1,15 do
				pal(i,7)
			end
		end
		if myen.flash1>0 then
			myen.flash1-=1
			for i=1,15 do
				pal(i,11)
			end
		end		 
		
		drwmyspr(myen)
		pal()
	end

	--muzzle flash
	if muzzle>0 then
		circfill(ship.x+2,ship.y-1,muzzle,12)
	end	
	
	if muzzle2>0 then
		circfill(ship.x+2,ship.y-1,muzzle2,9)
	end	
	--drawing shwaves
	for mysw in all(shwaves) do
		circ(mysw.x,mysw.y,mysw.r,mysw.col)
		mysw.r+=mysw.speed
		if mysw.r>mysw.tr then
			del(shwaves,mysw)
		end
	end
	
	--drawing particles
	for myp in all (parts) do
		local pc=7
		
		if myp.blue then
			pc=page_blue(myp.age)
		else
			pc=page_red(myp.age)
		end	
		circfill(myp.x,myp.y,myp.size,pc)
		myp.x+=myp.sx
		myp.y+=myp.sy
		myp.sx=myp.sx*0.7
		myp.sy=myp.sy*0.7
		myp.age+=1
		if myp.age>myp.maxage then
			myp.size-=0.5
			if myp.size<0 then
				del(parts,myp)
			end
		end
	end
	
	--drawing sparks
	for myp in all (parts2) do
		local pc=page_red(myp.age)
			
		circfill(myp.x,myp.y,myp.size,pc)
		myp.x+=myp.sx
		myp.y+=myp.sy
		myp.sx=myp.sx*0.7
		myp.sy=myp.sy*0.7
		myp.age+=1
		if myp.age>myp.maxage then
			myp.size-=0.5
			if myp.size<0 then
				del(parts,myp)
			end
		end
	end
	
	for myebul in all (ebuls) do
		pal(12,11)
		pal(1,3)
		drwmyspr(myebul)
		pal()
	end	
	
	--don't draw things below here	
	--ui elements
	
	--debug printout
	--seconds since game start
	--print(flr(t/30).." secs",100,95,8)
	--print(flr(t).." frames",90,89,8)
	
	--ending taunt message
		local kx=63
	if delay<110 and kills==0 then
		print("you got",25,kx,11)
		print("zero kills",55,kx,8)
	elseif delay<110 and kills==1 then
		print("you only got",25,kx,11)
		print("one",75,kx,8)
		print("kill!",88,kx,11)
	elseif delay<110 and kills>2 and kills<99 then
		print("you only got",25,kx,11)
		print(kills,75,kx,8)
		print("kills!",84,kx,11)
	elseif delay<110 and kills>99 then
		print("you only got",25,kx,11)
		print(kills,75,kx,8)
		print("kills!",89,kx,11)
	end	
	--lcars ui for torpedoes
	pal(12,8)
	spr(123,8,119,2,1)
	spr(104,0,119)
	
	for x=1,5 do
		spr(120,16+8*x,119)
	end
		
	spr(111,59,119)
	
	pal(7,8)
	pal(6,2)
	dis_spr(bul2cnt,3)
	pal()
	-- second screen on bot-right
	
	spr(104,69,119)
	
	for x=1,7 do
		spr(120,69+7*x,119)
	end
	
	spr(111,119,119)
	pal()
	
	if torout>=1 then
		if sin(t/6)<0 then
			pal(7,8)
			pal(6,2)
			spr(123,81,119,2,1)
			spr(118,94,119,2,1)
			pal()
		end
	end
	
	if moartor>=0 then
		if sin(t/5)<0 then
			spr(125,79,119,3,1)
			spr(123,105,119,2,1)
			spr(117,118,119)
		end	
	end

	--lcars ui for shields
	spr(104,0,111)
	spr(105,9,111,4,1)
	spr(109,37,111)
	spr(109,43,111)
	spr(109,49,111)
	spr(109,55,111)
	spr(109,61,111)
	for i=1,5 do
		if shields>=i then
			spr(26,31+i*6,111)
		end
	end
	
	pal(12,10)
	spr(104,69,111)
	for x=1,7 do
		spr(120,69+7*x,111)
	end
	spr(111,119,111)
	pal()
	
	if invul>0 and ded==0 then
		if sin(t/6)<0 then
			--lcars alert screen
			spr(105,79,111,4,1)
			spr(121,109,111,2,1)
		end
	end
	
	--kills
	pal(12,13)
	spr(104,0,0)
	
	for x=1,7 do
		spr(120,8*x,0)
	end
	
	spr(111,59,0)
	pal()
	
	spr(10,8,0,5,1)
	
	pal(7,8)
	pal(6,2)
	dis_spr(kills,4)
	pal()
	
	
	--viewscreen ui?
	
	--sprite to animate
	--spr(faceanim,69,-1)
	--print("we are borg!",78,1,8)
	
end
function draw_start()
	cls(0)
	starfield()
	
	spr(231,64,75,2,2)
	spr(18,57,82)
	
	print("star trek:",25,25,8)
	print("collective mischief",25,33,11)
	
	--print("time to go assimilating!",17,80,8)
	
end		
function draw_over()
 	cls(0)
	--REDO THIS:
	--[[
 	--planet
	spr(45,68,52,2,2)
	--borg ship
	spr(64,85,35,4,4)
	-- tractor beam?
	spr(24,70,40,2,2)
	-- destroyed ships
	spr(55,65,40)
	spr(56,69,45)
	spr(57,75,45)

	print("your crew is dead!", 30,20,8)
	print("your ship was destroyed!", 30,28,8)
	
	print("the borg",35,55,11)
	print("assimilated earth!",35,69,11)
	--lololol! n00b!
	print("you have lost everything.",20,90,8)
	print("the game is over!",34,100,8)
	]]--
end
function draw_cut1()
	
	cls(0)
	star_cut1()
	--[[
	spr(64,0,0,4,4)
	spr(64,80,20,4,4)
	spr(50,30,60)
	spr(50,60,30)
	spr(50,90,80)
	spr(70,75,8)
	spr(70,65,15)
	spr(70,45,9)
	spr(42,65,70,2,2)
	print("borg cubes",40,55,11)
	print("are approaching",40,63,8)
	print("earth!",40,70,12)
	]]--

	print("these borg bastards",40,50,11)
	print("are gonna     for",40,60,11)
	print("pay",80,60,8)
	print("shootin' up my ride!",40,70,11)
	print("press x to begin killing borg",5,100,blink())
end

function draw_win()
cls(0)
draw_game()

print("you saved earth!",30,20,8)
print("good job!", 40,30,8)

end

function draw_wavetxt()
	draw_game()
	-- wave ui
	pal(12,8)
	spr(104,43,49)
	spr(120,51,49)
	spr(120,59,49)
	spr(120,67,49)
	spr(111,71,49)
	pal()
	print("wave "..wave,50,50,blink())
end
-->8
--waves and enemies

function spawnwave1()

	
sfx(28)
t+=1
	if wave==1 then
	atkfreq=60
	placeens({
		{0,0,0,0,0,0,0,0,0,0},
		{0,0,1,1,1,1,1,1,0,0},
		{0,1,1,1,1,1,1,1,1,0},
		{1,1,1,1,1,1,1,1,1,1}
	})
	end
	
	if wave==2 and wavetime<=0 then
	atkfreq=60
	placeens({
		{2,1,1,1,1,1,1,1,1,2},
		{2,1,1,1,1,1,1,1,1,2},
		{2,1,1,1,1,1,1,1,1,2},
		{2,1,1,1,1,1,1,1,1,2}
	})
	end	
	if wave==3 and wavetime<=0 then
	atkfreq=60
	placeens({
		{3,1,1,1,3,3,1,1,1,3},
		{2,1,2,2,1,1,1,2,1,2},
		{2,1,2,2,1,1,1,2,1,2},
		{1,1,1,1,1,1,1,1,1,1}
	})
	end
	if wave==4 and wavetime<=0 then
	atkfreq=60
	placeens({
		{3,3,3,3,3,3,3,3,3,3},
		{1,1,1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,1,1,1},
		{2,2,4,2,2,2,2,2,4,2}
	})		
	end
	if wave==5 and wavetime<=0 then
	atkfreq=60
	placeens({
		{4,4,4,4,4,4,4,4,4,4},
		{0,4,4,4,4,4,0,4,4,4},
		{0,0,4,4,4,0,0,0,4,4},
		{0,0,0,4,0,0,0,0,0,4}
	})
	end
	
	if wave==6 and wavetime<=0 then
	atkfreq=60
	placeens({
		{5,0,0,0,5,0,0,0,0,5},
		{0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0}
	})
	end
	
	if wave==7 and wavetime<=0 then
	atkfreq=60
	placeens({
		{0,0,0,0,6,0,0,0,0,0},
		{6,0,0,0,0,0,0,6,0,0},
		{0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0}
	})
	end
	
	if wave==8 and wavetime<=0 then
	atkfreq=60
	placeens({
		{0,0,0,0,7,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0}
	})
	end
	
end

function placeens(lvl)
	
	for y=1,4 	do
		local myline=lvl[y]
		for x=1,10 do
			if myline[x]!=0 then
				spawnen(myline[x],x*12-6,4+y*10,x*-8)
			end
		end
	end
end

function nextwave()
	wave+=1
	delbul=1
	if wave>8 and ded<=0 then
		mode="win"
		lockout=t+50
		music(10)
	else
		if wave==1 then
			music(-1,1000)
			music(9)
		else
			music(8)
		end
			mode="wavetxt"
			wavetime=80
	end
	
end

function spawnen(entype,enx,eny,enwait)
	local myen=makespr()
		myen.x=enx*1.5-32
		myen.y=eny-35
		myen.mission="flyin"
		
		myen.posx=enx
		myen.posy=eny
		
		myen.anispd=0.4
		
		myen.wait=enwait
		
		myen.type=entype
		

	if entype==nil or entype==1 then
		--borg probe
		myen.spr=68
		myen.hp=2
		myen.ani={68,69,70,71}
		myen.colw=5
		myen.colh=6
	elseif entype==2 then
		-- sphere
		myen.spr=84
		myen.hp=3
		myen.ani={84,85,86,87}
		myen.colw=8
		myen.colh=8
	elseif entype==3 then
		-- med borg cube
		myen.spr=50
		myen.hp=7
		myen.ani={50,51,52,53}
	elseif entype==4 then
		-- pyramid
		myen.spr=100
		myen.hp=5	
		myen.ani={100,101,102,103}
	elseif entype==5 then
		-- mini boss-assimilated fed
		myen.spr=70
		myen.hp=15
		myen.ani={72,74,76}
		myen.sprw=2
		myen.sprh=2
		myen.colw=16
		myen.colh=16
	elseif entype==6 then
		-- large cube	- main boss?
		myen.spr=64
		myen.hp=20
		myen.ani={64}
		myen.sprw=4
		myen.sprh=4
		myen.colw=32
		myen.colh=32
	elseif entype==7 then
		-- invader sphere - doesn't exist.	
		myen.spr=128
		myen.hp=100
		myen.ani={128}
		myen.sprw=4
		myen.sprh=4
		myen.colw=32
		myen.colh=32 			
	end
	add(enemies,myen)
end


-->8
--behavior
function doenemy(myen)
	if myen.wait>0 then
		myen.wait-=1
		return
	end	
	if myen.mission=="flyin" then
		--flying in
		--basic easing function
		
		myen.y+=(myen.posy-myen.y)/9
		myen.x+=(myen.posx-myen.x)/9
		
		if abs(myen.posy-myen.y)<1 then
			myen.y=myen.posy
			myen.x=myen.posx
			myen.mission="protec"
		end
	elseif myen.mission=="protec" then
		--wait for collective
		
	elseif myen.mission=="assim" then
		--you will be assimilated.
		
		--borg probe
		if myen.type==1 then
			myen.sy=0.95
			myen.sx=sin(t/75)+0.5
			if t%25==0 then
				firespread(myen,1,1,0)
			end
		
			-- just tweaks
			if myen.x<32 then
				myen.sx+=1-(myen.x/32)
			end
			
			if myen.x>88 then
				myen.sx-=(myen.x-88)/32
			end
			--sphere
		elseif myen.type==2 then
			local	tar1x=ship.x+4
			local	tar1y=ship.y+4
			local	tar2x=myen.x
	  local	tar2y=myen.y
			if ship.y-myen.y<8 then 
				myen.sx=0
				myen.sy=2 
			else
				angle=atan2(tar1y-tar2y,tar1x-tar2x)
				myen.sx=sin(angle)-0.5
				myen.sy=cos(angle)-0.5
			end
			if t%30==0 then
					firespread(myen,5,1,time()/32)
			end
			--med borg cube
		elseif myen.type==3 then
			myen.sy=2.5
			myen.sx=sin(t/20)
			-- just tweaks
			if myen.x<32 then
				myen.sx+=1-(myen.x/32)
			end
			
			if myen.x>88 then
				myen.sx-=(myen.x-88)/32
			end
		
			--pyramid
		elseif myen.type==4 then
			--assimilated fed
		elseif myen.type==5 then
			myen.sy=0.25
			if t%25==0 then
				firespread(myen,10,3,time()/8)
			end		
			--large cube
		elseif myen.type==6 then
			--invader
		elseif myen.type==7 then
			
			if myen.y>90 then
				myen.sy=-0.5
			elseif myen.y<20 then
				myen.sy=0.25
			end	
				if t%30==0 then	
					firespread(myen,30,1.25,time()/16)
				end			
				
		end	
		move(myen)

	end
	
end

function picktimer()
	if mode!="game" then
		return
	end	
	
	if t>nextfire then
		pickfire()
		nextfire=t+20+rnd(15)
	end	
	
	if t%atkfreq==0 then
		pickattack()
	end	
end

function pickattack()
	local maxnum=min(10,#enemies)
	local myindex=flr(rnd(maxnum))
	
	myindex=#enemies-myindex
	local myen=enemies[myindex]
	
	if myen==nil then return
	elseif myen.mission=="protec" then
		myen.mission="assim"
		myen.anispd*=3
		myen.wait=25
		myen.shake=30
	end
end

function pickfire()
	local maxnum=min(10,#enemies)
	local myindex=flr(rnd(maxnum))
	myindex=#enemies-myindex
	local myen=enemies[myindex]
	if myen==nil then return
	elseif myen.mission=="protec" then
		firespread(myen,1,0.75,time()/8)
	end
end

function move(obj)
	obj.x+=obj.sx
	obj.y+=obj.sy
end

function animate(myen)
	myen.aniframe+=myen.anispd
	if flr(myen.aniframe)>#myen.ani then
		myen.aniframe=1
	end
	myen.spr=myen.ani[flr(myen.aniframe)]
end

function killen(myen)
	explodes(myen.x,myen.y)
	del(enemies,myen)
	sfx(2)
	kills+=1
	parttor+=1.125
	if myen.mission=="assim" then
		if rnd()<0.75 then
			pickattack()
		end
	end
end
-->8
--bullets

function fire(myen,ang,spd)
	
	local myebul=makespr()
	local angle=0
	myebul.x=myen.x
	myebul.y=myen.y+2
	myebul.spr=36
	myebul.ani={36,37,38,39,36}
	myebul.anispd=0.75
	
	
	myebul.sx=sin(ang)*spd
	myebul.sy=cos(ang)*spd
	
	myebul.colw=5
	myebul.colh=5
	myen.flash1=4
	myebul.bulmode=true
	
	if myen.type==7 then
		myebul.x=myen.x+15
		myebul.y=myen.y+15
	end
	
	if myen.type==1 then
		tar1x=ship.x+2
		tar1y=ship.y+2
 	tar2x=myen.x
		tar2y=myen.y
	 angle=atan2(tar1y-tar2y,tar1x-tar2x)	
		myebul.sx=sin(angle)
		myebul.sy=cos(angle)
	end
	
	add(ebuls,myebul)
	
	sfx(37)

	
end

function firespread(myen,num,spd,base)
 
	for i=1,num do
		fire(myen,1/num*i+base,spd)
	end	
	
	
end
__gfx__
67600000070000000700000007600000007000006770000007000000677000006760000067600000776167617761676117161776171117111676111100000000
70700000770000006070000070700000077000007000000070700000707000007070000070700000717171717171717117171171171117111717111100000000
70700000070000000070000000700000707000007000000070000000007000007070000070700000717171717171711117711171171117111711111100000000
70700000070000000700000007000000707000007760000077600000007000006760000067700000771171717711711117171171171117111676111100000000
70700000070000000700000000700000777000000070000070700000007000007070000000700000717171717761767117171171171117111117111100000000
70700000070000007000000070700000007000000070000070700000007000007070000000700000717171717171717117171171171117111717111100000000
67600000777000007760000007600000006000006760000007600000006000006760000077600000776167617171676116161676177717771676111100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
909000000700000000700000007000000000000000065000005665000005600000000000000000bb0ccccc100000000000000000000000000000000000000000
70700000058000000858000008500000000000000007600000677600000670000000000000000bb00cccccc00000000000000000000000000000000000000000
7070000057550000557550005575000000000000000850000058850000058000000000000000bb000cccccc00000000000000000000000000000000000000000
a0a00000567c0000c767c000c76500000000000005055080800550080805505000000000000bb0000cccccc00000000000000000000000000000000000000000
90900000056000000656000006500000000000000606606060066006060660600000000000bb00000cccccc00000000000000000000000000000000000000000
000000000060000000600000060000000000000007677c707c6776c707c77670000000000bb000000cccccc00000000000000000000000000000000000000000
000000000000000000000000000000000000000006066060600660060606606000000000bb0000000ccccc100000000000000000000000000000000000000000
00000000000000000000000000000000000000000c0000c0c000000c000000000000000bb0000000000000000000000000000000000000000000000000000000
00000000c171c0001c1c1000c171c000000100000001000000010000000100000000000b0000000000000334ccc000000083830000000c5cc550000000000000
00000000cc58c000c858c100c85cc000010c010000c1c000000c000000171000000000bb000000000003334cccccc00008838880000ccccc5bccc00000000000
00000000c5755000c575c1005575c00000171000001710000017100000c7c00000000bb00000000000c4444cc44ccc003388338800c55cc55ccccc0000000000
00076000c5671000176711001765c0001c777c101c777c101c777c101c777c100000bb00000000000ccccccc44ccccc0883338880cc5cc55ccccccc000000000
008558001c56c000c656c100c65c100000171000001710000017100000c7c000000bb0000000000004cccc33344434c0833383380ccccc55555cc5c000000000
007667000cc6c000c060c000c6cc0000010c010001c1c100000c00000017100000bb00000000000044ccc3344433334c88883388ccb5cccccc5c55cc00000000
00c88c0001cc10001c1c10001cc10000000100000001000000010000000100000bb000000000000044cc43444443333408833880cc5cccc5cc5c55bc00000000
0000000000000000000000000000000000000000000000000000000000000000bb00000000000000ccc44ccc4444434c00838800c5ccccc5ccc5cc5c00000000
00566500009000005655b6555655665556556b555655665500000000a000790967c0990000566500cc44ccccc444444c0000000055c55cc5cc55cc5500000000
0067760000900000b655665566556655b655665566556655000000007a9a979a5600009000677608cccccccc444ccccc00000000c555cccb5ccccccc00000000
00588500009000005656655b5b56b5565656b55b5b5b655600001000009779a76000900000588507cc4c44444cc44ccc00000000c5b55cccccccc55c00000000
0005500000900000555555555555555555555555555555550001c1000999907900099800009590990c44444ccc4444c0000000000ccc555ccc55c5c000000000
080660800090000055b56665556566b555656b6555b56b65000c7c000906907990997550977a97aa0ccccccccc4333c0000000000cccc55cc55ccbc000000000
0767767000900000565555665b5555665655556b565555660001c10007c79997099700009aa9a79000ccc444443333000000000000ccc55ccc5ccc0000000000
0c0000c0009000005655655b5655655b565565565655b55600001000060660600006000097999090000444443333300000000000000ccccc555cc00000000000
0000000000900000b66566656665b665b6656b6566b56b65000000000c0000c0000000000990000000000443333000000000000000000b5cccc0000000000000
5555555555555555555555555555555335555b00b555530035555b00b5555300000000000000000000000000000000000000000000000000000000000b585b00
b55555555535555555555556666665556533760065337600653376006533760000000000000000000000000000000000000000000000000000000000b35b53b0
555335335555333353535655555655555b55550053b55500553b55005553b50000c0000000000c0000c0000000000c0000c0000000000c000000000030030030
5b5bb5bb5355bbbb5b5b565666555b350566500005665000056650000566500000c0000000000c0000c0000000000c0000c0000000000c0000000000b00b00b0
53555555535555555555555566655b36005500000055000000550000005500000050000000000500005000000000050000500000000005000000000000030000
535666555355bbbb5555656655555b350000000000000000000000000000000000500000000005000050000000000500005000000000050000000000000b0000
5556555553b55553656565566655563500000000000000000000000000000000007b66555566b7000077b655556b7700007766b55b6677000000000000000000
65555b55555533536565565655555666000000000000000000000000000000000070558888550700007055888855070000705588885507000000000000000000
65535555b355555665665555535555550056650000566500005bb50000566500005057b55b75050000505b5b55b5050000505755b57505000000000000000000
55b35655b35565566555555653355535055655b00556556005565560055b556000b05b6666b50b0000b0566666650b0000b05b6666b50b000000000000000000
53bb5655b3566556555655565bb55535565b55b55b565565565655655b5b5565000057611675000000005b6116b5000000005761167500000000000000000000
53b55b55b35665553bb5565555555535b655b55b6b55655bb655b55b6b55655600005b6576b50000000056657665000000005b6576b500000000000000000000
55555655555665555b55565555bb3535b675b5656675b5b5b675b5b56b7565b5000057666675000000005b6666b5000000005766667500000000000000000000
55b5565b3556555555565556555b35355b5b656b5b5bb5b65b5b65bb5b566566000005b7b75000000000056b6b500000000005b7b75000000000000000000000
35b5555b3355555555566556556b35350566555005bb555005bb5550056655500000005555000000000000555500000000000055550000000000000000000000
35b55555535555353b56655565555555005566000055bb000055bb00005566000000000000000000000000000000000000000000000000000000000000000000
355b5665555553b5b556555566665b55b65b55533556555bb65555533556555b001cc1116761717177717771711177116761111108888800b00000b000000ccc
53555665655355555565665555555b350b55575003bb5750053b57500553bb5001ccc11171717171171171117111767171711111088888803853583000000ccc
5355556555bb55566555665655555b350055550000555500005b5500005555000cccc1117111777117117111711171717111111108888880035b530000000ccc
5555b5555555b5555bb556565555bb35000630000006b00000063000000bb0000cccc11167617671171177117111717167611111088888800006000000000ccc
b55bbbb5356553333333555555b5b335000050000000500000005000000050000cccc11111717171171171117111717111711111088888800006000000000ccc
b55bbbb5b553bbbbbb355555355555350000000000000000000000000000000001ccc11171717171171171117111767171711111088888800005000000000ccc
35533335b3555333555555566656555500000000000000000000000000000000001cc111676171717771777177717711676111110888880000b3b00000000ccc
35555355b3bb5555555bb5565565555b00000000000000000000000000000000000000000000000000000000000000000000000000000000000b000000000000
b5665555b55533353333355565555533000000007000000067607070777070001111111107070777077707007771676177611111677167617761777067717711
55655655536666b55555553555555555000000007000000076707070070070001111111107070070007007001711767171711111711171717171717071117671
55655b655556665bbbbbb5bbbb555555000000007000000070707070070070001111111107770070007007001711717171711111711171717171717071117171
55333556355555533333355b3335555b000000007000000070707070070070001111111107670070007007001711717177111111771171717711717077117171
553bb555355555555555555555555555000000007000000070707070070070001111111107070070007007001711717177611111711177717761717071117171
553b3563b35665535556655bbb55bb55000000000000000076707070070000001111111107070070007000001711767171711111711171717171717071117671
5556b5553555553b3655555533555535000000007000000067607770070070001111111107070777007007001711676171711111776171617171617077617711
5555555555555553555555655555b555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000005b655b55000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000b66536555556b6000000000000000000000077777770000000007777777000000000777777700000000000000000000000000000000000000000000
0000000653665565666b336650000000000000000000077733777000000007777333700000000777733370000000000000000000000000000000000000000000
000000b655666565565556665b0000000000000000007777bab370000000007b7bb370000000007b7ab370000000000000000000000000000000000000000000
000006355565556655565566536000000000000000077007bbb37700000000007ab30000000000007bb300000000000000000000000000000000000000000000
0000665555556556555665555566000000000000000700077ab30700000000007bb30000000000007ab300000000000000000000000000000000000000000000
000b3655b556665553555655b556600000000000007700077bb307000000000b7ab300000000000b7bb300000000000000000000000000000000000000000000
0055665b3b5566653b35555b3b55550000000000077007b7bab30770000007bb7bb30000000007bb7ab300000000000000000000000000000000000000000000
00655555b555566553555655b5536b0000000000070007b770000070000007bb70000000000007bb700000000000000000000000000000000000000000000000
0b36556555665b65555556655556665000000000770007bb7b300070000007bb7a300000000007bb7b3000000000000000000000000000000000000007000000
0666656656665565665655665555635000000000700000777a3000770000007b7b3000000000007b7a3000000000000000000000000000000000000000000000
066655665565566565566555566555500000000070000007bb300007000000007a300000000000007b3000000000000000300000000000000000000000000000
55655556555b5665656665556666656b00000000000000777a3000000000007b7b3000000000007b7a3000000000007bba300000000000000000000000000000
b55556b5b66655555555656565556563000000000000007b7b3000000000007b7a3000000000007b7b3000000000007bbb300000000000000000000000000000
66565566666655bbbbb555655535556600000000000000777a3000000000007b7bb300000000007b7ab300000000007bbab30000000000000003000000000000
b65665b55b655b3b3b3b553b53b35555000000000000077b7b3000000000007b7ab330000000007b7bb330000000007bbbb33000000070000000000000000000
3b566655b565b3333333b56355355655000000000000000000000000000000077bb33000000000077ab3300000000007bab33000000000000000300000000000
6655555bb555b33b33b3b56665556655000000000000000000000000000000007abb3000000000007bbb3000000000007bbb30000000000000b0300000000000
b3665b533355b3333333b5555556553b0000000000000000000000000000007b7bb300000000007b7ab300000000007bbab3000000000070ba00000000000000
066666555555b3bbbbb3b53b555556600000000000000000000000000000007b7a3000000000007b7b3000000000007bbb300000000000000000000000000000
0556665555b5bb33b33bb563566655600000000000000000000000000000007b7b0000000000007b7a0000000000007bba000000000000700000000007000000
0b35555355533bbbbbbb3555566555500000000000000000000000000000007b7ab300000000007b7bb330000000007bbbb330000007000ba0b0300000000000
0066553b3555535555555665555565000000000000000000000000000000000770000000000000077abb300000070007babb3000700000000000000000000000
00b35553556655566655655566663b0000000000000000000000000000000000000000000000000070bb30000000000000bb30000000000000b0000000000000
00056655566556553b535565555660000000000000000000000000000000000000000000007000007bbb3000000000007bbb3000000007007b00300000000000
0000635666656656555b5666653500000000000000000000000000000000000000000000000000077abb300007007007babb3000000000000a0b300000000000
00000b5665555555b353555555b000000000000000000000000000000000000000000000000007077bb3000700000007bbb3000070000000b003000007000000
000000535566655665556555560000000000000000000000000000000000000000000000000000077ab3000000070007bab30000000000000000000000000000
0000000b6366555555655566500000000000000000000000000000000000000000000000007700007bb30000700000007bb30007000000000000000000000000
000000000b653636555556b0000000000000000000000000000000000000000000000000000700007ab30000700000007ab30000000000000000000000000000
000000000000b6b65b3600000000000000000000000000000000000000000000000000000007707b7b7370077007707bbb737007707000000000700000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000779a7a9a9a70000779a9a9a90a77000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000655665566556650065566556655665006556655665566500000000000000000000000000000000000000000
6d4444d67ddd7d7d6d4444d6d7dddd7d6d4444d60656655b5b56b55006566553535635500656655b5b56b5500000000000000000000000000000000000000000
64044046d0d000d76404404670d777dd640440460555555555555550055555555555555005555555555555500000000000000000000000000000000000000000
64dddd467ddd77dd644dd446dd70d7dd64dddd4605b56665556566b0053566655565663005b56665556566b00000000000000000000000000000000000000000
5844448507dd000058d44d8507dd000d58440485065555665b5555600655556653555560065555665b5555600000000000000000000000000000000000000000
58888a85d0777dd758888a8577777dd758884a850655655b5655655006556553565565500655655b565565500000000000000000000000000000000000000000
0000000000000000000000000000000000000000066566656665b6600665666566653660066566656665b6600000000000000000000000000000000000000000
0000000000000000000000000000000000000000055555555555555005555555555555500555555555555b300000000000000000000000000000000000000000
000000000000000000000000000000000000000005555553666665500555555b666665500555555666666b300000000000000000000000000000000000000000
07dddd7d6d4444d6d000d7dd6d0440d6777dd7dd03535655555655500b5b565555565b300353565555565b300000000000000000000000000000000000000000
0007d7dd64044046dddd77dd64dddd46d007ddd70b5b565666555b300353565666555b300b5b5656665555300000000000000000000000000000000000000000
0dd00d7764dddd467007dd0064400446ddd007700555555566655b300555555566655b3005555555666556500000000000000000000000000000000000000000
07dddd7d58400485dd0777dd584444857777dddd0555653655555b30055565b65555563005556566555556600000000000000000000000000000000000000000
0000000058844a850000000058888a85000000000565655666555630056565566655566005656556665556600000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000006600000000000000666600000000000000660000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000056650000000000005666650000000000005665000000000000000000000000000000000000000000000
bb055550bb055550bb055550bb055550bb0555500000665566000000000066566566000000000066556600000000000000000000000000000000000000000000
bb555665bb555665bb555665bb556665bb5566650000666666000000000066677666000000000066666600000000000000000000000000000000000000000000
bbd58656bb558656bb558656bb586656bb5866560000665566000000000066566566000000000066556600000000000000000000000000000000000000000000
bbd6666dbbd6666dbbd6666dbbd6556dbbd6556d0000058850000000000005888850000000000005885000000000000000000000000000000000000000000000
b926556299265562992d55d29926dd629926dd620000006600000000000000666600000000000000660000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000006000000000000000055000000000000000060000000000000000000000000000000000000000000000
00000000000000000000000009999999911111190000806008000000000080066008000000000080060800000000000000000000000000000000000000000000
000000000000000000000000911111199111111900006c66c600000000006c6776c600000000006c66c600000000000000000000000000000000000000000000
03333330099999900222222091111119911111190000700007000000000070066007000000000070000700000000000000000000000000000000000000000000
0bbbbbb00aaaaaa00888888091111119911111190000600006000000000060000006000000000060000600000000000000000000000000000000000000000000
0bbbbbb00aaaaaa00888888091111119911111190000600006000000000060000006000000000060000600000000000000000000000000000000000000000000
0bbbbbb00aaaaaa00888888091111119911111190000500005000000000050000005000000000050000500000000000000000000000000000000000000000000
0bbbbbb00aaaaaa00888888091111119911111190000c0000c0000000000c000000c0000000000c0000c00000000000000000000000000000000000000000000
03333330099999900222222091111119911111190000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000007000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000
50000000000000000000000000000000000000000000500000070000000000000000000000000000000000000000000000000000005000000000000000000000
55555555555555555555555555555553000000000000000000555555555555555555555555555555530000000000000000005555555555555555555555555555
b5555555553555555555555666666555000000000000000000b5555555553555555555555666666555000000000000000010b555555555355555555555566666
55533533555533335353565555565555000000000000000000555335335555333353535655555655550000000000000000005553353355553333535356555556
5b5bb5bb5355bbbb5b5b565666555b350000000000000000005b5bb5bb5355bbbb5b5b565666555b350000000050000000005b5bb5bb5355bbbb5b5b56566655
53555555535555555555555566655b3600000000000000000053555555535555555555555566655b360000000000000000005355555553555555555555556665
535666555355bbbb5555656655555b35001000000000000000535666555355bbbb5555656655555b35000005000000000000535666555355bbbb555565665555
5556555553b5555365656556665556350000000000000070005556555553b5555365656556665556350000000000000000005556555553b55553656565566655
65555b5555553353656556565555566600000000000000700065555b5555553353656556565555566600000000000000000065555b5555553353656556565555
65535555b3555556656655555355555500000000000000700065535555b3555556656655555355555500000000000000000065535555b3555556656655555355
55b35655b3556556655555565335553500000000000000000055b35655b3556556655555565335553500000000000000000055b35655b3556556655555565335
53bb5655b3566556555655565bb5553500000000000000000053bb5655b3566556555655565bb5553500000000000000000053bb5655b3566556555655565bb5
53b55b55b35665553bb556555555553500000000000000000053b55b55b35665553bb556555555553500001000000000000053b55b55b35665553bb556555555
55555655555665555b55565555bb353500000000000000000055555655555665555b55565555bb353500000000000000000055555655555665555b55565555bb
55b5565b3556555555565556555b353500000000000000000055b5565b3556555555565556555b353500000000000000000055b5565b3556555555565556555b
35b5555b3355555555566556556b353500000000000000000035b5555b3355555555566556556b353500000000000000000035b5555b3355555555566556556b
35b55555535555353b5665556555555500000000000000000035b55555535555353b5665556555555500000000000000000035b55555535555353b5665556555
355b5665555553b5b556555566665b55000000000000000000355b5665555553b5b556555566665b55000000000000000000355b5665555553b5b55655556666
53555665655355555565665555555b3500000000000000000053555665655355555565665555555b350000000000000000005355566565535555556566555555
5355556555bb55566555665655555b350000000001000000005355556555bb55566555665655555b350000000000000000005355556555bb5556655566565555
5555b5555555b5555bb556565555bb350000000000000000005555b5555555b5555bb556565555bb350000000000000000005555b5555555b5555bb556565555
b55bbbb5356553333333555555b5b335000000000000000000b55bbbb5356553333333555555b5b335000000000000000000b55bbbb5356553333333555555b5
b55bbbb5b553bbbbbb35555535555535000000000000000000b55bbbb5b553bbbbbb35555535555535000000000000000000b55bbbb5b553bbbbbb3555553555
35533335b3555333555555566656555500000000000005000035533335b3555333555555566656555500000000070000000035533335b3555333555555566656
35555355b3bb5555555bb5565565555b00000000000000000035555355b3bb5555555bb5565565555b00000000070000000035555355b3bb5555555bb5565565
b5665555b55533353333355565555533000000000000000000b5665555b55533353333355565555533000000000700000000b5665555b5553335333335556555
55655655536666b5555555355555555500000000000000000055655655536666b5555555355555555500000000000000000055655655536666b5555555355555
55655b655556665bbbbbb5bbbb55555500000000000000000055655b655556665bbbbbb5bbbb55555500000000000000000055655b655556665bbbbbb5bbbb55
55333556355555533333355b3335555b00000000000000000055333556355555533333355b3335555b00000000000000000055333556355555533333355b3335
553bb555355555555555555555555555000000000000000000553bb555355555555555555555555555000000000000000000553bb55535555555555555555555
553b3563b35665535556655bbb55bb55000000000000000000553b3563b35665535556655bbb55bb55000000000000000000553b3563b35665535556655bbb55
5556b5553555553b36555555335555350000000000000000005556b5553555553b36555555335555350000000000000000005556b5553555553b365555553355
5555555555555553555555655555b5550000000000000000005555555555555553555555655555b5550000000000000000005555555555555553555555655555
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000075000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000077077707770777077707770770007700000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000707007007070707070700700707070000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000050000000000777007007770770077000700707070000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000007007007007070707070700700707070700000000000070500000000000000000000000000000000000000000100000
00000000000000000000500000000000007770007007070707070707770707077700700070007070000000000000000000000000000500000000000000000000
55555555555555555555530000000000007000000010000000000000000000000000000000000070000000000000000000000000000000555555555555555555
35555555555556666665550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b55555555535555555
55333353535655555655550000000000000000000000000000700000000000500000000000000000000000000000000000000000000000555335335555333353
55bbbb5b5b565666555b3500000000000000000000000000007000000000000000000000000000000000000000000001000000100000005b5bb5bb5355bbbb5b
5555555555555566655b360000000000000000000000000000700000000000000000000000000000050000000000000000000000000000535555555355555555
55bbbb5555656655555b35000000000000000000000bbb0b0b0bbb00000bbb00bb0bbb00bb000000000000000000000000000000000000535666555355bbbb55
b5555365656556665556350000000000000000000000b00b0b0b0000000b0b0b0b0b0b0b000000000000000000000000000000000000005556555553b5555365
55335365655656555556660000000000000000000000b00bbb0bb000000bb00b0b0bb00b0000000000000000000000000000000000000065555b555555335365
55555665665555535555550000000000050000000000b00b0b0b0000000b0b0b0b0b0b7b0b00000005000000000000000000000000000065535555b355555665
55655665555556533555350000000000000000000000b00b7b0bbb00000bbb0bb00b0b7bbb00000000000000000000000000000000000055b35655b355655665
566556555655565bb55535000000000050000000000000007000000000000000000000700000000000000000000000000000000000000053bb5655b356655655
5665553bb5565555555535000000000000000000000000007000000700000000000000000000000000000000000000000000000000000053b55b55b35665553b
5665555b55565555bb3535000000000000000000000000100000000777077000000000000000000000000000000000000000000000000055555655555665555b
56555555565556555b3535000000000000000000000000000000000770070700000000000000000000000000000000000000000000000055b5565b3556555555
55555555566556556b3535000000000000000000000000000000000070070770000000000000000000000000000000000000000000000035b5555b3355555555
5555353b56655565555555000000000000000000000000000000000070070770000000000000000000000000000000000000000000000035b55555535555353b
5553b5b556555566665b550000000000000000000000000000000007770707700000000000000000000050000000000000000000000000355b5665555553b5b5
5355555565665555555b350000000000000000000000000000000000000000000000000000000000000000000000000000000000000000535556656553555555
bb55566555665655555b3500000000000000000000000000000000000000000000000000000000000000000000000000000000000000005355556555bb555665
55b5555bb556565555bb350000000bb00bb0b000b000bbb00bb0bbb0bbb0b0b0bbb00000bbb0bbb00bb00bb0b0b0bbb0bbb0bbb00000005555b5555555b5555b
6553333333555555b5b335000000b000b0b0b000b000b000b0000b000b00b0b0b0000000bbb00b00b000b000b0b00b00b000b000000000b55bbbb53565533333
53bbbbbb35555535555535000000b000b0b0b000b000bb00b0000b000b00b0b0bb000000b0b00b00bbb0b000bbb00b00bb00bb00000000b55bbbb5b553bbbbbb
5553335555555666565555000000b000b0b0b000b000b000b0000b000b00bbb0b0000000b0b00b0000b0b000b0b00b00b000b00000000035533335b355533355
bb5555555bb5565565555b0000000bb0bb00bbb0bbb0bbb00bb00b00bbb00b00bbb00000b0b0bbb0bb000bb0b0b0bbb0bbb0b00000000035555355b3bb555555
55333533333555655555330000000000000000000000000000000000000000000000000000000000000000005000000000000000000000b5665555b555333533
6666b55555553555555555000000000000700000000000000000000000000000000000000000000000000000000000000000000000000055655655536666b555
56665bbbbbb5bbbb555555000000000000700000000000000000000000000000000000000000000000000000000000000000000000000055655b655556665bbb
5555533333355b3335555b0000000000007000000000000000000000000000000000000000000000000000000000000000000000000000553335563555555333
55555555555555555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000553bb5553555555555
5665535556655bbb55bb550000000000000000000000000000000000000000000000000000000000000000000000000007000000000000553b3563b356655355
55553b365555553355553500000000000000000000000000000000000000000000000000000000000000000007050000070000000000005556b5553555553b36
555553555555655555b5550000000000000000000000000000000000000000000000000000000000050000000700000007000000000000555555555555555355
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000010000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000005000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000007000000000000000000000000000
00000000000000000000000000000000000000000000000000000000007070000000000000000000000000000000000000007000000000000000000000000000
00000000000000000000000000000000000000100000000500000000007070000000000000000000000000000000000000007000000000000000000000000000
00000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000070000070000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000070000070000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000666066606660066006600010606000006660066000006660666006606660660000006060666060006000666066000660000066600660666006600000000
00000606060606000600060000000606000000600606000006060600060000600606000006060060060006000060060606000000060606060606060000000000
00000666066006600666066600000060000000600606000006600660060000600606000006600060060006000060060606000000066006060660060000000000
00000600060606000006000600000606000000600606000006060600060601600606000006060060060006000060060606060000060606060606060600000000
00000600060606660660066000000606000000600660000006660666066606660606000006060666066606660666060606660000066606600606066600000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000
00700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000700000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000700000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000700000000000000000
00000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__map__
0000000000000000000000003c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
16010000321202e1202e12031120201201f1201d1201b120181201612012120101200e1200b120091200712004120001200300001000040000400004000040000400004000030000300003000020000200001000
92010000245302253022530205301f5301d5301d5301b5301a53019530185301653016530145301353012530105300f5300d5300c5300a5200852006520045200252001520005300000000000000000000000000
06010000326402c6402664023640206401c6301963017630156401464014640136401364012640126401164013640166501465013650116500b640046400064001600006000b6000a60008600076000660005600
00020000016200662024630146001d600106000b60005600016000060001600006000060000600006000160001600016000160001600016000060000600006000060000600006000060000600016000060000600
00050000000000623000000000000723000000000000000000000000000000000000000002b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
080d00001b0001b0001b0001b0301b0001b0201d0201e030200302004020040200001b7001b700227001b7001b7001d7001b7001b7001b7001d700227001a7001b7001b700167001b7001b7001b7001c7001c700
050d00001f5001f000215001f5301f0001f5202152022530245302453024530245002070022700227001670000000000000000000000000000000000000000000000000000000000000000000000000000000000
010d00002200022000220002203022000220302403025030270302703027030270001e00020000200002000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000010501605019050160501905001050160501905016050190601b0611b0611b061290001d000170002600001050160501905016050190500105016050190501b0611b0611b0501b0501b0401b0301b025
00060000205401d540205401d540205401d540205401d54022540225502255022550225500000000000000000000025534225302553022530255301d530255302253019531275322753027530275322753027530
000600001972020720227201b730207301973020740227401b74020740227402274022740000000000000000000001672020720257201b730257301973025740227401b740277402274027740277402774027740
010c0000290502c0002a00029055290552a000270502900024000290002705024000240002400027050240002a05024000240002a0552a055240002905024000240002400029050240002a000290002405026200
510c00001431519315203251432519315203151432519325203151431519325203251431519315203251432519315203151432519325203151431519325203251431519315203251432519315203151432518325
010c00000175001750017500175001750017500175001750017500175001750017500175001750017500175001750017500175001750017500175001750017500175001750017500175001750017500175001750
010c0000195502c5002a50019555195552a500185502950024500295001855024500245002450018550245001b55024500245001b5551b555245001955024500245002450019550245002a500295001855026500
010c0000290502c0002a00029055290552a000270502900024000290002000024000240352504527050240002a050240002f0052d0552c0552400029050240002400024000240002400024030250422905026200
010c0000195502c5002a50019555195552a500185502950024500295002050024500145351654518550245001b550245002f5051e5551d5552450019550245002450024500245002450014530165401955026500
010c00002c05024000240002a05529055240002e050240002400029000270502400024000240002e050240003005024000240002e0552d05524000300502400024000290002905024000270002a0002900028000
510c0000143151931520325143251931520315163251932516315183151932516325183151931516325183251b3151e315183251b3251e315183151b3251e325183151b3151d325183251b3151d315183251b325
010c00000175001750017500175001750017500175001750037500375003750037500375003750037500375006750067500675006750067500675006750067500575005750057500575005750057500575005750
c11100000f5530f5000f5530a5000f55212500125000f5530f5000f5531f5000f5520d5520d5000d5000f5530f5000f5532e5000f5521255212500125000f5530f5000f5530a5000f5520d5520d5000d50000000
011100000f4130f4000f4130f4000f4111241112400004000f4130f4000f4130f4000f4110d41112400004000f4130f4000f4130f4000f4111241112400004000f4130f4000f4130f4000f4110d4111240003400
011000001e0500d5001e0501d0501b0501a0601a0621a062000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
511000001e0500d5001e0501d0501b0501a0601a0621a062000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00001d55024500245001b55519555245001e550245002450029500165502450024500245001e550245001e55024500245001d5551b555245001d5502450024500295001855024500275002a5002950028500
090d00001b0001b0001b0001d0001b0301b0001b0201d0201e0302003020040200401e0002000020000200001b7001d7001b7001b7001b7001d700227001a7001b7001b700167001b7001b7001b7001c7001c700
050d00001f5001f0001f500215001f5301f0001f52021520225302453024530245302250024500245002450000000000000000000000000000000000000000000000000000000000000000000000000000000000
010d00002200022000220002400022030220002203024030250302703027030270302500027000270002700000000000000000000000000000000000000000000000000000000000000000000000000000000000
51060000355522d5522755223552205521e5521b55219552165521155212552115520f5420e5420d5320b54209542075320554204532035320253201512005120050000500005000050000500005000050000500
002400001a0601f06023060210601d06028060260602606026060260602606026060260602606023060280602c0602a060280602d0602f0602f0602f0602f0600000000000000000000000000000000000000000
0024000000000000000000000000000000000000000000001f0601f0601f0601f0602606026060260602606029060280602806028060280602306023060230602306000000000000000000000000000000000000
002400000206007060020600706002060070600206007060020600706002060070600206007060020600000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002400000000000000000000000000000000000000000000000001f0601f0601f0601f060260602606026060260602b060290602b0602b0602b0602b0602b0602b0602b060000000000000000000000000000000
002400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001506000000000000000000000000000000000000
002400000206007060020600706002060070600206007060020600706002060070600206007060020600000000000000000000000000000000000007060000000000000000000000000000000000000706002060
00241a00000000000000000000000000000000000000000000000000001f0601f0601f0601f06026060260602606026060290602b0602b0602b0602b0602b0602b0602b060014000140001400014000140001400
00240e000706002060070600206007060020600706002060070600206007060020600706002060014000140001400014000140001400014000140001400014000140001400014000140001400014000140001400
64020000261200c02007620076200d020166201002010520125201352000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9116000013230132301323013230182301c2321a2301a2301a2301a2301d230212321f2301f2301f2301f2301f2301f2301f230162321d2321f232212321d2301f2301f2301f2321d2301d2301d2321c2301c230
011600000005500055000550705507055070550005500056000550705507055070550005500055000550705507055070550005500055000550705507055070550005500055000550705507055070550005500055
91160000182001c230182301c2321a2301a2301a2301a2301a2301a2301a2301a2301a2301a2221a2221a21400200002000020000200002000020000200002000020000200002000020000200002000020000200
011600000005507055070550705502045020450204507035070350703502025020250202507015070150701502000020000000000000000000000000000000000000000000000000000000000000000000000000
__music__
04 6264641d
01 401e6c1f
00 40202122
02 40232424
04 191a1b44
00 41424344
04 16174344
00 41424344
04 05060744
04 08090a44
01 0b0c0d0e
00 0f0c0d10
02 11121318
00 41424344
00 41424344
00 41424344
01 26274446
04 28294547

