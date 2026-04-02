import ApiService, { BaseResponse, UserIdParams, FavoriteSearchParams, DeleteMsgParams } from './ApiService';

/**
 * Favorite item
 */
export interface FavoriteItem {
  favorites_id: string;
  favorites_user_id: string;
  message_id: string;
  content: string;
  created_at: string;
}

/**
 * Favorite Search Result
 */
export interface FavoriteSearchItem {
  favorites_id: string;
  message_id: string;
  favorites_content: string;
  created_at: string;
}

/**
 * Data structures for requests to satisfy ArkTS strict typing
 */
interface AddFavoriteData {
  user_id: string;
  message_id: string;
}

/**
 * Service for favorites management
 */
export class FavoriteApi {
  /**
   * Query all favorites for a user
   */
  static async getFavorites(userId: string): Promise<FavoriteItem[]> {
    try {
      const data: UserIdParams = { user_id: userId };
      const res = await ApiService.request<object>('query_favorites', 'favorites', data);
      return ApiService.extractList<FavoriteItem>(res, userId);
    } catch (err) {
      return [];
    }
  }

  /**
   * Add a message to favorites
   */
  static async addFavorite(userId: string, messageId: string): Promise<BaseResponse> {
    try {
      const data: AddFavoriteData = { user_id: userId, message_id: messageId };
      return await ApiService.request<BaseResponse>('add_favorites_message', 'favorites', data);
    } catch (err) {
      return { result: 'fail', text: '网络错误' };
    }
  }

  /**
   * Delete a favorite
   */
  static async deleteFavorite(userId: string, messageId: string): Promise<BaseResponse> {
    try {
      const data: DeleteMsgParams = { user_id: userId, message_id: messageId };
      return await ApiService.request<BaseResponse>('delete_favorites_message', 'favorites', data);
    } catch (err) {
      return { result: 'fail', text: '网络错误' };
    }
  }

  /**
   * Search favorites
   */
  static async searchFavorites(userId: string, content: string): Promise<FavoriteSearchItem[]> {
    try {
      const data: FavoriteSearchParams = { user_id: userId, content: content };
      const res = await ApiService.request<object>('query_favorites_message', 'favorites', data);
      return ApiService.extractList<FavoriteSearchItem>(res, userId);
    } catch (err) {
      return [];
    }
  }
}

export default FavoriteApi;
