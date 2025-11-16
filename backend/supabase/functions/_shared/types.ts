// Shared types for edge functions

export interface HealthData {
  id?: string;
  user_id: string;
  steps?: number;
  heart_rate?: number;
  calories?: number;
  sleep_hours?: number;
  created_at?: string;
  updated_at?: string;
}

export interface ApiResponse<T> {
  data: T | null;
  error: string | null;
}


