import React, { useEffect, useState } from 'react';
import { getComplaints, createComplaint } from '../api/api';

function Complaints() {
  const [complaints, setComplaints] = useState([]);
  const [newComplaint, setNewComplaint] = useState({ description: '', phone: '', trackNumber: '' });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    fetchComplaints();
  }, []);

  const fetchComplaints = async () => {
    const data = await getComplaints();
    setComplaints(data);
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setNewComplaint({ ...newComplaint, [e.target.name]: e.target.value });
  };

  const handleSubmit = async () => {
    setLoading(true);
    await createComplaint(newComplaint);
    setNewComplaint({ description: '', phone: '', trackNumber: '' });
    fetchComplaints();
    setLoading(false);
  };

  return (
    <div>
      <h2>File a Complaint</h2>
      <div>
        <input
          name="description"
          placeholder="Description"
          value={newComplaint.description}
          onChange={handleInputChange}
        />
        <input
          name="phone"
          placeholder="Phone Number"
          value={newComplaint.phone}
          onChange={handleInputChange}
        />
        <input
          name="trackNumber"
          placeholder="Track Number"
          value={newComplaint.trackNumber}
          onChange={handleInputChange}
        />
        <button onClick={handleSubmit} disabled={loading}>Submit</button>
      </div>
      <h3>Existing Complaints</h3>
      <ul>
        {complaints.map((c: any) => (
          <li key={c.id}>
            {c.description} - Status: {c.status} - Track: {c.trackNumber}
          </li>
        ))}
      </ul>
    </div>
  );
}

export default Complaints;
