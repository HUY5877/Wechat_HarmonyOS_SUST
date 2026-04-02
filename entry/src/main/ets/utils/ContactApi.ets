import ApiService, { BaseResponse, UserIdParams, AccountParams, ContactSearchParams } from './ApiService';

/**
 * Contact/Friend item in list
 */
export interface FriendInfo {
  friend_id: string;
  name: string;
}

/**
 * Friend detail information
 */
export interface FriendDetail {
  friend_id: string;
  name: string;
  account: string;
  status: string;
  profile_picture_id: string;
}

/**
 * Friend item for forward page
 */
export interface FriendItem {
  friend_id: string;
  name: string;
}

/**
 * Add Friend result
 */
export interface AddFriendResult {
  result: 'success' | 'fail';
  text: string;
}

/**
 * Result of getFriendsList
 */
export interface GetFriendsResult {
  success: boolean;
  message: string;
  friends: FriendInfo[];
}

/**
 * Service for managing contacts
 */
export default class ContactApi {
  /**
   * Query all contacts for a user
   */
  static async getContacts(userId: string): Promise<FriendInfo[]> {
    try {
      const data: UserIdParams = { user_id: userId };
      const res = await ApiService.request<object>('query_contacts', 'contacts', data);
      return ApiService.extractList<FriendInfo>(res, userId);
    } catch (err) {
      console.error('[ContactApi] Error in getContacts:', err);
      return [];
    }
  }

  /**
   * Add a new friend by account
   */
  static async addFriend(userId: string, account: string): Promise<BaseResponse> {
    try {
      const data: AccountParams = { user_id: userId, account: account };
      return await ApiService.request<BaseResponse>('add_friend', 'contacts', data);
    } catch (err) {
      return { result: 'fail', text: '网络错误' };
    }
  }

  /**
   * Search for contacts by name
   */
  static async searchContacts(userId: string, friendName: string = ''): Promise<FriendInfo[]> {
    try {
      const data: ContactSearchParams = { user_id: userId, friend_name: friendName };
      const res = await ApiService.request<object>('query_contacts_', 'contacts', data);
      return ApiService.extractList<FriendInfo>(res, userId);
    } catch (err) {
      return [];
    }
  }

  /**
   * Get friend personal details
   */
  static async getFriendDetail(friendUserId: string): Promise<Record<string, string> | null> {
    try {
      const data: UserIdParams = { user_id: friendUserId };
      return await ApiService.request<Record<string, string>>('query_friend_homepage', 'user', data);
    } catch (err) {
      return null;
    }
  }
}

/**
 * Global accessor for shared usage
 */
export const getFriendsList = async (userId: string): Promise<GetFriendsResult> => {
  const friends = await ContactApi.getContacts(userId);
  return { success: true, message: '获取成功', friends: friends };
};
