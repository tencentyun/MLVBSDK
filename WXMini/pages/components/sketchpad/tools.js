function Line(user, option) {
	this.user = user;
	this.type = 'line';
	this.seq = option.belongSeq; // seq 唯一编号
	this.show = option.show; // 是否展示
	this.select = false; // 是否被选了
	this.color = option.color;
	this.time = parseInt(+ new Date() / 1000, 10);
	this.thin = option.thin;
	this.startSeq = option.belongSeq; // 开始点seq
	this.endSeq = 0; // 结束点seq
  this.belongSeq = option.belongSeq;
	// 每一个点  {x, y, seq}
	this.lines = [
		{
			x: option.x,
			y: option.y,
      belongSeq: option.belongSeq,
			seq: option.seq
		}
	];
	this.border = {
		maxX: option.x,
		maxY: option.y,
		minX: option.x,
		minY: option.y
	}
}

Line.prototype.setBorder = function(x, y) {
	if (x + this.thin > this.border.maxX) {
		this.border.maxX = x + this.thin;
	}
	if (x - this.thin < this.border.minX) {
		this.border.minX = x - this.thin;
	}
	if (y + this.thin > this.border.maxY) {
		this.border.maxY = y + this.thin;
	}
	if (y - this.thin < this.border.minY) {
		this.border.minY = y - this.thin;
	}
}

Line.prototype.sort = function () {
  // 给lines排序
  this.lines.sort(function (a, b) {
    return a.seq - b.seq;
  })
}

function dealColor(color) {
	let temp = parseInt(color).toString(16);
	temp = temp.substr(0, temp.length - 2);
	temp = '000000' + temp;
	temp = temp.substring(temp.length - 6, temp.length);
	return hexToRgba(temp);
}

function hexToRgba(hex) {
	let rgb = [];
	hex.replace(/../g, function(color) {
		rgb.push(parseInt(color, 0x10)); //按16进制将字符串转换为数字
	});
	return "rgba(" + rgb.join(",") + ",1)";
}

function formatColor(color) {
	let temp = rgbaToHex(color);
	return parseInt(temp + 'ff', 16);
}

function rgbaToHex(rgba) {
	let color = rgba.toString().match(/\d+/g);
	let hex = '';
	for (let i = 0; i < 3; i++) {
		hex += ("0" + Number(color[i]).toString(16)).slice(-2);
	}
	return hex;
}

function Graph(user, option) {
	this.user = user;
	this.type = 'graph';
	this.graph = option.graph; // line:直线 circle:圆 rect: 矩形
	this.seq = option.seq; // seq 唯一编号
	this.show = option.show; // 是否展示
	this.select = false; // 是否被选了
	this.time = parseInt(+ new Date() / 1000, 10);
	this.color = option.color;
	this.thin = option.thin;
	this.solid = option.solid || false; // 是否实心
	// 记录开始点与结束点
	this.startPoint = {
		x: option.beginPoint.x,
		y: option.beginPoint.y,
		seq: option.beginPoint.seq
	};
	this.endPoint = {
		x: option.endPoint.x,
		y: option.endPoint.y,
		seq: option.endPoint.seq
	};
}

module.exports.Line = Line;
module.exports.Graph = Graph;
module.exports.dealColor = dealColor;
module.exports.formatColor = formatColor;
