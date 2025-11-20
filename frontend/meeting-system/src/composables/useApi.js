import { ref } from 'vue'

export function useApi() {
  const loading = ref(false)
  const error = ref(null)

  const makeRequest = async (url, options = {}) => {
    loading.value = true
    error.value = null

    try {
      const response = await fetch(url, {
        headers: {
          'Content-Type': 'application/json',
          ...options.headers,
        },
        ...options,
      })

      const result = await response.json()
      return result
    } catch (err) {
      error.value = err.message
      return { success: false, error: err.message }
    } finally {
      loading.value = false
    }
  }

  return {
    loading,
    error,
    makeRequest,
  }
}
