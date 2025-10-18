import { supabase, supabaseOperations } from '@/lib/supabase'
import { toast } from 'sonner'

export class SupabaseService {
  // Test connection
  static async testConnection() {
    try {
      const result = await supabaseOperations.testConnection();
      if (result.success) {
        toast.success('Database connection successful!');
      } else {
        toast.error(`Connection failed: ${result.message}`);
      }
      return result.success;
    } catch (error) {
      console.error('Database connection failed:', error);
      toast.error('Database connection failed');
      return false;
    }
  }

  // Sync local data to Supabase
  static async syncLocalData(localData: {
    transactions?: any[]
    clients?: any[]
    invoices?: any[]
    exchangeRates?: any[]
  }) {
    try {
      const result = await supabaseOperations.syncData({
        transactions: localData.transactions || [],
        clients: localData.clients || [],
        invoices: localData.invoices || [],
        exchangeRates: localData.exchangeRates || []
      });

      const totalSynced = result.transactions + result.clients + result.invoices + result.exchangeRates;
      
      if (result.errors.length > 0) {
        toast.error(`Partially synced: ${totalSynced} records. ${result.errors.length} errors occurred.`);
        console.warn('Sync errors:', result.errors);
      } else {
        toast.success(`Successfully synced ${totalSynced} records to database`);
      }

      return { 
        success: result.errors.length === 0, 
        synced: totalSynced, 
        errors: result.errors 
      };
    } catch (error) {
      console.error('Error syncing data:', error);
      toast.error('Failed to sync data to database');
      return { success: false, synced: 0, errors: [error instanceof Error ? error.message : 'Unknown error'] };
    }
  }

  // Sync local data to Supabase (alias for syncLocalData)
  static async syncLocalDataToSupabase(localData: {
    transactions?: any[]
    clients?: any[]
    invoices?: any[]
    exchangeRates?: any[]
  }) {
    return await this.syncLocalData(localData);
  }

  // Get data from Supabase
  static async getTransactions() {
    try {
      return await supabaseOperations.getTransactions();
    } catch (error) {
      console.error('Error fetching transactions:', error)
      toast.error('Failed to load transactions from database')
      return []
    }
  }

  static async getClients() {
    try {
      return await supabaseOperations.getClients();
    } catch (error) {
      console.error('Error fetching clients:', error)
      toast.error('Failed to load clients from database')
      return []
    }
  }

  static async getInvoices() {
    try {
      return await supabaseOperations.getInvoices();
    } catch (error) {
      console.error('Error fetching invoices:', error)
      toast.error('Failed to load invoices from database')
      return []
    }
  }

  static async getExchangeRates() {
    try {
      return await supabaseOperations.getExchangeRates();
    } catch (error) {
      console.error('Error fetching exchange rates:', error)
      toast.error('Failed to load exchange rates from database')
      return []
    }
  }
}