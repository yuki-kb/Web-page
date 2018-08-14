require "dxruby"

Window.width = 1000
Window.height = 500
$wall = 5
$kill = 0

class Enemy1 < Sprite
  @@image1 = Image.load_tiles("./image/enemy.png",1,4)#画像を先に読み込ませる
  @@image2 = Image.load_tiles("./image/enebomb.png",2,4)
  private :initialize
  def initialize(x,y)#初期座標とエネミーのスピードを渡してポップさせる
    super
    self.image = @@image1[0]#画像は上記の@@imageを使用
  end

  def update#移動速度は@@speed、画面の端(1000px)まで行くと消えるようにする。
    self.x += 1
      if self.x >= 1000
        self.vanish
        $wall -= 1
      end
  end

  def hit(o)#衝突時の動作
    self.vanish#衝突したら消える
    $kill += 1
  end

end

class Enemy2 < Enemy1

  def initialize(x,y)
    super
    self.image = @@image2[6]
  end

  def update
    super
    self.x += 1.3
  end
end

class User < Sprite
  @@image1 = Image.load("./image/magician.png")#画像を先に読み込ませる
  @@image2 = Image.load("./image/saberSke.png")

  def initialize(x,y,num)#hpの乱数を与える
    super
    self.x = x
    self.y = y
    if num == 1
      self.image = @@image1#ユーザーキャラは上記のmagicianを使用
      self.scale_x = 0.1#画像サイズが大きすぎるので調整
      self.scale_y = 0.1
    elsif num == 2
      self.image = @@image2
      self.scale_x = 0.095#画像サイズが大きすぎるので調整
      self.scale_y = 0.095
    end
  end

end

#遠距離魔法について
class Attack1 < Sprite
  @@shot = Image.load("./image/shot.png")#画像を先に読み込ませる
  @@range = 400
  def initialize(x,y)
    super
    self.image = @@shot
    self.scale_x = 0.08
    self.scale_y = 0.08
  end

  def update
    self.x -= 10
    @@range -= 10
    if @@range <= 0
      @@range = 400
      self.vanish
    end
  end

  def shot(o)
    self.vanish
    @@range = 400
  end

end
#範囲魔法について
class Attack2 < Sprite
  @@shot = Image.load("./image/bombT.png")#画像を先に読み込ませる
  @@range = 200
  @@time = 60
  def initialize(x,y)
    super
    self.x = x - @@range
    self.image = @@shot
    self.scale_x = 0.15
    self.scale_y = 0.15
  end

  def update
    @@time -= 1
    if @@time <= 0
      self.vanish
      @@time = 60
    end
  end

end
#近接魔法について
class Attack3 < Sprite
  @@shot = Image.load("./image/wind_2.png")#画像を先に読み込ませる
  @@range = 5
  @@time = 6

  def initialize(x,y)
    super
    self.x = x - @@range
    self.image = @@shot
    self.scale_x = 0.25
    self.scale_y = 0.25
  end

  def update
    @@time -= 1
    if @@time <= 0
      self.vanish
      @@time = 6
    end
  end

end
#レイピア攻撃
class Attack4 < Sprite
  @@image = Image.load("./image/reipia.png")#画像を先に読み込ませる
  @@range = 10
  @@time = 3
  def initialize(x,y)
    super
    self.x = x - @@range
    self.image = @@image
    self.scale_x = 0.15
    self.scale_y = 0.15
  end

  def update
    super
    @@time -= 1
    if @@time == 0
      self.vanish
      @@time = 3
    end
  end

end

enemies = []#enemyを入れる配列
magics = []#魔法攻撃を入れる要素
character1 = User.new(500,-100,1)
character2 = User.new(310,-400,2)
cl_1,cl_2,cl_3 = 0,0,0
count,pop_level,pops = 0,1,126#時間とポップする程度を扱う
hp1,hp2 = rand(50..100),rand(50..100)
x,y=100,100
cooltime,time = 0,30
scene = "title"

