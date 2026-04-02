import ApiService, { BaseResponse, UserIdParams } from './ApiService';

/**
 * Common Login/Register Result
 */
export interface AuthResult {
  success: boolean;
  message: string;
  userId?: string;
}

/**
 * User personal homepage information
 */
export interface UserInfo {
  user_id: string;
  account: string;
  name: string;
  status: string;
  profile_picture_id: string;
}

/**
 * Search message item
 */
export interface SearchMessageItem {
  message_id: string;
  friend_id: string;
  content: string;
  created_at: string;
}

/**
 * Friend item for forward page
 */
export interface FriendItem {
  friend_id: string;
  name: string;
}

/**
 * Data structures for requests to satisfy ArkTS strict typing
 */
interface RegisterData {
  account: string;
  password: string;
  name: string;
  status: string;
  profile_picture_id: string;
}

interface LoginData {
  account: string;
  password: string;
}

interface UpdateUserInfoData {
  user_id: string;
  name: string;
  status: string;
  profile_picture_id: string;
}

export interface SearchMessageParams {
  user_id: string;
  friend_id: string;
  content: string;
}

export interface SearchMessageResult {
  success: boolean;
  message: string;
  messages: SearchMessageItem[];
}

/**
 * Register user
 */
export async function register(account: string, password: string, name: string, avatarId: string = '0'): Promise<AuthResult> {
  try {
    const data: RegisterData = {
      account: account.trim(),
      password: password,
      name: name.trim(),
      status: '1',
      profile_picture_id: avatarId
    };
    const res = await ApiService.request<BaseResponse>('register', 'user', data);
    if (res.result === 'success') {
      return { success: true, message: '注册成功', userId: res.user_id };
    }
    return { success: false, message: res.text || '注册失败' };
  } catch (err) {
    return { success: false, message: '网络错误' };
  }
}

/**
 * Login user
 */
export async function login(account: string, password: string): Promise<AuthResult> {
  try {
    const data: LoginData = {
      account: account.trim(),
      password: password
    };
    const res = await ApiService.request<BaseResponse>('login', 'user', data);
    if (res.result === 'success') {
      return { success: true, message: '登录成功', userId: String(res.user_id) };
    }
    return { success: false, message: res.text || '登录失败' };
  } catch (err) {
    return { success: false, message: '网络错误' };
  }
}

/**
 * Get user personal homepage info
 */
export async function getUserInfo(userId: string): Promise<UserInfo | null> {
  try {
    const data: UserIdParams = { user_id: userId };
    const res = await ApiService.request<UserInfo>('query_personal_homepage', 'user', data);
    if (res && res.user_id) {
      return res;
    }
    return null;
  } catch (err) {
    return null;
  }
}

/**
 * Modify personal information
 */
export async function updateUserInfo(userId: string, name: string, status: string, avatarId: string): Promise<AuthResult> {
  try {
    const data: UpdateUserInfoData = {
      user_id: userId,
      name: name,
      status: status,
      profile_picture_id: avatarId
    };
    const res = await ApiService.request<BaseResponse>('recompose_personal_homepage', 'user', data);
    if (res.result === 'success') {
      return { success: true, message: '修改成功' };
    }
    return { success: false, message: res.text || '修改失败' };
  } catch (err) {
    return { success: false, message: '网络错误' };
  }
}

/**
 * Search messages by keyword
 */
export async function searchMessage(userId: string, friendId: string, keyword: string): Promise<SearchMessageResult> {
  try {
    const data: SearchMessageParams = { user_id: userId, friend_id: friendId, content: keyword };
    const res = await ApiService.request<object>('search_message', 'message', data);
    const messages = ApiService.extractList<SearchMessageItem>(res, userId);
    return { success: true, message: '搜索成功', messages: messages };
  } catch (err) {
    return { success: false, message: '网络错误', messages: [] };
  }
}

/**
 * Support for Friends/Messages - moved to individual services but keeping legacy imports if needed
 */
export { getMessagesList, sendMessage, deleteMessage } from './ChatApi';
export { getFriendsList } from './ContactApi';
