pico-8 cartridge // http://www.pico-8.com
version 37
__lua__
--"star trek:collective mischief"
--by chaz(🐱)
--version 0.7.10
--tng music/starfield by phlox
--some music/sfx by gruber
--shmup tutorial by lazy devs
--playtesting by cat

function _init()
	mode1,debug,blinkt,t,lockout,shake,flash,flash_r,version="","",1,0,0,0,0,0,"0.7.10"
	cartdata("star_trek_shmup")
	--starfield test
	star_modes={"slow","normal","fast","gold"}
	mode=1--1:slow 2:normal 3:fast
			--4:green   
	stars={}
	star_density,star_speed=150,-1.6
	for i=1,star_density do
		spawn_star()
	end
	--menu_init()
	startscreen()
end

function state_switch(state)
  if state=="start" then 
    _update,_draw,mode1=update_start,draw_start,state
  elseif state=="cutscene1" then
  	_update,_draw,mode1=update_cut1,draw_cut1,state
  elseif state=="menu" then
	_update,_draw,mode1=update_menu,draw_menu,state
  elseif state=="game" then  
    _update,_draw,mode1=update_game,draw_game,state
  elseif state=="over" then
  	 _update,_draw,mode1=update_over,draw_over,state
  elseif state=="wavetxt" then
    _update,_draw,mode1=update_wavetxt,draw_wavetxt,state
  elseif state=="win" then
     _update,_draw,mode1=update_win,draw_win,state
  end
end

function startgame()
	state_switch("wavetxt")
	wave,t,lastwave,btimer,btimer2,star_speed=0,0,9,1000,1000,10
	nextwave()
	ship=makespr()
	if menu_pos==2 then
		ship.x,ship.y,ship.sx,ship.sy,ship.colh,ship.colw,ship.ded=63,90,1,1,6,5,false
	else
		ship.x,ship.y,ship.sx,ship.sy,ship.colh,ship.colw,ship.ded,ship.sprh,ship.sprw=63,90,1,1,15,6,false,2,2
	end
	--starting game conditions
	shields,cher,firefreq=5,1,20
	--score and hiscore
	score,hiscore=0,dget(0)
	--kills and hikills
	kills,hikills=0,dget(1)
	--
	muzzle,muzzle2,torspr,invul,torout,delay=0,0,0,0,0,120
	wavetime,atkfreq,nextfire,hit=220,40,0,0
	buls,buls2,ebuls,enemies={},{},{},{}
	explode,parts,parts2,shwaves,pickups,pickups2,floats={},{},{},{},{},{},{}
end

function startcut1()
	state_switch("cutscene1")
	mode,star_speed=4,10
	parts2={}
	t,b,subphs,off_1,off_2=0,0,1,0,0
	music(23)
end

function startscreen()
	state_switch("start")
	mode=2
	t,subphs,off_1,off_2,ms_y1,ms_y2,b,b2=0,1,0,0,75,82,1000,0
end

function menu_init()
	
	state_switch("menu")
	subphs,menu_pos,delay,torout=1,1,0,0
end

