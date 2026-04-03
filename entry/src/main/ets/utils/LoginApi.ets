import http from '@ohos.net.http'
import AppStorage from '@ohos.app.ability.common'

export class LoginData {
  account: string = ''
  password: string = ''
}

export function logout(): void {
  try {
    AppStorage.delete('userId')
  } catch (_e) {}
}

export async function updateUserInfo(userId: string, name: string, status: string, profilePictureId: string): Promise<UpdateUserInfoResult> {
  const url = 'http://146.56.215.115:10001/api/v1/service'
  const payload: UpdateUserInfoPayload = new UpdateUserInfoPayload()
  payload.data.user_id = String(userId)
  payload.data.name = name
  payload.data.status = status
  payload.data.profile_picture_id = profilePictureId

  const client = http.createHttp()
  try {
    const options: http.HttpRequestOptions = new HttpOptions()
    options.extraData = JSON.stringify(payload)

    const res = await client.request(url, options)
    const ok = res.responseCode === 200
    const raw: string = typeof res.result === 'string' ? (res.result as string) : ''
    if (ok && raw) {
      try {
        const parsed = JSON.parse(raw) as LoginResponse
        if (parsed && parsed.result === 'success') {
          return { success: true, message: '更新成功' }
        }
        return { success: false, message: parsed && parsed.text ? parsed.text : '更新失败' }
      } catch (_e) {
        return { success: false, message: '解析失败' }
      }
    }
    return { success: false, message: '网络错误' }
  } catch (_err) {
    return { success: false, message: '请求失败' }
  } finally {
    client.destroy()
  }
}

export class LoginPayload {
  operation: string = 'login'
  table_name: string = 'user'
  data: LoginData = new LoginData()
}

export class LoginResponse {
  result: string = ''
  user_id?: string
  text?: string
}

class Headers {
  ['Content-Type']: string = 'application/json'
}

class HttpOptions implements http.HttpRequestOptions {
  method: http.RequestMethod = http.RequestMethod.POST
  header?: Headers = new Headers()
  expectDataType?: http.HttpDataType = http.HttpDataType.STRING
  extraData?: string
  connectTimeout?: number = 15000
  readTimeout?: number = 15000
}

export interface LoginResult {
  success: boolean
  message: string
  userId?: string
}

export interface UserInfo {
  account: string
  name: string
  profile_picture_id: string
  user_id?: string
  status?: string
}

export interface UserInfoResult {
  success: boolean
  message: string
  data?: UserInfo
}

export class UserInfoData {
  user_id?: string
  account?: string
}

export class UserInfoPayload {
  operation: string = 'query_personal_homepage'
  table_name: string = 'user'
  data: UserInfoData = new UserInfoData()
}

export interface RegisterResult {
  success: boolean
  message: string
}

export interface UpdateUserInfoResult {
  success: boolean
  message: string
}

export class UpdateUserInfoData {
  user_id?: string
  name?: string
  status?: string
  profile_picture_id?: string
}

export class UpdateUserInfoPayload {
  operation: string = 'recompose_personal_homepage'
  table_name: string = 'user'
  data: UpdateUserInfoData = new UpdateUserInfoData()
}

export class RegisterData extends LoginData {
  name?: string
  status?: string
  profile_picture_id?: string
}

export class RegisterPayload {
  operation: string = 'register'
  table_name: string = 'user'
  data: RegisterData = new RegisterData()
}

export async function register(account: string, password: string, name: string, avatarId: string = '0'): Promise<RegisterResult> {
  const url = 'http://146.56.215.115:10001/api/v1/service'
  const payload: RegisterPayload = new RegisterPayload()
  payload.data.account = account.trim()
  payload.data.password = password
  payload.data.name = name.trim()
  payload.data.status = '1' // 默认状态
  payload.data.profile_picture_id = avatarId // 使用传入的头像ID

  const client = http.createHttp()
  try {
    const options: http.HttpRequestOptions = new HttpOptions()
    options.extraData = JSON.stringify(payload)

    const res = await client.request(url, options)
    const ok = res.responseCode === 200

    let body: LoginResponse | null = null
    const raw: string = typeof res.result === 'string' ? (res.result as string) : ''

    if (raw) {
      try {
        body = JSON.parse(raw) as LoginResponse
      } catch (_e) {
        body = null
      }
    }

    if (ok) {
      if (body && body.result === 'success') {
        return { success: true, message: '注册成功' }
      } else {
        const msg: string = body && body.text ? body.text : '注册失败'
        return { success: false, message: msg }
      }
    } else {
      return { success: false, message: '网络错误' }
    }
  } catch (err) {
    return { success: false, message: '请求失败' }
  } finally {
    client.destroy()
  }
}

