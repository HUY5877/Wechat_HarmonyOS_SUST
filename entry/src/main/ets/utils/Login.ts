import http from '@ohos.net.http';

interface LoginResponse {
  success: boolean;
  message: string;
  data?: {
    user_id: string;
    account: string;
    name: string;
    profile_picture_id: string;
  };
}

interface UserInfoResponse {
  success: boolean;
  message: string;
  data?: {
    user_id: string;
    account: string;
    name: string;
    profile_picture_id: string;
  };
}

const baseUrl: string = 'http://146.56.215.115:10001/api/v1/service';

async function request(operation: string, tableName: string, data: any): Promise<any> {
  const httpRequest = http.createHttp();
  try {
    const response = await httpRequest.request(
      baseUrl,
      {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify({
          operation: operation,
          table_name: tableName,
          data: data
        })
      }
    );
    if (response.responseCode === 200) {
      const resultString: string = response.result as string;
      console.log('登录API响应:', resultString);
      const result = JSON.parse(resultString);
      return result;
    } else {
      console.log('网络请求失败');
      return { success: false, message: '网络请求失败' };
    }
  } catch (error) {
    console.error('API请求错误:', error);
    return { success: false, message: '请求错误' };
  } finally {
    httpRequest.destroy();
  }
}

export async function login(account: string, password: string): Promise<LoginResponse> {
  const data = {
    account: account,
    password: password
  };
  const result = await request('login', 'user', data);
  
  // 转换为标准格式
  if (result.result === 'success') {
    return {
      success: true,
      message: '登录成功',
      data: {
        user_id: result.user_id || '',
        account: account,
        name: result.name || '',
        profile_picture_id: result.profile_picture_id || '0'
      }
    };
  } else {
    return {
      success: false,
      message: result.text || '登录失败'
    };
  }
}

export async function getUserInfo(userId: string): Promise<UserInfoResponse> {
  const data = {
    user_id: userId
  };
  const result = await request('query_friend_homepage', 'user', data);
  
  // 转换为标准格式
  if (result.friend_id) {
    return {
      success: true,
      message: '获取用户信息成功',
      data: {
        user_id: result.friend_id,
        account: result.account || '',
        name: result.name || '',
        profile_picture_id: result.profile_picture_id || '0'
      }
    };
  } else {
    return {
      success: false,
      message: '获取用户信息失败'
    };
  }
}