-->8
--tools
function spawn_star()
	local star={}
  star.x,star.y,star.spd=rnd(128),rnd(256)-128,rnd(1.5)+.5
  star.t,star.trail,star.c=4,0,7
  star.mode=star_modes[mode]
  star.seed=rnd(#stars)
  add(stars,star)
end

function drawout(myspr)
	spr(myspr.spr,myspr.x+1,myspr.y,myspr.sprw,myspr.sprh)
	spr(myspr.spr,myspr.x-1,myspr.y,myspr.sprw,myspr.sprh)
	spr(myspr.spr,myspr.x,myspr.y+1,myspr.sprw,myspr.sprh)
	spr(myspr.spr,myspr.x,myspr.y-1,myspr.sprw,myspr.sprh)
end

function drwmyspr(myspr)
	local sprx,spry=myspr.x,myspr.y
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
	local blanim={8,8,8,2,8,8,2,6,6,7,7,6,6,8,8}
	 
	if blinkt>#blanim then
		blinkt=5
	end
	return blanim[blinkt]
end

function col(a,b)
	if a.ghost or b.ghost then
		return false
	end	

 local a_left,a_top,a_right,a_bottom=a.x,a.y,a.x+a.colw-1,a.y+a.colh-1
 
 local b_left,b_top,b_right,b_bottom=b.x,b.y,b.x+b.colw-1,b.y+b.colh-1
 
 if a_top >b_bottom then return false end
 if b_top >a_bottom then return false end
 if a_left>b_right then return false end
 if b_left>a_right then return false end
 
	return true
end

function sparks(expx,expy)
	for i=1,4 do
		local myp={}
		myp.x,myp.y,myp.sx,myp.sy=expx+4,expy+4,(rnd()-1)*10,(rnd()-1)*10
		myp.age,myp.maxage,myp.size=rnd(2),9+rnd(10),1
		add(parts2,myp)
	end
end

function explodes(expx,expy,isblue)
	
	local myp={}
	myp.x,myp.y,myp.sx,myp.sy=expx+4,expy+4,0,0
	myp.age,myp.maxage,myp.size,myp.blue=rnd(2),8,10,isblue
	add(parts,myp)
	
	--clouds n shiz
	for i=1,15 do
		local myp={}
		myp.x,myp.y,myp.sx,myp.sy=expx+4,expy+4,(rnd()-0.5)*7,(rnd()-0.5)*7
		myp.age,myp.maxage,myp.size,myp.blue=rnd(2),7+rnd(7),0.75+rnd(3),isblue
		add(parts,myp)
	end
	
	--sparks
	for i=1,4 do
		local myp={}
		myp.x,myp.y,myp.sx,myp.sy=expx+4,expy+4,rnd()*17-0.5,rnd()*15-0.5
		myp.age,myp.maxage,myp.size,myp.blue=3,10+rnd(7),1,false
		add(parts,myp)
	end
big_shwave(expx,expy)
end

function bigexplode(expx,expy)
	
	local myp={}
	myp.x,myp.y,myp.sx,myp.sy,myp.age=expx+4,expy+4,0,0,rnd(2)
	
	myp.maxage,myp.size=6,20
	
	add(parts,myp)
	
	--clouds n shiz
	for i=1,15 do
		local myp={}
		myp.x,myp.y,myp.sx,myp.sy,myp.age,myp.maxage,myp.size=expx+4,expy+4,rnd()*12-6,rnd()*12-6,rnd(2),20+rnd(20),1+rnd(6)
		add(parts,myp)
	end
	
	--sparks
	for i=1,5 do
		local myp={}
		myp.x=expx+4
		myp.y=expy+4
		myp.sx=rnd()*25-0.25--partspd
		myp.sy=rnd()*25-0.25--partspd
		myp.age=3
		myp.maxage=20+rnd(20)
		myp.size=1
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

function smol_shwave(shx,shy,shcol)
	if shcol==nil then
		shcol=9
	end
	local mysw={}
	mysw.x=shx+3
	mysw.y=shy+3
	mysw.r=3
	mysw.tr=4.25
	mysw.col=shcol
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
	local pos,digit,start=5,0,0
	--tor,lowright
	if loc==3 then locx=99 locy=119 end
	--score,uppleft
	if loc==4 then locx=30 locy=0 end	
	if mynum==0 then
		spr(start+digit,locx,locy)
	end
	if mynum>=1 and mynum<=9 then
		digit=sub(mynum,1,1)
		spr(start+digit,locx,locy)
		if loc==4 then
			spr(0,locx+pos,locy)
			spr(0,locx+pos*2,locy)
		end
	end
	if mynum>=10 and mynum<=99 then
		digit,digit2=sub(mynum,1,1),sub(mynum,2,2)
		spr(start+digit,locx,locy)
		spr(start+digit2,locx+pos,locy)
		if loc==4 then
			spr(0,locx+pos*2,locy)
			spr(0,locx+pos*3,locy)
		end
	end
	if mynum>=100	then
		digit,digit2,digit3=sub(mynum,1,1),sub(mynum,2,2),sub(mynum,3,3)
		spr(start+digit,locx,locy)
		spr(start+digit2,locx+pos,locy)
		spr(start+digit3,locx+pos*2,locy)
		if loc==4 then
			spr(0,locx+pos*3,locy)
			spr(0,locx+pos*4,locy)
		end
	end
	if mynum>=1000 then
		digit,digit2,digit3,digit4=sub(mynum,1,1),sub(mynum,2,2),sub(mynum,3,3),sub(mynum,4,4)
		spr(start+digit,locx,locy)
		spr(start+digit2,locx+pos,locy)
		spr(start+digit3,locx+pos*2,locy)
		spr(start+digit4,locx+pos*3,locy)
		if loc==4 then
			spr(0,locx+pos*4,locy)
			spr(0,locx+pos*5,locy)
		end
	end
	if mynum>=10000 then
		digit,digit2,digit3,digit4,digit5=sub(mynum,1,1),sub(mynum,2,2),sub(mynum,3,3),sub(mynum,4,4),sub(mynum,5,5)
		spr(start+digit,locx,locy)
		spr(start+digit2,locx+pos,locy)
		spr(start+digit3,locx+pos*2,locy)
		spr(start+digit4,locx+pos*3,locy)
		spr(start+digit5,locx+pos*4,locy)
		if loc==4 and mynum>=10000 then
			spr(0,locx+pos*5,locy)
			spr(0,locx+pos*6,locy)
		end	
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

function doshake()
	local shakex,shakey=rnd(shake)-(shake/2),rnd(shake)-(shake/2)
	camera(shakex,shakey)
	if shake>10 then
		shake*=0.9
	else	
		shake-=1
		if shake<1 then
			shake=0
		end
	end			
end

function popfloat(fltxt,flx,fly)
	if flx<25 then
		flx=flx+25
	end
	if flx>100 then
		flx=flx-8
	end
	local fl={}
	fl.x,fl.y,fl.txt,fl.age=flx,fly,fltxt,0
	add(floats,fl)
end

function cprint(txt,x,y,c)
	print(txt,x-#txt*2,y,c)
end

function starfield_update()

 --add new stars
 if #stars<star_density then
  local star={}
  spawn_star()
 end
   
 for star in all(stars) do
  
  --apply speed
  local velocity=mid(0,star.spd+star_speed,10)
  star.y+=velocity
  
  --loop & remove excess
  if star.y>140 then
	  if #stars==star_density then
	   star.y=rnd(128)-128
	  elseif #stars>star_density then
	   del(stars,star)
	  end 
  end 
 end 
 --modes
 local mod=star_modes[mode]
 if mod=="normal" then
  if star_speed>0 then
	  star_speed-=.2
	 elseif star_speed<0 then
	  star_speed+=0.01
  end
  star_density=100  
 elseif mod=="fast" then
  if star_speed<0 then
   star_speed+=.05   
  elseif star_speed>=0 then
   star_speed+=.08
  end
  
  star_speed=mid(-1,star_speed,10)
  
  star_density+=.5
  star_density=mid(100,star_density,150)
 
 elseif mod=="slow" or mod=="gold" then
 
  if star_speed<1 then
   star_speed-=.01
  else
   star_speed-=.1
  end
  star_speed=mid(-1.6,star_speed,10)
  
  star_density+=.5
  star_density=mid(150,star_density,200) 
 
 end
end

function starfield_draw()
 for star in all(stars) do
  
  --trails
  local gradient={7,6,13,1,1}
  star.trail=star.spd+star_speed
  
  --color / depth
  local grad=0
  if star.spd>1.7 then
   star.c=7
   star.trail*=2
   grad=0
  elseif star.spd>1.4 then
   star.c=6
   star.trail*=1.4
   grad=1
  elseif star.spd>0.8 then
   star.c=13
   star.trail*=1
   grad=2
  elseif star.spd>0 then
   star.c=1
   star.trail*=0.5
   grad=3
  end
   
  star.trail=mid(1,star.trail,100)
  
  for i=1,star.trail do
   local pos=i/star.trail
   
   --modes
	   if star.mode=="normal" then
      //do nothing

	   elseif star.mode=="fast" then
	    star.c=gradient[flr(pos*(#gradient-grad))+grad]
	   
	   elseif star.mode=="slow" 
	       or star.mode=="gold" then
	    
	    local slow,gold,mod={0,0,0,0,1,1,13,13,6,00}
	    local gold={0,0,1,13,6,7,11,3,11}
		   local mod=slow
		   	      
		    if mode==1 then
       mod=slow
		    elseif mode==4 then
		     mod=gold
		    end

	    local s=flr(#mod*abs(sin((t+star.seed+star.x+star.y)/200)))

	    if star_speed<7 then
	     star.c=mod[s]
	    else
	     --star.c=7
	    end
	    

	   end

   pset(star.x,star.y-i,star.c)
  end
  
  --set mode
  if (mode==1 or mode==4) 
  and pget(star.x,star.y)==0 then
   star.mode=star_modes[mode]
  elseif star.y<0 then
   star.mode=star_modes[mode]
  end
  
 end
end
-->8
-- update functions
function update_game()
	t+=1
	blinkt+=1
	doshake()
	starfield_update()
	--reset vars
	ship.sx,ship.sy,muzzle,muzzle2=0,0,0,0
	
	if menu_pos==2 then
		ship.spr,shipsd=18,1.6
		pulse_p,q_tor=2.5,25
	else
		ship.spr,shipsd=45,0.8
		pulse_p,q_tor=3.25,30
	end	
	--left
	if btn(0) and ship.ded!=true then
		ship.sx=-shipsd+rnd(0.25)-0.05
		if menu_pos==2 then
			ship.spr=17
		else
			ship.spr=43
		end
	end
	--right
	if btn(1) and ship.ded!=true then
		ship.sx=shipsd+rnd(0.25)-0.05
		if menu_pos==2 then
			ship.spr=19
		else
			ship.spr=47
		end
	end
	--up
	if btn(2) and ship.ded!=true then
		ship.sy=-shipsd+rnd(0.25)-0.05
	end
	--down
	if btn(3) and ship.ded!=true then
		ship.sy=shipsd+rnd(0.25)-0.05
	end	
	--controls phasers o
	if btimer<=0 then	
		if btn(5) and ship.ded!=true then
			local newbul=makespr()
			newbul.colw,newbul.sx,newbul.sy=4,0,-4
			if menu_pos==2 then
				newbul.x,newbul.y,newbul.spr,muzzle2=ship.x,ship.y-1,16,3
			else
				newbul.x,newbul.y,newbul.spr,muzzle2=ship.x+2,ship.y-4,49,5
			end
			add(buls,newbul)
			sfx(0)
			btimer=3.5
		end
	end	
	--controls torpedoes x
	torout-=1
	if btimer2<=0 then
		if btn(4) and ship.ded!=true and torout<0 then
			if cher>=1 then
				sfx(44)
				cherbomb()
				cher,btimer2,shake,muzzle2,invul=0,35,10,5,30
			else
			torout=15
			sfx(4)
			end	
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
	if ship.y>118-ship.colh then
		ship.y=118-ship.colh
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
			
	end
	-- moving pickups
	for mypick in all(pickups) do
		move(mypick)
		if mypick.y>128 then
			del(pickups,mypick)
		end		
	end
	
	for mypick in all(pickups2) do
		move(mypick)
		if mypick.y>128 then
			del(pickups2,mypick)
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
			if col(myen,mybul) and ship.ded!=true then
				if mybul.type=="qtor" then
					smol_shwave(mybul.x,mybul.y,12)
					applydam(myen,mybul,mybul.type)
					del(buls2,mybul)
				elseif mybul.type=="bomb" then
					smol_shwave(mybul.x,mybul.y)	
					applydam(myen,mybul,mybul.type)
					del(buls2,mybul)
				end
				if myen.hp<=0 then
					killen(myen)
				end
			end	
		end		
	end

	-- collision ebuls x bomb
	for myebuls in all(ebuls) do
		for mybul in all(buls2) do
			if mybul.type=="bomb" then
				if col(myebuls,mybul) and ship.ded!=true then
						smol_shwave(myebuls.x,myebuls.y)	
						del(ebuls,myebuls)
				end	
			end
		end		
	end
	
	-- collision borg x pulse_phasers
	for myen in all(enemies) do
		for mybul in all(buls) do
			if col(myen,mybul) and ship.ded!=true then
				smol_shwave(mybul.x,mybul.y)
				del(buls,mybul)
				applydam(myen,mybul,"pulse")
				if myen.hp<=0 then
					killen(myen)
				end
			end
		end		
	end
	
	-- collision ship x enemies
	if invul<=0 then
		for myen in all(enemies) do
			if col(myen,ship) and ship.ded!=true then
				if myen.boss and myen.mission=="flyin" then
					shake,hit,invul,flash_r=5,2,30,4
					shields-=1
					sparks(ship.x,ship.y)
					applydam(myen,mybul,"bomb")
					explodes(ship.x,ship.y,true)
					ship.y=100
				else
					applydam(myen,mybul,"ram")
					shake=10
					sfx(2)
					hit=2
					flash_r=4
					ship.y=100
					sparks(ship.x,ship.y)
					explodes(ship.x,ship.y,true)
				if myen.hp<=0 then	
					killen(myen)	
				end
			end
		end		
	end
	else 
		invul-=1		
	end
	hit-=1
	-- coll x ebuls
	if invul<=0 then
		for myebul in all(ebuls) do
			if col(myebul,ship) and ship.ded!=true then
				sfx(2)
				shields-=1
				invul,shake,hit,flash_r,ship.y=45,12,2,4,100
				sparks(ship.x,ship.y)
				explodes(ship.x,ship.y)
			end		
		end
	end
	
	-- collision pickups x ships
	-- torpedo spread
	for mypick in all(pickups) do
		if col(mypick,ship) and ship.ded!=true then
			del(pickups,mypick)
			plogic(mypick)
		end	
	end
	-- shield recharge
	for mypick in all(pickups2) do
		if col(mypick,ship) and ship.ded!=true then
			del(pickups2,mypick)
			plogic2(mypick)
		end	
	end

	--u ded
	if shields<=0 then	
		invul=10000
		delay-=1
		ship.ded=true
		if score>hiscore then
			dset(0,score)
		end
		if kills>hikills then	
			dset(1,kills)
		end
		wave_rec=wave	
	end
	if shields<=0 and ship.ded and delay>118.5 then
		explodes(ship.x,ship.y)
		music(8)
	end
	if delay==0 then
		state_switch("over")
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
	
	if mode1=="wavetxt" and wave<9 then
		mode=3
		star_speed+=0.05
		if star_speed>=7 then
			star_speed=7
		end
	elseif mode1=="game" and wave<9 then
		if mode==3 then
			star_speed-=0.27
			if star_speed<=3 then
				mode=1
			end
		elseif mode==1 then
			if star_speed>-0.5 then
				star_speed-=0.07
			else	
				star_speed=-0.5
			end	
		end
	elseif mode1=="wavetxt" and wave>=8 then
		mode=4
		star_speed=5
	elseif mode1=="game" and wave>=8 then
		mode=4
	end
	
	if mode1=="game" and #enemies==0 and ship.ded!=true and wave!=9 then
		nextwave()
	end
end
-- start screen check for x/o
function update_start()
	starfield_update()
	blinkt+=1
	t+=1	
	if t>0 and t<2 and subphs==1 then
		b2=t
	end
	if subphs==1 then	
		mode=1
		star_speed=0.5
		if btn(4)==false and btn(5)==false then
			btnreleased=true
		end
		if btnp(5) or btnp(4) then
			btnreleased=false
			b=t
		end		
		if btnreleased then
			if b+0.25*30<t then
				subphs=1.5
			end	
		end
	elseif subphs==1.5 then
		sfx(10)
		menu_init()	
	elseif subphs==2 then
		if b+0.75*30<t then
			star_speed+=0.3
			if star_speed>=8 then
				star_speed=8
			end
			ms_y1-=1.5
			ms_y2-=1.5
			off_1-=3
			off_2-=3
			music(-1,2000)
		end	
		if b+4*30<t then
			
			b=t
			subphs=3
		end
	elseif subphs==3 then
		if b+0.5*30<t then
			mode=4
			startcut1()
			t=0
			b=t
		end	
	end	
end

function update_cut1()
	starfield_update()
	blinkt+=1
	t+=1
	if t>0 and t<2 then
		b=t
	end
	
		if off_1>-60 then 
			off_1-=2
			off_2-=2
		else
			off_1-=1
			off_2-=1
		end
		if off_1==-50 then
			sfx(8)
		end			
		star_speed-=0.10
		
		if off_1<-260 then
			
			startgame()
		end
end

function update_over()
	blinkt+=1
	t+=1
	if t<lockout then
		return
	end
	if btn(4)==false and btn(5)==false then
		btnreleased=true
	end
	if btnreleased then
		if btnp(5) or btnp(4) then
			startgame()
			music(5)
			wave=wave_rec
			btnreleased=false
		end
	end
end

function update_win()
	blinkt+=1
	t+=1
	lockout=t+30
	if t<lockout then
		return
	end

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
	star_speed-=0.01
	if wavetime<=0 then
	
		state_switch("game")
		
		btimer=0
		btimer2=0
		
		spawnwave1()
	end	
	
	if ship.y<57 then
		ship.y=57
	end
	
end

function update_menu()
	
	music(-1,100)
	blinkt+=1
	
	t+=1
	
	
	if menu_pos==1 then
		rx,ry,lrx,lry=25,25,95,67
	elseif menu_pos==2 then
		rx,ry,lrx,lry=25,68,95,107
	end
	delay-=1
	if btnp(⬆️) and delay<0 then
		menu_pos+=1
		sfx(9)
		delay=10
	elseif btnp(⬇️) and delay<0 then
		menu_pos+=1
		sfx(9)
		delay=10
	end
	
	if btnp(❎) and delay <0 then
		sfx(10)
		delay=1000
		torout=26
		
	end
	if torout>25 then
		torout+=1
	end
	if torout>50 then
		music(5)
		state_switch("start")
		subphs=2
		t=0
		b=t
	end
	
	if menu_pos>=3 then
		menu_pos=1
	end
end
-->8
-- draw functions
function draw_game()
	print(wavetime,50,50)
	if flash>0 then
		flash-=1
		cls(1)
	elseif flash_r>0 then
		flash_r-=1
		cls(8)
	else	
		cls(0)
	end	
	starfield_draw()
	-- draw player ship
	if invul<=0 then
		drwmyspr(ship)	
		else
		if invul<=0 and ship.ded then
			
		elseif invul>0 and ship.ded!=true then
			if sin(t/5)<0 then
				
				drwmyspr(ship)
				if menu_pos==2 then
					spr(34,ship.x,ship.y)
				elseif menu_pos==1 then
					sspr(96,72,16,16,ship.x-2,ship.y-1,20,20)
				end
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
	--drawing pickups
	for mypick in all(pickups) do
		local mycol=7
		if t%4<2 then
			mycol=14
		end
			for i=1,15 do
				pal(i,mycol)
			end	
		drawout(mypick)
		pal()
		drwmyspr(mypick)
	end
	
	for mypick in all(pickups2) do
		local mycol=7
		if t%4<2 then
			mycol=14
		end
			for i=1,15 do
				pal(i,mycol)
			end	
		drawout(mypick)
		pal()
		drwmyspr(mypick)
	end
	--drawing enemies
	for myen in all(enemies) do
		if myen.flash>0 then
			myen.flash-=1
			if myen.boss then
				if t%4<2 then
					pal(11,8)
					pal(3,2)
				end
				myen.spr=136	
				else
				for i=1,15 do
					pal(i,7)
				end
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
		if menu_pos==2 then
			circfill(ship.x+2,ship.y-1,muzzle2,9)
		else
			circfill(ship.x+3,ship.y-1,muzzle2,9)
		end
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
				del(parts2,myp)
			end
		end
	end
	
	for myebul in all (ebuls) do
		pal(12,11)
		pal(1,3)
		drwmyspr(myebul)
		pal()
	end	
	
	--floats
	for myfl in all(floats) do
		local mycol=7
		if t%4<2 then
			mycol=8
		end 	
		cprint(myfl.txt,myfl.x,myfl.y,mycol)
		myfl.y-=0.5
		myfl.age+=1
		if myfl.age>60 then
			del(floats,myfl)
		end	
	end
	--don't draw game below	
	--ui elements
	
	--ending taunt message
	
	if delay<119 then
		print("your score is only",15,63,11)
		print(score.."00",89,63,8)
		
	end
	
	--lcars ui for torpedoes
	pal(12,8)
	spr(123,77,119,2,1)
	spr(104,69,119)
	for x=1,4 do
		spr(120,84+8*x,119)
	end
	spr(111,119,119)
	
	pal(7,8)
	pal(6,2)
	dis_spr(cher,3)
	pal()
	
	--torpedo related alerts
	if torout>14 then
		popfloat("no torpedoes!",ship.x,ship.y)
	end

	--pickups
	sspr(64,16,8,8,90,119,7,7)

	--lcars ui for shields
	spr(104,0,119)
	spr(105,8,119,4,1)
	for i=1,5 do
		if invul>0 and ship.ded!=true then
			if sin(t/5)<0 then
				spr(109,31+i*6,119)
			end 
		else
				spr(109,31+i*6,119)
		end	
	end
	for i=1,5 do
		if shields>=i then
			spr(26,31+i*6,119)
		end
	end

	if invul>0 and ship.ded!=true and hit==1 then
		popfloat("shields hit!",ship.x,ship.y)
	end
	
	--score
	pal(12,13)
	spr(104,0,0)
	
	for x=1,7 do
		spr(120,8*x,0)
	end
	
	spr(111,59,0)
	pal()
 spr(12,8,0,3,1)
	pal(7,8)
	pal(6,2)
	dis_spr(score,4)
	pal()
	
	print(debug,0,9,7)
	
end

function makescore(val)
	if val==0 then
		return "0"
	end
	return val.."00"
end

function draw_start()
	blinkt+=1
	cls(0)
	starfield_draw()
	cprint(version,64,120+off_1,1)

	if subphs==1 then
		spr(45,60,ms_y1,2,2)
		spr(18,53,ms_y2)
		if b2+1.5*30<t then
			cprint("press x to save earth!",65,100,blink())
		end
	elseif subphs==2 then
		if menu_pos==2 then
			spr(18,53,ms_y2)
		else
			spr(45,60,ms_y1,2,2)
		end
	end
	spr(192,0,25+off_1,16,3)
 	--print("time to go assimilating!",17,80,8)
end		
function draw_over()
	cls(0)
	starfield_draw()
	mode=1
	cprint("score:"..makescore(score),64,20,7)
	if score>hiscore then
		cprint("new highscore!",64,30,blink())
	end
	
	cprint("the borg",60,45,11)
	cprint("assimilated earth!",64,53,11)
	--lololol! n00b!
		
	cprint("press x to try again!",64,90,blink())
	
end
function draw_cut1()
	cls(0)
	starfield_draw()
	
	--[[
	cprint("these borg drones",64,50,11)
	cprint("are gonna pay for",64,60,11)
	cprint("shootin' up my ride!",64,70,11)
	cprint("press x to save earth",64,100,blink())
	]]--
	spr(64,40,160+off_1,2,2)
	spr(64,10,140+off_2,2,2)
end

function draw_win()
	cls(0)
	draw_game()

	cprint("you saved earth!",64,20,8)
	cprint("good job!",64,30,8)

end

function draw_wavetxt()
	
	draw_game()
	-- wave ui
	pal(12,8)
	spr(104,35,49)
	for i=1,6 do
		spr(120,36+i*7,49)
	end
	spr(111,82,49)
	pal()
	if wave==lastwave then
		cprint("Oh no!",64,50,blink())
	else 
		cprint("wave "..wave.. " of "..lastwave,64,50,blink())
	end
end

function draw_menu()
cls()
draw_start()
rectfill(20,10,100,113,2)
rectfill(25,15,95,108,0)

rect(rx,ry,lrx,lry,8)
if torout>26 then
	rectfill(rx,ry,lrx,lry,blink())
end
cprint("select your ship:",62,18,7)

cprint("uss enterprise",62,27,12)
spr(45,57,40,2,2)
print("def:",29,60,8)
print("5",45,60,7)
print("spd:",51,60,8)
print("2",67,60,7)
print("off:",72,60,8)
print("5",88,60,7)

cprint("uss defiant",62,70,12)
spr(18,59,85)
print("def:",29,100,8)
print("3",45,100,7)
print("spd:",51,100,8)
print("5",67,100,7)
print("off:",72,100,8)
print("4",88,100,7)
end
-->8
--waves and enemies

function spawnwave1()
	t+=1
	if wave<lastwave then
		sfx(28)
	else
		music(10)
	end
	if wave==1 and wavetime<=0 then
	--opening wave
	atkfreq,firefreq=50,20
	placeens({
		{0,0,0,1,1,1,0,0,0,0},
		{0,0,1,1,1,1,1,1,0,0},
		{0,1,1,1,1,1,1,1,1,0},
		{1,1,1,1,1,1,1,1,1,1}
	})
	end
	
	if wave==2 and wavetime<=0 then
	-- sphere introduction
	atkfreq,firefreq=47,20
	placeens({
		{0,0,0,0,2,0,0,0,0,0},
		{0,1,1,1,1,1,1,1,1,0},
		{0,1,1,1,1,1,1,1,1,0},
		{1,1,1,2,1,1,1,2,1,2}
	})
	end
	if wave==3 and wavetime<=0 then
	-- medium cube introduction
	atkfreq=45
	firefreq=20
	placeens({
		{3,1,2,1,1,3,1,2,1,3},
		{1,1,2,2,2,2,1,2,1,2},
		{1,1,1,1,1,1,1,2,1,1},
		{0,0,0,1,2,1,1,0,0,0}
	})
	end
	if wave==4 and wavetime<=0 then
	-- pyramid intro
	atkfreq=42
	firefreq=20
	placeens({
		{3,3,2,3,3,3,3,2,3,3},
		{1,1,1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,1,1,1},
		{2,2,0,2,2,2,2,2,0,2}
	})		
	end
	if wave==5 and wavetime<=0 then
	-- assim fed ship intro
	atkfreq=100
	firefreq=20
	placeens({
		{3,3,3,0,5,0,3,3,3,1},
		{0,2,2,3,0,0,1,2,3,1},
		{0,0,2,2,1,0,1,1,2,1},
		{0,0,0,1,0,0,1,0,0,2}
	})
	end
	-- assim fed ships are angry
	if wave==6 and wavetime<=0 then
	atkfreq=45
	firefreq=20
	placeens({
		{0,0,5,0,5,0,5,0,0,0},
		{2,1,0,0,0,0,0,0,1,2},
		{2,1,3,1,1,1,1,3,1,2},
		{1,1,2,1,1,1,1,2,1,1}
	})
	end
	-- cube hell
	if wave==7 and wavetime<=0 then
	atkfreq=100
	firefreq=20
	placeens({
		{0,0,0,0,0,0,0,0,0,0},
		{6,0,3,3,3,3,3,3,3,0},
		{0,0,3,3,3,3,3,3,3,0},
		{3,3,3,3,3,3,3,3,3,0}
	})
	end
	-- cube's revenge
	if wave==8 and wavetime<=0 then
	atkfreq=300
	firefreq=40
	placeens({
		{6,0,0,0,6,0,0,0,6,0},
		{0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0},
		{0,0,0,0,0,0,0,0,0,0}
	})
	end
	--final baws
	if wave==9 and wavetime<=0 then
	atkfreq=25
	firefreq=20
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
	ebuls={}
	if wave>lastwave and ship.ded!=true then
		state_switch("win")
		lockout=t+50
		music(2)
		if score>hiscore then
			dset(0,score)
		end
		if kills>hikills then	
			dset(1,kills)
		end
	else
		if wave==1 then
			music(-1,1000)
			music(22)
			
		else
			music(0)
		end
			state_switch("wavetxt")
			wavetime=90
	end
	
end

function spawnen(entype,enx,eny,enwait)
	local myen=makespr()
		myen.x,myen.y,myen.mission,myen.posx,myen.posy,myen.anispd=enx*rnd(3),eny-50,"flyin",enx,eny,0.4
		myen.wait,myen.type=enwait,entype
	if entype==nil or entype==1 then
		--borg probe
		myen.spr=68
		myen.hp=2.51
		myen.ani={68,69,70,71}
		myen.colw=5
		myen.colh=6
		myen.score=1
	elseif entype==2 then
		-- sphere
		myen.spr=84
		myen.hp=7
		myen.ani={84,85,86,87}
		myen.colw=8
		myen.colh=8
		myen.score=3
	elseif entype==3 then
		-- med borg cube
		myen.spr=50
		myen.hp=13
		myen.ani={50,51,52,53}
		myen.colw=8
		myen.colh=8
		myen.score=6
	elseif entype==4 then
		-- pyramid, not used
	elseif entype==5 then
		-- mini boss-assimilated fed
		myen.spr=70
		myen.hp=25
		myen.ani={72,74,76}
		myen.sprw=2
		myen.sprh=2
		myen.colw=8
		myen.colh=15
		myen.score=10
	elseif entype==6 then
		-- large cube -- second mini boss
		myen.spr=64
		myen.hp=48
		myen.ani={64,66,96}
		myen.sprw=2
		myen.sprh=2
		myen.colw=14
		myen.colh=14
		myen.score=15
	elseif entype==7 then
		-- invader sphere - doesn't exist.
		myen.x=48
		myen.y=-24
		myen.posx=48
		myen.posy=25
		myen.spr=128
		myen.hp=150
		myen.ani={128,132}
		myen.sprw=4
		myen.sprh=4
		myen.colw=32
		myen.colh=32 
		myen.boss=true
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
		--easing function
		myen.ghost=true
		local dx=(myen.posx-myen.x)/12
		local dy=(myen.posy-myen.y)/12
		if myen.boss then
			dx=min(dx,1)
			dy=min(dy,1)
		end
			myen.x+=dx
			myen.y+=dy
		
		if abs(myen.posy-myen.y)<1 then
			myen.y=myen.posy
			myen.x=myen.posx
			if myen.boss then
				sfx(53)
				myen.shake,myen.wait,myen.mission=20,25,"boss1"
				myen.phbegin=t
				myen.ghost=false
			else
				myen.mission="protec"
				myen.ghost=false
			end
		end
	--wait for collective	
	elseif myen.mission=="protec" then
		--boss first phase	
	elseif myen.mission=="boss1" then
		boss1(myen)
	elseif myen.mission=="boss2" then
		boss2(myen)
	elseif myen.mission=="boss3" then
		boss3(myen)
	elseif myen.mission=="boss4" then
		boss4(myen)
	elseif myen.mission=="boss5" then
		boss5(myen)
	--you will be assimilated.
	elseif myen.mission=="assim" then
		--borg probe
		if myen.type==1 then
			myen.sy=0.95
			myen.sx=sin(t/75)+0.5
			if t%25==0 then
				fireshotmod(myen,3,1.25,time()/16)
			end
			tweakloc(myen)
			
			--sphere
		elseif myen.type==2 then
			local	tar1x,tar1y,tar2x,tar2y=ship.x+4,ship.y+4,myen.x,myen.y
			if ship.y-myen.y<5 then 
				myen.sx=0
				myen.sy=2 
			else
				angle=atan2(tar1y-tar2y,tar1x-tar2x)
				myen.sx=sin(angle)-0.10
				myen.sy=cos(angle)+0.25
			end
			if t%30==0 then
					fireshotgun(myen,5,1.5,0.10)
			end
			--med borg cube
		elseif myen.type==3 then
			myen.sy=0.5
			myen.sx=sin(time(rnd())/20)
			if myen.y<65 then
				if t%40==0 then
					aimedfire(myen,2)
				end
			elseif myen.y>=66 then
				if t%30==0 then
					fireshotgun(myen,6,1.5,-0.15)
				end
			end		
			
			tweakloc(myen)
			--pyramid
		elseif myen.type==4 then
			--assimilated fed
		elseif myen.type==5 then
			myen.sy=0.25
			if t%55==0 and myen.hp>=24 then
				firespread(myen,12,1.5,time()/8)
			elseif t%35==0 and myen.hp<24 then
				aimedfire(myen,2)	
			end	
					
			--large cube
		elseif myen.type==6 then
			if t%19==0 then
				aimedfire(myen,2)
			end
			if myen.y>91 then
				myen.sy=-0.5	
			elseif myen.y<25 then
				myen.sy=0.25
			end	
			--invader
		elseif myen.type==7 then
			--taken care of in boss function
		end	
		move(myen)
	end
end

function picktimer()
	if mode1!="game" then
		return
	end	
	
	if t>nextfire then
		pickfire()
		nextfire=t+firefreq+rnd(firefreq)
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

	for myen in all(enemies) do
		if myen.type==6 and myen.mission=="protec" then
			if t%3==0 then
				firespread(myen,12,1,time()/8)
				return
			end
		end
	end
	
	myindex=#enemies-myindex
	local myen=enemies[myindex]
	if myen==nil then return
	elseif myen.mission=="protec" then
		--
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

	if myen.boss then
		myen.mission,myen.phbegin,myen.ghost="boss5",t,true
		ebuls={}
		sfx(54)
		return
	end
	local scoremult=1
	if myen.mission=="assim" then
		scoremult=3
	end
	score+=myen.score*scoremult
	popfloat(makescore(myen.score*scoremult),myen.x,myen.y)
	kills+=1
	explodes(myen.x,myen.y)
	del(enemies,myen)
	sfx(2)
	reschance,cherchance=0.009,0.09
	if shields==5 then
		reschance=0
	elseif shields==1 then
		reschance=0.25
	end		
	if myen.mission=="assim" then
		if rnd()<0.75 then
			pickattack()
		end
		cherchance=0.15
	end
	if rnd()<reschance then
		drop_pickup2(myen.x,myen.y)
	end
	if rnd()<cherchance then
		drop_pickup(myen.x,myen.y)
	end
end

function drop_pickup(pix,piy)
	local mypick=makespr()
	mypick.x,mypick.y,mypick.sy,mypick.spr=pix,piy,0.85,40
	add(pickups,mypick)
end

function drop_pickup2(pix,piy)
	local mypick=makespr()
	mypick.x,mypick.y,mypick.sy,mypick.spr=pix,piy,0.85,41
	add(pickups2,mypick)
end

function plogic(mypick)
	
	cher+=1
	popfloat("torpedoes!",mypick.x+4,mypick.y)
	smol_shwave(mypick.x,mypick.y,8)
	if cher>=10 then
		if shields<5 then
			shields,cher=5,0
			sfx(43)
			popfloat("shields restored!",mypick.x+4,mypick.y)
		end
	else
	sfx(42)
	end
end

function plogic2(mypick)
	if shields<5 then
		shields+=1
		sfx(42)
		popfloat("shields!",mypick.x+4,mypick.y)
	else
		sfx(04)
		popfloat("shields at max!",mypick.x+4,mypick.y)
	end
end

function tweakloc(myen)

-- tweaking location--
	if myen.x<32 then
		myen.sx+=1-(myen.x/32)
	end
	
	if myen.x>88 then
		myen.sx-=(myen.x-88)/32
	end
	
end
-->8
--bullets

function fire(myen,ang,spd)
	local myebul=makespr()
	myebul.x,myebul.y,myebul.spr,myebul.ani,myebul.anispd=myen.x,myen.y+2,36,{36,37,38,39,36},0.75
	
	myebul.sx,myebul.sy=sin(ang)*spd,cos(ang)*spd
	
	myebul.colw,myebul.colh=5,5

	if myen.boss!=true then
		myen.flash1=4
		sfx(37)
	else
		sfx(45)
	end
	myebul.bulmode=true
	
	if myen.boss then
		myebul.x=myen.x+13
		myebul.y=myen.y+15
	end
	if myen.type==6 then
		myebul.x=myen.x+8
		myebul.y=myen.y+8
	end
	
	add(ebuls,myebul)
	
	return myebul
	
end

function firespread(myen,num,spd,base)
 
	for i=1,num do
		fire(myen,1/num*i+base,spd)
	end	
	
end

function fireshotgun(myen,num,spd,base)
 local b=base
	for i=1,num do
		fire(myen,(-0.30)+(b*i),spd)
	end	
	
end

function fireshotmod(myen,num,spd,base)
 
	for i=1,num do
		fire(myen,rnd()%1,spd)
	end	
	
end

function aimedfire(myen,spd)
	local myebul=fire(myen,0,spd)
	local ang=atan2(ship.y-(myebul.y),ship.x-(myebul.x))
	myebul.sx=sin(ang)*spd
	myebul.sy=cos(ang)*spd
end

function applydam(myen,mybul,kind)
	sfx(3)
	sparks(myen.x,myen.y)
	
	if myen.boss then
		myen.flash=3
	else
		myen.flash=2
		myen.y=myen.y-1
	end
	if myen.mission!="flyin" then
		if kind=="pulse" then
			myen.hp-=pulse_p
		elseif kind=="bomb" then
			myen.hp-=mybul.dmg
			shake=6
		elseif kind=="ram" then
			myen.hp-=15
			shields-=1
			invul,shake=45,8
			sparks(myen.x,myen.y)	
		end
	end		
	return myen
	
end

function cherbomb()
	local spc=0.25/(cher*2)
	flash=3
	for i=0,cher*2 do
		local ang=0.375+spc*i
		local newbul=makespr()
		newbul.x=ship.x
		newbul.y=ship.y-3
		newbul.spr=36
		newbul.dmg=10
		newbul.type="bomb"
		newbul.sx=sin(ang)*4
		newbul.sy=cos(ang)*4
		add(buls2,newbul)
		line(newbul.x,newbul.y,newbul.x+4,newbul.y+4,7)
	end
	big_shwave(ship.x,ship.y)
end
-->8
--boss
function boss1(boss)
	--movement
	local spd=2
	
	if boss.sx==0 or boss.x>=93 then
		boss.sx=-spd
	end
	
	if boss.x<=3 then
		boss.sx=spd
	end

	--shooting
	if t%30>2.25 then
		if t%3==0 then
			fire(boss,0,2)
		end
	end
	
	--transition
	
	if boss.phbegin+8*30<t then
		boss.mission="boss2"
		boss.phbegin=t
		boss.subphase=1
	end	
	move(boss)
end

function boss2(boss)
	local spd=1.5
	--movement
	if boss.subphase==1 then
		boss.sx=-spd
		if boss.x<=4 then
			boss.subphase=2
		end
	elseif boss.subphase==2 then
		boss.sx=0
		boss.sy=spd
		if boss.y>=84 then
			boss.subphase=3
		end
	elseif boss.subphase==3 then
		boss.sx=spd
		boss.sy=0
		if boss.x>=91 then
			boss.subphase=4
		end
	elseif boss.subphase==4 then
		boss.sx=0
		boss.sy=-spd
		if boss.y<=25 then
			boss.mission="boss3"
			boss.phbegin=t
			boss.sy=0
		end
	end
	--shooting
	if t%15==0 then
		aimedfire(boss,2)
	end
	--transtion
	
	move(boss)
end

function boss3(boss)
	
	--movement
	local spd=0.5
	
	if boss.sx==0 or boss.x>=93 then
		boss.sx=-spd
	end
	
	if boss.x<=3 then
		boss.sx=spd
	end
	--shooting
	
	if t%10==0 then
		firespread(boss,8,3,time()/16)
	end
	--transtion
	
	if boss.phbegin+8*30<t then
		boss.mission,boss.phbegin,boss.subphase="boss4",t,1
	end
	move(boss)
end

function boss4(boss)
	--movement
	local spd=1.5
	if boss.subphase==1 then
		boss.sx=spd
		if boss.x>=91 then
			boss.subphase=2
		end
	elseif boss.subphase==2 then
		boss.sx=0
		boss.sy=spd
		if boss.y>=84 then
			boss.subphase=3
		end
	elseif boss.subphase==3 then
		boss.sx=-spd
		boss.sy=0
		if boss.x<=4 then
			boss.subphase=4
		end
	elseif boss.subphase==4 then
		boss.sx=0
		boss.sy=-spd
		if boss.y<=25 then
			boss.mission,boss.phbegin,boss.sy="boss1",t,0
		end
	end
	--shooting
	if t%12==0 then
		if boss.subphase==1 then
			fire(boss,0,2)
		elseif boss.subphase==2 then
			fire(boss,0.25,2)
		elseif boss.subphase==3 then
			fire(boss,0.5,2)
		elseif boss.subphase==4 then
			fire(boss,0.75,2)
		end
		
	end
	--transtion
	move(boss)
end

function boss5(boss)
	boss.shake,boss.flash=10,10
	music(-1)
	if t%8==0 then
		explodes(boss.x-5+rnd(32),boss.y-5+rnd(32))
		sfx(2)
		shake=2
	end
	if boss.phbegin+3*30<t then
		if t%4==2 then
			explodes(boss.x-5+rnd(32),boss.y-5+rnd(32))
			sfx(2)
			shake=2
		end
	end
	if boss.phbegin+6*30<t then
		score+=100
		popfloat(makescore(100),boss.x+16,boss.y+6)
		shake=18
		bigexplode(boss.x+15,boss.y+15)
		sfx(46)
		enemies={}	
	end
 
	if #enemies==0  then
		nextwave()
	end

end
__gfx__
67600000070000000700000007600000007000006770000007000000677000006760000067600000776167617761676167616771676177616771111100000000
70700000770000006070000070700000077000007000000070700000707000007070000070700000717171717171717171717111767171717111111100000000
70700000070000000070000000700000707000007000000070000000007000007070000070700000717171717171711171117111717171717111111100000000
70700000070000000700000007000000707000007760000077600000007000006760000067700000771171717711711167617111717177117711111100000000
70700000070000000700000000700000777000000070000070700000007000007070000000700000717171717761767111717111717177617111111100000000
70700000070000007000000070700000007000000070000070700000007000007070000000700000717171717171717171717111767171717111111100000000
67600000777000007760000007600000006000006760000007600000006000006760000077600000776167617171676167616771676171717761111100000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
070700000700000000700000007000000000000000065000005665000005600000000000000000000ccccc100000000000000000000000000000000000000000
970790000580000008580000085000000000000000076000006776000006700000000000000bbbb00cccccc00000000000000000000000000000000000000000
79097000575500005575500055750000000000000008500000588500000580000000000000b00b000cccccc00000000000000000000000000000000000000000
79097000567c0000c767c000c7650000000000000505508080055008080550500000000000b00b000cccccc00000000000000000000000000000000000000000
9a0a90000560000006560000065000000000000006066060600660060606606000000000088088000cccccc00000000000000000000000000000000000000000
0a0a00000060000000600000060000000000000007677c707c6776c707c7767000000000878808800cccccc00000000000000000000000000000000000000000
000000000000000000000000000000000000000006066060600660060606606000000000888808800ccccc100000000000000000000000000000000000000000
00000000000000000000000000000000000000000c0000c0c000000c000000000000000008808800000000000000000000000000000000000000000000000000
00000000000000001c1c10000000000000010000000100000001000000010000000d770000666600000000000016000000000000006666000000000000610000
0000000000000000c000c10000000000010c010000c1c000000c00000017100000dcd70006cccc60000000000516500000000000056666500000000005615000
0000000000000000c000c1000000000000171000001710000017100000c7c00000dcc77006111160000000001155660000000000665665660000000066551100
000760000000000010001100000000001c777c101c777c101c777c101c777c100d1c7c7006cccc60000000001116660000000000666776660000000066611100
0085580000000000c000c1000000000000171000001710000017100000c7c0000d1c7cd006111160000000001155660000000000665665660000000066551100
0076670000000000c000c00000000000010c010001c1c100000c0000001710000017cd0006cccc60000000000288700000000000058888500000000007882000
00c88c00000000001c1c1000000000000001000000010000000100000001000000711d0006111160000000000016000000000000006666000000000000610000
0000000000000000000000000000000000000000000000000000000000000000000dd00000666600000000000016000000000000000550000000000000610000
00566500009000005655b6555655665556556b555655665500000000a000790967c0990000566500000000002016080000000000800660080000000080610200
0067760000700000b655665566556655b655665566556655000000007a9a979a5600009000677608000000001116c600000000006c6776c6000000006c611100
00588500007000005656655b5b56b5565656b55b5b5b655600001000009779a76000900000588507000000006000070000000000700660070000000070000600
0005500000700000555555555555555555555555555555550001c100099990790009980000959099000000001000060000000000600000060000000060000100
080660800090000055b56665556566b555656b6555b56b65000c7c000906907990997550977a97aa000000001000060000000000600000060000000060000100
0767767000900000565555665b5555665655556b565555660001c10007c79997099700009aa9a790000000001000050000000000500000050000000050000100
0c0000c000a000005655655b5655655b565565565655b5560000100006066060000600009799909000000000c0000c0000000000c000000c00000000c0000c00
0000000000900000b66566656665b665b6656b6566b56b65000000000c0000c00000000009900000000000000000000000000000000000000000000000000000
6556655665566500655665566556650035555b00b555530035555b00b5555300c000000c00000000c000000c00000000c000000c000000000000000000000000
656655b5b56b55006566553535635500653376006533760065337600653376005000000500000000500000050000000050000005000000000000000000000000
555555555555550055555555555555005b55550053b55500553b55005553b5006000000600000000600000060000000060000006000000000000000000000000
5b56665556566b005356665556566300056650000566500005665000056650006000000600000000600000060000000060000006000000000000000000000000
65555665b555560065555665355556000055000000550000005500000055000070033007000000007003300700000000700bb007000000000000000000000000
655655b5655655006556553565565500000000000000000000000000000000006b6bb6b60000000063633636000000006b6336b6000000000000000000000000
66566656665b66006656665666536600000000000000000000000000000000008003300800000000800bb0080000000080033008000000000000000000000000
55555555555555005555555555555500000000000000000000000000000000000005500000000000000550000000000000055000000000000000000000000000
5555553666665500555555b6666655000056650000566500005bb500005665000066660000000000006666000000000000666600000000000000000000000000
3535655555655500b5b5655555653b00055655b00556556005565560055b55600588885000000000058888500000000005888850000000000000000000000000
b5b565666555b3003535656665553b00565b55b55b565565565655655b5b556563533536000000006b5bb5b600000000635bb536000000000000000000000000
555555566655b3005555555666556600b655b55b6b55655bb655b55b6b5565566b6776b600000000636776360000000063677636000000000000000000000000
555653655555560055565b6555555600b675b5656675b5b5b675b5b56b7565b563533536000000006353b536000000006b5b35b6000000000000000000000000
565655666555650056565566655565005b5b656b5b5bb5b65b5b65bb5b56656605b33b5000000000053bb3500000000005bb3350000000000000000000000000
000000000000000000000000000000000566555005bb555005bb5550056655500066660000000000006666000000000000666600000000000000000000000000
00000000000000000000000000000000005566000055bb000055bb00005566000000000000000000000000000000000000000000000000000000000000000000
65566556655665000b585b00b00000b0b65b55533556555bb65555533556555b001cc11167617171777177717111771167611111088888000000000000000ccc
656655b5b56b5500b35b53b0385358300b55575003bb5750053b57500553bb5001ccc11171717171171171117111767171711111088888800000000000000ccc
555555555555550030030030035b53000055550000555500005b5500005555000cccc11171117771171171117111717171111111088888800000000000000ccc
5b56665556566b00b00b00b000060000000630000006b00000063000000bb0000cccc11167617671171177117111717167611111088888800000000000000ccc
65555665b55556000003000000060000000050000000500000005000000050000cccc11111717171171171117111717111711111088888800000000000000ccc
655655b565565500000b0000000500000000000000000000000000000000000001ccc11171717171171171117111767171711111088888800000000000000ccc
66566656665b66000000000000b3b00000000000000000000000000000000000001cc11167617171777177717771771167611111088888000000000000000ccc
555555555555b30000000000000b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
555555666666550000aaaa0000000000000000000000000000000000000000001111111100000000000000007771676177611111000000000000000000000000
353565555565b3000a1111a000880000000000000000000000008800000000001111111100000000000000001711767171711111000000000000000000000000
b5b565666555b300a111111a08880000000000000000000000008880000000001111111100000000000000001711717171711111000000000000000000000000
5555555666556600a111111a08880000000000000000000000008880000000001111111100000000000000001711717177111111000000000000000000000000
5556566555555600a111111a00000000088800000000888000000000000000001111111100000000000000001711717177611111000000000000000000000000
5656556665556500a111111a00000000088800000000888000000000000000001111111100000000000000001711767171711111000000000000000000000000
00000000000000000a1111a000000000008800000000880000000000000000001111111100000000000000001711676171711111000000000000000000000000
000000000000000000aaaa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000005b655b55000000000000000000000000536553550000000000000000000000005b655b55000000000000b00000b0b00700b00007000070070070
000000000b66536555556b60000000000000000003665b655555636000000000000000000b665b6555556b60000000000b000b0007070700000b00000b0b0b00
0000000653665565666b336650000000000000065b6655656663bb6650000000000000065b665565666bbb665000000000b7b00000b7b00000bbb000007b7000
000000b655666565565556665b00000000000036556665655655566653000000000000b655666565565556665b00000000777000777777707bbbbb707bb7bb70
00000635556555665556556653600000000006b555655566555655665b600000000006b555655566555655665b60000000b7b00000b7b00000bbb000007b7000
0000665555556556555665555566000000006655555565565556655555660000000066555555655655566555556600000b000b0007070700000b00000b0b0b00
000b3655b556665553555655b55660000003b655355666555b55565535566000000bb655b55666555b555655b5566000b00000b0b00700b00007000070070070
0055665b3b5566653b35555b3b55550000556653b3556665b3b55553b35555000055665bbb556665bbb5555bbb55550000000000000000000000000000000000
00655555b555566553555655b5536b0000655555355556655b555655355b630000655555b55556655b555655b55b6b00000cccc0000000000000000000000000
0b36556555665b65555556655556665003b655655566536555555665555666500bb6556555665b65555556655556665001c0000c100000000000000000000000
0666656656665565665655665555635006666566566655656656556655556b500666656656665565b656556655556b500c000000c00000000000000000000000
06665566556556656556655556655550066655665565566565566555566555500666556655655665b55b6555566555501c000000c10000000000000000000000
55655556555b5665656665556666656b5565555655535665656665556666656355655556555b5665656bb5556666656bc10000001c0000000000000000000000
b55556b3b666555555556565655565633555563b36665555555565656555656bb55556bbb66655555555b5656555656bc00000000c0000000000000000000000
66565566666655bbbbb555655535556666565566666655bbbbb5556555b5556666565566666655bbbbb5556555b55566c00000000c0000000000000000000000
b65665b55b655b3b3b3b553b53b355553656653553655b3b3b3b55b35b3b5555b65665b55b655b3b3b3b55bb5bbb5555c00000000c0000000000000000000000
3b566655b565b3333333b56355355655b35666553565b3333333b56b55b55655bb566655b565b3333333b56b55b55655c00000000c0000000000000000000000
6655555bb555b33b33b3b56665556655665555533555b33b33b3b566655566556655555bb555b33b33b3b56665556655c00000000c0000000000000000000000
b3665b533355b3333333b5555556553b3366535bbb55b3333333b555555655b3bb665b5bbb55333333333555555655bbc00000000c0000000000000000000000
066666555555b3bbbbb3b53b55555660066666555555b3bbbbb3b5b355555660066666555555bbbbbbbbb5bb55555660c10000001c0000000000000000000000
0556665555b5bb33b33bb56356665560055666555535bb3bbb3bb56b566655600bb6665555b5bbbbbbbbb56b5bb655601c000000c10000000000000000000000
0b35555355553bbbbbbb35555665555003b5555b5555bb3bbb3bb555566555500bb5555b555bbbbbbbbbb5555bb555500c000000c00000000000000000000000
0066553b355555555555566555556500006655b3b55555555555566555556500006655bbb5555b55555556655555650001c0000c100000000000000000000000
00b35553556655566655655566663b00003b555b55665556665565556666b30000bb555b55665556665565556666bb00000cccc0000000000000000000000000
00056655566556553b535565555660000005665556655655b35b556555566000000b665556655655bb5b55655556600000000000000000000000000000000000
0000635666656656555b56666535000000006b56666566565553566665b5000000006b5666656656555b566665b5000000000000000000000000000000000000
00000b5665555555b353555555b0000000000356655555553b5b55555530000000000b5665555555bb5b555555b0000000000000000000000000000000000000
000000535566655665556555560000000000005b5566655665556555560000000000005b55666556655565555600000000000000000000000000000000000000
0000000b636655555565556650000000000000036b66555555655566500000000000000b6b665555556555665000000000000000000000000000000000000000
000000000b653636555556b000000000000000000365b6b65555563000000000000000000b6bb6b6555556b00000000000000000000000000000000000000000
000000000000b6b65b36000000000000000000000000363653b6000000000000000000000000b6b65bb600000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000d677675d7777777d000077770000d777777761000000d7777777dd7777777610d777777750577760d77610000000000000000000000
00000000000000000000d77d55756d17775d6000077770000077750677d0000006d17775d6077750677d00777501dd0077710d61000000000000000000000000
000000000000000000007770005dd0077700d000566775000077700d775000000d0077700d077700d7750077700d0d007771d700000000000000000000000000
000000000000000000017776d1000007770000006dd77600007770577500000000007770000777057750007777770000777677d0000000000000000000000000
00000000000000000000677777650007770000007517770000777677600000000000777000077767760000777006100077767775000000000000000000000000
000000000000000000000567777750077700000d77d7775000777d777d00000000007770000777d777d00077700050007771d776000000000000000000000000
000000000000000000050001d777d00777000006d5677760007770d777100000000077700007770d777100777000005077710777500000000000000000000000
00000000000000000005d0000d77500777000017100d77700077700677d000000000777000077700677d00777000055077710d77600000000000000000000000
00000000000000000005765157760007770000670000777500777105777000000000777000077710577700777501d70077710177710000000000000000000000
00000000000000000005666776d0006777600d77100577775d777d0d777600000006777600d777d0d7776d7777777d0577760577761000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bbbb003bbb3003bb30003bb30003bbbbb0003bbbb03bbbbb3bb03bb300b33bbbbb000003bb303bb33bb001bbbb0003bbbb03bb30bbb3bb03bbbbb03bbbbb0
0bb300b0bb00bb300bb00000bb00000bb00300bb300b030bb303bb00bb300b00bb003000000bbb0bbb00bb00bb00300bb300b00bb003b30bb00bb00300bb0031
3bb00003bb003bb00bb00000bb00000bb03013bb0000300bb303bb003bb00300bb0301000003bb33bb00bb01bb30003bb000010bb33bb30bb00bb03010bb0003
3b300003b3000bb00bb00000bb00000bb3b003b30000000bb300bb000bb03300bb3b000000033bb0bb00bb00bbbb303b3000000bb003b30bb00bb3b000bb3b00
3bb00003bb000bb00bb00000bb00000bb00103bb0000000bb300bb000bb1b000bb00100000030b30bb00bb000bbbbb3bb000000bb003b30bb00bb00100bb0010
1bb00003bb000bb00bb00030bb00030bb00003bb0000000bb300bb0003bb3000bb00000000030300bb00bb030003bb1bb000000bb003b30bb00bb00000bb0000
03bb0003bb303b300bb00310bb00310bb000303bb000300bb300bb0000bb3000bb00030000030000bb00bb033003bb03bb00030bb003b30bb00bb00030bb0000
003bbbb003bbb3003bbbbb03bbbbb03bbbbb3003bbbb000bbb03bb0000bb3003bbbbb300003b0003bb33bb03bbbb30003bbbb03bb30bbb3bb03bbbbb33bb1000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d00000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000010000000000000000000000000000000000000d000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000d000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000d00000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000d677675d7777777d000077770000d777777761000000d7777777dd7777777610d777777750577760d77610000000000000000000000
00000000000000000000d77d55756d17775d6000077770000077750677d0000006d17775d6077750677d00777501dd0077710d61000000000000000000000000
000000000000000000007770005dd0077700d000566775000077700d775000000d0077700d077700d7750077700d0d007771d700000000000000000000000000
000000000000000000017776d1000007770000006dd77600007770577500000000007770000777057750007777770000777677d0000000000000000000000000
00000000000000000000677777650007770000007517770000777677600000000000777000677767760000777006100077767775000000000000000000000000
000006000000000000000567777750077700000d77d7775000777d777d00000000007770000777d777d00077700050007771d776000000000000000000000000
000000000000000000050001d777d00777000006d5677760007770d777100000000077700007770d777100777000005077710777500000000000000000000000
00000000000000000005d0000d77500777000017100d77700077700677d000000000777000077700677d00777000055077710d77600000000000000000000000
00000000000000000005765157760007770000670000777500777105777000000000777000077710577700777501d70077710177710000000000000000000000
00000000000000000005666776d0006777600d77100577775d777d0d777600000006777600d777d0d7776d7777777d0577760577761000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bbbb003bbb3003bb30003bb30003bbbbb0003bbbb03bbbbb3bb03bb300b33bbbbb000003bb303bb33bb001bbbb0003bbbb03bb30bbb3bb03bbbbb03bbbbb0
0bb300b0bb00bb300bb00000bb00000bb00300bb300b030bb303bb00bb300b00bb003000000bbb0bbb00bb00bb00300bb300b00bb003b30bb00bb00300bb0031
3bb00003bb003bb00bb00000bb00000bb03013bb0000300bb303bb003bb00300bb0301000003bb33bb00bb01bb30003bb000010bb33bb30bb00bb03010bb0003
3b300003b3000bb00bb00000bb00000bb3b003b30000000bb300bb000bb03300bb3b000000033bb0bb00bb00bbbb303b3000000bb003b30bb00bb3b000bb3b00
3bb00003bbd00bb00bb00000bb00060bb00103bb0000000bb300bb000bb1b000bb00100000030b30bb00bb000bbbbb3bb000000bb003b30bb00bb00100bb0010
1bb00003bbd00bb00bb00030bb00030bb60003bb0000000bb300bb0003bb3000bb00000000030300bb00bb030003bb1bb000000bb003b30bb00bb00000bb0000
03bb0003bb303b300bb00310bb00310bb000303bb000300bb300bb0000bb3000bb00030000030000bb00bb033003bb03bb00030bb003b30bb00bb00030bb0000
003bbbb003bbb3003bbbbb03bbbbb03bbbbb3003bbbb000bbb03bb0000bb3003bbbbb300003b0003bb33bb03bbbb30003bbbb03bb30bbb3bb03bbbbb33bb1000
000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000d0000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000000000000100000000000010000000000000
00000000000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000d0000100000000000010000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000d00000000000000100000000000010000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000100000000000010000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000
60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000
60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000060000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000060000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000060000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000000000000000d000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000000000000000d000000d00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000061000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000d000001000000000000000000000000000000000000000000000000000000
000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000d0000000000000000000000000000000000000000000000000000000000000000000000000000d00000000000000000000000000000000000
00000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000d00000000000000000000000000000000000
00060000000000000d00000000000000000000000000000000000000000000000000000000000000000000000000d00000000000000000000000000000000000
00000000000000000d0000000000000000000000000000000d000000000000000000000000000000000000000000d00000000000000000000000000000000000
00000000000000000d0000000000000000000000000000000d0d0000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000100d0000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000100d0000000000000000000000000000000000000000000000000000000000000000000000000000
000000100000000000000000000010000000000000000000100d0000000000000000000000000000000000000000000000000000000000000000000000000000
00000010000000000000000000001000000000000000000010000000000000666600000000000000000000000000000000000000000010000000000000000000
0000000d000000000000000000001000000000000000000000000000000005666650000000000000000000000000000000000000000010000000000000000000
00000000000000000000000000001000000000000000000000000000000066566566000000000000000000000000000000000000000010000000000000000000
00000000000000000000000000000000000000000000000000000000000066677666000000000000000000000000000000000000000010000000000000000000
00000000000000000000000000000000000000000000000000000000000066566566000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000005888850000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000666600000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000007000000055000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000085800080066008000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000010000000000000000000000000055755006c6776c6000000000000000000600000000000000000000000000000000000000000
0000000000000000000000000000000000d000000000000000000c767c0070066007000000000000000000600000000000000000000000000000000000000000
0000000000000000000000000000000000d000000000000000000065600060000006000000000000000000600000000000000000060000000000000000000000
0000000000000000000000000000000060d0000000000000000000060000600000060000000000000d0000600000000000000000060000000000000000000000
000000000000000000000000000000000000000000000000000000000000500000050000000000000d0000000000000000000000060000000000000000000000
000000000000000000000000000000000000000000000000000000000000c000000c0000000000000d0000000000000000000000060000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000d000001000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000006000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000600000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000
00000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000001000000100000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000000000000000000000000
6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d00000000000
00000000000000000000060000000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000d00000000000
00000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000d00000000000
00000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000006000000000d00000000000
00000000000000000000000000000000000000000600000000000000000000000000000000000000000000000060000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000d000000000000000000000000000000000060000000000000000000000000000000000000
000000000100000000000000000000000000000000000000000000000d0000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000d0000000000000000000000000000000000000000000000000000000000000000000000
0000d0000000000000000000000000000000000000000000000000000d0000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000d000000000000000000d0000000000000000000000000000000000000000000000000000000000600000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000
00000000000d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000d0000000000000000000000000000000000

__map__
0000000000000000000000003c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
160100002e1102e11031110201101f1101d1101b110181101611012110101100e1100b11009110071100411000110030000100004000040000400004000040000400003000030000300002000020000100000000
92010000245212252122521205111f5111d5111d5111b5111a52119521185211651116511145111351112511105210f5210d5210c5210a5210852106511045110251101511005210000000000000000000000000
06010000326302c6302662023620206201c6101961017620156201462014620136201362012620126201162013630166201463013630116200b620046200062001600006000b6000a60008600076000660005600
00020000016100661024620146001d600106000b60005600016000060001600006000060000600006000160001600016000160001600016000060000600006000060000600006000060000600016000060000600
00050000000000622000000000000722000000000000000000000000000000000000000002b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
080d00001b0001b0001b0001b0301b0001b0201d0201e030200302004020040200001b7001b700227001b7001b7001d7001b7001b7001b7001d700227001a7001b7001b700167001b7001b7001b7001c7001c700
050d00001f5001f000215001f5301f0001f5202152022530245302453024530245002070022700227001670000000000000000000000000000000000000000000000000000000000000000000000000000000000
010d00002200022000220002203022000220302403025030270302703027030270001e00020000200002000000000000000000000000000000000000000000000000000000000000000000000000000000000000
770c00000c7300a73006730017300173001730017300173006730087300b730007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700
000300002f73534735000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400002474526745297452e7453074532745357453a7452400526005290052e0053000532005350053a00500000000000000000000000000000000000000000000000000000000000000000000000000000000
010c0000290502c0002a00029055290552a000270502900024000290002705024000240002400027050240002a05024000240002a0552a055240002905024000240002400029050240002a000290002405026200
510c00001431519315203251432519315203151432519325203151431519325203251431519315203251432519315203151432519325203151431519325203251431519315203251432519315203151432518325
760c00000173001730017300173001730017300173001730017300173001730017300173001730017300173001730017300173001730017300173001730017300173001730017300173001730017300173001730
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
010a00000c4200c4200c4200c4200c4200c4200c4200c4200f4200f4200f4200f4200f4200f4200f4200f42010420104201042010420104201042010420104201442014420144201442014420144201442014420
010a00000532105320053200532005320053200532005320083200832008320083200832008320083200832009320093200932009320093200932009320093200d3200d3200d3200d3200d3200d3200d3200d320
000a002034615296152b6161e6061c6401d6452b6152760528615296152b6151e6001c6401d6452b6152761534615296152b6161e6061c6401d6452b6152760528615356152b6151e6051c6401d6452b61527615
050a00200232002320023200232002320023200232002320023200230502325023250232002325023200232503320033200332003320033200332003320033200732007320073200732007320073200732007320
010a000002320023200232002320023200232002320023200a3200a3200a3200a3200a3200a3200a3200a32005320053200532005320053200532005320053200332003320033200332003320033200332003320
010a000009220092200922009220092200922009220092200e2200e2200e2200e2200e2200e2200e2200e2200a2200a2200a2200a2200a2200a2200a2200a2200022000220002200022001220012200122001220
010a000005220052200522005220052200522005220052200e2200e2200e2200e2200e2200e2200e2200e2200a2200a2200a2200a2200a2200a2200a2200a2200022000220002200022001220012200122001220
010a00000d2200d2200d2200d2200d2200d2200d2200d220052200522005220052200522005220052200522011220112201122011220112201122011220112200322003220032200322003220032200322003220
64020000261200c02007620076200d020166201002010520125201352000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9116000013230132301323013230182301c2321a2301a2301a2301a2301d230212321f2301f2301f2301f2301f2301f2301f230162321d2321f232212321d2301f2301f2301f2321d2301d2301d2321c2301c230
011600000005500055000550705507055070550005500056000550705507055070550005500055000550705507055070550005500055000550705507055070550005500055000550705507055070550005500055
91160000182001c230182301c2321a2301a2301a2301a2301a2301a2301a2301a2301a2301a2221a2221a21400200002000020000200002000020000200002000020000200002000020000200002000020000200
011600000005507055070550705502045020450204507035070350703502025020250202507015070150701502000020000000000000000000000000000000000000000000000000000000000000000000000000
04040000000360203603026040160601607026080160a0260c0160e0161102614016160171a0271d0172301727027380370000000000000003700000000000000000000000000000000000000000000000000000
480a00000b0260f036140471b03627066360362e046330363a0363b03635046080061e00700006000061a0061700613006100060e0060d0060c0060b006090060700607006080060000000000000000000000000
4e030000356612b661236612066129611326411c6111b6111a64118641176411661112611116110f6110e6110c6410b6610a6611c66105661076410761106611056110461103641026610164108611146110a611
5b010000261200c12007120071200b1201a1201010010100121001310000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100001000010000100
0304000038660236603466025660306602f660206502c6502a650286502565023640206401d6401c6401a64018640166301563012630106300d6300c6200a6200962007620066100461002610016100061000610
150a00001522015220152201522015220152201522015220152201522015220152201322013220152201522016220162201622016220162201622016220162201922019220192201922019220192201922019220
150a00001a2201a2201a2201a2201a2201a2201a2251a2251d2201d2201d2201d2201d2201d2201d2201d22019220192201922019220192201922019220192201622016220162201622016220162201622016220
150a0000192201922019220192201922019220192251922511220112201122011220112201122011220112201d2201d2201d2201d2201d2201d2201d2201d22018220192211a2211d22121221252212622126221
090a00001d2171a217212172221729217262172d2172e2171d2171a2172121722217112170e21715217162171d2171a217212172221729217262172d2172e2171d2171a2172121722217112170e2171521716217
090a000029217262172d2172e2173521732217392173a21729217262172d2172e2171d2171a2172121722217112170e21715217162171d2171a2172121722217112170e21715217162170521702217092170a217
010a00000e003296000e0031e600286151d6052b605276150e003296052b6151e600286151d6452b615276051f6501f6301f6201e6001f6251f6251f625276050e003356052b6051e605106111c6112862133631
5c030000131212513131151381711b1613b1513b1413c14116141291413913135131321312d13228132221321c13216132131321d1320e1320d1320a132091320813206122051220412203122031220312201120
5c0400000817120161181610f17108171171711017109171071710d1610f161091510715106151051410514105132041320313202132021320113201132001320113201132011320112200122001220012200122
002100001a5401f54023540215401d54028540265402654026540265402654026540265402654023540285402c5402a540285402d5402f5402f5402f5402f5400050000500005000050000500005000050000500
002100001a7401f74023740217401d74028740267402674026740267402674026740267402674023740287402c7402a740287402d7402f7402f7402f7402f7400070000700007000070000700007000070000700
0124000000000000000000000000000000000000000000001f0301f0301f0301f0302603026030260302603029030280302803028030280302303023030230302303000000000000000000000000000000000000
012400000202007020020200702002020070200202007020020200702002020070200202007020020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012400000000000000000000000000000000000000000000000001f0401f0401f0401f040260402604026040260402b040290402b0402b0402b0402b0402b0402b0402b040000000000000000000000000000000
012400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001504000000000000000000000000000000000000
012400000204007040020400704002040070400204007040020400704002040070400204007040020400000000000000000000000000000000000007040000000000000000000000000000000000000704002040
00241a00000000000000000000000000000000000000000000000000001f0601f0601f0601f06026060260602606026060290602b0602b0602b0602b0602b0602b0602b060014000140001400014000140001400
00240e000706002060070600206007060020600706002060070600206007060020600706002060014000140001400014000140001400014000140001400014000140001400014000140001400014000140001400
__music__
04 05060744
04 48494a44
01 0b0c0d0e
00 0f0c0d10
02 11121318
01 26274446
04 28294547
04 191a1b44
04 16174344
00 1d1e6844
01 1f202144
00 1f212266
00 1f202365
00 1f232465
00 1f202f44
00 1f223044
00 1f202f44
00 1f233144
00 21223244
00 21223344
00 20243244
02 1e1d3444
04 62643837
01 40396c3a
00 403b3c3d
02 407e7f7f

