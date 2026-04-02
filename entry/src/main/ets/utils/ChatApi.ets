import ApiService, { BaseResponse, UserIdParams, FriendIdParams, DeleteMsgParams, AddMsgParams, MsgSearchParams } from './ApiService';

/**
 * Message Model
 */
export interface MessageItem {
  message_id: string;
  message_user_id: string;
  content: string;
  created_at?: string;
}

/**
 * Message List Summary (Conversation Item)
 */
export interface MessageSummary {
  user_id: string;
  user_name: string;
  new_message: string;
}

/**
 * Result of sendMessage
 */
export interface SendMessageResult {
  success: boolean;
  message: string;
  userId?: string;
}

/**
 * Query message list (conversations)
 */
export async function getMessageList(userId: string): Promise<MessageSummary[]> {
  try {
    const data: UserIdParams = { user_id: userId };
    const res = await ApiService.request<object>('query_message_list', 'message', data);
    return ApiService.extractList<MessageSummary>(res, userId);
  } catch (err) {
    return [];
  }
}

/**
 * Query message history between user and friend
 */
export async function getMessagesHistory(userId: string, friendId: string): Promise<MessageItem[]> {
  try {
    const data: FriendIdParams = { user_id: userId, friend_id: friendId };
    const res = await ApiService.request<object>('query_message', 'message', data);
    return ApiService.extractList<MessageItem>(res, userId);
  } catch (err) {
    return [];
  }
}

/**
 * Send a message
 */
export async function sendMessage(userId: string, friendId: string, content: string): Promise<SendMessageResult> {
  try {
    const data: AddMsgParams = { user_id: userId, friend_id: friendId, content: content };
    const res = await ApiService.request<BaseResponse>('add_message', 'message', data);
    if (res.result === 'success') {
      return { success: true, message: '发送成功', userId: res.user_id };
    }
    return { success: false, message: res.text || '发送失败' };
  } catch (err) {
    return { success: false, message: '网络错误' };
  }
}

/**
 * Delete a message
 */
export async function deleteMessage(userId: string, messageId: string): Promise<SendMessageResult> {
  try {
    const data: DeleteMsgParams = { user_id: userId, message_id: messageId };
    const res = await ApiService.request<BaseResponse>('delete_message', 'message', data);
    if (res.result === 'success') {
      return { success: true, message: '删除成功' };
    }
    return { success: false, message: res.text || '删除失败' };
  } catch (err) {
    return { success: false, message: '网络错误' };
  }
}

/**
 * Search for messages
 */
export async function searchMessage(userId: string, keyword: string): Promise<object | null> {
    try {
        const data: MsgSearchParams = { user_id: userId, content: keyword };
        const res = await ApiService.request<object>('search_message', 'message', data);
        return res;
    } catch (err) {
        return null;
    }
}

// Legacy aliases to maintain compatibility in intermediate steps
export const getMessagesList = getMessagesHistory;
