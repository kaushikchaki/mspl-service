import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { getComplaintById } from '../api/api';

function ComplaintDetails() {
  const { id } = useParams<{ id: string }>();
  const [complaint, setComplaint] = useState<any>(null);

  useEffect(() => {
    if (id) {
      fetchComplaint();
    }
  }, [id]);

  const fetchComplaint = async () => {
    const data = await getComplaintById(id!);
    setComplaint(data);
  };

  if (!complaint) return <div>Loading...</div>;

  return (
    <div>
      <h2>Complaint Details</h2>
      <p>Description: {complaint.description}</p>
      <p>Status: {complaint.status}</p>
      <p>Phone: {complaint.phone}</p>
      <p>Track Number: {complaint.trackNumber}</p>
    </div>
  );
}

export default ComplaintDetails;