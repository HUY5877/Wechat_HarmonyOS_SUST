import http from '@ohos.net.http';

// 定义接口
interface RequestParams {
  operation: string;
  table_name: string;
  data: object;
}

interface UserInfo {
  user_id: string;
  account: string;
  name: string;
  status: string;
  profile_picture_id: string;
}

interface UserIdData {
  user_id: string;
}

interface UserIdRequest {
  user_id: string;
}

class ApiService {
  private static readonly BASE_URL = 'http://146.56.215.115:10001/api/v1/service';
  /**
   * 发送API请求
   * @param operation 操作类型
   * @param tableName 表名
   * @param data 请求数据
   * @returns Promise<UserInfo> 返回结果
   */
  static async request(operation: string, tableName: string, data: object): Promise<UserInfo> {
    try {
      // 创建HTTP请求
      let httpRequest = http.createHttp();
      
      // 构建请求参数
      const requestParams: RequestParams = {
        operation,
        table_name: tableName,
        data
      };

      // 发送请求
      let response = await httpRequest.request(ApiService.BASE_URL, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(requestParams)
      });

      // 解析响应
      if (response.responseCode === 200) {
        const result = JSON.parse(response.result as string) as UserInfo;
        return result;
      } else {
        throw new Error(`HTTP request failed with code ${response.responseCode}`);
      }
    } catch (error) {
      console.error('API request error:', error);
      throw error instanceof Error ? error : new Error('Unknown error occurred');
    }
  }

  /**
   * 获取用户个人主页信息
   * @param userId 用户ID，默认值为1
   * @returns Promise<UserInfo> 用户信息
   */
  static async getPersonalHomepage(userId: string = "1"): Promise<UserInfo> {
    // 使用UserIdData接口定义数据结构
    const data: UserIdData = { user_id: userId };
    // 直接传递data对象，因为request方法现在接受any类型的参数
    return ApiService.request('query_personal_homepage', 'user', data);
  }
}

export default ApiService;


