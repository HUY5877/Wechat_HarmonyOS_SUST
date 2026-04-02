import ApiService from './ApiService';

export interface WalletQueryParams {
  user_id: string;
}

export interface WalletUpdateParams {
  user_id: string;
  amount: number;
}

export interface BalanceResponse {
  result: 'success' | 'fail';
  Change?: number | string;
  text?: string;
}

export interface LingqiantongResponse {
  result: 'success' | 'fail';
  Change_Pass?: number | string;
  text?: string;
}

export interface BankCardItem {
  bankCard: string;
  bank: string;
}

export interface BankCardList {
  card: Record<string, string>[];
}

export interface BankCardResponse {
  result: 'success' | 'fail';
  card?: BankCardList;
  text?: string;
}

export interface AddBankCardParams {
  user_id: string;
  "Bank Card": string;
  "Bank": string;
}

export interface DeleteBankCardParams {
  user_id: string;
  "Bank Card": string;
}

/**
 * 获取零钱
 */
export async function queryChange(userId: string): Promise<number> {
  try {
    const data: WalletQueryParams = { user_id: userId };
    const res = await ApiService.request<BalanceResponse>('query_change', 'user', data);
    if (res.result === 'success' && res.Change !== undefined) {
      return typeof res.Change === 'string' ? parseFloat(res.Change) : res.Change;
    }
    return 0;
  } catch (err) {
    console.error(`[WalletApi] queryChange error: ${JSON.stringify(err)}`);
    return 0;
  }
}

/**
 * 获取零钱通
 */
export async function queryChangePass(userId: string): Promise<number> {
  try {
    const data: WalletQueryParams = { user_id: userId };
    const res = await ApiService.request<LingqiantongResponse>('query_change_pass', 'user', data);
    if (res.result === 'success' && res.Change_Pass !== undefined) {
      return typeof res.Change_Pass === 'string' ? parseFloat(res.Change_Pass) : res.Change_Pass;
    }
    return 0;
  } catch (err) {
    console.error(`[WalletApi] queryChangePass error: ${JSON.stringify(err)}`);
    return 0;
  }
}

/**
 * 增加零钱
 */
export async function addChange(userId: string, amount: number): Promise<boolean> {
  try {
    const data: WalletUpdateParams = { user_id: userId, amount: amount };
    const res = await ApiService.request<BalanceResponse>('add_change', 'user', data);
    return res.result === 'success';
  } catch (err) {
    console.error(`[WalletApi] addChange error: ${JSON.stringify(err)}`);
    return false;
  }
}

/**
 * 减少零钱
 */
export async function reduceChange(userId: string, amount: number): Promise<boolean> {
  try {
    const data: WalletUpdateParams = { user_id: userId, amount: amount };
    const res = await ApiService.request<BalanceResponse>('reduce_change', 'user', data);
    return res.result === 'success';
  } catch (err) {
    console.error(`[WalletApi] reduceChange error: ${JSON.stringify(err)}`);
    return false;
  }
}

/**
 * 增加零钱通
 */
export async function addChangePass(userId: string, amount: number): Promise<boolean> {
  try {
    const data: WalletUpdateParams = { user_id: userId, amount: amount };
    const res = await ApiService.request<LingqiantongResponse>('add_change_pass', 'user', data);
    return res.result === 'success';
  } catch (err) {
    console.error(`[WalletApi] addChangePass error: ${JSON.stringify(err)}`);
    return false;
  }
}

/**
 * 减少零钱通
 */
export async function reduceChangePass(userId: string, amount: number): Promise<boolean> {
  try {
    const data: WalletUpdateParams = { user_id: userId, amount: amount };
    const res = await ApiService.request<LingqiantongResponse>('reduce_change_pass', 'user', data);
    return res.result === 'success';
  } catch (err) {
    console.error(`[WalletApi] reduceChangePass error: ${JSON.stringify(err)}`);
    return false;
  }
}

/**
 * 零钱转零钱通
 */
export async function transferToLingqiantong(userId: string, amount: number): Promise<boolean> {
  if (amount <= 0) return false;
  // 先扣除零钱
  const reduceSuccess = await reduceChange(userId, amount);
  if (reduceSuccess) {
    // 增加零钱通
    const addSuccess = await addChangePass(userId, amount);
    if (addSuccess) {
      return true;
    } else {
      // 补偿机制：如果增加零钱通失败，退还零钱
      await addChange(userId, amount);
      return false;
    }
  }
  return false;
}

/**
 * 零钱通转零钱
 */
export async function transferToBalance(userId: string, amount: number): Promise<boolean> {
  if (amount <= 0) return false;
  // 先扣除零钱通
  const reduceSuccess = await reduceChangePass(userId, amount);
  if (reduceSuccess) {
    // 增加零钱
    const addSuccess = await addChange(userId, amount);
    if (addSuccess) {
      return true;
    } else {
      // 补偿机制：如果增加零钱失败，退还零钱通
      await addChangePass(userId, amount);
      return false;
    }
  }
  return false;
}

/**
 * 获取银行卡列表
 */
export async function queryBankCards(userId: string): Promise<BankCardItem[]> {
  try {
    const data: WalletQueryParams = { user_id: userId };
    // 使用严格类型接收后端包含空格字段的数据
    const res = await ApiService.request<BankCardResponse>('query_card', 'user', data);
    if (res.result === 'success' && res.card && Array.isArray(res.card.card)) {
      // 转换后端字段以符合 ArkTS 命名规范
      const mappedCards: BankCardItem[] = res.card.card.map((item: Record<string, string>) => {
        return {
          bankCard: item["Bank Card"] || '',
          bank: item["Bank"] || ''
        } as BankCardItem;
      });
      return mappedCards;
    }
    return [];
  } catch (err) {
    console.error(`[WalletApi] queryBankCards error: ${JSON.stringify(err)}`);
    return [];
  }
}

/**
 * 添加银行卡
 */
export async function addBankCard(userId: string, bankCard: string, bankName: string): Promise<boolean> {
  try {
    const data: AddBankCardParams = { 
      user_id: userId, 
      "Bank Card": bankCard,
      "Bank": bankName
    };
    const res = await ApiService.request<BankCardResponse>('add_card', 'user', data);
    return res.result === 'success';
  } catch (err) {
    console.error(`[WalletApi] addBankCard error: ${JSON.stringify(err)}`);
    return false;
  }
}

/**
 * 删除银行卡
 */
export async function deleteBankCard(userId: string, bankCard: string): Promise<boolean> {
  try {
    const data: DeleteBankCardParams = { 
      user_id: userId, 
      "Bank Card": bankCard
    };
    const res = await ApiService.request<BankCardResponse>('reduce_card', 'user', data);
    return res.result === 'success';
  } catch (err) {
    console.error(`[WalletApi] deleteBankCard error: ${JSON.stringify(err)}`);
    return false;
  }
}
