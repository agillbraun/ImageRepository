import axios from 'axios';
import { Image, CreatedImage, ImageInfo, Tag, Thumbnail } from 'core/types';

type ProgressCallback = (progress: number) => void;

const baseUrl = process.env.REACT_APP_BASE_URL;
export default class RestService {
  private constructor() {}

  // Image

  public static async getImage(id: string): Promise<Image> {
    const url = `${baseUrl}/api/images/${id}`;
    const res = await axios.get<Image>(url);
    return res.data;
  }

  public static async editImage(
    id: string,
    secret: string | null,
    info: ImageInfo
  ): Promise<Image> {
    if (!secret) throw new Error('Unauthorized');

    const url = `${baseUrl}/api/images/${id}`;
    const res = await axios.patch<Image>(url, info, {
      headers: this.makeAuthHeader(secret),
    });
    return res.data;
  }

  public static async deleteImage(
    id: string,
    secret: string | null
  ): Promise<void> {
    if (!secret) throw new Error('Unauthorized');
    const url = `${baseUrl}/api/images/${id}`;
    await axios.delete(url, {
      headers: this.makeAuthHeader(secret),
    });
  }

  // Images

  public static async getImages(
    page: number,
    pageSize: number
  ): Promise<Thumbnail[]> {
    page = Math.abs(page);
    pageSize = Math.abs(pageSize);
    const url = `${baseUrl}/api/images?thumbnails=true`;
    const res = await axios.get<Thumbnail[]>(url);
    return res.data;
  }

  public static async uploadImages(
    files: FileList,
    callback?: ProgressCallback
  ): Promise<CreatedImage[]> {
    const url = `${baseUrl}/api/images`;
    const formData = new FormData();
    for (const file of files) {
      formData.append('files[]', file);
    }

    const res = await axios.post<CreatedImage[]>(url, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
      onUploadProgress: event => {
        const { loaded, total } = event;
        const progress = Math.round((loaded * 100) / total);
        callback?.(progress);
      },
    });
    return res.data;
  }

  // Tag

  public static async deleteTag(
    id: string,
    secret: string | null,
    tag: Tag
  ): Promise<void> {
    if (!secret) throw new Error('Unauthorized');
    const name = encodeURIComponent(tag).replace(/%20/g, '+');
    const url = `${baseUrl}/api/images/${id}/tags/${name}`;
    await axios.delete(url, {
      headers: this.makeAuthHeader(secret),
    });
  }

  // Tags

  public static async getTags(id: string): Promise<Tag[]> {
    const url = `${baseUrl}/api/images/${id}/tags`;
    const res = await axios.get<Tag[]>(url);
    return res.data;
  }

  public static async addTags(
    id: string,
    secret: string | null,
    tags: Tag[]
  ): Promise<void> {
    if (!secret) throw new Error('Unauthorized');
    const url = `${baseUrl}/api/images/${id}/tags`;
    await axios.post(url, tags, {
      headers: this.makeAuthHeader(secret),
    });
  }

  // Search

  public static async searchImages(path: string): Promise<Thumbnail[]> {
    const url = `${baseUrl}/api${path}`;
    const res = await axios.get<Thumbnail[]>(url);
    return res.data;
  }

  // private

  private static makeAuthHeader(secret: string) {
    return {
      Authorization: `Basic ${btoa(`Owner:${secret}`)}`,
    };
  }
}
