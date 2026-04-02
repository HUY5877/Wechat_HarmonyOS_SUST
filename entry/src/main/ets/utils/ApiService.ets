import http from '@ohos.net.http';

/**
 * Common request data interfaces to satisfy ArkTS strict typing
 */
export interface UserIdParams {
  user_id: string;
}

export interface FriendIdParams {
  user_id: string;
  friend_id: string;
}

export interface AccountParams {
  user_id: string;
  account: string;
}

export interface MsgSearchParams {
  user_id: string;
  content: string;
}

export interface FavoriteSearchParams {
  user_id: string;
  content: string;
}

export interface DeleteMsgParams {
  user_id: string;
  message_id: string;
}

export interface AddMsgParams {
  user_id: string;
  friend_id: string;
  content: string;
}

export interface ContactSearchParams {
  user_id: string;
  friend_name: string;
}

/**
 * Unified request payload structure
 */
export interface RequestParams {
  operation: string;
  table_name: string;
  data: object; // Use object instead of Record for broader compatibility with specific interfaces
}

/**
 * Standard Success/Fail response result
 */
export interface BaseResponse {
  result: 'success' | 'fail';
  user_id?: string;
  text?: string;
}

/**
 * Service for central communication with the backend
 */
export class ApiService {
  private static readonly BASE_URL = 'http://146.56.215.115:10001/api/v1/service';

  /**
   * Generic POST requester
   */
  static async request<T>(operation: string, tableName: string, data: object): Promise<T> {
    const httpRequest = http.createHttp();
    try {
      const payload: RequestParams = {
        operation: operation,
        table_name: tableName,
        data: data
      };

      console.info(`[ApiService] Request: ${JSON.stringify(payload)}`);

      const response = await httpRequest.request(ApiService.BASE_URL, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(payload),
        connectTimeout: 15000,
        readTimeout: 15000
      });

      if (response.responseCode === 200) {
        const resultString: string = response.result as string;
        console.info(`[ApiService] Response: ${resultString}`);
        return JSON.parse(resultString) as T;
      } else {
        throw new Error(`HTTP ${response.responseCode}`);
      }
    } catch (error) {
      console.error(`[ApiService] Error: ${JSON.stringify(error)}`);
      throw new Error(`API请求失败: ${error}`);
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * Helper to extract the list from a response that is keyed by userId
   * e.g. {"123": [...]}
   */
  static extractList<T>(response: object, userId: string): T[] {
    if (!response || !userId) return [];
    const resObj = response as Record<string, T[]>;
    const list = resObj[userId];
    return Array.isArray(list) ? list : [];
  }

  /**
   * Get user personal homepage information
   */
  static async getPersonalHomepage(userId: string): Promise<Record<string, string> | null> {
    try {
      const data: UserIdParams = { user_id: userId };
      return await ApiService.request<Record<string, string>>('query_personal_homepage', 'user', data);
    } catch (err) {
      console.error(`[ApiService] Error in getPersonalHomepage: ${JSON.stringify(err)}`);
      return null;
    }
  }
}

export default ApiService;
