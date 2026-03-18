import prompt from '@ohos.promptAction';
import http from '@ohos.net.http';

interface ApiResponse {
  result: string
  user_id: string
  text: string
}

export interface FriendInfo {
  friend_id: string
  name: string
}

interface ContactApiResult {
  user_id: FriendInfo[]
}

interface AddFriendResult {
  result: string
  text: string
}

interface RequestData {
  user_id?: string
  friend_name?: string
  account?: string
}

export default class ContactApi {
  private static baseUrl: string = 'http://47.110.126.251:8080/api';

  private static async request(operation: string, tableName: string, data: RequestData): Promise<ApiResponse | ContactApiResult | AddFriendResult> {
    const httpRequest = http.createHttp();
    try {
      const response = await httpRequest.request(
        ContactApi.baseUrl,
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
        const result = JSON.parse(response.result as string) as ApiResponse | ContactApiResult | AddFriendResult;
        return result;
      } else {
        prompt.showToast({ message: '网络请求失败' });
        return { result: 'fail', text: '网络请求失败' } as AddFriendResult;
      }
    } catch (error) {
      prompt.showToast({ message: '请求错误: ' + JSON.stringify(error) });
      return { result: 'fail', text: '请求错误' } as AddFriendResult;
    } finally {
      httpRequest.destroy();
    }
  }

  static async getContacts(userId: string): Promise<FriendInfo[]> {
    const data: RequestData = { user_id: userId };
    const result = await ContactApi.request('query_contacts', 'contacts', data) as ContactApiResult;
    return result.user_id || [];
  }

  static async searchContacts(userId: string, friendName: string): Promise<FriendInfo[]> {
    const data: RequestData = {
      user_id: userId,
      friend_name: friendName
    };
    const result = await ContactApi.request('query_contacts_', 'contacts', data) as ContactApiResult;
    return result.user_id || [];
  }

  static async addFriend(userId: string, account: string): Promise<AddFriendResult> {
    const data: RequestData = {
      user_id: userId,
      account: account
    };
    const result = await ContactApi.request('add_friend', 'contacts', data) as AddFriendResult;
    return result;
  }

  static async getFriendHomepage(userId: string, friendId: string): Promise<ApiResponse> {
    const data: RequestData = {
      user_id: friendId
    };
    const result = await ContactApi.request('query_friend_homepage', 'user', data) as ApiResponse;
    return result;
  }
}
