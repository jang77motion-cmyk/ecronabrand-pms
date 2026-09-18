import axios, { AxiosInstance } from 'axios';
import dotenv from 'dotenv';

dotenv.config();

interface Cafe24Config {
  clientId: string;
  clientSecret: string;
  mallId: string;
  redirectUri: string;
}

interface TokenResponse {
  access_token: string;
  expires_in: number;
  token_type: string;
  refresh_token?: string;
  scope?: string;
}

export class Cafe24Client {
  private config: Cafe24Config;
  private axiosInstance: AxiosInstance;
  private accessToken: string = '';
  private tokenExpiry: number = 0;
  private refreshToken: string = '';

  private readonly baseURL = 'https://api.cafe24.com';
  private readonly authURL = 'https://auth.cafe24.com';

  constructor(config?: Partial<Cafe24Config>) {
    this.config = {
      clientId: config?.clientId || process.env.CAFE24_CLIENT_ID || '',
      clientSecret: config?.clientSecret || process.env.CAFE24_CLIENT_SECRET || '',
      mallId: config?.mallId || process.env.CAFE24_MALL_ID || '',
      redirectUri: config?.redirectUri || process.env.CAFE24_REDIRECT_URI || 'http://localhost:3001/api/cafe24/callback'
    };

    this.axiosInstance = axios.create({
      baseURL: this.baseURL,
      headers: {
        'Content-Type': 'application/json'
      }
    });

    // Add interceptor to include access token
    this.axiosInstance.interceptors.request.use((config) => {
      if (this.accessToken) {
        config.headers.Authorization = `Bearer ${this.accessToken}`;
      }
      return config;
    });
  }

  /**
   * Get OAuth authorization URL for user login
   */
  getAuthorizationUrl(state: string = ''): string {
    const params = new URLSearchParams({
      client_id: this.config.clientId,
      redirect_uri: this.config.redirectUri,
      response_type: 'code',
      state: state || 'random_state_value'
    });

    return `${this.authURL}/oauth/authorize?${params.toString()}`;
  }

  /**
   * Exchange authorization code for access token
   */
  async exchangeCodeForToken(code: string): Promise<TokenResponse> {
    try {
      const response = await axios.post<TokenResponse>(
        `${this.authURL}/oauth/token`,
        {
          client_id: this.config.clientId,
          client_secret: this.config.clientSecret,
          code: code,
          grant_type: 'authorization_code',
          redirect_uri: this.config.redirectUri
        }
      );

      this.accessToken = response.data.access_token;
      this.tokenExpiry = Date.now() + (response.data.expires_in * 1000);
      this.refreshToken = response.data.refresh_token || '';

      return response.data;
    } catch (error) {
      console.error('Error exchanging code for token:', error);
      throw error;
    }
  }

  /**
   * Refresh access token using refresh token
   */
  async refreshAccessToken(): Promise<TokenResponse> {
    if (!this.refreshToken) {
      throw new Error('No refresh token available');
    }

    try {
      const response = await axios.post<TokenResponse>(
        `${this.authURL}/oauth/token`,
        {
          client_id: this.config.clientId,
          client_secret: this.config.clientSecret,
          refresh_token: this.refreshToken,
          grant_type: 'refresh_token'
        }
      );

      this.accessToken = response.data.access_token;
      this.tokenExpiry = Date.now() + (response.data.expires_in * 1000);
      this.refreshToken = response.data.refresh_token || this.refreshToken;

      return response.data;
    } catch (error) {
      console.error('Error refreshing access token:', error);
      throw error;
    }
  }

  /**
   * Check if token needs refresh
   */
  private isTokenExpired(): boolean {
    return Date.now() >= this.tokenExpiry;
  }

  /**
   * Ensure token is valid (refresh if needed)
   */
  private async ensureValidToken(): Promise<void> {
    if (this.isTokenExpired() && this.refreshToken) {
      await this.refreshAccessToken();
    }
  }

