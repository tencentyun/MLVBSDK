var webrtcroom = require('../../../utils/webrtcroom.js');
const app = getApp()

Page({

	/**
	 * 页面的初始数据
	 */
	data: {
		roomName:'',
		roomNo:'',
		userName: '',
		tapTime: '',
    template: 'float',
    roomList: [],
    headerHeight: app.globalData.headerHeight,
		statusBarHeight: app.globalData.statusBarHeight,
		lc : "◀︎"
	},
	// 绑定输房间号入框
	bindRoomNo: function (e) {
		var self = this;
		self.setData({
			roomNo: e.detail.value
		});
	},
  radioChange: function (e) {
		// this.data.template = e.detail.value;
		this.setData({
			template: e.detail.value
		})
		console.log('this.data.template', this.data.template)
  },
	// 进入rtcroom页面
	joinRoom: function() {

		var self = this;
		// 防止两次点击操作间隔太快
		var nowTime = new Date();
		if (nowTime - this.data.tapTime < 1000) {
			return;
		}

		if (self.data.roomNo==='list') {
			self.showListInConsole()
			self.setData({
				roomNo: ''
			})
			return
		}

    if (!self.data.roomNo) {
			wx.showToast({
				title : '请输入房间号',
				icon : 'none',
				duration : 2000
			})
			return
      
    }
		if (/^\d*$/.test(self.data.roomNo)===false) {
			wx.showToast({
				title : '只能为数字',
				icon : 'none',
				duration : 2000
			})
			return
		}

		// let roomIndex= this.isRoomIDExists(self.data.roomNo)
		// if (roomIndex===-1){
		// 	// wx.showToast({
		// 	// 	title : '房间号不存在',
		// 	// 	icon : 'none',
		// 	// 	duration: 2000
		// 	// })
		// 	self.setData({
		// 		roomNo: ''
		// 	})
		// }
		// self.setData({
		// 	roomName : self.data.roomList[roomIndex]['roomName']
		// })

    var url = '../room/room?type=create&roomID='+self.data.roomNo+'&roomName=' + self.data.roomName + '&template=' + self.data.template + '&userName=' + self.data.userName;
    wx.navigateTo({
			url: url
		});
		wx.showToast({
			title: '进入房间',
			icon: 'success',
			duration: 1000
		})
		self.setData({ 'tapTime': nowTime });
	},
	/**
	 * @uses 在控制台输出房间列表， 用于测试
	 * @name showListInConsole
	 */
	showListInConsole :function() {
		console.log('roomList', this.data.roomList)
	},
	/**
	 * @uses 判断房间是不是存在
	 * @name isRoomIDExists
	 * @param roomID
	 * @return int 
	 */
	isRoomIDExists: function(roomID){
		let index= 0;
		let roomList= this.data.roomList
		for (let i=0; i<roomList.length; i++){
			if (roomList[i]['roomID']===roomID) {
				return i
			}
		}
		return -1
	},

	// 拉取房间列表
	getRoomList: function (callback) {
		var self = this;
		webrtcroom.getRoomList(0, 20, function (res) {
			console.log('拉取房间列表成功:', res);
			if (res.data && res.data.rooms) {
				self.setData({
					roomList: res.data.rooms
				});
			}
		}, function (res) {});
	},
	/**
	 * 生命周期函数--监听页面加载
	 */
	onLoad: function (options) {
		this.getRoomList() //先拉一下房间列表
		this.setData({
			userName: options.userName || ''			
		})
	},

	/**
	 * 生命周期函数--监听页面初次渲染完成
	 */
	onReady: function () {
	
	},

	/**
	 * 生命周期函数--监听页面显示
	 */
	onShow: function () {
	
	},

	/**
	 * 生命周期函数--监听页面隐藏
	 */
	onHide: function () {
	
	},

	/**
	 * 生命周期函数--监听页面卸载
	 */
	onUnload: function () {
	
	},

	/**
	 * 页面相关事件处理函数--监听用户下拉动作
	 */
	onPullDownRefresh: function () {
	
	},

	/**
	 * 页面上拉触底事件的处理函数
	 */
	onReachBottom: function () {
	
	},

	/**
	 * 用户点击右上角分享
	 */
	onShareAppMessage: function () {
    return {
      // title: '',
      // path: '/pages/multiroom/roomlist/roomlist',
      path: '/pages/main/main',
      imageUrl: 'https://mc.qcloudimg.com/static/img/dacf9205fe088ec2fef6f0b781c92510/share.png'
    }
	},
  onBack: function () {
    wx.navigateBack({
      delta: 1
    });
  },
})