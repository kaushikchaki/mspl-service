import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:4000/api',
});

export const getComplaints = async () => {
  const response = await api.get('/complaints');
  return response.data;
};

export const getComplaintById = async (id: string) => {
  const response = await api.get(`/complaints/${id}`);
  return response.data;
};

export const createComplaint = async (complaint: { description: string; phone: string; trackNumber: string }) => {
  await api.post('/complaints', complaint);
};