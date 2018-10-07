class Parent {
  public:
    Parent();
    virtual ~Parent();
  protected:
    int m_intVar[N];
  private:
    struct Nested {
      Nested();
      ~Nested();
      double
        m_multiLineArray[L];
    };
};
