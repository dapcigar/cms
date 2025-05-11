import { createClient } from '@supabase/supabase-js'

// Use the exact variable names from your .env file
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY // Changed to match .env

// Create and export the Supabase client
export const supabase = createClient(supabaseUrl, supabaseKey, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true
  },
  // Recommended options for real-time functionality
  realtime: {
    params: {
      eventsPerSecond: 10
    }
  }
})