export async function login(account: string, password: string): Promise<LoginResult> {
  const url = 'http://146.56.215.115:10001/api/v1/service'
  const payload: LoginPayload = new LoginPayload()
  payload.data.account = account.trim()
  payload.data.password = password

  const client = http.createHttp()
  try {
    const options: http.HttpRequestOptions = new HttpOptions()
    options.extraData = JSON.stringify(payload)

    const res = await client.request(url, options)
    const ok = res.responseCode === 200

    let body: LoginResponse | null = null
    const raw: string = typeof res.result === 'string' ? (res.result as string) : ''

    if (raw) {
      try {
        body = JSON.parse(raw) as LoginResponse
      } catch (_e) {
        body = null
      }
    }

    if (ok) {
      if (body && body.result === 'success') {
        return { success: true, message: '登录成功', userId: String(body.user_id) }
      } else {
        const msg: string = body && body.text ? body.text : '登录失败'
        return { success: false, message: msg }
      }
    } else {
      return { success: false, message: '网络错误' }
    }
  } catch (err) {
    return { success: false, message: '请求失败' }
  } finally {
    client.destroy()
  }
}

export interface UserInfoResponse {
  user_id?: string
  account?: string
  name?: string
  status?: string
  profile_picture_id?: string
}

export async function getUserInfo(userId: string): Promise<UserInfoResult> {
  const url = 'http://146.56.215.115:10001/api/v1/service'
  const payload: UserInfoPayload = new UserInfoPayload()

  // 按照新的接口要求传递 user_id
  payload.data.user_id = String(userId)

  console.info(`[getUserInfo] 发起请求，userId: ${userId}, payload: ${JSON.stringify(payload)}`)

  const client = http.createHttp()
  try {
    const options: http.HttpRequestOptions = new HttpOptions()
    options.extraData = JSON.stringify(payload)

    const res = await client.request(url, options)
    const ok = res.responseCode === 200

    console.info(`[getUserInfo] 响应状态码: ${res.responseCode}`)
    console.info(`[getUserInfo] 响应内容: ${res.result}`)

    let body: UserInfoResponse | null = null
    const raw: string = typeof res.result === 'string' ? (res.result as string) : ''

    if (raw) {
      try {
        body = JSON.parse(raw) as UserInfoResponse
      } catch (_e) {
        body = null
      }
    }

    if (ok && body) {
      // 检查返回体是否包含有效的数据字段
      if (body.account || body.name) {
        return {
          success: true,
          message: '获取成功',
          data: {
            account: body.account || '',
            name: body.name || '',
            status: body.status || '',
            profile_picture_id: body.profile_picture_id !== undefined ? String(body.profile_picture_id) : '0'
          }
        }
      }

      return { success: false, message: '获取用户信息失败: 数据为空' }
    } else {
      return { success: false, message: '网络错误' }
    }
  } catch (err) {
    console.info(`[getUserInfo] 请求异常: ${JSON.stringify(err)}`)
    return { success: false, message: '请求失败' }
  } finally {
    client.destroy()
  }
}

export interface FriendItem {
  friend_id: string
  name: string
}

class FriendItemRaw {
  friend_id: number = 0
  name: string = ''
}

export interface FriendsListResult {
  success: boolean
  message: string
  friends: FriendItem[]
}

export class FriendsListData {
  user_id?: string
}

export class FriendsListPayload {
  operation: string = 'query_contacts'
  table_name: string = 'contacts'
  data: FriendsListData = new FriendsListData()
}

