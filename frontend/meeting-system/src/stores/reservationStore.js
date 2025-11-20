import { defineStore } from 'pinia'
import { ref } from 'vue'

export const useReservationStore = defineStore('reservation', () => {
  // STATE
  const rooms = ref([])
  const myReservations = ref([])
  const loading = ref(false)
  const activeTab = ref('rooms')
  const user = ref(null)
  const isAuthenticated = ref(false)

  // ACTIONS - AUTH
  const login = async (email, password) => {
    try {
      const response = await fetch('http://localhost/meeting-system/backend/api/auth.php', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          action: 'login',
          email: email,
          password: password,
        }),
        credentials: 'include', // ✅ TAMBAH INI UNTUK KONSISTEN
      })

      const result = await response.json()

      if (result.success) {
        user.value = result.user
        isAuthenticated.value = true
        return { success: true }
      } else {
        return { success: false, error: result.error }
      }
    } catch (error) {
      return { success: false, error: error.message }
    }
  }

  const checkAuth = async () => {
    try {
      const response = await fetch('http://localhost/meeting-system/backend/api/auth.php', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          action: 'check',
        }),
        credentials: 'include',
      })

      const result = await response.json()

      if (result.success) {
        user.value = result.user
        isAuthenticated.value = true
      } else {
        user.value = null
        isAuthenticated.value = false
      }
    } catch (error) {
      console.error('Auth check failed:', error)
      user.value = null
      isAuthenticated.value = false
    }
  }

  const logout = () => {
    user.value = null
    isAuthenticated.value = false
    myReservations.value = []
  }

  // ACTIONS - DATA
  const fetchRooms = async () => {
    if (!isAuthenticated.value) return

    loading.value = true
    try {
      const response = await fetch('http://localhost/meeting-system/backend/api/rooms.php', {
        credentials: 'include',
      })
      const result = await response.json()
      if (result.success) {
        rooms.value = result.data
      }
    } catch (error) {
      console.error('Error fetching rooms:', error)
    } finally {
      loading.value = false
    }
  }

  const fetchMyReservations = async () => {
    if (!isAuthenticated.value) return

    try {
      const response = await fetch('http://localhost/meeting-system/backend/api/reservations.php', {
        credentials: 'include',
      })
      const result = await response.json()
      if (result.success) {
        myReservations.value = result.data
      }
    } catch (error) {
      console.error('Error fetching reservations:', error)
    }
  }

  return {
    // STATE
    rooms,
    myReservations,
    loading,
    activeTab,
    user,
    isAuthenticated,

    // ACTIONS
    login,
    checkAuth,
    logout,
    fetchRooms,
    fetchMyReservations,
  }
})
