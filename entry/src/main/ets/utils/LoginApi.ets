import http from '@ohos.net.http'
import AppStorage from '@ohos.app.ability.common'

export class LoginData {
  account: string = ''
  password: string = ''
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
            profile_picture_id: body.profile_picture_id !== undefined ? String(body.profile_picture_id) : '0',
            status: body.status || ''
          }
        }
      }
      
      return { success: false, message: '获取用户信息失败: 数据为空' }
    } else {
      return { success: false, message: '网络错误' }
    }
  } catch (err) {
    console.error(`[getUserInfo] 请求异常: ${JSON.stringify(err)}`)
    return { success: false, message: '请求失败' }
  } finally {
    client.destroy()
  }
}

/**
 * 退出登录
 */
export function logout(): void {
  // 清除 AppStorage 中的用户ID
  AppStorage.delete('userId');
  console.info('[logout] 退出登录成功');
}

/**
 * 更新用户信息
 */
export async function updateUserInfo(userId: string, name: string, status: string, profilePictureId: string): Promise<RegisterResult> {
  const url = 'http://146.56.215.115:10001/api/v1/service';
  
  class UpdatePayload {
    operation: string = 'recompose_personal_homepage';
    table_name: string = 'user';
    data: UpdateData = new UpdateData();
  }
  
  class UpdateData {
    user_id: string = '';
    name: string = '';
    status: string = '';
    profile_picture_id: string = '';
  }
  
  const payload: UpdatePayload = new UpdatePayload();
  payload.data.user_id = userId;
  payload.data.name = name;
  payload.data.status = status;
  payload.data.profile_picture_id = profilePictureId;

  console.info(`[updateUserInfo] 发起请求，payload: ${JSON.stringify(payload)}`);

  const client = http.createHttp();
  try {
    const options: http.HttpRequestOptions = new HttpOptions();
    options.extraData = JSON.stringify(payload);
    
    const res = await client.request(url, options);
    const ok = res.responseCode === 200;
    
    console.info(`[updateUserInfo] 响应状态码: ${res.responseCode}`);
    console.info(`[updateUserInfo] 响应内容: ${res.result}`);
    
    let body: LoginResponse | null = null;
    const raw: string = typeof res.result === 'string' ? (res.result as string) : '';
    
    if (raw) {
      try {
        body = JSON.parse(raw) as LoginResponse;
      } catch (_e) {
        body = null;
      }
    }

    if (ok) {
      if (body && body.result === 'success') {
        return { success: true, message: '更新成功' };
      } else {
        const msg: string = body && body.text ? body.text : '更新失败';
        return { success: false, message: msg };
      }
    } else {
      return { success: false, message: '网络错误' };
    }
  } catch (err) {
    console.error(`[updateUserInfo] 请求异常: ${JSON.stringify(err)}`);
    return { success: false, message: '请求失败' };
  } finally {
    client.destroy();
  }
}
