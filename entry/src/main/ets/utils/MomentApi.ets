import ApiService, { BaseResponse, UserIdParams } from './ApiService';

/**
 * Moment item in list
 */
export interface MomentItem {
  moments_id: string;
  moments_user_id: string;
  moments_content: string;
  created_at: string;
}

/**
 * Data structures for requests to satisfy ArkTS strict typing
 */
interface AddMomentData {
  user_id: string;
  content: string;
}

interface DeleteMomentData {
  user_id: string;
  moments_id: string;
}

/**
 * Service for moments management
 */
export class MomentApi {
  /**
   * Query moments for all users or specified user
   * According to spec, it takes user_id and returns a list.
   */
  static async getMoments(userId: string): Promise<MomentItem[]> {
    try {
      const data: UserIdParams = { user_id: userId };
      const res = await ApiService.request<object>('query_moments', 'moments', data);
      return ApiService.extractList<MomentItem>(res, userId);
    } catch (err) {
      console.error('[MomentApi] Error in getMoments:', err);
      return [];
    }
  }

  /**
   * Post a new moment
   */
  static async addMoment(userId: string, content: string): Promise<BaseResponse> {
    try {
      const data: AddMomentData = { user_id: userId, content: content };
      return await ApiService.request<BaseResponse>('add_moments', 'moments', data);
    } catch (err) {
      return { result: 'fail', text: '网络错误' };
    }
  }

  /**
   * Delete a moment
   */
  static async deleteMoment(userId: string, momentId: string): Promise<BaseResponse> {
    try {
      const data: DeleteMomentData = { user_id: userId, moments_id: momentId };
      return await ApiService.request<BaseResponse>('delete_moments', 'moments', data);
    } catch (err) {
      return { result: 'fail', text: '网络错误' };
    }
  }
}

export default MomentApi;