export async function getFriendsList(userId: string): Promise<FriendsListResult> {
  const url = 'http://146.56.215.115:10001/api/v1/service'
  const payload: FriendsListPayload = new FriendsListPayload()
  payload.data.user_id = String(userId)

  console.info(`[getFriendsList] 发起请求，userId: ${userId}, payload: ${JSON.stringify(payload)}`)

  const client = http.createHttp()
  try {
    const options: http.HttpRequestOptions = new HttpOptions()
    options.extraData = JSON.stringify(payload)

    const res = await client.request(url, options)
    const ok = res.responseCode === 200

    console.info(`[getFriendsList] 响应状态码: ${res.responseCode}`)
    console.info(`[getFriendsList] 响应内容: ${res.result}`)

    let body: string | null = null
    const raw: string = typeof res.result === 'string' ? (res.result as string) : ''
    body = raw

    if (raw) {
      try {
        const parsedObj: Record<string, FriendItemRaw[]> = JSON.parse(raw)
        const userIdKey = String(userId)
        const friendsArray = parsedObj[userIdKey]
        if (Array.isArray(friendsArray)) {
          const friends: FriendItem[] = []
          for (let i = 0; i < friendsArray.length; i++) {
            const item = friendsArray[i]
            if (typeof item === 'object' && item !== null) {
              const fItem = item as FriendItemRaw
              const friend: FriendItem = {
                friend_id: String(fItem.friend_id),
                name: fItem.name
              }
              friends.push(friend)
            }
          }
          return {
            success: true,
            message: '获取成功',
            friends: friends
          }
        }
      } catch (_e) {
        return { success: false, message: '解析好友列表失败', friends: [] }
      }
    }

    if (ok) {
      return {
        success: true,
        message: '获取成功',
        friends: []
      }
    } else {
      return { success: false, message: '获取好友列表失败', friends: [] }
    }
  } catch (err) {
    console.error(`[getFriendsList] 请求异常: ${JSON.stringify(err)}`)
    return { success: false, message: '请求失败', friends: [] }
  } finally {
    client.destroy()
  }
}

export interface MessageItem {
  message_id: string
  message_user_id: string
  content: string
}

export interface MessageListResult {
  success: boolean
  message: string
  messages: MessageItem[]
}

class MessageItemRaw {
  message_id: number = 0
  message_user_id: number = 0
  content: string = ''
}

class MessagesData {
  user_id?: string
  friend_id?: string
}

class MessagesPayload {
  operation: string = 'query_message'
  table_name: string = 'message'
  data: MessagesData = new MessagesData()
}

export async function getMessagesList(userId: string, friendId: string): Promise<MessageListResult> {
  const url = 'http://146.56.215.115:10001/api/v1/service'
  const payload: MessagesPayload = new MessagesPayload()
  payload.data.user_id = String(userId)
  payload.data.friend_id = String(friendId)

  console.info(`[getMessagesList] 发起请求，userId: ${userId}, friendId: ${friendId}`)

  const client = http.createHttp()
  try {
    const options: http.HttpRequestOptions = new HttpOptions()
    options.extraData = JSON.stringify(payload)

    const res = await client.request(url, options)
    const ok = res.responseCode === 200

    console.info(`[getMessagesList] 响应状态码: ${res.responseCode}`)
    console.info(`[getMessagesList] 响应内容: ${res.result}`)

    const raw: string = typeof res.result === 'string' ? (res.result as string) : ''

    if (raw && ok) {
      try {
        const parsedObj: Record<string, MessageItemRaw[]> = JSON.parse(raw)
        const userIdKey = String(userId)
        const messagesArray = parsedObj[userIdKey]

        if (Array.isArray(messagesArray)) {
          const messages: MessageItem[] = []
          for (let i = 0; i < messagesArray.length; i++) {
            const item = messagesArray[i]
            if (typeof item === 'object' && item !== null) {
              const mItem = item as MessageItemRaw
              const msg: MessageItem = {
                message_id: String(mItem.message_id),
                message_user_id: String(mItem.message_user_id),
                content: mItem.content
              }
              messages.push(msg)
            }
          }
          return {
            success: true,
            message: '获取成功',
            messages: messages
          }
        }
      } catch (_e) {
        return { success: false, message: '解析消息列表失败', messages: [] }
      }
    }

    return { success: true, message: '获取成功', messages: [] }
  } catch (err) {
    console.error(`[getMessagesList] 请求异常: ${JSON.stringify(err)}`)
    return { success: false, message: '请求失败', messages: [] }
  } finally {
    client.destroy()
  }
}

export interface DeleteMessageResult {
  success: boolean
  message: string
}

class DeleteMessageData {
  user_id?: string
  message_id?: string
}

class DeleteMessagePayload {
  operation: string = 'delete_message'
  table_name: string = 'message'
  data: DeleteMessageData = new DeleteMessageData()
}

