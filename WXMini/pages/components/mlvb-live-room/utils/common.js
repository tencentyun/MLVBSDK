// 判断是否是json string
export function isJSON (str) {
  if (typeof str === 'string') {
    try {
      let obj = JSON.parse(str)
      return !!(typeof obj === 'object' && obj)
    } catch (e) {
      return false
    }
  }
}
