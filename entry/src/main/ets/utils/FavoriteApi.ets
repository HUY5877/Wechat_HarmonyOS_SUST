import http from '@ohos.net.http'

export interface FavoriteRecord {
  favorites_id: string
  content: string
  created_at: string
  favorites_user_id?: string // 搜索接口可能不返回此字段
}

export interface FavoriteListResult {
  success: boolean
  message: string
  data: FavoriteRecord[]
}

export interface FavoriteActionResult {
  success: boolean
  message: string
}

export class FavoritePayloadData {
  user_id?: string
  content?: string
  message_id?: string
}

class BasePayload {
  operation: string = ''
  table_name: string = 'favorites'
  data: FavoritePayloadData = new FavoritePayloadData()
}

const API_URL = 'http://146.56.215.115:10001/api/v1/service'

// 获取收藏列表
export async function getFavoriteList(userId: string): Promise<FavoriteListResult> {
  const payload = new BasePayload()
  payload.operation = 'query_favorites'
  payload.data.user_id = userId

  return await requestFavoriteList(payload, userId)
}

// 搜索收藏
export async function searchFavorites(userId: string, content: string): Promise<FavoriteListResult> {
  const payload = new BasePayload()
  payload.operation = 'query_favorites_message'
  payload.data.user_id = userId
  payload.data.content = content

  return await requestFavoriteList(payload, userId)
}

// 统一的列表请求处理
async function requestFavoriteList(payload: BasePayload, userId: string): Promise<FavoriteListResult> {
  const client = http.createHttp()
  try {
    let httpRequestOptions: http.HttpRequestOptions = {
      method: http.RequestMethod.POST,
      header: { 'Content-Type': 'application/json' } as Record<string, string>,
      extraData: JSON.stringify(payload),
      expectDataType: http.HttpDataType.STRING,
      connectTimeout: 15000,
      readTimeout: 15000
    }
    const res = await client.request(API_URL, httpRequestOptions)

    if (res.responseCode === 200) {
      let body: Record<string, Object> | null = null
      if (typeof res.result === 'string' && res.result) {
        try {
          body = JSON.parse(res.result) as Record<string, Object>
        } catch (e) {
          console.error('[FavoriteApi] JSON解析失败', e)
        }
      }

      if (body) {
        // 后端返回的格式是 {"userId": [数组]}，我们用传入的 userId 作为 key 去取数组
        const listData = body[userId]
        if (Array.isArray(listData)) {
          // 统一映射字段，因为搜索接口返回 favorites_content，而列表接口返回 content
          const records: FavoriteRecord[] = listData.map((itemObj: Object) => {
            const item = itemObj as Record<string, Object>
            const record: FavoriteRecord = {
              favorites_id: item['favorites_id'] ? String(item['favorites_id']) : '',
              content: item['content'] ? String(item['content']) : (item['favorites_content'] ? String(item['favorites_content']) : ''),
              created_at: item['created_at'] ? String(item['created_at']) : '',
              favorites_user_id: item['favorites_user_id'] ? String(item['favorites_user_id']) : undefined
            }
            return record
          })
          return { success: true, message: '获取成功', data: records }
        }
        return { success: true, message: '暂无数据', data: [] }
      }
      return { success: false, message: '数据格式错误', data: [] }
    }
    return { success: false, message: '网络错误', data: [] }
  } catch (err) {
    return { success: false, message: '请求失败', data: [] }
  } finally {
    client.destroy()
  }
}

// 删除收藏
export async function deleteFavorite(userId: string, messageId: string): Promise<FavoriteActionResult> {
  const payload = new BasePayload()
  payload.operation = 'delete_favorites_message'
  payload.data.user_id = userId
  payload.data.message_id = messageId

  return await requestFavoriteAction(payload)
}

// 添加收藏 (备用)
export async function addFavorite(userId: string, messageId: string): Promise<FavoriteActionResult> {
  const payload = new BasePayload()
  payload.operation = 'add_favorites_message'
  payload.data.user_id = userId
  payload.data.message_id = messageId

  return await requestFavoriteAction(payload)
}

// 统一的操作请求处理
async function requestFavoriteAction(payload: BasePayload): Promise<FavoriteActionResult> {
  const client = http.createHttp()
  try {
    let httpRequestOptions: http.HttpRequestOptions = {
      method: http.RequestMethod.POST,
      header: { 'Content-Type': 'application/json' } as Record<string, string>,
      extraData: JSON.stringify(payload),
      expectDataType: http.HttpDataType.STRING,
      connectTimeout: 15000,
      readTimeout: 15000
    }
    const res = await client.request(API_URL, httpRequestOptions)

    if (res.responseCode === 200) {
      let body: Record<string, Object> | null = null
      if (typeof res.result === 'string' && res.result) {
        try {
          body = JSON.parse(res.result) as Record<string, Object>
        } catch (e) {
          console.error('[FavoriteApi] JSON解析失败', e)
        }
      }

      if (body) {
        if (body['result'] === 'success') {
          return { success: true, message: '操作成功' }
        } else {
          return { success: false, message: (body['text'] as string) || '操作失败' }
        }
      }
      return { success: false, message: '返回数据异常' }
    }
    return { success: false, message: '网络错误' }
  } catch (err) {
    return { success: false, message: '请求失败' }
  } finally {
    client.destroy()
  }
}
