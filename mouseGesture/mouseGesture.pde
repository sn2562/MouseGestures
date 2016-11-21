
//ベクトルのばらつきをストロークごとに認識する
//ベクトル内で線の判定をする
//ベクトル方向(色)が一致している間で、z座標を補正する
//判定用
static ArrayList<PVector> mousesVector;//直近1ストローク分のマウスの方向ベクトル

//直線判定
LineJudge judge;//判定本体
int textArea_h = 30;
int w_size = 300;

void setup() {
	int w_h = w_size+textArea_h;
	size(300, 330);
	mousesVector=new ArrayList<PVector>();//マウスの方向ベクトル
	judge = new LineJudge();
	drawInfo();//文字

}

void draw() {
	drawAxis();//十字線
}

void mousePressed(){
	//ベクトルをリセット
	mousesVector.clear();
	//	mousesVector.add(new PVector(mouseX-pmouseX, mouseY-pmouseY).normalize(v));//マウスの方向ベクトルに新しく追加

	//画面をクリア
	background(200);
	drawAxis();//十字線
	drawInfo();//文字
}

void mouseDragged() {
	//点を描画
	fill(judge.getColor());
	noStroke();
	ellipse(mouseX-5, mouseY-5, 10, 10);

	//ベクトル追加
	PVector addPoint = new PVector(mouseX-pmouseX, mouseY-pmouseY);
	addPoint.normalize();

	mousesVector.add(addPoint);//マウスの方向ベクトルに新しく追加

	if (mousesVector.size()>0) {//ドラッグを続けていたら判定結果を表示する
		judge.run(mousesVector);//判定実行

		drawInfo();//文字表示領域
	}
}

void mouseReleased() {
	//	if (mousesVector.size()!=0)
	mousesVector.clear();

	judge.reset();
}

void drawAxis(){
	stroke(0);
	line(0, w_size/2, w_size, w_size/2);
	line(w_size/2, 0, w_size/2, w_size);
}

void drawInfo(){

	fill(0);
	rect(0,height-textArea_h,width,textArea_h);//文字表示領域

	//文字を表示
	textAlign(RIGHT);
	textSize(13);
	fill(255);
	String txt = judge.getGesture()+" -- id:"+judge.getID();
	text(txt,width-30,height-18);
	txt = "Straight "+judge.getStraight();
	text(txt,width-30,height-5);
}