export async function deleteMessage(userId: string, messageId: string): Promise<DeleteMessageResult> {
  const url = 'http://146.56.215.115:10001/api/v1/service'
  const payload: DeleteMessagePayload = new DeleteMessagePayload()
  payload.data.user_id = String(userId)
  payload.data.message_id = String(messageId)

  console.info(`[deleteMessage] 发起请求，userId: ${userId}, messageId: ${messageId}`)

  const client = http.createHttp()
  try {
    const options: http.HttpRequestOptions = new HttpOptions()
    options.extraData = JSON.stringify(payload)

    const res = await client.request(url, options)
    const ok = res.responseCode === 200

    console.info(`[deleteMessage] 响应状态码: ${res.responseCode}`)
    console.info(`[deleteMessage] 响应内容: ${res.result}`)

    const raw: string = typeof res.result === 'string' ? (res.result as string) : ''

    if (raw && ok) {
      try {
        const parsedObj: DeleteMessageResponse = JSON.parse(raw)
        if (parsedObj.result === 'success') {
          return {
            success: true,
            message: '删除成功'
          }
        } else {
          return {
            success: false,
            message: parsedObj.text || '删除失败'
          }
        }
      } catch (_e) {
        return { success: false, message: '解析删除结果失败' }
      }
    }

    return { success: false, message: '网络错误' }
  } catch (err) {
    console.error(`[deleteMessage] 请求异常: ${JSON.stringify(err)}`)
    return { success: false, message: '请求失败' }
  } finally {
    client.destroy()
  }
}

class DeleteMessageResponse {
  result: string = ''
  user_id: string = ''
  text: string = ''
}

class SendMessageData {
  user_id: string = ''
  friend_id: string = ''
  content: string = ''
}

class SendMessagePayload {
  operation: string = 'add_message'
  table_name: string = 'message'
  data: SendMessageData = new SendMessageData()
}

class SendMessageResponse {
  result: string = ''
  user_id: string = ''
  text: string = ''
}

class SendMessageResult {
  success: boolean = false
  message: string = ''
}

export async function sendMessage(userId: string, friendId: string, content: string): Promise<SendMessageResult> {
  const url = 'http://146.56.215.115:10001/api/v1/service'
  const payload: SendMessagePayload = new SendMessagePayload()
  payload.data.user_id = String(userId)
  payload.data.friend_id = String(friendId)
  payload.data.content = String(content)

  console.info(`[sendMessage] 发起请求，userId: ${userId}, friendId: ${friendId}`)

  const client = http.createHttp()
  try {
    const options: http.HttpRequestOptions = new HttpOptions()
    options.extraData = JSON.stringify(payload)

    const res = await client.request(url, options)
    const ok = res.responseCode === 200

    console.info(`[sendMessage] 响应状态码: ${res.responseCode}`)
    console.info(`[sendMessage] 响应内容: ${res.result}`)

    const raw: string = typeof res.result === 'string' ? (res.result as string) : ''

    if (raw && ok) {
      try {
        const parsedObj: SendMessageResponse = JSON.parse(raw)
        const result: SendMessageResult = new SendMessageResult()
        if (parsedObj.result === 'success') {
          result.success = true
          result.message = '发送成功'
          return result
        } else {
          result.success = false
          result.message = parsedObj.text || '发送失败'
          return result
        }
      } catch (_e) {
        const result: SendMessageResult = new SendMessageResult()
        result.success = false
        result.message = '解析发送结果失败'
        return result
      }
    }

    const result: SendMessageResult = new SendMessageResult()
    result.success = false
    result.message = '请求失败'
    return result
  } catch (err) {
    console.error(`[sendMessage] 请求异常: ${JSON.stringify(err)}`)
    const result: SendMessageResult = new SendMessageResult()
    result.success = false
    result.message = '请求失败'
    return result
  } finally {
    client.destroy()
  }
}

class FavoriteMessageData {
  user_id: string = ''
  message_id: string = ''
}

class FavoriteMessagePayload {
  operation: string = 'add_favorites_message'
  table_name: string = 'favorites'
  data: FavoriteMessageData = new FavoriteMessageData()
}

class FavoriteMessageResponse {
  result: string = ''
  user_id: string = ''
  text: string = ''
}

class FavoriteMessageResult {
  success: boolean = false
  message: string = ''
}

