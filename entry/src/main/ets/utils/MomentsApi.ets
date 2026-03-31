import http from '@ohos.net.http';

const BASE_URL = 'http://146.56.215.115:10001/api/v1/service';
const CURRENT_USER_ID = '1'; // 默认当前用户ID，后续应从登录状态获取

export class Moment {
  moments_id: string = '';
  moments_user_id: string = '';
  moments_content: string = '';
  created_at: string = '';
}

class RequestBody {
  operation: string = '';
  table_name: string = '';
  data: Object = new Object();
}

export class MomentsApi {

  static async request(operation: string, tableName: string, data: Object): Promise<Object | null> {
    const httpRequest = http.createHttp();
    let reqBody: RequestBody = {
      operation: operation,
      table_name: tableName,
      data: data
    };
    
    try {
      const response = await httpRequest.request(BASE_URL, {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: JSON.stringify(reqBody),
        readTimeout: 10000,
        connectTimeout: 10000
      });
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string) as Object;
      } else {
        console.error('API Error:', response.responseCode);
        return null;
      }
    } catch (err) {
      console.error('Request Exception:', err);
      return null;
    } finally {
      httpRequest.destroy();
    }
  }

  static async queryMoments(userId: string = CURRENT_USER_ID): Promise<Moment[]> {
    let data: Record<string, string> = { "user_id": userId };
    const res = await MomentsApi.request('query_moments', 'moments', data);
    if (res) {
      let resObj = res as Record<string, Object>;
      let keys = Object.keys(resObj);
      for (let i = 0; i < keys.length; i++) {
        let key = keys[i];
        let val = resObj[key];
        if (Array.isArray(val)) {
          return val as Moment[];
        }
      }
    }
    return [];
  }

  static async addMoment(userId: string = CURRENT_USER_ID, content: string): Promise<boolean> {
    let data: Record<string, string> = { "user_id": userId, "content": content };
    const res = await MomentsApi.request('add_moments', 'moments', data);
    if (res) {
      let resObj = res as Record<string, string>;
      if (resObj["result"] === 'success') {
        return true;
      }
    }
    return false;
  }

  static async deleteMoment(userId: string = CURRENT_USER_ID, momentsId: string): Promise<boolean> {
    let data: Record<string, string> = { "user_id": userId, "moments_id": momentsId };
    const res = await MomentsApi.request('delete_moments', 'moments', data);
    if (res) {
      let resObj = res as Record<string, string>;
      if (resObj["result"] === 'success') {
        return true;
      }
    }
    return false;
  }
  
  static getCurrentUserId(): string {
    return CURRENT_USER_ID;
  }
}