Window.loop do#描画について
  case scene
  when "title"
    Window.draw_font(300,100,"
      Please push \"S\"
      and Game starts",Font.new(40),:color =>[255,255,255])
    if Input.key_push?(K_S)
      scene = "rules"
    end
    if Input.key_push?(K_ESCAPE)
      Window.close
    end

  when "rules"
    Window.draw_font(0,50,"
      ～ルール～
      画面左端からやってくる敵を倒して右端まで到達できないようにしましょう。
      また、敵に触れるとダメージを受けるので注意してください。
      1Pは十字キーで移動、\"J\",\"K\",\"L\"で攻撃
      2Pは\"W\",\"A\",\"S\",\"D\"で移動\"B\"で攻撃です。

      それでは\"S\"キーを押してゲームを始めましょう。",Font.new(30),:color =>[255,255,255])
    if Input.key_push?(K_S)
      scene = "main"
    end
    if Input.key_push?(K_ESCAPE)
      Window.close
    end

  when "main"
    #背景画像
    Window.draw_scale(0,0,Image.load("./image/back1.png"),1.25,1.25,0,0)

    count += 1#毎フレームカウントを減らしてポップさせるまでの間隔を図る
    if cooltime <= 0
      if count%1200 == 0
        pop_level +=1
        case pop_level
        when 1
          cooltime = 300
        when 2,3,4
          pops = 64
          cooltime = 500
        when 5,6
          pops = 32
          cooltime = 1200
        when 7
          pops =100000000000000000
        end
      elsif (count%pops) == 0
        for i in 0..pop_level/2
          type = rand(2)
          case type
          when 0
            enemies << Enemy1.new(-10,rand(20..470))
          when 1
            enemies << Enemy2.new(-10,rand(20..470))
          end
        end
      end
    elsif cooltime >= 0
      cooltime -= 1
    end
    if pop_level == 8
      Window.draw_font(500,200,"GAME CLEAR!",Font.new(40),:color =>[0,0,0])
      time -= 1
      if time == 0
        sleep(10)
        scene = "clear"
      end
    end
        
    
    #キャラの移動設定
    character1.x += 4*Input.x
    if character1.x >= 550
        character1.x = 550
    elsif character1.x <= -350 
        character1.x = -350
    end
    character1.y += 4*Input.y
    if character1.y >= 60
        character1.y = 60
    elsif character1.y <= -360 
        character1.y = -360
    end

    if Input.key_down?(K_D)
      character2.x += 5
      if character2.x >= 550
        character2.x = 550
      end
    elsif Input.key_down?(K_A)
      character2.x -= 5
      if character2.x <= -400
        character2.x = -400
      end
    end
    if Input.key_down?(K_S)
      character2.y += 5
      if character2.y >= -160
        character2.y = -160
      end
    elsif Input.key_down?(K_W)
      character2.y -= 5
      if character2.y <= -565
        character2.y = -565
      end
    end

    #魔法の発射(遠距離)
    if Input.key_push?(K_L) && cl_1 == 0 && !(character1.vanished?)
      magics << Attack1.new(character1.x,character1.y+36)
      cl_1 = 120
    elsif cl_1 > 0
      cl_1 -= 1
    end

    #魔法の発射(範囲)
    if Input.key_push?(K_K) && cl_2 == 0 && !(character1.vanished?)
      magics << Attack2.new(character1.x,character1.y)
      cl_2 = 150
    elsif cl_2 > 0
      cl_2 -= 1
    end

    #魔法の発動(斬撃)
    if Input.key_down?(K_J) && cl_3 == 0 && !(character1.vanished?)
      magics << Attack3.new(character1.x+170,character1.y+185)
      cl_3 = 30
    elsif cl_3 > 0
      cl_3 -= 1
    end

    #レイピア攻撃
    if Input.key_down?(K_B) && !(character2.vanished?)
      magics << Attack4.new(character2.x+186,character2.y+564)
    end

    #キャラと敵の当たり判定
    if character1 === enemies#敵と衝突したときに体力を減らし、敵を消す
      hp1 -= rand(5..10)
      Sprite.check(character1,enemies)
      if !(character1.vanished?)
        $kill -=1
      end
      if hp1 <= 0
        character1.vanish
        hp1 = 0
      end
    end
    if character2 === enemies#敵と衝突したときに体力を減らし、敵を消す
      hp2 -= rand(5..10)
      Sprite.check(character2,enemies)
      if !(character2.vanished?)
        $kill -=1
      end
      if hp2 <= 0
        character2.vanish
        hp2 = 0
      end
    end
    if $wall == 0 || (hp1 == 0 && hp2 == 0)
      Window.draw_font(500,200,"Game Over",Font.new(40),:color =>[0,0,0])
      time -= 1
      if time == 0
        sleep(10)
        scene = "over"
      end
    end
    
    Sprite.update([enemies,magics])
    Sprite.clean([enemies,magics])#vanishされた要素を削除する
    Sprite.check(magics,enemies)

    #表示関連
    character1.draw#characterの表示
    character2.draw
    Sprite.draw([enemies,magics])#enemyとmagicすべて表示
    Window.draw_font(0,0,"
   難易度：#{pop_level}
   撃破数：#{$kill}
   User1HP：#{hp1}
   User2HP：#{hp2}
   MagicLクールタイム：#{cl_1}
   MagicKクールタイム：#{cl_2}
   護衛目標残存数：#{$wall}
   character1(#{character1.x},#{character1.y})
   character2(#{character2.x},#{character2.y})",Font.new(13),:color =>[0,0,0])

    if Input.key_push?(K_ESCAPE)
      Window.close
    end

  when "clear"
    Window.draw_font(250,100,"
      Conglatulations!
       ↓your score↓
       撃破数：#{$kill}
       User1_HP：#{hp1}
       User2_HP：#{hp2}
       護衛目標残存数：#{$wall}",Font.new(30),:color =>[255,255,255])
    if Input.key_push?(K_ESCAPE)
      Window.close
    end

  when "over"
    Window.draw_font(250,100,"
      GAME OVER
    ↓your score↓
      難易度：#{pop_level}
      撃破数：#{$kill}",Font.new(30),:color =>[255,255,255])
    if Input.key_push?(K_ESCAPE)
      Window.close
    end
  end

end