export async function addFavoriteMessage(userId: string, messageId: string): Promise<FavoriteMessageResult> {
  const url = 'http://146.56.215.115:10001/api/v1/service'
  const payload: FavoriteMessagePayload = new FavoriteMessagePayload()
  payload.data.user_id = String(userId)
  payload.data.message_id = String(messageId)

  console.info(`[addFavoriteMessage] 发起请求，userId: ${userId}, messageId: ${messageId}`)

  const client = http.createHttp()
  try {
    const options: http.HttpRequestOptions = new HttpOptions()
    options.extraData = JSON.stringify(payload)

    const res = await client.request(url, options)
    const ok = res.responseCode === 200

    console.info(`[addFavoriteMessage] 响应状态码: ${res.responseCode}`)
    console.info(`[addFavoriteMessage] 响应内容: ${res.result}`)

    const raw: string = typeof res.result === 'string' ? (res.result as string) : ''

    if (raw && ok) {
      try {
        const parsedObj: FavoriteMessageResponse = JSON.parse(raw)
        const result: FavoriteMessageResult = new FavoriteMessageResult()
        if (parsedObj.result === 'success') {
          result.success = true
          result.message = '收藏成功'
          return result
        } else {
          result.success = false
          result.message = parsedObj.text || '收藏失败'
          return result
        }
      } catch (_e) {
        const result: FavoriteMessageResult = new FavoriteMessageResult()
        result.success = false
        result.message = '解析收藏结果失败'
        return result
      }
    }

    const result: FavoriteMessageResult = new FavoriteMessageResult()
    result.success = false
    result.message = '请求失败'
    return result
  } catch (err) {
    console.error(`[addFavoriteMessage] 请求异常: ${JSON.stringify(err)}`)
    const result: FavoriteMessageResult = new FavoriteMessageResult()
    result.success = false
    result.message = '请求失败'
    return result
  } finally {
    client.destroy()
  }
}

export interface SearchMessageResult {
  success: boolean
  message: string
  messages: SearchMessageItem[]
}

export interface SearchMessageItem {
  friend_id: string
  message_id: string
  content: string
}

class SearchMessageData {
  user_id: string = ''
  friend_id: string = ''
  content: string = ''
}

class SearchMessagePayload {
  operation: string = 'search_message'
  table_name: string = 'message'
  data: SearchMessageData = new SearchMessageData()
}

export async function searchMessage(userId: string, friendId: string, keyword: string): Promise<SearchMessageResult> {
  const url = 'http://146.56.215.115:10001/api/v1/service'
  const payload: SearchMessagePayload = new SearchMessagePayload()
  payload.data.user_id = String(userId)
  payload.data.friend_id = String(friendId)
  payload.data.content = keyword

  console.info(`[searchMessage] 发起请求，userId: ${userId}, friendId: ${friendId}, keyword: ${keyword}`)

  const client = http.createHttp()
  try {
    const options: http.HttpRequestOptions = new HttpOptions()
    options.extraData = JSON.stringify(payload)

    const res = await client.request(url, options)
    const ok = res.responseCode === 200

    console.info(`[searchMessage] 响应状态码: ${res.responseCode}`)
    console.info(`[searchMessage] 响应内容: ${res.result}`)

    const raw: string = typeof res.result === 'string' ? (res.result as string) : ''

    if (raw && ok) {
      try {
        const parsedObj: Record<string, Array<Record<string, string>>> = JSON.parse(raw)
        const messages: SearchMessageItem[] = []
        const keys: string[] = Object.keys(parsedObj)
        for (let i = 0; i < keys.length; i++) {
          const key: string = keys[i]
          const arr: Array<Record<string, string>> = parsedObj[key]
          if (arr && Array.isArray(arr)) {
            for (let j = 0; j < arr.length; j++) {
              const item: Record<string, string> = arr[j]
              messages.push({
                friend_id: item['friend_id'] || '',
                message_id: item['message_id'] || '',
                content: item['content'] || ''
              })
            }
          }
        }
        return {
          success: true,
          message: '搜索成功',
          messages: messages
        }
      } catch (_e) {
        return { success: false, message: '解析搜索结果失败', messages: [] }
      }
    }

    return { success: false, message: '网络错误', messages: [] }
  } catch (err) {
    console.error(`[searchMessage] 请求异常: ${JSON.stringify(err)}`)
    return { success: false, message: '请求失败', messages: [] }
  } finally {
    client.destroy()
  }
}


