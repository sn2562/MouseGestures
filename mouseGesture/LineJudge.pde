class LineJudge{
	ArrayList<Integer> gestures;//判定対象の座標群
	int GID;//判定結果のID番号(0-8)
	int r, g, b;//色
	boolean straight;//直線かどうか

	int oldGID;//一つ前のID番号
	int startCheck;//ストロークの中でも判定に使う部分の頭出しを行う

	float allowMisAngle=20;//判定実行時の容認誤差(角度)


	LineJudge(){
		gestures = new ArrayList<Integer>();
		GID = oldGID = 0;//ジェスチャID
		straight = false;//ストロークが直線かどうか
		r = 100;
		g = 10;
		b = 50;//色
		startCheck = 0;//ストロークの中での判定開始位置
	}

	//進んでいる方向(直線判定)を行う (ドラッグされている間ずっと呼び出して更新する)
	void run (ArrayList<PVector> line) {
		PVector vAverage=new PVector(0, 0);//平均
		PVector vVariance=new PVector(0, 0);//分散

		//平均
		for (int i=startCheck; i<line.size(); i++) {//line内のすべての要素を足して平均を出す
			vAverage.x = vAverage.x + line.get(i).x;
			vAverage.y = vAverage.y + line.get(i).y;
		}
		vAverage.x=vAverage.x/(line.size()-startCheck);//平均
		vAverage.y=vAverage.y/(line.size()-startCheck);//平均
		//println("平均 "+vAverage);

		//分散
		for (int i=startCheck; i<line.size (); i++) {
			vVariance.x=vVariance.x+sq(line.get(i).x-vAverage.x);//分散
			vVariance.y=vVariance.y+sq(line.get(i).y-vAverage.y);//分散
		}
		//直線運動(傾きが一致している)であるほど小さくなる 0.1か0.05より小さい
		//円運動などの場合はx,yの値がどちらもm+-0.1くらいに収まる
		vVariance.x=vVariance.x/(line.size()-startCheck);
		vVariance.y=vVariance.y/(line.size()-startCheck);
		//println("分散 "+vVariance);

		if (vVariance.x<0.05 && vVariance.y<0.05) {//直線運動
			float x=vAverage.x;
			float y=vAverage.y;

			//下 1
			if (abs(x)<=cos(radians(90-allowMisAngle)) && y>=sin(radians(90-allowMisAngle))) { 
				GID=1;
			}
			//上 2
			else if (abs(x)<=cos(radians(90-allowMisAngle)) && y<=sin(radians(90-allowMisAngle))) { 
				GID=2;
			}
			//右 3
			else if (x>=cos(radians(allowMisAngle)) && abs(y)<=sin(radians(allowMisAngle))) { 
				GID=3;
			}
			//左 4
			else if (x<=cos(radians(allowMisAngle)) && abs(y)<=sin(radians(allowMisAngle))) { 
				GID=4;
			}

			//左上 5
			else if (x<=0 && y<=0) { 
				GID=5;
			}
			//右上 6
			else if (x>=0 && y<=0) { 
				GID=6;
			}
			//左下 7
			else if (x<=0 && y>=0) { 
				GID=7;
			}
			//右下 8
			else if (x>=0 && y>=0) { 
				GID=8;
			}
		} else if (vVariance.x<0.5 || vVariance.y<0.5) {//直線運動以外
			//直線描画でなくなったら判定を一旦切
			startCheck = line.size();
			if (GID!=0)
				GID=oldGID;
		}

		//一連のジェスチャとみなされなかったとき
		if (oldGID!=GID) {
			changeColor();
		} else {
		}
		oldGID=GID;
		gestures.add(GID);
		checkStraight();//一連の流れとしての判定
		//		return getGesture(GID);//ジェスチャ名を返す
		//		return GID;//ジェスチャ番号を返す
	}

	//登録済みのgesturesからこのストロークが一連の動きをしているかどうか判定する
	void checkStraight(){
		//ジェスチャの分散度合いを確認する
		//0番目のデータはid0であるので、考慮しないようにする
		if(gestures.size()>2 && gestures.get(0)==0){
			gestures.set(0,gestures.get(1));//置き換え 
		}
		float gAverage=0;
		float gVariance=0;

		//平均
		for (int id : gestures) {
			gAverage += id;
		}
		gAverage = gAverage/gestures.size();
		//分散
		for (int id : gestures) {
			gVariance += sq(id-gAverage);//分散
		}
		gVariance=gVariance/gestures.size();

		//		println("平均"+gAverage+"	分散 "+gVariance);

		//TODO idのバラ付きではなくて、実際の値がどれくらいばらついているかで判断
		if(gVariance<0.01)
			straight=true;
		else
			straight=false;

	}

	color getColor(){
		return color(r, g, b);
	}

	boolean getStraight(){
		return straight;
	}

	int getID(){
		return GID;
	}
	void printGestures(){
		println(gestures);
	}

	String getGesture(){
		switch(GID) {
			case 1:
			return "down";
			case 2:
			return "up";
			case 3:
			return "right";
			case 4:
			return "left";
			case 5:
			return "upper left";
			case 6:
			return "upper right";
			case 7:
			return "lower left";
			case 8:
			return "lower right";
			case 9:
			return "other";
			default:
			break;
		}
		return "no gesture";//念のため
	}

	void changeColor() {
		r=int(random(0, 255));
		g=int(random(0, 255));
		b=int(random(0, 255));
	}
	void reset(){
		GID=0;//ジェスチャID
		straight = false;//直線かどうか
		startCheck = 0;//判定開始位置
		changeColor();//色変更
		gestures.clear();
	}

}