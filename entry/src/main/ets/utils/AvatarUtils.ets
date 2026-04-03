/**
 * 根据用户的 profile_picture_id 获取对应的头像资源
 * @param profilePictureId 用户的头像 ID
 * @returns 对应的头像资源，如果不存在则返回默认头像
 */
export function getAvatarResource(profilePictureId: string): Resource {
  // 构建头像资源名称
  const avatarName = `avatar_${profilePictureId}`;
  
  try {
    // 尝试获取对应的头像资源
    return $r(`app.media.${avatarName}`);
  } catch (error) {
    // 如果资源不存在，返回默认头像
    console.warn(`Avatar resource ${avatarName} not found, using default`);
    return $r('app.media.avatar_0');
  }
}