  /**
   * Set access token directly
   */
  setAccessToken(token: string, expiresIn: number, refreshToken?: string): void {
    this.accessToken = token;
    this.tokenExpiry = Date.now() + (expiresIn * 1000);
    if (refreshToken) {
      this.refreshToken = refreshToken;
    }
  }

  /**
   * Get list of orders from Cafe24
   */
  async getOrders(params?: Record<string, any>): Promise<any> {
    await this.ensureValidToken();

    try {
      const response = await this.axiosInstance.get(
        `/api/v2/admin/orders`,
        { params: { limit: 100, ...params } }
      );
      return response.data;
    } catch (error) {
      console.error('Error fetching orders:', error);
      throw error;
    }
  }

  /**
   * Get single order details
   */
  async getOrder(orderNo: string): Promise<any> {
    await this.ensureValidToken();

    try {
      const response = await this.axiosInstance.get(
        `/api/v2/admin/orders/${orderNo}`
      );
      return response.data;
    } catch (error) {
      console.error(`Error fetching order ${orderNo}:`, error);
      throw error;
    }
  }

  /**
   * Update order status
   */
  async updateOrderStatus(orderNo: string, status: string): Promise<any> {
    await this.ensureValidToken();

    try {
      const response = await this.axiosInstance.put(
        `/api/v2/admin/orders/${orderNo}`,
        { status: status }
      );
      return response.data;
    } catch (error) {
      console.error(`Error updating order ${orderNo}:`, error);
      throw error;
    }
  }

  /**
   * Get list of products from Cafe24
   */
  async getProducts(params?: Record<string, any>): Promise<any> {
    await this.ensureValidToken();

    try {
      const response = await this.axiosInstance.get(
        `/api/v2/admin/products`,
        { params: { limit: 100, ...params } }
      );
      return response.data;
    } catch (error) {
      console.error('Error fetching products:', error);
      throw error;
    }
  }

  /**
   * Get single product details
   */
  async getProduct(productNo: string): Promise<any> {
    await this.ensureValidToken();

    try {
      const response = await this.axiosInstance.get(
        `/api/v2/admin/products/${productNo}`
      );
      return response.data;
    } catch (error) {
      console.error(`Error fetching product ${productNo}:`, error);
      throw error;
    }
  }

  /**
   * Update product information
   */
  async updateProduct(productNo: string, data: Record<string, any>): Promise<any> {
    await this.ensureValidToken();

    try {
      const response = await this.axiosInstance.put(
        `/api/v2/admin/products/${productNo}`,
        data
      );
      return response.data;
    } catch (error) {
      console.error(`Error updating product ${productNo}:`, error);
      throw error;
    }
  }

  /**
   * Update product inventory
   */
  async updateProductInventory(productNo: string, inventoryQty: number): Promise<any> {
    await this.ensureValidToken();

    try {
      const response = await this.axiosInstance.put(
        `/api/v2/admin/products/variants/inventories`,
        {
          product_no: productNo,
          inventory_quantity: inventoryQty
        }
      );
      return response.data;
    } catch (error) {
      console.error(`Error updating inventory for product ${productNo}:`, error);
      throw error;
    }
  }

  /**
   * Get shipment information
   */
  async getShipments(params?: Record<string, any>): Promise<any> {
    await this.ensureValidToken();

    try {
      const response = await this.axiosInstance.get(
        `/api/v2/admin/orders/shipments`,
        { params: { limit: 100, ...params } }
      );
      return response.data;
    } catch (error) {
      console.error('Error fetching shipments:', error);
      throw error;
    }
  }

  /**
   * Get current access token (for storage/debugging)
   */
  getAccessToken(): string {
    return this.accessToken;
  }

  /**
   * Get token expiry time
   */
  getTokenExpiry(): number {
    return this.tokenExpiry;
  }
}

export default Cafe24Client;
